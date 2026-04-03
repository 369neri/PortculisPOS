import 'package:cashier_app/core/persistence/app_database.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_status.dart';
import 'package:cashier_app/features/checkout/data/datasources/local_transaction_datasource.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late LocalTransactionDatasource datasource;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    datasource = LocalTransactionDatasource(db.transactionsDao);
  });

  tearDown(() async => db.close());

  final tradeItem = TradeItem(
    sku: 'SKU-001',
    label: 'Coffee',
    unitPrice: Price.from(350),
    gtin: '5901234123457',
  );

  final serviceItem = ServiceItem(
    sku: 'SVC-001',
    label: 'Delivery',
    unitPrice: Price.from(200),
  );

  final keyedItem = KeyedPriceItem(Price.from(999));

  Invoice makeInvoice({InvoiceStatus status = InvoiceStatus.active}) =>
      Invoice(
        items: [
          InvoiceItem(item: tradeItem, quantity: 2),
          InvoiceItem(item: serviceItem),
          InvoiceItem(item: keyedItem),
        ],
        status: status,
      );

  Transaction makeTx({Invoice? invoice}) => Transaction(
        invoice: invoice ?? makeInvoice(),
        payments: [
          Payment(method: PaymentMethod.cash, amount: Price.from(1000)),
          Payment(method: PaymentMethod.card, amount: Price.from(899)),
        ],
        status: TransactionStatus.completed,
        createdAt: DateTime(2024, 6, 15, 10, 30),
      );

  group('LocalTransactionDatasource', () {
    test('save returns new id and getAll retrieves it', () async {
      final id = await datasource.save(makeTx());
      expect(id, greaterThan(0));

      final all = await datasource.getAll();
      expect(all.length, 1);
      expect(all.first.id, id);
    });

    test('round-trips a transaction with trade, service and keyed items',
        () async {
      await datasource.save(makeTx());
      final loaded = (await datasource.getAll()).first;

      // Invoice items
      expect(loaded.invoice.items.length, 3);

      final first = loaded.invoice.items[0];
      expect(first.item, isA<TradeItem>());
      expect(first.item.sku, 'SKU-001');
      expect(first.item.label, 'Coffee');
      expect(first.item.unitPrice.value, BigInt.from(350));
      expect((first.item as TradeItem).gtin, '5901234123457');
      expect(first.quantity, 2);

      final second = loaded.invoice.items[1];
      expect(second.item, isA<ServiceItem>());
      expect(second.item.sku, 'SVC-001');

      final third = loaded.invoice.items[2];
      expect(third.item, isA<KeyedPriceItem>());
      expect(third.item.unitPrice.value, BigInt.from(999));
    });

    test('round-trips payments', () async {
      await datasource.save(makeTx());
      final loaded = (await datasource.getAll()).first;

      expect(loaded.payments.length, 2);
      expect(loaded.payments[0].method, PaymentMethod.cash);
      expect(loaded.payments[0].amount.value, BigInt.from(1000));
      expect(loaded.payments[1].method, PaymentMethod.card);
      expect(loaded.payments[1].amount.value, BigInt.from(899));
    });

    test('round-trips status and createdAt', () async {
      await datasource.save(makeTx());
      final loaded = (await datasource.getAll()).first;

      expect(loaded.status, TransactionStatus.completed);
      expect(loaded.createdAt, DateTime(2024, 6, 15, 10, 30));
    });

    test('findById returns the correct transaction', () async {
      final id = await datasource.save(makeTx());
      final found = await datasource.findById(id);
      expect(found, isNotNull);
      expect(found!.id, id);
    });

    test('findById returns null for missing id', () async {
      final found = await datasource.findById(999);
      expect(found, isNull);
    });

    test('voidTransaction changes status', () async {
      final id = await datasource.save(makeTx());
      await datasource.voidTransaction(id);

      final loaded = await datasource.findById(id);
      expect(loaded!.status, TransactionStatus.voided);
    });

    test('getAll returns transactions in desc createdAt order', () async {
      final earlier = Transaction(
        invoice: makeInvoice(),
        payments: [
          Payment(method: PaymentMethod.cash, amount: Price.from(100)),
        ],
        status: TransactionStatus.completed,
        createdAt: DateTime(2024),
      );
      final later = Transaction(
        invoice: makeInvoice(),
        payments: [
          Payment(method: PaymentMethod.cash, amount: Price.from(100)),
        ],
        status: TransactionStatus.completed,
        createdAt: DateTime(2024, 12, 31),
      );

      await datasource.save(earlier);
      await datasource.save(later);

      final all = await datasource.getAll();
      expect(all.length, 2);
      expect(all.first.createdAt.isAfter(all.last.createdAt), isTrue);
    });

    test('round-trips processed invoice status', () async {
      final tx = Transaction(
        invoice: makeInvoice(status: InvoiceStatus.processed),
        payments: [
          Payment(method: PaymentMethod.cash, amount: Price.from(100)),
        ],
        status: TransactionStatus.completed,
        createdAt: DateTime(2024),
      );
      await datasource.save(tx);
      final loaded = (await datasource.getAll()).first;
      expect(loaded.invoice.status, InvoiceStatus.processed);
    });
  });
}
