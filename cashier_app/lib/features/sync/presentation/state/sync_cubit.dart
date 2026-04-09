import 'package:cashier_app/core/logging/app_logger.dart';
import 'package:cashier_app/features/settings/domain/repositories/settings_repository.dart';
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
  const SyncIdle({this.lastBackupAt});
  final DateTime? lastBackupAt;

  @override
  List<Object?> get props => [lastBackupAt];
}

final class SyncInProgress extends SyncState {
  const SyncInProgress();
  @override
  List<Object?> get props => [];
}

final class SyncError extends SyncState {
  const SyncError(this.message, {this.lastBackupAt});
  final String message;
  final DateTime? lastBackupAt;
  @override
  List<Object?> get props => [message, lastBackupAt];
}

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

class SyncCubit extends Cubit<SyncState> {
  SyncCubit(this._backupService, this._settingsRepo)
      : super(const SyncIdle()) {
    _init();
  }

  final BackupService _backupService;
  final SettingsRepository _settingsRepo;

  Future<void> _init() async {
    final settings = await _settingsRepo.getSettings();
    emit(SyncIdle(lastBackupAt: settings.lastBackupAt));
  }

  /// Run a backup now. Called manually or after a transaction completes.
  Future<void> runBackup() async {
    emit(const SyncInProgress());
    try {
      await _backupService.exportBackup();
      final now = DateTime.now();
      // Persist the timestamp
      final settings = await _settingsRepo.getSettings();
      await _settingsRepo.saveSettings(
        settings.copyWith(lastBackupAt: now),
      );
      emit(SyncIdle(lastBackupAt: now));
    } on Exception catch (e, st) {
      appLogger.e('Auto-backup failed', error: e, stackTrace: st);
      final settings = await _settingsRepo.getSettings();
      emit(SyncError(
        'Backup failed: $e',
        lastBackupAt: settings.lastBackupAt,
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
