import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';

abstract interface class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
}
