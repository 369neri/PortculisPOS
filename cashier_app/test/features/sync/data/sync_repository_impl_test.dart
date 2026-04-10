import 'package:cashier_app/core/network/api_client.dart';
import 'package:cashier_app/features/customers/domain/entities/customer.dart';
import 'package:cashier_app/features/customers/domain/repositories/customer_repository.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/items/domain/repositories/item_repository.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:cashier_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:cashier_app/features/sync/data/datasources/remote_sync_datasource.dart';
import 'package:cashier_app/features/sync/data/sync_repository_impl.dart';
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
  Future<void> save(Item item) async => saved.add(item);
  @override
  Future<Item?> findBySku(String sku) async => null;
  @override
  Future<Item?> findByGtin(String gtin) async => null;
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

class _FakeCustomerRepo implements CustomerRepository {
  List<Customer> customers = [];
  final List<Customer> saved = [];
  final List<Customer> updated = [];

  @override
  Future<List<Customer>> getAll() async => List.unmodifiable(customers);
  @override
  Future<Customer?> findById(int id) async {
    for (final c in customers) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Future<int> save(Customer c) async {
    saved.add(c);
    return c.id ?? saved.length;
  }

  @override
  Future<void> update(Customer c) async => updated.add(c);
  @override
  Future<List<Customer>> search(String query) async => [];
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

class _FakeRemoteSyncDatasource extends RemoteSyncDatasource {
  _FakeRemoteSyncDatasource()
      : super(ApiClient(baseUrl: 'http://unused'));

  DateTime pushResult = DateTime.utc(2025, 6, 1, 12);
  SyncPayload pullResult = const SyncPayload();

  List<Item>? lastPushedItems;
  List<Customer>? lastPushedCustomers;
  AppSettings? lastPushedSettings;
  String? lastPulledDeviceId;
  DateTime? lastPulledSince;

  @override
  Future<DateTime> push({
    required String deviceId,
    List<Item> items = const [],
    List<Customer> customers = const [],
    List<dynamic> transactions = const [],
    List<dynamic> cashDrawerSessions = const [],
    AppSettings? settings,
  }) async {
    lastPushedItems = items;
    lastPushedCustomers = customers;
    lastPushedSettings = settings;
    return pushResult;
  }

  @override
  Future<SyncPayload> pull({
    required String deviceId,
    DateTime? since,
  }) async {
    lastPulledDeviceId = deviceId;
    lastPulledSince = since;
    return pullResult;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SyncRepositoryImpl', () {
    late _FakeItemRepo itemRepo;
    late _FakeCustomerRepo customerRepo;
    late _FakeSettingsRepo settingsRepo;
    late _FakeRemoteSyncDatasource remote;
    late SyncRepositoryImpl repo;

    setUp(() {
      itemRepo = _FakeItemRepo();
      customerRepo = _FakeCustomerRepo();
      settingsRepo = _FakeSettingsRepo();
      remote = _FakeRemoteSyncDatasource();
      repo = SyncRepositoryImpl(
        remote,
        itemRepository: itemRepo,
        customerRepository: customerRepo,
        settingsRepository: settingsRepo,
      );
    });

    group('pushChanges', () {
      test('sends all local data to remote', () async {
        itemRepo.items = [
          TradeItem(
            sku: 'W-001',
            label: 'Widget',
            unitPrice: Price(BigInt.from(1500)),
          ),
        ];
        customerRepo.customers = [
          const Customer(id: 1, name: 'Alice'),
        ];
        settingsRepo.settings = const AppSettings(businessName: 'TestBiz');

        final syncedAt = await repo.pushChanges(deviceId: 'dev-1');

        expect(syncedAt, remote.pushResult);
        expect(remote.lastPushedItems, hasLength(1));
        expect(remote.lastPushedItems!.first.sku, 'W-001');
        expect(remote.lastPushedCustomers, hasLength(1));
        expect(remote.lastPushedCustomers!.first.name, 'Alice');
        expect(remote.lastPushedSettings!.businessName, 'TestBiz');
      });

      test('pushes empty lists when no local data', () async {
        await repo.pushChanges(deviceId: 'dev-1');

        expect(remote.lastPushedItems, isEmpty);
        expect(remote.lastPushedCustomers, isEmpty);
      });
    });

    group('pullAndMerge', () {
      test('saves pulled items to local repo', () async {
        remote.pullResult = SyncPayload(
          items: [
            TradeItem(
              sku: 'W-001',
              label: 'Widget',
              unitPrice: Price(BigInt.from(1500)),
            ),
          ],
          syncedAt: DateTime.utc(2025, 6, 1, 12),
        );

        await repo.pullAndMerge(deviceId: 'dev-1');

        expect(itemRepo.saved, hasLength(1));
        expect(itemRepo.saved.first.sku, 'W-001');
      });

      test('saves new customers to local repo', () async {
        remote.pullResult = SyncPayload(
          customers: [
            const Customer(id: 99, name: 'Bob'),
          ],
          syncedAt: DateTime.utc(2025, 6, 1, 12),
        );

        await repo.pullAndMerge(deviceId: 'dev-1');

        expect(customerRepo.saved, hasLength(1));
        expect(customerRepo.saved.first.name, 'Bob');
      });

      test('updates existing customers', () async {
        customerRepo.customers = [
          const Customer(id: 5, name: 'Original'),
        ];
        remote.pullResult = SyncPayload(
          customers: [
            const Customer(id: 5, name: 'Updated'),
          ],
          syncedAt: DateTime.utc(2025, 6, 1, 12),
        );

        await repo.pullAndMerge(deviceId: 'dev-1');

        expect(customerRepo.updated, hasLength(1));
        expect(customerRepo.updated.first.name, 'Updated');
        expect(customerRepo.saved, isEmpty);
      });

      test('merges settings from server', () async {
        settingsRepo.settings = const AppSettings(
          businessName: 'Local Biz',
          taxRate: 5,
        );
        remote.pullResult = SyncPayload(
          settings: const AppSettings(
            businessName: 'Remote Biz',
            taxRate: 10,
          ),
          syncedAt: DateTime.utc(2025, 6, 1, 12),
        );

        await repo.pullAndMerge(deviceId: 'dev-1');

        expect(settingsRepo.settings.businessName, 'Remote Biz');
        expect(settingsRepo.settings.taxRate, 10.0);
      });

      test('passes since timestamp to remote', () async {
        final since = DateTime.utc(2025, 5);
        await repo.pullAndMerge(deviceId: 'dev-1', since: since);

        expect(remote.lastPulledSince, since);
        expect(remote.lastPulledDeviceId, 'dev-1');
      });

      test('returns the payload', () async {
        remote.pullResult = SyncPayload(
          items: [
            ServiceItem(
              sku: 'S-001',
              label: 'Service',
              unitPrice: Price(BigInt.from(500)),
            ),
          ],
          syncedAt: DateTime.utc(2025, 6),
        );

        final result = await repo.pullAndMerge(deviceId: 'dev-1');

        expect(result.items, hasLength(1));
        expect(result.syncedAt, DateTime.utc(2025, 6));
      });

      test('does not overwrite settings when server sends null', () async {
        settingsRepo.settings = const AppSettings(businessName: 'Keep Me');
        remote.pullResult = const SyncPayload(
          
        );

        await repo.pullAndMerge(deviceId: 'dev-1');

        expect(settingsRepo.settings.businessName, 'Keep Me');
      });
    });
  });
}
