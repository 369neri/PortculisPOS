import 'package:cashier_app/features/checkout/domain/entities/refund_line_item.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getAll();
  Future<List<Transaction>> getPage(int limit, int offset);
  Future<Transaction?> findById(int id);
  Future<int> save(Transaction transaction);
  Future<void> voidTransaction(int id);
  Future<void> refundTransaction(int id);
  Future<void> partialRefund(int id, List<RefundLineItem> items);
  Future<List<RefundLineItem>> getRefunds(int transactionId);
}
