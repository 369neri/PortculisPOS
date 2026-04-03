import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:equatable/equatable.dart';

sealed class TransactionHistoryState extends Equatable {
  const TransactionHistoryState();
}

final class TransactionHistoryInitial extends TransactionHistoryState {
  const TransactionHistoryInitial();
  @override
  List<Object?> get props => [];
}

final class TransactionHistoryLoading extends TransactionHistoryState {
  const TransactionHistoryLoading();
  @override
  List<Object?> get props => [];
}

final class TransactionHistoryLoaded extends TransactionHistoryState {
  const TransactionHistoryLoaded(this.transactions);

  final List<Transaction> transactions;

  @override
  List<Object?> get props => [transactions];
}

final class TransactionHistoryError extends TransactionHistoryState {
  const TransactionHistoryError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
