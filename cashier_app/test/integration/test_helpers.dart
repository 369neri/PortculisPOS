import 'package:cashier_app/core/persistence/app_database.dart';
import 'package:cashier_app/features/cash_drawer/data/datasources/local_cash_drawer_datasource.dart';
import 'package:cashier_app/features/cash_drawer/domain/repositories/cash_drawer_repository.dart';
import 'package:cashier_app/features/checkout/data/datasources/local_transaction_datasource.dart';
import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/customers/data/datasources/local_customer_datasource.dart';
import 'package:cashier_app/features/customers/domain/repositories/customer_repository.dart';
import 'package:cashier_app/features/items/data/datasources/local_item_datasource.dart';
import 'package:cashier_app/features/items/domain/repositories/item_repository.dart';
import 'package:cashier_app/features/settings/data/datasources/local_settings_datasource.dart';
import 'package:cashier_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:drift/native.dart';

/// All production-level dependencies backed by an in-memory Drift DB.
class TestDeps {
  TestDeps() : db = AppDatabase(NativeDatabase.memory()) {
    itemRepo = LocalItemDatasource(db);
    txRepo = LocalTransactionDatasource(db.transactionsDao);
    settingsRepo = LocalSettingsDatasource(db.settingsDao);
    cashDrawerRepo = LocalCashDrawerDatasource(db.cashDrawerDao);
    customerRepo = LocalCustomerDatasource(db.customersDao);
  }

  final AppDatabase db;
  late final ItemRepository itemRepo;
  late final TransactionRepository txRepo;
  late final SettingsRepository settingsRepo;
  late final CashDrawerRepository cashDrawerRepo;
  late final CustomerRepository customerRepo;

  Future<void> dispose() => db.close();
}
