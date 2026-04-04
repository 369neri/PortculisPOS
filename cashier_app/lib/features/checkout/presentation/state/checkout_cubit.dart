import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_state.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(this._repository) : super(const CheckoutIdle());

  final TransactionRepository _repository;

  void startCheckout(Invoice invoice, {double taxRate = 0.0}) {
    if (invoice.items.isEmpty) return;
    emit(CheckoutCollecting(invoice: invoice, taxRate: taxRate));
  }

  void setCustomer({int? id, String? name}) {
    final current = state;
    if (current is! CheckoutCollecting) return;
    emit(
      CheckoutCollecting(
        invoice: current.invoice,
        payments: current.payments,
        taxRate: current.taxRate,
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
        ),
      );
    } on Exception catch (e) {
      emit(CheckoutError(e.toString()));
    }
  }

  void reset() => emit(const CheckoutIdle());
}
