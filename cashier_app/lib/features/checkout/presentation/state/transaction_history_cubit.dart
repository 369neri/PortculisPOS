import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/checkout/presentation/state/transaction_history_state.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/items/domain/repositories/item_repository.dart';
import 'package:cashier_app/core/logging/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionHistoryCubit extends Cubit<TransactionHistoryState> {
  TransactionHistoryCubit(this._repo, {ItemRepository? itemRepository})
      : _itemRepo = itemRepository,
        super(const TransactionHistoryInitial());

  final TransactionRepository _repo;
  final ItemRepository? _itemRepo;

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
      }
      await load();
    } on Exception catch (e, st) {
      appLogger.e('Failed to refund transaction $id', error: e, stackTrace: st);
      emit(TransactionHistoryError('Unable to refund transaction.'));
    }
  }

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
}
