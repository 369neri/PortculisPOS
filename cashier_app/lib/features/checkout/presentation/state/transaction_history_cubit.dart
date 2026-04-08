import 'package:cashier_app/features/cash_drawer/domain/entities/cash_movement.dart';
import 'package:cashier_app/features/cash_drawer/domain/repositories/cash_drawer_repository.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/refund_line_item.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/checkout/presentation/state/transaction_history_state.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/items/domain/repositories/item_repository.dart';
import 'package:cashier_app/core/logging/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionHistoryCubit extends Cubit<TransactionHistoryState> {
  TransactionHistoryCubit(
    this._repo, {
    ItemRepository? itemRepository,
    CashDrawerRepository? cashDrawerRepository,
  })  : _itemRepo = itemRepository,
        _cashDrawerRepo = cashDrawerRepository,
        super(const TransactionHistoryInitial());

  final TransactionRepository _repo;
  final ItemRepository? _itemRepo;
  final CashDrawerRepository? _cashDrawerRepo;

  static const _pageSize = 30;

  Future<void> load() async {
    emit(const TransactionHistoryLoading());
    try {
      final page = await _repo.getPage(_pageSize, 0);
      emit(TransactionHistoryLoaded(page, hasMore: page.length == _pageSize));
    } on Exception catch (e, st) {
      appLogger.e('Failed to load transactions', error: e, stackTrace: st);
      emit(TransactionHistoryError('Unable to load transactions.'));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! TransactionHistoryLoaded || !current.hasMore) return;
    try {
      final page = await _repo.getPage(_pageSize, current.transactions.length);
      final all = [...current.transactions, ...page];
      emit(TransactionHistoryLoaded(all, hasMore: page.length == _pageSize));
    } on Exception catch (e, st) {
      appLogger.e('Failed to load more transactions', error: e, stackTrace: st);
      // Keep existing data visible — don't wipe the list.
    }
  }

  Future<void> voidTransaction(int id) async {
    try {
      final tx = await _repo.findById(id);
      if (tx != null && tx.status == TransactionStatus.completed) {
        await _repo.voidTransaction(id);
        await _restoreStock(tx);
        await _recordCashMovement(tx, CashMovementType.voidTx);
      }
      await load();
    } on Exception catch (e, st) {
      appLogger.e('Failed to void transaction $id', error: e, stackTrace: st);
      emit(TransactionHistoryError('Unable to void transaction.'));
    }
  }

  Future<void> refundTransaction(int id) async {
    try {
      final tx = await _repo.findById(id);
      if (tx != null && tx.status == TransactionStatus.completed) {
        await _repo.refundTransaction(id);
        await _restoreStock(tx);
        await _recordCashMovement(tx, CashMovementType.refund);
      }
      await load();
    } on Exception catch (e, st) {
      appLogger.e('Failed to refund transaction $id', error: e, stackTrace: st);
      emit(TransactionHistoryError('Unable to refund transaction.'));
    }
  }

  Future<void> partialRefund(int id, List<RefundLineItem> items) async {
    try {
      final tx = await _repo.findById(id);
      if (tx == null || tx.status != TransactionStatus.completed) return;
      await _repo.partialRefund(id, items);
      // Restore stock only for the refunded quantities.
      if (_itemRepo != null) {
        for (final refundItem in items) {
          if (refundItem.lineIndex < tx.invoice.items.length) {
            final invoiceItem = tx.invoice.items[refundItem.lineIndex];
            final item = invoiceItem.item;
            if (item is TradeItem && item.stockQuantity >= 0) {
              await _itemRepo!.incrementStock(
                item.sku,
                qty: refundItem.quantity,
              );
            }
          }
        }
      }
      // Record refund as negative cash movement (best-effort).
      final refundSubunits =
          items.fold<int>(0, (sum, r) => sum + r.amountSubunits);
      if (refundSubunits > 0 && _hasCashPayment(tx)) {
        await _recordCashMovementRaw(
          CashMovementType.refund,
          -refundSubunits,
          note: 'Partial refund #$id',
        );
      }
      await load();
    } on Exception catch (e, st) {
      appLogger.e('Failed to partial-refund transaction $id',
          error: e, stackTrace: st);
      emit(TransactionHistoryError('Unable to process refund.'));
    }
  }

  Future<List<RefundLineItem>> getRefunds(int transactionId) =>
      _repo.getRefunds(transactionId);

  /// Restores stock for tracked items when a transaction is voided/refunded.
  Future<void> _restoreStock(Transaction transaction) async {
    if (_itemRepo == null) return;
    for (final invoiceItem in transaction.invoice.items) {
      final item = invoiceItem.item;
      if (item is TradeItem && item.stockQuantity >= 0) {
        await _itemRepo!.incrementStock(
          item.sku,
          qty: invoiceItem.quantity,
        );
      }
    }
  }

  bool _hasCashPayment(Transaction tx) =>
      tx.payments.any((p) => p.method == PaymentMethod.cash);

  /// Record a cash movement equal to the cash portion of a full transaction.
  Future<void> _recordCashMovement(
    Transaction tx,
    CashMovementType type,
  ) async {
    if (!_hasCashPayment(tx)) return;
    final cashSubunits = tx.payments
        .where((p) => p.method == PaymentMethod.cash)
        .fold<int>(0, (sum, p) => sum + p.amount.subunits);
    await _recordCashMovementRaw(type, -cashSubunits,
        note: '${type.name} #${tx.id}');
  }

  Future<void> _recordCashMovementRaw(
    CashMovementType type,
    int amountSubunits, {
    String note = '',
  }) async {
    if (_cashDrawerRepo == null) return;
    try {
      final session = await _cashDrawerRepo!.getActiveSession();
      if (session?.id == null) return;
      await _cashDrawerRepo!.addMovement(CashMovement(
        sessionId: session!.id!,
        type: type,
        amountSubunits: amountSubunits,
        note: note,
        createdAt: DateTime.now(),
      ));
    } on Exception catch (e, st) {
      appLogger.e('Failed to record cash movement',
          error: e, stackTrace: st);
    }
  }
}
