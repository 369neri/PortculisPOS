import 'dart:convert';

import 'package:cashier_app/core/network/api_client.dart';
import 'package:cashier_app/features/items/data/datasources/remote_item_datasource.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

ApiClient _fakeApi(Future<http.Response> Function(http.Request) handler) =>
    ApiClient(
      baseUrl: 'http://localhost:8080',
      httpClient: MockClient(handler),
    );

void main() {
  group('RemoteItemDatasource', () {
    test('getAll parses trade and service items', () async {
      final api = _fakeApi(
        (req) async => http.Response(
          jsonEncode({
            'items': [
              {
                'id': 1,
                'sku': 'ITEM-001',
                'label': 'Widget',
                'unitPriceSubunits': 1500,
                'type': 'trade',
                'gtin': '1234567890123',
                'category': 'Hardware',
                'stockQuantity': 10,
                'isFavorite': true,
                'imagePath': null,
                'itemTaxRate': 8.5,
              },
              {
                'id': 2,
                'sku': 'SVC-001',
                'label': 'Repair',
                'unitPriceSubunits': 5000,
                'type': 'service',
                'category': 'Services',
                'stockQuantity': -1,
                'isFavorite': false,
                'imagePath': null,
                'itemTaxRate': null,
              },
            ],
          }),
          200,
        ),
      );
      final ds = RemoteItemDatasource(api);
      final items = await ds.getAll();

      expect(items, hasLength(2));
      expect(items[0], isA<TradeItem>());
      expect(items[0].sku, 'ITEM-001');
      expect(items[0].label, 'Widget');
      expect(items[0].unitPrice, Price(BigInt.from(1500)));
      expect((items[0] as TradeItem).gtin, '1234567890123');
      expect(items[0].stockQuantity, 10);
      expect(items[0].isFavorite, true);
      expect(items[0].itemTaxRate, 8.5);

      expect(items[1], isA<ServiceItem>());
      expect(items[1].sku, 'SVC-001');
      expect(items[1].stockQuantity, -1);
    });

    test('findBySku returns matching item', () async {
      final api = _fakeApi(
        (req) async => http.Response(
          jsonEncode({
            'items': [
              {
                'sku': 'A',
                'label': 'A',
                'unitPriceSubunits': 100,
                'type': 'trade',
              },
              {
                'sku': 'B',
                'label': 'B',
                'unitPriceSubunits': 200,
                'type': 'trade',
              },
            ],
          }),
          200,
        ),
      );
      final ds = RemoteItemDatasource(api);
      final item = await ds.findBySku('B');
      expect(item, isNotNull);
      expect(item!.sku, 'B');
    });

    test('findBySku returns null when not found', () async {
      final api = _fakeApi(
        (req) async => http.Response(jsonEncode({'items': []}), 200),
      );
      final ds = RemoteItemDatasource(api);
      expect(await ds.findBySku('MISSING'), isNull);
    });

    test('save sends correct JSON for TradeItem', () async {
      Map<String, dynamic>? sentBody;
      final api = _fakeApi((req) async {
        if (req.method == 'POST') {
          sentBody = jsonDecode(req.body) as Map<String, dynamic>;
          return http.Response(jsonEncode({'id': 1}), 201);
        }
        return http.Response(jsonEncode({'items': []}), 200);
      });
      final ds = RemoteItemDatasource(api);
      await ds.save(
        TradeItem(
          sku: 'T-001',
          label: 'Thing',
          unitPrice: Price(BigInt.zero),
          gtin: '123',
          category: 'Cat',
          stockQuantity: 5,
          isFavorite: true,
        ),
      );
      expect(sentBody, isNotNull);
      expect(sentBody!['sku'], 'T-001');
      expect(sentBody!['type'], 'trade');
      expect(sentBody!['gtin'], '123');
    });

    test('getFavorites filters locally', () async {
      final api = _fakeApi(
        (req) async => http.Response(
          jsonEncode({
            'items': [
              {
                'sku': 'A',
                'label': 'A',
                'unitPriceSubunits': 100,
                'type': 'trade',
                'isFavorite': true,
              },
              {
                'sku': 'B',
                'label': 'B',
                'unitPriceSubunits': 200,
                'type': 'trade',
                'isFavorite': false,
              },
            ],
          }),
          200,
        ),
      );
      final ds = RemoteItemDatasource(api);
      final favs = await ds.getFavorites();
      expect(favs, hasLength(1));
      expect(favs.first.sku, 'A');
    });
  });
}
