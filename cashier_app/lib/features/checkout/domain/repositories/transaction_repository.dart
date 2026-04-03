import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getAll();
  Future<Transaction?> findById(int id);
  Future<int> save(Transaction transaction);
  Future<void> voidTransaction(int id);
}
