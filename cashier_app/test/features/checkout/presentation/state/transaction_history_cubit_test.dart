import 'package:bloc_test/bloc_test.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/checkout/presentation/state/transaction_history_cubit.dart';
import 'package:cashier_app/features/checkout/presentation/state/transaction_history_state.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Test double
// ---------------------------------------------------------------------------

class _FakeRepo implements TransactionRepository {
  bool throws = false;
  final _store = <Transaction>[];

  void seed(List<Transaction> txs) => _store.addAll(txs);

  @override
  Future<List<Transaction>> getAll() async {
    if (throws) throw Exception('db error');
    return List.unmodifiable(_store);
  }

  @override
  Future<Transaction?> findById(int id) async =>
      _store.where((t) => t.id == id).firstOrNull;

  @override
  Future<int> save(Transaction transaction) async {
    _store.add(transaction);
    return _store.length;
  }

  @override
  Future<void> voidTransaction(int id) async {
    if (throws) throw Exception('db error');
    final index = _store.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final old = _store[index];
    _store[index] = Transaction(
      id: old.id,
      invoiceNumber: old.invoiceNumber,
      invoice: old.invoice,
      payments: old.payments,
      status: TransactionStatus.voided,
      createdAt: old.createdAt,
    );
  }
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

final _item = TradeItem(
  sku: 'SKU-001',
  label: 'Coffee',
  unitPrice: Price.from(500),
);

Transaction _makeTx({
  required int id,
  required DateTime createdAt,
  TransactionStatus status = TransactionStatus.completed,
}) {
  return Transaction(
    id: id,
    invoice: Invoice(
      items: [InvoiceItem(item: _item)],
    ).process(),
    payments: [
      Payment(method: PaymentMethod.cash, amount: Price.from(500)),
    ],
    status: status,
    createdAt: createdAt,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeRepo repo;

  setUp(() => repo = _FakeRepo());

  group('TransactionHistoryCubit', () {
    test('initial state is TransactionHistoryInitial', () {
      expect(
        TransactionHistoryCubit(repo).state,
        const TransactionHistoryInitial(),
      );
    });

    blocTest<TransactionHistoryCubit, TransactionHistoryState>(
      'load() emits loading then loaded with empty list',
      build: () => TransactionHistoryCubit(repo),
      act: (c) => c.load(),
      expect: () => const [
        TransactionHistoryLoading(),
        TransactionHistoryLoaded([]),
      ],
    );

    blocTest<TransactionHistoryCubit, TransactionHistoryState>(
      'load() returns transactions sorted newest first',
      build: () {
        repo.seed([
          _makeTx(id: 1, createdAt: DateTime(2026)),
          _makeTx(id: 2, createdAt: DateTime(2026, 6)),
        ]);
        return TransactionHistoryCubit(repo);
      },
      act: (c) => c.load(),
      expect: () => [
        const TransactionHistoryLoading(),
        isA<TransactionHistoryLoaded>().having(
          (s) => s.transactions.map((t) => t.id).toList(),
          'ids',
          [2, 1],
        ),
      ],
    );

    blocTest<TransactionHistoryCubit, TransactionHistoryState>(
      'load() emits error when repo throws',
      build: () {
        repo.throws = true;
        return TransactionHistoryCubit(repo);
      },
      act: (c) => c.load(),
      expect: () => [
        const TransactionHistoryLoading(),
        isA<TransactionHistoryError>(),
      ],
    );

    blocTest<TransactionHistoryCubit, TransactionHistoryState>(
      'voidTransaction marks tx voided then reloads',
      build: () {
        repo.seed([_makeTx(id: 1, createdAt: DateTime(2026))]);
        return TransactionHistoryCubit(repo);
      },
      act: (c) => c.voidTransaction(1),
      expect: () => [
        const TransactionHistoryLoading(),
        isA<TransactionHistoryLoaded>().having(
          (s) => s.transactions.first.status,
          'status',
          TransactionStatus.voided,
        ),
      ],
    );

    blocTest<TransactionHistoryCubit, TransactionHistoryState>(
      'voidTransaction emits error when repo throws',
      build: () {
        repo.throws = true;
        return TransactionHistoryCubit(repo);
      },
      act: (c) => c.voidTransaction(1),
      expect: () => [isA<TransactionHistoryError>()],
    );
  });
}
