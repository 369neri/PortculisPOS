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
  TextColumn get category => text().withDefault(const Constant(''))();
  IntColumn get stockQuantity =>
      integer().withDefault(const Constant(-1))(); // -1 = untracked
  BoolColumn get isFavorite =>
      boolean().withDefault(const Constant(false))();
  TextColumn get imagePath => text().nullable()();
  RealColumn get itemTaxRate => real().nullable()();
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

  /// 'completed' | 'voided' | 'refunded'
  TextColumn get status => text()();

  DateTimeColumn get createdAt => dateTime()();

  /// Optional customer association.
  IntColumn get customerId =>
      integer().nullable().references(CustomersTable, #id)();
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
  TextColumn get themeMode =>
      text().withDefault(const Constant('system'))();
  TextColumn get logoPath => text().nullable()();
  BoolColumn get autoBackupEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get lastBackupAt => text().nullable()();
  TextColumn get printerType =>
      text().withDefault(const Constant('none'))();
  TextColumn get printerAddress =>
      text().withDefault(const Constant(''))();
  BoolColumn get taxInclusive =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Cash drawer sessions table
// ---------------------------------------------------------------------------

class CashDrawerSessionsTable extends Table {
  @override
  String get tableName => 'cash_drawer_sessions';

  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get openedAt => dateTime()();
  DateTimeColumn get closedAt => dateTime().nullable()();
  IntColumn get openingBalanceSubunits => integer()();
  IntColumn get closingBalanceSubunits => integer().nullable()();
  TextColumn get notes => text().nullable()();
}

// ---------------------------------------------------------------------------
// Customers table
// ---------------------------------------------------------------------------

class CustomersTable extends Table {
  @override
  String get tableName => 'customers';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
}

// ---------------------------------------------------------------------------
// Refunds table
// ---------------------------------------------------------------------------

class RefundsTable extends Table {
  @override
  String get tableName => 'refunds';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get originalTransactionId =>
      integer().references(TransactionsTable, #id)();
  IntColumn get lineIndex => integer()();
  IntColumn get quantity => integer()();
  IntColumn get amountSubunits => integer()();
  TextColumn get reason => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
}

// ---------------------------------------------------------------------------
// Cash Movements Table
// ---------------------------------------------------------------------------

class CashMovementsTable extends Table {
  @override
  String get tableName => 'cash_movements';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(CashDrawerSessionsTable, #id)();
  TextColumn get type => text()(); // sale, refund, voidTx, adjustment
  IntColumn get amountSubunits => integer()();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
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

  Future<ItemsTableData?> findByGtin(String gtin) =>
      (select(itemsTable)..where((t) => t.gtin.equals(gtin)))
          .getSingleOrNull();

  Future<int> upsertItem(ItemsTableCompanion companion) =>
      into(itemsTable).insert(
        companion,
        onConflict: DoUpdate((_) => companion, target: [itemsTable.sku]),
      );

  Future<int> deleteItem(int id) =>
      (delete(itemsTable)..where((t) => t.id.equals(id))).go();

  /// Returns all items marked as favorites.
  Future<List<ItemsTableData>> getFavorites() =>
      (select(itemsTable)..where((t) => t.isFavorite.equals(true))).get();

  /// Decrements stock by [qty]. No-op if item is untracked (stockQuantity == -1).
  Future<void> decrementStock(String sku, int qty) async {
    final row = await findBySku(sku);
    if (row == null || row.stockQuantity < 0) return;
    final newQty = (row.stockQuantity - qty).clamp(0, 999999);
    await (update(itemsTable)..where((t) => t.sku.equals(sku)))
        .write(ItemsTableCompanion(stockQuantity: Value(newQty)));
  }

  /// Increments stock by [qty] (for refunds). No-op if untracked.
  Future<void> incrementStock(String sku, int qty) async {
    final row = await findBySku(sku);
    if (row == null || row.stockQuantity < 0) return;
    final newQty = row.stockQuantity + qty;
    await (update(itemsTable)..where((t) => t.sku.equals(sku)))
        .write(ItemsTableCompanion(stockQuantity: Value(newQty)));
  }
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

  Future<List<TransactionsTableData>> getTransactionPage(
    int limit,
    int offset,
  ) =>
      (select(transactionsTable)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit, offset: offset))
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
// Cash drawer DAO
// ---------------------------------------------------------------------------

@DriftAccessor(tables: [CashDrawerSessionsTable])
class CashDrawerDao extends DatabaseAccessor<AppDatabase>
    with _$CashDrawerDaoMixin {
  CashDrawerDao(super.db);

  Future<int> openSession(int openingBalanceSubunits) =>
      into(cashDrawerSessionsTable).insert(
        CashDrawerSessionsTableCompanion.insert(
          openedAt: DateTime.now(),
          openingBalanceSubunits: openingBalanceSubunits,
        ),
      );

  Future<void> closeSession(
    int id,
    int closingBalanceSubunits, {
    String? notes,
  }) =>
      (update(cashDrawerSessionsTable)..where((t) => t.id.equals(id))).write(
        CashDrawerSessionsTableCompanion(
          closedAt: Value(DateTime.now()),
          closingBalanceSubunits: Value(closingBalanceSubunits),
          notes: Value(notes),
        ),
      );

  Future<CashDrawerSessionsTableData?> getActiveSession() =>
      (select(cashDrawerSessionsTable)
            ..where((t) => t.closedAt.isNull())
            ..limit(1))
          .getSingleOrNull();

  Future<List<CashDrawerSessionsTableData>> getAllSessions() =>
      (select(cashDrawerSessionsTable)
            ..orderBy([(t) => OrderingTerm.desc(t.openedAt)]))
          .get();
}

// ---------------------------------------------------------------------------
// Customers DAO
// ---------------------------------------------------------------------------

@DriftAccessor(tables: [CustomersTable])
class CustomersDao extends DatabaseAccessor<AppDatabase>
    with _$CustomersDaoMixin {
  CustomersDao(super.db);

  Future<List<CustomersTableData>> getAll() =>
      (select(customersTable)..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();

  Future<CustomersTableData?> findById(int id) =>
      (select(customersTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<List<CustomersTableData>> search(String query) =>
      (select(customersTable)
            ..where(
              (t) =>
                  t.name.like('%$query%') |
                  t.phone.like('%$query%') |
                  t.email.like('%$query%'),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();

  Future<int> insertCustomer(CustomersTableCompanion companion) =>
      into(customersTable).insert(companion);

  Future<void> updateCustomer(CustomersTableCompanion companion) =>
      (update(customersTable)
            ..where((t) => t.id.equals(companion.id.value)))
          .write(companion);

  Future<int> deleteCustomer(int id) =>
      (delete(customersTable)..where((t) => t.id.equals(id))).go();
}

// ---------------------------------------------------------------------------
// Users table (auth)
// ---------------------------------------------------------------------------

class UsersTable extends Table {
  @override
  String get tableName => 'users';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().unique()();
  TextColumn get displayName => text()();
  TextColumn get pin => text()(); // hashed PIN
  TextColumn get salt => text().withDefault(const Constant(''))();
  TextColumn get role => text().withDefault(const Constant('cashier'))(); // admin | manager | cashier
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get failedAttempts =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get lockedUntil => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

// ---------------------------------------------------------------------------
// Users DAO
// ---------------------------------------------------------------------------

@DriftAccessor(tables: [UsersTable])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);

  Future<List<UsersTableData>> getAll() =>
      (select(usersTable)..orderBy([(t) => OrderingTerm.asc(t.displayName)]))
          .get();

  Future<UsersTableData?> findByUsername(String username) =>
      (select(usersTable)..where((t) => t.username.equals(username)))
          .getSingleOrNull();

  Future<int> insertUser(UsersTableCompanion companion) =>
      into(usersTable).insert(companion);

  Future<void> updateUser(UsersTableCompanion companion) =>
      (update(usersTable)..where((t) => t.id.equals(companion.id.value)))
          .write(companion);

  Future<int> deleteUser(int id) =>
      (delete(usersTable)..where((t) => t.id.equals(id))).go();

  Future<void> incrementFailedAttempts(int id, {DateTime? lockUntil}) async {
    final row = await (select(usersTable)..where((t) => t.id.equals(id)))
        .getSingle();
    await (update(usersTable)..where((t) => t.id.equals(id))).write(
      UsersTableCompanion(
        failedAttempts: Value(row.failedAttempts + 1),
        lockedUntil: Value(lockUntil),
      ),
    );
  }

  Future<void> resetFailedAttempts(int id) =>
      (update(usersTable)..where((t) => t.id.equals(id))).write(
        const UsersTableCompanion(
          failedAttempts: Value(0),
          lockedUntil: Value(null),
        ),
      );
}

// ---------------------------------------------------------------------------
// Refunds DAO
// ---------------------------------------------------------------------------

@DriftAccessor(tables: [RefundsTable])
class RefundsDao extends DatabaseAccessor<AppDatabase> with _$RefundsDaoMixin {
  RefundsDao(super.db);

  Future<List<RefundsTableData>> forTransaction(int txId) =>
      (select(refundsTable)
            ..where((t) => t.originalTransactionId.equals(txId)))
          .get();

  Future<void> insertAll(List<RefundsTableCompanion> items) async {
    for (final item in items) {
      await into(refundsTable).insert(item);
    }
  }
}

// ---------------------------------------------------------------------------
// Cash Movements DAO
// ---------------------------------------------------------------------------

@DriftAccessor(tables: [CashMovementsTable])
class CashMovementsDao extends DatabaseAccessor<AppDatabase>
    with _$CashMovementsDaoMixin {
  CashMovementsDao(super.db);

  Future<void> insert(CashMovementsTableCompanion entry) =>
      into(cashMovementsTable).insert(entry);

  Future<List<CashMovementsTableData>> forSession(int sessionId) =>
      (select(cashMovementsTable)
            ..where((t) => t.sessionId.equals(sessionId)))
          .get();
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [
    ItemsTable,
    TransactionsTable,
    PaymentsTable,
    SettingsTable,
    CashDrawerSessionsTable,
    CustomersTable,
    UsersTable,
    RefundsTable,
    CashMovementsTable,
  ],
  daos: [
    ItemsDao,
    TransactionsDao,
    SettingsDao,
    CashDrawerDao,
    CustomersDao,
    UsersDao,
    RefundsDao,
    CashMovementsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 17;

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
        if (from < 6) {
          await m.createTable(cashDrawerSessionsTable);
        }
        if (from < 7) {
          await m.addColumn(settingsTable, settingsTable.themeMode);
        }
        if (from < 8) {
          await m.createTable(customersTable);
          await m.addColumn(
            transactionsTable,
            transactionsTable.customerId,
          );
        }
        if (from < 9) {
          await m.addColumn(itemsTable, itemsTable.category);
          await m.addColumn(itemsTable, itemsTable.stockQuantity);
          await m.addColumn(itemsTable, itemsTable.isFavorite);
          await m.createTable(usersTable);
        }
        if (from < 10) {
          await m.addColumn(itemsTable, itemsTable.imagePath);
        }
        if (from < 11) {
          await m.addColumn(settingsTable, settingsTable.logoPath);
          await m.addColumn(
            settingsTable,
            settingsTable.autoBackupEnabled,
          );
          await m.addColumn(settingsTable, settingsTable.lastBackupAt);
        }
        if (from < 12) {
          await m.addColumn(usersTable, usersTable.salt);
          await m.addColumn(usersTable, usersTable.failedAttempts);
          await m.addColumn(usersTable, usersTable.lockedUntil);
        }
        if (from < 13) {
          await m.createTable(refundsTable);
        }
        if (from < 14) {
          await m.createTable(cashMovementsTable);
        }
        if (from < 15) {
          await m.addColumn(settingsTable, settingsTable.printerType);
          await m.addColumn(
            settingsTable,
            settingsTable.printerAddress,
          );
        }
        if (from < 16) {
          await m.addColumn(
            settingsTable,
            settingsTable.taxInclusive,
          );
        }
        if (from < 17) {
          await m.addColumn(itemsTable, itemsTable.itemTaxRate);
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
