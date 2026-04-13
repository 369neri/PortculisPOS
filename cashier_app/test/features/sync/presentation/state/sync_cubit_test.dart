import 'package:bloc_test/bloc_test.dart';
import 'package:cashier_app/features/checkout/domain/entities/refund_line_item.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/customers/domain/entities/customer.dart';
import 'package:cashier_app/features/customers/domain/repositories/customer_repository.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/items/domain/repositories/item_repository.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:cashier_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:cashier_app/features/sync/data/datasources/remote_sync_datasource.dart';
import 'package:cashier_app/features/sync/domain/repositories/sync_repository.dart';
import 'package:cashier_app/features/sync/domain/services/backup_service.dart';
import 'package:cashier_app/features/sync/presentation/state/sync_cubit.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeSettingsRepo implements SettingsRepository {
  AppSettings settings = const AppSettings();

  @override
  Future<AppSettings> getSettings() async => settings;
  @override
  Future<void> saveSettings(AppSettings s) async => settings = s;
}

class _StubItemRepo implements ItemRepository {
  @override
  Future<List<Item>> getAll() async => [];
  @override
  Future<Item?> findBySku(String sku) async => null;
  @override
  Future<Item?> findByGtin(String gtin) async => null;
  @override
  Future<void> save(Item item) async {}
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

class _StubTxRepo implements TransactionRepository {
  @override
  Future<List<Transaction>> getAll() async => [];
  @override
  Future<List<Transaction>> getPage(int limit, int offset) async => [];
  @override
  Future<Transaction?> findById(int id) async => null;
  @override
  Future<int> save(Transaction transaction) async => 1;
  @override
  Future<void> voidTransaction(int id) async {}
  @override
  Future<void> refundTransaction(int id) async {}
  @override
  Future<void> partialRefund(int id, List<RefundLineItem> items) async {}
  @override
  Future<List<RefundLineItem>> getRefunds(int transactionId) async => [];
}

class _StubCustomerRepo implements CustomerRepository {
  @override
  Future<List<Customer>> getAll() async => [];
  @override
  Future<Customer?> findById(int id) async => null;
  @override
  Future<List<Customer>> search(String query) async => [];
  @override
  Future<int> save(Customer customer) async => 1;
  @override
  Future<void> update(Customer customer) async {}
  @override
  Future<void> delete(int id) async {}
}

class _FakeBackupService extends BackupService {
  _FakeBackupService()
      : super(
          _StubItemRepo(),
          _StubTxRepo(),
          _StubCustomerRepo(),
          _FakeSettingsRepo(),
        );

  bool shouldThrow = false;

  @override
  Future<String> exportBackup() async {
    if (shouldThrow) throw Exception('backup error');
    return '/tmp/backup.json';
  }
}

class _FakeSyncRepo implements SyncRepository {
  DateTime pushResult = DateTime.utc(2025, 6, 1, 12);
  SyncPayload pullResult = SyncPayload(
    syncedAt: DateTime.utc(2025, 6, 1, 12),
  );
  bool shouldThrow = false;

  @override
  Future<DateTime> pushChanges({required String deviceId}) async {
    if (shouldThrow) throw Exception('push error');
    return pushResult;
  }

  @override
  Future<SyncPayload> pullAndMerge({
    required String deviceId,
    DateTime? since,
  }) async {
    if (shouldThrow) throw Exception('pull error');
    return pullResult;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeSettingsRepo settingsRepo;
  late _FakeBackupService backupService;
  late _FakeSyncRepo syncRepo;

  setUp(() {
    settingsRepo = _FakeSettingsRepo();
    backupService = _FakeBackupService();
    syncRepo = _FakeSyncRepo();
  });

  group('SyncCubit', () {
    blocTest<SyncCubit, SyncState>(
      'emits SyncIdle on init with lastBackupAt from settings',
      setUp: () {
        settingsRepo.settings = AppSettings(
          lastBackupAt: DateTime.utc(2025),
        );
      },
      build: () => SyncCubit(backupService, settingsRepo),
      expect: () => [
        SyncIdle(lastBackupAt: DateTime.utc(2025)),
      ],
    );

    blocTest<SyncCubit, SyncState>(
      'emits SyncIdle with both timestamps on init',
      setUp: () {
        settingsRepo.settings = AppSettings(
          lastBackupAt: DateTime.utc(2025),
          lastSyncedAt: DateTime.utc(2025, 2),
        );
      },
      build: () => SyncCubit(backupService, settingsRepo),
      expect: () => [
        SyncIdle(
          lastBackupAt: DateTime.utc(2025),
          lastSyncedAt: DateTime.utc(2025, 2),
        ),
      ],
    );

    group('runBackup', () {
      blocTest<SyncCubit, SyncState>(
        'emits InProgress then Idle with updated timestamp',
        build: () => SyncCubit(backupService, settingsRepo),
        act: (cubit) async {
          await Future<void>.delayed(Duration.zero);
          await cubit.runBackup();
        },
        expect: () => [
          const SyncIdle(),
          const SyncInProgress(),
          isA<SyncIdle>().having(
            (s) => s.lastBackupAt,
            'lastBackupAt',
            isNotNull,
          ),
        ],
      );

      blocTest<SyncCubit, SyncState>(
        'emits SyncError when backup fails',
        setUp: () => backupService.shouldThrow = true,
        build: () => SyncCubit(backupService, settingsRepo),
        act: (cubit) async {
          await Future<void>.delayed(Duration.zero);
          await cubit.runBackup();
        },
        expect: () => [
          const SyncIdle(),
          const SyncInProgress(),
          isA<SyncError>().having(
            (s) => s.message,
            'message',
            contains('backup error'),
          ),
        ],
      );
    });

    group('syncWithServer', () {
      blocTest<SyncCubit, SyncState>(
        'emits InProgress then Idle with syncedAt',
        setUp: () {
          settingsRepo.settings =
              const AppSettings(deviceId: 'dev-1');
        },
        build: () => SyncCubit(
          backupService,
          settingsRepo,
          syncRepository: syncRepo,
        ),
        act: (cubit) async {
          await Future<void>.delayed(Duration.zero);
          await cubit.syncWithServer();
        },
        expect: () => [
          const SyncIdle(),
          const SyncInProgress(),
          SyncIdle(lastSyncedAt: DateTime.utc(2025, 6, 1, 12)),
        ],
      );

      blocTest<SyncCubit, SyncState>(
        'persists lastSyncedAt to settings',
        setUp: () {
          settingsRepo.settings =
              const AppSettings(deviceId: 'dev-1');
        },
        build: () => SyncCubit(
          backupService,
          settingsRepo,
          syncRepository: syncRepo,
        ),
        act: (cubit) async {
          await Future<void>.delayed(Duration.zero);
          await cubit.syncWithServer();
        },
        verify: (_) {
          expect(
            settingsRepo.settings.lastSyncedAt,
            DateTime.utc(2025, 6, 1, 12),
          );
        },
      );

      blocTest<SyncCubit, SyncState>(
        'emits SyncError when sync fails',
        setUp: () {
          syncRepo.shouldThrow = true;
          settingsRepo.settings =
              const AppSettings(deviceId: 'dev-1');
        },
        build: () => SyncCubit(
          backupService,
          settingsRepo,
          syncRepository: syncRepo,
        ),
        act: (cubit) async {
          await Future<void>.delayed(Duration.zero);
          await cubit.syncWithServer();
        },
        expect: () => [
          const SyncIdle(),
          const SyncInProgress(),
          isA<SyncError>().having(
            (s) => s.message,
            'message',
            contains('Sync failed'),
          ),
        ],
      );

      blocTest<SyncCubit, SyncState>(
        'does nothing when syncRepository is null',
        build: () => SyncCubit(backupService, settingsRepo),
        act: (cubit) async {
          await Future<void>.delayed(Duration.zero);
          await cubit.syncWithServer();
        },
        expect: () => [const SyncIdle()],
      );
    });

    group('onTransactionCompleted', () {
      blocTest<SyncCubit, SyncState>(
        'runs backup when autoBackupEnabled is true',
        setUp: () {
          settingsRepo.settings = const AppSettings(
            autoBackupEnabled: true,
          );
        },
        build: () => SyncCubit(backupService, settingsRepo),
        act: (cubit) async {
          await Future<void>.delayed(Duration.zero);
          await cubit.onTransactionCompleted();
        },
        expect: () => [
          const SyncIdle(),
          const SyncInProgress(),
          isA<SyncIdle>().having(
            (s) => s.lastBackupAt,
            'lastBackupAt',
            isNotNull,
          ),
        ],
      );

      blocTest<SyncCubit, SyncState>(
        'skips backup when autoBackupEnabled is false',
        build: () => SyncCubit(backupService, settingsRepo),
        act: (cubit) async {
          await Future<void>.delayed(Duration.zero);
          await cubit.onTransactionCompleted();
        },
        expect: () => [const SyncIdle()],
      );
    });
  });
}
