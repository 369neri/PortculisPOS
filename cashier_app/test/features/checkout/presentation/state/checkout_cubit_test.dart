import 'package:bloc_test/bloc_test.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_cubit.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_state.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Test double
// ---------------------------------------------------------------------------

class _FakeRepo implements TransactionRepository {
  int nextId = 1;
  bool throws = false;
  final saved = <Transaction>[];

  @override
  Future<List<Transaction>> getAll() async => saved;

  @override
  Future<Transaction?> findById(int id) async =>
      saved.where((t) => t.id == id).firstOrNull;

  @override
  Future<int> save(Transaction transaction) async {
    if (throws) throw Exception('db error');
    final id = nextId++;
    saved.add(
      Transaction(
        id: id,
        invoice: transaction.invoice,
        payments: transaction.payments,
        status: transaction.status,
        createdAt: transaction.createdAt,
      ),
    );
    return id;
  }

  @override
  Future<void> voidTransaction(int id) async {
    if (throws) throw Exception('db error');
  }

  @override
  Future<void> refundTransaction(int id) async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _item = TradeItem(
  sku: 'SKU-001',
  label: 'Coffee',
  unitPrice: Price.from(500),
);

final _invoice = Invoice(
  items: [InvoiceItem(item: _item, quantity: 2)],
);

// total = 500 * 2 = 1000

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeRepo repo;

  setUp(() => repo = _FakeRepo());

  group('CheckoutCubit', () {
    test('initial state is idle', () {
      expect(CheckoutCubit(repo).state, const CheckoutIdle());
    });

    blocTest<CheckoutCubit, CheckoutState>(
      'startCheckout emits collecting with empty payments',
      build: () => CheckoutCubit(repo),
      act: (c) => c.startCheckout(_invoice),
      expect: () => [
        isA<CheckoutCollecting>()
            .having((s) => s.invoice, 'invoice', _invoice)
            .having((s) => s.payments, 'payments', isEmpty),
      ],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'startCheckout preserves taxRate in state',
      build: () => CheckoutCubit(repo),
      act: (c) => c.startCheckout(_invoice, taxRate: 8.5),
      expect: () => [
        isA<CheckoutCollecting>()
            .having((s) => s.taxRate, 'taxRate', 8.5),
      ],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'startCheckout with empty invoice emits nothing',
      build: () => CheckoutCubit(repo),
      act: (c) => c.startCheckout(const Invoice()),
      expect: () => <CheckoutState>[],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'addPayment appends payment and preserves taxRate',
      build: () => CheckoutCubit(repo),
      seed: () => CheckoutCollecting(invoice: _invoice, taxRate: 5),
      act: (c) => c.addPayment(PaymentMethod.cash, Price.from(500)),
      expect: () => [
        isA<CheckoutCollecting>()
            .having((s) => s.payments.length, 'payments.length', 1)
            .having((s) => s.taxRate, 'taxRate', 5)
            .having(
              (s) => s.payments.first.method,
              'method',
              PaymentMethod.cash,
            )
            .having(
              (s) => s.payments.first.amount.value,
              'amount',
              BigInt.from(500),
            ),
      ],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'addPayment with zero amount is ignored',
      build: () => CheckoutCubit(repo),
      seed: () => CheckoutCollecting(invoice: _invoice),
      act: (c) => c.addPayment(PaymentMethod.cash, Price.from(0)),
      expect: () => <CheckoutState>[],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'addPayment when idle is ignored',
      build: () => CheckoutCubit(repo),
      act: (c) => c.addPayment(PaymentMethod.cash, Price.from(500)),
      expect: () => <CheckoutState>[],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'removePayment removes at index and preserves taxRate',
      build: () => CheckoutCubit(repo),
      seed: () => CheckoutCollecting(
        invoice: _invoice,
        taxRate: 5,
        payments: [
          Payment(method: PaymentMethod.cash, amount: Price.from(300)),
          Payment(method: PaymentMethod.card, amount: Price.from(200)),
        ],
      ),
      act: (c) => c.removePayment(0),
      expect: () => [
        isA<CheckoutCollecting>()
            .having((s) => s.payments.length, 'len', 1)
            .having((s) => s.taxRate, 'taxRate', 5)
            .having(
              (s) => s.payments.first.method,
              'method',
              PaymentMethod.card,
            ),
      ],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'completeCheckout when fully paid emits completed with taxRate',
      build: () => CheckoutCubit(repo),
      seed: () => CheckoutCollecting(
        invoice: _invoice,
        taxRate: 8,
        payments: [
          // 1000 subtotal + 8% tax = 1080 → must pay at least 1080
          Payment(method: PaymentMethod.cash, amount: Price.from(1080)),
        ],
      ),
      act: (c) => c.completeCheckout(),
      expect: () => [
        isA<CheckoutCompleted>()
            .having((s) => s.transaction.id, 'id', 1)
            .having(
              (s) => s.transaction.status,
              'status',
              TransactionStatus.completed,
            )
            .having((s) => s.taxRate, 'taxRate', 8),
      ],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'completeCheckout when not fully paid emits nothing',
      build: () => CheckoutCubit(repo),
      seed: () => CheckoutCollecting(
        invoice: _invoice,
        payments: [
          Payment(method: PaymentMethod.cash, amount: Price.from(500)),
        ],
      ),
      act: (c) => c.completeCheckout(),
      expect: () => <CheckoutState>[],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'completeCheckout on db error emits error state',
      build: () {
        repo.throws = true;
        return CheckoutCubit(repo);
      },
      seed: () => CheckoutCollecting(
        invoice: _invoice,
        payments: [
          Payment(method: PaymentMethod.cash, amount: Price.from(1000)),
        ],
      ),
      act: (c) => c.completeCheckout(),
      expect: () => [isA<CheckoutError>()],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'reset returns to idle',
      build: () => CheckoutCubit(repo),
      seed: () => CheckoutCollecting(invoice: _invoice),
      act: (c) => c.reset(),
      expect: () => [const CheckoutIdle()],
    );

    group('CheckoutCollecting computed properties', () {
      test('totalDue includes tax when taxRate > 0', () {
        // 1000 subunits + 10% = 1100
        final state = CheckoutCollecting(
          invoice: _invoice,
          taxRate: 10,
        );
        expect(state.totalDue.value, BigInt.from(1100));
      });

      test('remaining returns outstanding amount', () {
        final state = CheckoutCollecting(
          invoice: _invoice,
          payments: [
            Payment(method: PaymentMethod.cash, amount: Price.from(400)),
          ],
        );
        // total 1000, paid 400 → remaining 600
        expect(state.remaining.value, BigInt.from(600));
      });

      test('changeDue returns overpayment', () {
        final state = CheckoutCollecting(
          invoice: _invoice,
          payments: [
            Payment(method: PaymentMethod.cash, amount: Price.from(1500)),
          ],
        );
        expect(state.changeDue.value, BigInt.from(500));
      });

      test('isFullyPaid is true when paid enough', () {
        final state = CheckoutCollecting(
          invoice: _invoice,
          payments: [
            Payment(method: PaymentMethod.cash, amount: Price.from(1000)),
          ],
        );
        expect(state.isFullyPaid, isTrue);
      });
    });
  });
}
