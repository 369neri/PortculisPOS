import 'package:cashier_app/core/persistence/app_database.dart';
import 'package:cashier_app/features/archive/domain/services/archive_service.dart';
import 'package:cashier_app/features/archive/presentation/state/archive_cubit.dart';
import 'package:cashier_app/features/auth/data/datasources/local_user_datasource.dart';
import 'package:cashier_app/features/auth/domain/repositories/user_repository.dart';
import 'package:cashier_app/features/auth/presentation/state/auth_cubit.dart';
import 'package:cashier_app/features/billing/presentation/state/sales_register_cubit.dart';
import 'package:cashier_app/features/cash_drawer/data/datasources/local_cash_drawer_datasource.dart';
import 'package:cashier_app/features/cash_drawer/domain/repositories/cash_drawer_repository.dart';
import 'package:cashier_app/features/cash_drawer/presentation/state/cash_drawer_cubit.dart';
import 'package:cashier_app/features/checkout/data/datasources/local_transaction_datasource.dart';
import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_cubit.dart';
import 'package:cashier_app/features/checkout/presentation/state/transaction_history_cubit.dart';
import 'package:cashier_app/features/customers/data/datasources/local_customer_datasource.dart';
import 'package:cashier_app/features/customers/domain/repositories/customer_repository.dart';
import 'package:cashier_app/features/customers/presentation/state/customer_cubit.dart';
import 'package:cashier_app/features/items/data/datasources/local_item_datasource.dart';
import 'package:cashier_app/features/items/domain/repositories/item_repository.dart';
import 'package:cashier_app/features/items/presentation/state/item_catalog_cubit.dart';
import 'package:cashier_app/features/items/presentation/state/item_lookup_cubit.dart';
import 'package:cashier_app/features/pricing/presentation/state/keypad_cubit.dart';
import 'package:cashier_app/features/pricing/presentation/state/keypad_cubit_state.dart';
import 'package:cashier_app/features/reports/presentation/state/reports_cubit.dart';
import 'package:cashier_app/features/settings/data/datasources/local_settings_datasource.dart';
import 'package:cashier_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:cashier_app/features/settings/presentation/state/settings_cubit.dart';
import 'package:cashier_app/features/sync/domain/services/backup_service.dart';
import 'package:cashier_app/features/sync/presentation/state/sync_cubit.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void initServiceLocator() {
  sl
    // Persistence
    ..registerSingleton<AppDatabase>(AppDatabase())
    ..registerSingleton<ItemRepository>(
      LocalItemDatasource(sl<AppDatabase>()),
    )
    ..registerSingleton<TransactionRepository>(
      LocalTransactionDatasource(sl<AppDatabase>().transactionsDao),
    )
    ..registerSingleton<SettingsRepository>(
      LocalSettingsDatasource(sl<AppDatabase>().settingsDao),
    )
    // Cubits
    ..registerFactory<KeypadCubit>(
      () => KeypadCubit(const KeypadInitialState()),
    )
    ..registerFactory<SalesRegisterCubit>(SalesRegisterCubit.new)
    ..registerFactory<ItemLookupCubit>(
      () => ItemLookupCubit(sl<ItemRepository>()),
    )
    ..registerFactory<ItemCatalogCubit>(
      () => ItemCatalogCubit(sl<ItemRepository>()),
    )
    ..registerFactory<CheckoutCubit>(
      () => CheckoutCubit(
        sl<TransactionRepository>(),
        itemRepository: sl<ItemRepository>(),
        syncCubit: sl<SyncCubit>(),
      ),
    )
    ..registerSingleton<SettingsCubit>(
      SettingsCubit(sl<SettingsRepository>()),
    )
    ..registerSingleton<TransactionHistoryCubit>(
      TransactionHistoryCubit(
        sl<TransactionRepository>(),
        itemRepository: sl<ItemRepository>(),
      ),
    )
    ..registerSingleton<ReportsCubit>(
      ReportsCubit(sl<TransactionRepository>(), sl<SettingsRepository>()),
    )
    // Cash drawer
    ..registerSingleton<CashDrawerRepository>(
      LocalCashDrawerDatasource(sl<AppDatabase>().cashDrawerDao),
    )
    ..registerFactory<CashDrawerCubit>(
      () => CashDrawerCubit(sl<CashDrawerRepository>()),
    )
    // Customers
    ..registerSingleton<CustomerRepository>(
      LocalCustomerDatasource(sl<AppDatabase>().customersDao),
    )
    ..registerFactory<CustomerCubit>(
      () => CustomerCubit(sl<CustomerRepository>()),
    )
    // Archive
    ..registerSingleton<ArchiveService>(ArchiveService())
    ..registerFactory<ArchiveCubit>(
      () => ArchiveCubit(sl<ArchiveService>()),
    )
    // Auth
    ..registerSingleton<UserRepository>(
      LocalUserDatasource(sl<AppDatabase>().usersDao),
    )
    ..registerSingleton<AuthCubit>(
      AuthCubit(sl<UserRepository>()),
    )
    // Backup
    ..registerSingleton<BackupService>(
      BackupService(
        sl<ItemRepository>(),
        sl<TransactionRepository>(),
        sl<CustomerRepository>(),
        sl<SettingsRepository>(),
      ),
    )
    // Sync
    ..registerSingleton<SyncCubit>(
      SyncCubit(sl<BackupService>(), sl<SettingsRepository>()),
    );
}
