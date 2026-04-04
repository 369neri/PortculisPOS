import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_cubit.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_state.dart';
import 'package:cashier_app/features/customers/domain/entities/customer.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  late TestDeps deps;

  setUp(() {
    deps = TestDeps();
  });

  tearDown(() => deps.dispose());

  group('Customer flow (full stack)', () {
    test('save and retrieve customer', () async {
      final id = await deps.customerRepo.save(
        const Customer(name: 'Alice', phone: '555-1234', email: 'a@b.com'),
      );
      expect(id, isPositive);

      final found = await deps.customerRepo.findById(id);
      expect(found, isNotNull);
      expect(found!.name, 'Alice');
      expect(found.phone, '555-1234');
      expect(found.email, 'a@b.com');
    });

    test('getAll returns all customers sorted by name', () async {
      await deps.customerRepo.save(const Customer(name: 'Charlie'));
      await deps.customerRepo.save(const Customer(name: 'Alice'));
      await deps.customerRepo.save(const Customer(name: 'Bob'));

      final all = await deps.customerRepo.getAll();
      expect(all.map((c) => c.name).toList(), ['Alice', 'Bob', 'Charlie']);
    });

    test('search finds by name', () async {
      await deps.customerRepo.save(const Customer(name: 'Alice'));
      await deps.customerRepo.save(const Customer(name: 'Bob'));

      final results = await deps.customerRepo.search('ali');
      expect(results.length, 1);
      expect(results.first.name, 'Alice');
    });

    test('search finds by phone', () async {
      await deps.customerRepo.save(
        const Customer(name: 'Alice', phone: '555-1234'),
      );
      final results = await deps.customerRepo.search('555');
      expect(results.length, 1);
    });

    test('search finds by email', () async {
      await deps.customerRepo.save(
        const Customer(name: 'Alice', email: 'alice@example.com'),
      );
      final results = await deps.customerRepo.search('example');
      expect(results.length, 1);
    });

    test('update modifies existing customer', () async {
      final id = await deps.customerRepo.save(
        const Customer(name: 'Alice'),
      );
      await deps.customerRepo.update(
        Customer(id: id, name: 'Alice Smith', phone: '555-0000'),
      );

      final updated = await deps.customerRepo.findById(id);
      expect(updated!.name, 'Alice Smith');
      expect(updated.phone, '555-0000');
    });

    test('delete removes customer', () async {
      final id = await deps.customerRepo.save(
        const Customer(name: 'Alice'),
      );
      await deps.customerRepo.delete(id);

      final found = await deps.customerRepo.findById(id);
      expect(found, isNull);
    });

    test('checkout with customer persists association', () async {
      // Create a customer
      final customerId = await deps.customerRepo.save(
        const Customer(name: 'Alice'),
      );

      // Build an invoice
      final coffee = TradeItem(
        sku: 'COFFEE',
        label: 'Coffee',
        unitPrice: Price.from(350),
      );
      final invoice = Invoice(
        items: [InvoiceItem(item: coffee)],
      );

      // Checkout with customer attached
      final cubit = CheckoutCubit(deps.txRepo)
        ..startCheckout(invoice)
        ..setCustomer(id: customerId, name: 'Alice')
        ..addPayment(PaymentMethod.cash, Price.from(350));
      await cubit.completeCheckout();

      final completed = cubit.state as CheckoutCompleted;
      expect(completed.transaction.customerId, customerId);
      expect(completed.transaction.status, TransactionStatus.completed);

      // Verify persisted
      final transactions = await deps.txRepo.getAll();
      expect(transactions.length, 1);
      expect(transactions.first.customerId, customerId);

      await cubit.close();
    });
  });
}
