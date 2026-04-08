import 'dart:convert';

import 'package:cashier_app/core/network/api_client.dart';
import 'package:cashier_app/features/sync/data/datasources/remote_sync_datasource.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/customers/domain/entities/customer.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
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
  group('RemoteSyncDatasource', () {
    test('push sends items, customers, and returns syncedAt', () async {
      Map<String, dynamic>? sentBody;
      final api = _fakeApi((req) async {
        sentBody = jsonDecode(req.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'synced': {'items': 1, 'customers': 1},
            'syncedAt': '2025-06-01T12:00:00.000Z',
          }),
          200,
        );
      });

      final ds = RemoteSyncDatasource(api);
      final syncedAt = await ds.push(
        deviceId: 'dev-1',
        items: [
          TradeItem(
            sku: 'T-001',
            label: 'Widget',
            unitPrice: Price(BigInt.zero),
          ),
        ],
        customers: [
          Customer(name: 'Alice'),
        ],
      );

      expect(syncedAt, DateTime.utc(2025, 6, 1, 12));
      expect(sentBody!['deviceId'], 'dev-1');
      expect((sentBody!['items'] as List), hasLength(1));
      expect((sentBody!['customers'] as List), hasLength(1));
    });

    test('push includes settings when provided', () async {
      Map<String, dynamic>? sentBody;
      final api = _fakeApi((req) async {
        sentBody = jsonDecode(req.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({'synced': {}, 'syncedAt': '2025-06-01T12:00:00.000Z'}),
          200,
        );
      });

      final ds = RemoteSyncDatasource(api);
      await ds.push(
        deviceId: 'dev-1',
        settings: const AppSettings(businessName: 'TestBiz', taxRate: 10.0),
      );

      expect(sentBody!['settings'], isNotNull);
      expect(sentBody!['settings']['businessName'], 'TestBiz');
      expect(sentBody!['settings']['taxRate'], 10.0);
    });

    test('pull returns parsed items, customers, settings', () async {
      final api = _fakeApi(
        (req) async => http.Response(
          jsonEncode({
            'items': [
              {
                'sku': 'W-001',
                'label': 'Widget',
                'unitPriceSubunits': 1500,
                'type': 'trade',
                'category': '',
                'stockQuantity': 10,
                'isFavorite': false,
              },
            ],
            'customers': [
              {
                'id': 1,
                'name': 'Alice',
                'phone': '',
                'email': '',
                'notes': '',
              },
            ],
            'transactions': [],
            'settings': {
              'businessName': 'Remote Biz',
              'taxRate': 5.0,
              'currencySymbol': r'$',
              'receiptFooter': 'Thanks',
              'themeMode': 'dark',
              'taxInclusive': true,
            },
            'users': [],
            'syncedAt': '2025-06-01T12:00:00.000Z',
          }),
          200,
        ),
      );

      final ds = RemoteSyncDatasource(api);
      final payload = await ds.pull(deviceId: 'dev-1');

      expect(payload.items, hasLength(1));
      expect(payload.items.first.sku, 'W-001');
      expect(payload.items.first.unitPrice, Price(BigInt.from(1500)));

      expect(payload.customers, hasLength(1));
      expect(payload.customers.first.name, 'Alice');

      expect(payload.settings, isNotNull);
      expect(payload.settings!.businessName, 'Remote Biz');
      expect(payload.settings!.taxRate, 5.0);
      expect(payload.settings!.taxInclusive, true);

      expect(payload.syncedAt, DateTime.utc(2025, 6, 1, 12));
    });

    test('pull sends since timestamp when provided', () async {
      Map<String, dynamic>? sentBody;
      final api = _fakeApi((req) async {
        sentBody = jsonDecode(req.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'items': [],
            'customers': [],
            'transactions': [],
            'settings': null,
            'users': [],
            'syncedAt': '2025-06-01T12:00:00.000Z',
          }),
          200,
        );
      });

      final ds = RemoteSyncDatasource(api);
      await ds.pull(
        deviceId: 'dev-1',
        since: DateTime.utc(2025, 5, 1),
      );

      expect(sentBody!['since'], '2025-05-01T00:00:00.000Z');
    });

    test('pull with null since sends null', () async {
      Map<String, dynamic>? sentBody;
      final api = _fakeApi((req) async {
        sentBody = jsonDecode(req.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'items': [],
            'customers': [],
            'transactions': [],
            'settings': null,
            'users': [],
            'syncedAt': '2025-06-01T12:00:00.000Z',
          }),
          200,
        );
      });

      final ds = RemoteSyncDatasource(api);
      await ds.pull(deviceId: 'dev-1');

      expect(sentBody!['since'], isNull);
    });

    test('pull handles transactions with payments', () async {
      final api = _fakeApi(
        (req) async => http.Response(
          jsonEncode({
            'items': [],
            'customers': [],
            'transactions': [
              {
                'id': 1,
                'invoiceNumber': 'INV-001',
                'invoiceJson':
                    '{"version":1,"status":"processed","items":[{"quantity":2,"item":{"type":"trade","sku":"W-001","label":"Widget","unitPriceSubunits":"1500"}}]}',
                'status': 'completed',
                'createdAt': '2025-06-01T10:00:00.000Z',
                'customerId': null,
                'payments': [
                  {'method': 'cash', 'amountSubunits': 3000},
                ],
              },
            ],
            'settings': null,
            'users': [],
            'syncedAt': '2025-06-01T12:00:00.000Z',
          }),
          200,
        ),
      );

      final ds = RemoteSyncDatasource(api);
      final payload = await ds.pull(deviceId: 'dev-1');

      expect(payload.transactions, hasLength(1));
      final txn = payload.transactions.first;
      expect(txn.invoiceNumber, 'INV-001');
      expect(txn.invoice.items, hasLength(1));
      expect(txn.invoice.items.first.quantity, 2);
      expect(txn.invoice.items.first.item.sku, 'W-001');
      expect(txn.payments, hasLength(1));
      expect(txn.payments.first.amount, Price(BigInt.from(3000)));
    });
  });
}
