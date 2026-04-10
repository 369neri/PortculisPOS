import 'package:cashier_app/core/persistence/app_database.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:cashier_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:drift/drift.dart';

class LocalSettingsDatasource implements SettingsRepository {
  LocalSettingsDatasource(this._dao);

  final SettingsDao _dao;

  @override
  Future<AppSettings> getSettings() async {
    final row = await _dao.getOrCreate();
    return AppSettings(
      businessName: row.businessName,
      taxRate: row.taxRate,
      currencySymbol: row.currencySymbol,
      receiptFooter: row.receiptFooter,
      lastZReportAt: row.lastZReportAt != null
          ? DateTime.tryParse(row.lastZReportAt!)
          : null,
      themeMode: row.themeMode,
      logoPath: row.logoPath,
      autoBackupEnabled: row.autoBackupEnabled,
      lastBackupAt: row.lastBackupAt != null
          ? DateTime.tryParse(row.lastBackupAt!)
          : null,
      printerType: row.printerType,
      printerAddress: row.printerAddress,
      taxInclusive: row.taxInclusive,
      lastSyncedAt: row.lastSyncedAt != null
          ? DateTime.tryParse(row.lastSyncedAt!)
          : null,
      serverUrl: row.serverUrl,
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) => _dao.save(
        SettingsTableCompanion(
          id: const Value(1),
          businessName: Value(settings.businessName),
          taxRate: Value(settings.taxRate),
          currencySymbol: Value(settings.currencySymbol),
          receiptFooter: Value(settings.receiptFooter),
          lastZReportAt: Value(settings.lastZReportAt?.toIso8601String()),
          themeMode: Value(settings.themeMode),
          logoPath: Value(settings.logoPath),
          autoBackupEnabled: Value(settings.autoBackupEnabled),
          lastBackupAt: Value(settings.lastBackupAt?.toIso8601String()),
          printerType: Value(settings.printerType),
          printerAddress: Value(settings.printerAddress),
          taxInclusive: Value(settings.taxInclusive),
          lastSyncedAt: Value(settings.lastSyncedAt?.toIso8601String()),
          serverUrl: Value(settings.serverUrl),
        ),
      );
}
