import 'dart:convert';
import 'dart:io';

import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/items/domain/repositories/item_repository.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
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

  @override
  Future<List<Transaction>> getAll() async => transactions;
  @override
  Future<Transaction?> findById(int id) async => null;
  @override
  Future<int> save(Transaction transaction) async => 1;
  @override
  Future<void> voidTransaction(int id) async {}
  @override
  Future<void> refundTransaction(int id) async {}
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
  isFavorite: false,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeItemRepo itemRepo;
  late _FakeTxRepo txRepo;
  late BackupService sut;

  setUp(() {
    itemRepo = _FakeItemRepo();
    txRepo = _FakeTxRepo();
    sut = BackupService(itemRepo, txRepo);
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
    test('imports items from valid JSON file', () async {
      final json = jsonEncode({
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'items': [
          sut.encodeItemForTest(_trade),
          sut.encodeItemForTest(_service),
        ],
        'transactionCount': 0,
      });

      // Write to a temp file
      final tmpDir = Directory.systemTemp.createTempSync('backup_test_');
      final file = File('${tmpDir.path}/backup.json');
      file.writeAsStringSync(json);

      final count = await sut.importBackup(file.path);
      expect(count, 2);
      expect(itemRepo.saved.length, 2);
      expect(itemRepo.saved[0], isA<TradeItem>());
      expect(itemRepo.saved[1], isA<ServiceItem>());

      // Cleanup
      tmpDir.deleteSync(recursive: true);
    });

    test('throws FormatException for unsupported version', () async {
      final json = jsonEncode({'version': 99, 'items': []});
      final tmpDir = Directory.systemTemp.createTempSync('backup_test_');
      final file = File('${tmpDir.path}/backup.json');
      file.writeAsStringSync(json);

      expect(
        () => sut.importBackup(file.path),
        throwsA(isA<FormatException>()),
      );

      tmpDir.deleteSync(recursive: true);
    });

    test('returns 0 for empty items list', () async {
      final json = jsonEncode({
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'items': [],
        'transactionCount': 0,
      });
      final tmpDir = Directory.systemTemp.createTempSync('backup_test_');
      final file = File('${tmpDir.path}/backup.json');
      file.writeAsStringSync(json);

      final count = await sut.importBackup(file.path);
      expect(count, 0);
      expect(itemRepo.saved, isEmpty);

      tmpDir.deleteSync(recursive: true);
    });
  });
}
