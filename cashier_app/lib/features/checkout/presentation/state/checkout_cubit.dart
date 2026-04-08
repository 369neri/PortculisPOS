import 'dart:async';

import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/cash_drawer/domain/entities/cash_movement.dart';
import 'package:cashier_app/features/cash_drawer/domain/repositories/cash_drawer_repository.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_state.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/items/domain/repositories/item_repository.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/sync/presentation/state/sync_cubit.dart';
import 'package:cashier_app/core/logging/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(
    this._repository, {
    ItemRepository? itemRepository,
    SyncCubit? syncCubit,
    CashDrawerRepository? cashDrawerRepository,
  })  : _itemRepository = itemRepository,
        _syncCubit = syncCubit,
        _cashDrawerRepository = cashDrawerRepository,
        super(const CheckoutIdle());

  final TransactionRepository _repository;
  final ItemRepository? _itemRepository;
  final SyncCubit? _syncCubit;
  final CashDrawerRepository? _cashDrawerRepository;

  void startCheckout(Invoice invoice,
      {double taxRate = 0.0, bool taxInclusive = false}) {
    if (invoice.items.isEmpty) return;
    emit(CheckoutCollecting(
        invoice: invoice, taxRate: taxRate, taxInclusive: taxInclusive));
  }

  void setCustomer({int? id, String? name}) {
    final current = state;
    if (current is! CheckoutCollecting) return;
    emit(
      CheckoutCollecting(
        invoice: current.invoice,
        payments: current.payments,
        taxRate: current.taxRate,
        taxInclusive: current.taxInclusive,
        customerId: id,
        customerName: name,
      ),
    );
  }

  void addPayment(PaymentMethod method, Price amount) {
    final current = state;
    if (current is! CheckoutCollecting) return;
    if (amount.value <= BigInt.zero) return;
    emit(
      CheckoutCollecting(
        invoice: current.invoice,
        payments: [...current.payments, Payment(method: method, amount: amount)],
        taxRate: current.taxRate,
        taxInclusive: current.taxInclusive,
        customerId: current.customerId,
        customerName: current.customerName,
      ),
    );
  }

  void removePayment(int index) {
    final current = state;
    if (current is! CheckoutCollecting) return;
    emit(
      CheckoutCollecting(
        invoice: current.invoice,
        payments: [...current.payments]..removeAt(index),
        taxRate: current.taxRate,
        taxInclusive: current.taxInclusive,
        customerId: current.customerId,
        customerName: current.customerName,
      ),
    );
  }

  Future<void> completeCheckout() async {
    final current = state;
    if (current is! CheckoutCollecting) return;
    if (!current.isFullyPaid) return;

    try {
      final transaction = Transaction(
        invoice: current.invoice.process(),
        payments: current.payments,
        status: TransactionStatus.completed,
        createdAt: DateTime.now(),
        customerId: current.customerId,
        customerName: current.customerName,
      );
      final id = await _repository.save(transaction);

      // Decrement stock for tracked items (best-effort; sale is already saved)
      if (_itemRepository != null) {
        for (final invoiceItem in transaction.invoice.items) {
          final item = invoiceItem.item;
          if (item is TradeItem && item.stockQuantity >= 0) {
            try {
              await _itemRepository!.decrementStock(
                item.sku,
                qty: invoiceItem.quantity,
              );
            } on Exception {
              // Stock update failed but transaction is committed — continue
            }
          }
        }
      }
      final saved = await _repository.findById(id);
      emit(
        CheckoutCompleted(
          saved ??
              Transaction(
                id: id,
                invoice: transaction.invoice,
                payments: transaction.payments,
                status: transaction.status,
                createdAt: transaction.createdAt,
              ),
          taxRate: current.taxRate,
          taxInclusive: current.taxInclusive,
        ),
      );

      // Trigger auto-backup (fire-and-forget; sale is already saved)
      unawaited(_syncCubit?.onTransactionCompleted() ?? Future<void>.value());

      // Record cash movement in the active drawer session (best-effort).
      unawaited(_recordCashSaleMovement(current.payments));
    } on Exception catch (e, st) {
      appLogger.e('Checkout failed', error: e, stackTrace: st);
      emit(CheckoutError('Unable to complete sale. Please try again.'));
    }
  }

  void reset() => emit(const CheckoutIdle());

  Future<void> _recordCashSaleMovement(List<Payment> payments) async {
    if (_cashDrawerRepository == null) return;
    final cashSubunits = payments
        .where((p) => p.method == PaymentMethod.cash)
        .fold<int>(0, (sum, p) => sum + p.amount.subunits);
    if (cashSubunits <= 0) return;
    try {
      final session = await _cashDrawerRepository!.getActiveSession();
      if (session?.id == null) return;
      await _cashDrawerRepository!.addMovement(CashMovement(
        sessionId: session!.id!,
        type: CashMovementType.sale,
        amountSubunits: cashSubunits,
        note: '',
        createdAt: DateTime.now(),
      ));
    } on Exception catch (e, st) {
      appLogger.e('Failed to record cash sale movement',
          error: e, stackTrace: st);
    }
  }
}
