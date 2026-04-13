import 'dart:convert';

import 'package:cashier_app/core/network/api_client.dart';
import 'package:cashier_app/features/settings/data/datasources/remote_settings_datasource.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

ApiClient _fakeApi(Future<http.Response> Function(http.Request) handler) =>
    ApiClient(
      baseUrl: 'http://localhost:8080',
      httpClient: MockClient(handler),
    );

void main() {
  group('RemoteSettingsDatasource', () {
    test('getSettings parses response', () async {
      final api = _fakeApi(
        (req) async => http.Response(
          jsonEncode({
            'businessName': 'Acme',
            'taxRate': 7.5,
            'currencySymbol': 'EUR',
            'receiptFooter': 'Thanks!',
            'themeMode': 'dark',
            'printerType': 'esc_pos',
            'printerAddress': '192.168.1.50',
            'taxInclusive': true,
          }),
          200,
        ),
      );
      final ds = RemoteSettingsDatasource(api);
      final s = await ds.getSettings();

      expect(s.businessName, 'Acme');
      expect(s.taxRate, 7.5);
      expect(s.currencySymbol, 'EUR');
      expect(s.receiptFooter, 'Thanks!');
      expect(s.themeMode, 'dark');
      expect(s.printerType, 'esc_pos');
      expect(s.printerAddress, '192.168.1.50');
      expect(s.taxInclusive, isTrue);
    });

    test('getSettings uses defaults for missing fields', () async {
      final api = _fakeApi(
        (req) async => http.Response(jsonEncode(<String, dynamic>{}), 200),
      );
      final ds = RemoteSettingsDatasource(api);
      final s = await ds.getSettings();

      expect(s.businessName, 'My Business');
      expect(s.taxRate, 0.0);
      expect(s.currencySymbol, r'$');
    });

    test('saveSettings sends PUT with correct body', () async {
      http.Request? captured;
      final api = _fakeApi((req) async {
        captured = req;
        return http.Response(jsonEncode({}), 200);
      });
      final ds = RemoteSettingsDatasource(api);
      await ds.saveSettings(const AppSettings(
        businessName: 'Test Biz',
        taxRate: 10,
        currencySymbol: '£',
      ));

      expect(captured, isNotNull);
      expect(captured!.method, 'PUT');
      final body = jsonDecode(captured!.body) as Map<String, dynamic>;
      expect(body['businessName'], 'Test Biz');
      expect(body['taxRate'], 10);
      expect(body['currencySymbol'], '£');
    });
  });
}
