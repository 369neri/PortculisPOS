import 'package:cashier_app/features/customers/domain/repositories/customer_repository.dart';
import 'package:cashier_app/features/items/domain/repositories/item_repository.dart';
import 'package:cashier_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:cashier_app/features/sync/data/datasources/remote_sync_datasource.dart';
import 'package:cashier_app/features/sync/domain/repositories/sync_repository.dart';

class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl(
    this._remote, {
    required ItemRepository itemRepository,
    required CustomerRepository customerRepository,
    required SettingsRepository settingsRepository,
  })  : _items = itemRepository,
        _customers = customerRepository,
        _settings = settingsRepository;

  final RemoteSyncDatasource _remote;
  final ItemRepository _items;
  final CustomerRepository _customers;
  final SettingsRepository _settings;

  @override
  Future<DateTime> pushChanges({required String deviceId}) async {
    final items = await _items.getAll();
    final customers = await _customers.getAll();
    final settings = await _settings.getSettings();

    return _remote.push(
      deviceId: deviceId,
      items: items,
      customers: customers,
      settings: settings,
    );
  }

  @override
  Future<SyncPayload> pullAndMerge({
    required String deviceId,
    DateTime? since,
  }) async {
    final payload = await _remote.pull(deviceId: deviceId, since: since);

    // Merge items — upsert each pulled item into local storage.
    for (final item in payload.items) {
      await _items.save(item);
    }

    // Merge customers.
    for (final customer in payload.customers) {
      if (customer.id != null) {
        final existing = await _customers.findById(customer.id!);
        if (existing != null) {
          await _customers.update(customer);
        } else {
          await _customers.save(customer);
        }
      } else {
        await _customers.save(customer);
      }
    }

    // Merge settings if the server sent any.
    if (payload.settings != null) {
      final local = await _settings.getSettings();
      await _settings.saveSettings(
        local.copyWith(
          businessName: payload.settings!.businessName,
          taxRate: payload.settings!.taxRate,
          currencySymbol: payload.settings!.currencySymbol,
          receiptFooter: payload.settings!.receiptFooter,
          taxInclusive: payload.settings!.taxInclusive,
        ),
      );
    }

    return payload;
  }
}
