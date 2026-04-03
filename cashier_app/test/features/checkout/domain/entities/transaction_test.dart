import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:test/test.dart';

void main() {
  final item = TradeItem(
    sku: 'SKU-001',
    label: 'Coffee',
    unitPrice: Price.from(350),
  );

  final invoice = Invoice(
    items: [InvoiceItem(item: item, quantity: 2)],
  );

  group('Transaction', () {
    test('totalPaid sums all payment amounts', () {
      final tx = Transaction(
        invoice: invoice,
        payments: [
          Payment(method: PaymentMethod.cash, amount: Price.from(300)),
          Payment(method: PaymentMethod.card, amount: Price.from(200)),
        ],
        status: TransactionStatus.completed,
        createdAt: DateTime(2024),
      );

      expect(tx.totalPaid.value, BigInt.from(500));
    });

    test('changeDue returns overpayment', () {
      // invoice total = 350 * 2 = 700
      final tx = Transaction(
        invoice: invoice,
        payments: [
          Payment(method: PaymentMethod.cash, amount: Price.from(1000)),
        ],
        status: TransactionStatus.completed,
        createdAt: DateTime(2024),
      );

      expect(tx.changeDue.value, BigInt.from(300));
    });

    test('changeDue returns zero when underpaid', () {
      final tx = Transaction(
        invoice: invoice,
        payments: [
          Payment(method: PaymentMethod.cash, amount: Price.from(100)),
        ],
        status: TransactionStatus.completed,
        createdAt: DateTime(2024),
      );

      expect(tx.changeDue.value, BigInt.zero);
    });

    test('isFullyPaid is true when totalPaid >= total', () {
      final tx = Transaction(
        invoice: invoice,
        payments: [
          Payment(method: PaymentMethod.cash, amount: Price.from(700)),
        ],
        status: TransactionStatus.completed,
        createdAt: DateTime(2024),
      );

      expect(tx.isFullyPaid, isTrue);
    });

    test('isFullyPaid is false when totalPaid < total', () {
      final tx = Transaction(
        invoice: invoice,
        payments: [
          Payment(method: PaymentMethod.cash, amount: Price.from(500)),
        ],
        status: TransactionStatus.completed,
        createdAt: DateTime(2024),
      );

      expect(tx.isFullyPaid, isFalse);
    });

    test('props include all fields for equality', () {
      final now = DateTime(2024);
      final tx1 = Transaction(
        invoice: invoice,
        payments: [
          Payment(method: PaymentMethod.cash, amount: Price.from(700)),
        ],
        status: TransactionStatus.completed,
        createdAt: now,
      );

      final tx2 = Transaction(
        invoice: invoice,
        payments: [
          Payment(method: PaymentMethod.cash, amount: Price.from(700)),
        ],
        status: TransactionStatus.completed,
        createdAt: now,
      );

      expect(tx1, equals(tx2));
    });
  });
}
