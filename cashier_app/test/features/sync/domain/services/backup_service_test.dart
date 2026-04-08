import 'dart:convert';
import 'dart:io';

import 'package:cashier_app/features/checkout/domain/entities/refund_line_item.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/customers/domain/entities/customer.dart';
import 'package:cashier_app/features/customers/domain/repositories/customer_repository.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/items/domain/repositories/item_repository.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:cashier_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:cashier_app/features/sync/domain/services/backup_service.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeItemRepo implements ItemRepository {
  List<Item> items = [];
  final List<Item> saved = [];

  @override
  Future<List<Item>> getAll() async => List.unmodifiable(items);
  @override
  Future<Item?> findBySku(String sku) async => null;
  @override
  Future<Item?> findByGtin(String gtin) async => null;
  @override
  Future<void> save(Item item) async => saved.add(item);
  @override
  Future<void> deleteById(int id) async {}
  @override
  Future<void> deleteBySku(String sku) async {}
  @override
  Future<List<Item>> getFavorites() async => [];
  @override
  Future<void> decrementStock(String sku, {int qty = 1}) async {}
  @override
  Future<void> incrementStock(String sku, {int qty = 1}) async {}
}

class _FakeTxRepo implements TransactionRepository {
  List<Transaction> transactions = [];
  final List<Transaction> saved = [];

  @override
  Future<List<Transaction>> getAll() async => transactions;
  @override
  Future<List<Transaction>> getPage(int limit, int offset) async =>
      transactions.skip(offset).take(limit).toList();
  @override
  Future<Transaction?> findById(int id) async => null;
  @override
  Future<int> save(Transaction transaction) async {
    saved.add(transaction);
    return saved.length;
  }

  @override
  Future<void> voidTransaction(int id) async {}
  @override
  Future<void> refundTransaction(int id) async {}

  @override
  Future<void> partialRefund(int id, List<RefundLineItem> items) async {}

  @override
  Future<List<RefundLineItem>> getRefunds(int transactionId) async => [];
}

class _FakeCustomerRepo implements CustomerRepository {
  List<Customer> customers = [];
  final List<Customer> saved = [];

  @override
  Future<List<Customer>> getAll() async => customers;
  @override
  Future<Customer?> findById(int id) async => null;
  @override
  Future<List<Customer>> search(String query) async => [];
  @override
  Future<int> save(Customer customer) async {
    saved.add(customer);
    return saved.length;
  }

  @override
  Future<void> update(Customer customer) async {}
  @override
  Future<void> delete(int id) async {}
}

class _FakeSettingsRepo implements SettingsRepository {
  AppSettings settings = const AppSettings();

  @override
  Future<AppSettings> getSettings() async => settings;
  @override
  Future<void> saveSettings(AppSettings s) async => settings = s;
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

final _trade = TradeItem(
  sku: 'SKU-1',
  label: 'Widget',
  unitPrice: Price.from(999),
  gtin: '1234567890128',
  category: 'Parts',
  stockQuantity: 42,
  isFavorite: true,
);

final _service = ServiceItem(
  sku: 'SVC-1',
  label: 'Repair',
  unitPrice: Price.from(2500),
  category: 'Labor',
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Write [json] to a temp file and return the path. Caller must clean up.
(String path, Directory dir) _writeTempJson(String json) {
  final tmpDir = Directory.systemTemp.createTempSync('backup_test_');
  final path = '${tmpDir.path}/backup.json';
  File(path).writeAsStringSync(json);
  return (path, tmpDir);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeItemRepo itemRepo;
  late _FakeTxRepo txRepo;
  late _FakeCustomerRepo customerRepo;
  late _FakeSettingsRepo settingsRepo;
  late BackupService sut;

  setUp(() {
    itemRepo = _FakeItemRepo();
    txRepo = _FakeTxRepo();
    customerRepo = _FakeCustomerRepo();
    settingsRepo = _FakeSettingsRepo();
    sut = BackupService(itemRepo, txRepo, customerRepo, settingsRepo);
  });

  group('BackupService encode/decode round-trip', () {
    test('TradeItem survives encode → decode', () {
      final encoded = sut.encodeItemForTest(_trade);
      final decoded = sut.decodeItemForTest(encoded);

      expect(decoded, isA<TradeItem>());
      final t = decoded! as TradeItem;
      expect(t.sku, 'SKU-1');
      expect(t.label, 'Widget');
      expect(t.unitPrice, Price.from(999));
      expect(t.gtin, '1234567890128');
      expect(t.category, 'Parts');
      expect(t.stockQuantity, 42);
      expect(t.isFavorite, true);
    });

    test('ServiceItem survives encode → decode', () {
      final encoded = sut.encodeItemForTest(_service);
      final decoded = sut.decodeItemForTest(encoded);

      expect(decoded, isA<ServiceItem>());
      final s = decoded! as ServiceItem;
      expect(s.sku, 'SVC-1');
      expect(s.label, 'Repair');
      expect(s.unitPrice, Price.from(2500));
      expect(s.category, 'Labor');
      expect(s.isFavorite, false);
    });

    test('KeyedPriceItem survives encode → decode as null (unsupported)', () {
      final keyed = KeyedPriceItem(Price.from(500));
      final encoded = sut.encodeItemForTest(keyed);
      expect(encoded['type'], 'keyed');

      // keyed items are not decoded on import
      final decoded = sut.decodeItemForTest(encoded);
      expect(decoded, isNull);
    });

    test('unknown type decodes to null', () {
      final decoded = sut.decodeItemForTest({
        'type': 'unknown',
        'unitPrice': '100',
      });
      expect(decoded, isNull);
    });
  });

  group('importBackup', () {
    test('imports items from valid v1 JSON file', () async {
      final json = jsonEncode({
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'items': [
          sut.encodeItemForTest(_trade),
          sut.encodeItemForTest(_service),
        ],
        'transactionCount': 0,
      });

      final (path, dir) = _writeTempJson(json);
      addTearDown(() => dir.deleteSync(recursive: true));

      final count = await sut.importBackup(path);
      expect(count, 2);
      expect(itemRepo.saved.length, 2);
      expect(itemRepo.saved[0], isA<TradeItem>());
      expect(itemRepo.saved[1], isA<ServiceItem>());
    });

    test('throws FormatException for unsupported version', () async {
      final json = jsonEncode({
        'version': 99,
        'items': <dynamic>[],
      });

      final (path, dir) = _writeTempJson(json);
      addTearDown(() => dir.deleteSync(recursive: true));

      expect(
        () => sut.importBackup(path),
        throwsA(isA<FormatException>()),
      );
    });

    test('returns 0 for empty items list', () async {
      final json = jsonEncode({
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'items': <dynamic>[],
        'transactionCount': 0,
      });

      final (path, dir) = _writeTempJson(json);
      addTearDown(() => dir.deleteSync(recursive: true));

      final count = await sut.importBackup(path);
      expect(count, 0);
      expect(itemRepo.saved, isEmpty);
    });
  });
}
