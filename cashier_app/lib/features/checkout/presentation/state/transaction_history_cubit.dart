import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/checkout/presentation/state/transaction_history_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionHistoryCubit extends Cubit<TransactionHistoryState> {
  TransactionHistoryCubit(this._repo) : super(const TransactionHistoryInitial());

  final TransactionRepository _repo;

  Future<void> load() async {
    emit(const TransactionHistoryLoading());
    try {
      final all = await _repo.getAll();
      final sorted = [...all]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(TransactionHistoryLoaded(sorted));
    } on Exception catch (e) {
      emit(TransactionHistoryError(e.toString()));
    }
  }

  Future<void> voidTransaction(int id) async {
    try {
      await _repo.voidTransaction(id);
      await load();
    } on Exception catch (e) {
      emit(TransactionHistoryError(e.toString()));
    }
  }
}
