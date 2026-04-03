import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Items table
// ---------------------------------------------------------------------------

class ItemsTable extends Table {
  @override
  String get tableName => 'items';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get sku => text().unique()();
  TextColumn get label => text()();
  IntColumn get unitPriceSubunits => integer()();
  TextColumn get type => text()();
  TextColumn get gtin => text().nullable()();
}

// ---------------------------------------------------------------------------
// Transactions table
// ---------------------------------------------------------------------------

class TransactionsTable extends Table {
  @override
  String get tableName => 'transactions';

  IntColumn get id => integer().autoIncrement()();

  /// Human-readable invoice number, e.g. INV-00001. Nullable for legacy rows.
  TextColumn get invoiceNumber => text().nullable()();

  /// JSON-encoded invoice snapshot.
  TextColumn get invoiceJson => text()();

  /// 'completed' | 'voided'
  TextColumn get status => text()();

  DateTimeColumn get createdAt => dateTime()();
}

// ---------------------------------------------------------------------------
// Payments table
// ---------------------------------------------------------------------------

class PaymentsTable extends Table {
  @override
  String get tableName => 'payments';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId =>
      integer().references(TransactionsTable, #id)();
  TextColumn get method => text()();
  IntColumn get amountSubunits => integer()();
}

// ---------------------------------------------------------------------------
// Settings table (singleton row, id = 1)
// ---------------------------------------------------------------------------

class SettingsTable extends Table {
  @override
  String get tableName => 'settings';

  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get businessName =>
      text().withDefault(const Constant('My Business'))();
  RealColumn get taxRate =>
      real().withDefault(const Constant<double>(0))();
  TextColumn get currencySymbol =>
      text().withDefault(const Constant(r'$'))();
  TextColumn get receiptFooter =>
      text().withDefault(const Constant('Thank you for your business!'))();
  TextColumn get lastZReportAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Items DAO
// ---------------------------------------------------------------------------

@DriftAccessor(tables: [ItemsTable])
class ItemsDao extends DatabaseAccessor<AppDatabase> with _$ItemsDaoMixin {
  ItemsDao(super.db);

  Future<List<ItemsTableData>> getAllItems() => select(itemsTable).get();

  Stream<List<ItemsTableData>> watchAllItems() =>
      select(itemsTable).watch();

  Future<ItemsTableData?> findBySku(String sku) =>
      (select(itemsTable)..where((t) => t.sku.equals(sku)))
          .getSingleOrNull();

  Future<int> upsertItem(ItemsTableCompanion companion) =>
      into(itemsTable).insert(
        companion,
        onConflict: DoUpdate((_) => companion, target: [itemsTable.sku]),
      );

  Future<int> deleteItem(int id) =>
      (delete(itemsTable)..where((t) => t.id.equals(id))).go();
}

// ---------------------------------------------------------------------------
// Transactions DAO
// ---------------------------------------------------------------------------

@DriftAccessor(tables: [TransactionsTable, PaymentsTable])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Future<List<TransactionsTableData>> getAllTransactions() =>
      (select(transactionsTable)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<TransactionsTableData?> findById(int id) =>
      (select(transactionsTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<List<PaymentsTableData>> paymentsForTransaction(int txId) =>
      (select(paymentsTable)..where((p) => p.transactionId.equals(txId)))
          .get();

  /// Returns the next invoice number in the format INV-XXXXX.
  Future<String> nextInvoiceNumber() async {
    final count = await (selectOnly(transactionsTable)
          ..addColumns([transactionsTable.id.count()]))
        .map((r) => r.read(transactionsTable.id.count()) ?? 0)
        .getSingle();
    return 'INV-${(count + 1).toString().padLeft(5, '0')}';
  }

  Future<int> insertTransaction(
    TransactionsTableCompanion tx,
    List<PaymentsTableCompanion> payments,
  ) {
    return transaction(() async {
      final txId = await into(transactionsTable).insert(tx);
      for (final pay in payments) {
        await into(paymentsTable).insert(
          pay.copyWith(transactionId: Value(txId)),
        );
      }
      return txId;
    });
  }

  Future<void> updateStatus(int id, String status) =>
      (update(transactionsTable)..where((t) => t.id.equals(id)))
          .write(TransactionsTableCompanion(status: Value(status)));
}

// ---------------------------------------------------------------------------
// Settings DAO
// ---------------------------------------------------------------------------

@DriftAccessor(tables: [SettingsTable])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<SettingsTableData> getOrCreate() async {
    final existing =
        await (select(settingsTable)..where((t) => t.id.equals(1)))
            .getSingleOrNull();
    if (existing != null) return existing;
    await into(settingsTable).insert(const SettingsTableCompanion());
    return (select(settingsTable)..where((t) => t.id.equals(1))).getSingle();
  }

  Future<void> save(SettingsTableCompanion companion) =>
      into(settingsTable).insertOnConflictUpdate(companion);
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [ItemsTable, TransactionsTable, PaymentsTable, SettingsTable],
  daos: [ItemsDao, TransactionsDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await _seedItems();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(transactionsTable);
          await m.createTable(paymentsTable);
        }
        if (from < 3) {
          await m.addColumn(
            transactionsTable,
            transactionsTable.invoiceNumber,
          );
        }
        if (from < 4) {
          await m.createTable(settingsTable);
        }
        if (from < 5) {
          await m.addColumn(settingsTable, settingsTable.lastZReportAt);
        }
      },
    );
  }

  Future<void> _seedItems() async {
    final seeds = [
      ItemsTableCompanion.insert(
        sku: 'SKU-001',
        label: 'Coffee',
        unitPriceSubunits: 350,
        type: 'trade',
        gtin: const Value(null),
      ),
      ItemsTableCompanion.insert(
        sku: 'SKU-002',
        label: 'Tea',
        unitPriceSubunits: 250,
        type: 'trade',
        gtin: const Value(null),
      ),
      ItemsTableCompanion.insert(
        sku: 'SKU-003',
        label: 'Sandwich',
        unitPriceSubunits: 650,
        type: 'trade',
        gtin: const Value(null),
      ),
      ItemsTableCompanion.insert(
        sku: 'SVC-001',
        label: 'Delivery',
        unitPriceSubunits: 200,
        type: 'service',
        gtin: const Value(null),
      ),
    ];
    for (final s in seeds) {
      await into(itemsTable).insertOnConflictUpdate(s);
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (!kIsWeb) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'portculis.db'));
    return NativeDatabase.createInBackground(file);
  });
}
