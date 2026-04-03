import 'package:cashier_app/core/persistence/app_database.dart';
import 'package:cashier_app/features/billing/presentation/state/sales_register_cubit.dart';
import 'package:cashier_app/features/checkout/data/datasources/local_transaction_datasource.dart';
import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_cubit.dart';
import 'package:cashier_app/features/checkout/presentation/state/transaction_history_cubit.dart';
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
      () => CheckoutCubit(sl<TransactionRepository>()),
    )
    ..registerSingleton<SettingsCubit>(
      SettingsCubit(sl<SettingsRepository>()),
    )
    ..registerSingleton<TransactionHistoryCubit>(
      TransactionHistoryCubit(sl<TransactionRepository>()),
    )
    ..registerSingleton<ReportsCubit>(
      ReportsCubit(sl<TransactionRepository>(), sl<SettingsRepository>()),
    );
}
