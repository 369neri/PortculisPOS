import 'package:cashier_app/core/logging/app_logger.dart';
import 'package:cashier_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:cashier_app/features/sync/domain/repositories/sync_repository.dart';
import 'package:cashier_app/features/sync/domain/services/backup_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

@immutable
sealed class SyncState extends Equatable {
  const SyncState();
}

final class SyncIdle extends SyncState {
  const SyncIdle({this.lastBackupAt, this.lastSyncedAt});
  final DateTime? lastBackupAt;
  final DateTime? lastSyncedAt;

  @override
  List<Object?> get props => [lastBackupAt, lastSyncedAt];
}

final class SyncInProgress extends SyncState {
  const SyncInProgress();
  @override
  List<Object?> get props => [];
}

final class SyncError extends SyncState {
  const SyncError(this.message, {this.lastBackupAt, this.lastSyncedAt});
  final String message;
  final DateTime? lastBackupAt;
  final DateTime? lastSyncedAt;
  @override
  List<Object?> get props => [message, lastBackupAt, lastSyncedAt];
}

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

class SyncCubit extends Cubit<SyncState> {
  SyncCubit(
    this._backupService,
    this._settingsRepo, {
    SyncRepository? syncRepository,
  })  : _syncRepository = syncRepository,
        super(const SyncIdle()) {
    _init();
  }

  final BackupService _backupService;
  final SettingsRepository _settingsRepo;
  final SyncRepository? _syncRepository;

  Future<void> _init() async {
    final settings = await _settingsRepo.getSettings();
    emit(SyncIdle(
      lastBackupAt: settings.lastBackupAt,
      lastSyncedAt: settings.lastSyncedAt,
    ),);
  }

  /// Run a local backup now.
  Future<void> runBackup() async {
    emit(const SyncInProgress());
    try {
      await _backupService.exportBackup();
      final now = DateTime.now();
      final settings = await _settingsRepo.getSettings();
      await _settingsRepo.saveSettings(
        settings.copyWith(lastBackupAt: now),
      );
      emit(SyncIdle(
        lastBackupAt: now,
        lastSyncedAt: settings.lastSyncedAt,
      ),);
    } on Exception catch (e, st) {
      appLogger.e('Auto-backup failed', error: e, stackTrace: st);
      final settings = await _settingsRepo.getSettings();
      emit(SyncError(
        'Backup failed: $e',
        lastBackupAt: settings.lastBackupAt,
        lastSyncedAt: settings.lastSyncedAt,
      ),);
    }
  }

  /// Sync local data with the remote server (push then pull).
  ///
  /// The [deviceId] identifies this device for the server.
  Future<void> syncWithServer(String deviceId) async {
    final syncRepository = _syncRepository;
    if (syncRepository == null) return;
    emit(const SyncInProgress());
    try {
      // Push local changes first.
      await syncRepository.pushChanges(deviceId: deviceId);

      // Then pull remote changes (delta since last sync).
      final settings = await _settingsRepo.getSettings();
      final payload = await syncRepository.pullAndMerge(
        deviceId: deviceId,
        since: settings.lastSyncedAt,
      );

      // Persist the sync timestamp.
      final syncedAt = payload.syncedAt ?? DateTime.now().toUtc();
      await _settingsRepo.saveSettings(
        settings.copyWith(lastSyncedAt: syncedAt),
      );

      emit(SyncIdle(
        lastBackupAt: settings.lastBackupAt,
        lastSyncedAt: syncedAt,
      ),);
    } on Exception catch (e, st) {
      appLogger.e('Server sync failed', error: e, stackTrace: st);
      final settings = await _settingsRepo.getSettings();
      emit(SyncError(
        'Sync failed: $e',
        lastBackupAt: settings.lastBackupAt,
        lastSyncedAt: settings.lastSyncedAt,
      ),);
    }
  }

  /// Called after a successful checkout if auto-backup is enabled.
  Future<void> onTransactionCompleted() async {
    final settings = await _settingsRepo.getSettings();
    if (!settings.autoBackupEnabled) return;
    await runBackup();
  }
}
