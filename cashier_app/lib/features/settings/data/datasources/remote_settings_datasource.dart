import 'package:cashier_app/core/network/api_client.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:cashier_app/features/settings/domain/repositories/settings_repository.dart';

/// Remote datasource that proxies [SettingsRepository] calls to the server API.
class RemoteSettingsDatasource implements SettingsRepository {
  RemoteSettingsDatasource(this._api);

  final ApiClient _api;

  @override
  Future<AppSettings> getSettings() async {
    final data = await _api.get('/api/settings/');
    return _fromJson(data);
  }

  @override
  Future<void> saveSettings(AppSettings settings) =>
      _api.put('/api/settings/', _toJson(settings));

  // ---------------------------------------------------------------------------
  // JSON helpers
  // ---------------------------------------------------------------------------

  static AppSettings _fromJson(Map<String, dynamic> m) => AppSettings(
        businessName: m['businessName'] as String? ?? 'My Business',
        taxRate: (m['taxRate'] as num?)?.toDouble() ?? 0.0,
        currencySymbol: m['currencySymbol'] as String? ?? r'$',
        receiptFooter:
            m['receiptFooter'] as String? ?? 'Thank you for your business!',
        themeMode: m['themeMode'] as String? ?? 'system',
        printerType: m['printerType'] as String? ?? 'none',
        printerAddress: m['printerAddress'] as String? ?? '',
        taxInclusive: m['taxInclusive'] as bool? ?? false,
      );

  static Map<String, dynamic> _toJson(AppSettings s) => {
        'businessName': s.businessName,
        'taxRate': s.taxRate,
        'currencySymbol': s.currencySymbol,
        'receiptFooter': s.receiptFooter,
        'themeMode': s.themeMode,
        'printerType': s.printerType,
        'printerAddress': s.printerAddress,
        'taxInclusive': s.taxInclusive,
      };
}
