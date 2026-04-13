import 'dart:convert';

import 'package:cashier_app/core/network/api_client.dart';
import 'package:cashier_app/features/checkout/data/datasources/remote_transaction_datasource.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/refund_line_item.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
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

/// Minimal JSON for a transaction as returned by the server.
Map<String, dynamic> _txJson({
  int id = 1,
  String status = 'completed',
  String? invoiceJson,
}) =>
    {
      'id': id,
      'invoiceNumber': 'INV-001',
      'status': status,
      'createdAt': '2025-06-01T12:00:00.000Z',
      'customerId': null,
      'invoiceJson': invoiceJson ??
          jsonEncode({
            'version': 1,
            'status': 'processed',
            'items': [
              {
                'quantity': 2,
                'item': {
                  'type': 'trade',
                  'sku': 'A1',
                  'label': 'Widget',
                  'unitPriceSubunits': '1500',
                  'gtin': null,
                },
              },
            ],
          }),
      'payments': [
        {'method': 'cash', 'amountSubunits': 3000},
      ],
    };

void main() {
  group('RemoteTransactionDatasource', () {
    test('getAll parses transaction list', () async {
      final api = _fakeApi(
        (req) async => http.Response(
          jsonEncode({
            'transactions': [_txJson(), _txJson(id: 2)],
          }),
          200,
        ),
      );
      final ds = RemoteTransactionDatasource(api);
      final txns = await ds.getAll();

      expect(txns, hasLength(2));
      expect(txns[0].id, 1);
      expect(txns[0].invoiceNumber, 'INV-001');
      expect(txns[0].status, TransactionStatus.completed);
      expect(txns[0].payments, hasLength(1));
      expect(txns[0].payments.first.method, PaymentMethod.cash);
      expect(txns[0].payments.first.amount, Price(BigInt.from(3000)));
    });

    test('getAll decodes invoice items', () async {
      final api = _fakeApi(
        (req) async => http.Response(
          jsonEncode({'transactions': [_txJson()]}),
          200,
        ),
      );
      final ds = RemoteTransactionDatasource(api);
      final txns = await ds.getAll();
      final items = txns[0].invoice.items;

      expect(items, hasLength(1));
      expect(items[0].quantity, 2);
      expect(items[0].item, isA<TradeItem>());
      expect(items[0].item.sku, 'A1');
      expect(items[0].item.unitPrice, Price(BigInt.from(1500)));
    });

    test('getPage passes limit and offset query params', () async {
      http.Request? captured;
      final api = _fakeApi((req) async {
        captured = req;
        return http.Response(
          jsonEncode({'transactions': <dynamic>[]}),
          200,
        );
      });
      final ds = RemoteTransactionDatasource(api);
      await ds.getPage(10, 20);

      expect(captured!.url.queryParameters['limit'], '10');
      expect(captured!.url.queryParameters['offset'], '20');
    });

    test('findById returns transaction', () async {
      final api = _fakeApi(
        (req) async => http.Response(jsonEncode(_txJson(id: 5)), 200),
      );
      final ds = RemoteTransactionDatasource(api);
      final tx = await ds.findById(5);

      expect(tx, isNotNull);
      expect(tx!.id, 5);
    });

    test('findById returns null on 404', () async {
      final api = _fakeApi(
        (req) async =>
            http.Response(jsonEncode({'error': 'not found'}), 404),
      );
      final ds = RemoteTransactionDatasource(api);
      final tx = await ds.findById(99);
      expect(tx, isNull);
    });

    test('save posts and returns id', () async {
      http.Request? captured;
      final api = _fakeApi((req) async {
        captured = req;
        if (req.method == 'GET') {
          return http.Response(
            jsonEncode({'transactions': [_txJson()]}),
            200,
          );
        }
        return http.Response(jsonEncode({'id': 10}), 200);
      });
      final ds = RemoteTransactionDatasource(api);
      final existing = (await ds.getAll()).first;

      final id = await ds.save(existing);
      expect(id, 10);
      expect(captured!.method, 'POST');
    });

    test('voidTransaction sends PATCH', () async {
      http.Request? captured;
      final api = _fakeApi((req) async {
        captured = req;
        return http.Response(jsonEncode({}), 200);
      });
      final ds = RemoteTransactionDatasource(api);
      await ds.voidTransaction(3);

      expect(captured!.method, 'PATCH');
      expect(captured!.url.path, '/api/transactions/3/void');
    });

    test('partialRefund posts refund items', () async {
      http.Request? captured;
      final api = _fakeApi((req) async {
        captured = req;
        return http.Response(jsonEncode({}), 200);
      });
      final ds = RemoteTransactionDatasource(api);
      await ds.partialRefund(1, [
        const RefundLineItem(
          lineIndex: 0,
          quantity: 1,
          amountSubunits: 1500,
          reason: 'Defective',
        ),
      ]);

      expect(captured!.method, 'POST');
      expect(captured!.url.path, '/api/transactions/1/refund');
      final body = jsonDecode(captured!.body) as Map<String, dynamic>;
      final items = body['items'] as List;
      expect(items, hasLength(1));
      expect((items[0] as Map)['reason'], 'Defective');
    });

    test('getRefunds parses refund list', () async {
      final api = _fakeApi(
        (req) async => http.Response(
          jsonEncode({
            ..._txJson(),
            'refunds': [
              {
                'lineIndex': 0,
                'quantity': 1,
                'amountSubunits': 1500,
                'reason': 'Wrong item',
              },
            ],
          }),
          200,
        ),
      );
      final ds = RemoteTransactionDatasource(api);
      final refunds = await ds.getRefunds(1);

      expect(refunds, hasLength(1));
      expect(refunds[0].lineIndex, 0);
      expect(refunds[0].reason, 'Wrong item');
    });

    test('decodes service and keyed items', () async {
      final invoice = jsonEncode({
        'version': 1,
        'status': 'processed',
        'items': [
          {
            'quantity': 1,
            'item': {
              'type': 'service',
              'sku': 'SVC',
              'label': 'Repair',
              'unitPriceSubunits': '5000',
            },
          },
          {
            'quantity': 1,
            'item': {
              'type': 'keyed',
              'unitPriceSubunits': '999',
            },
          },
        ],
      });
      final api = _fakeApi(
        (req) async => http.Response(
          jsonEncode({
            'transactions': [_txJson(invoiceJson: invoice)],
          }),
          200,
        ),
      );
      final ds = RemoteTransactionDatasource(api);
      final items = (await ds.getAll()).first.invoice.items;

      expect(items[0].item, isA<ServiceItem>());
      expect(items[0].item.label, 'Repair');
      expect(items[1].item, isA<KeyedPriceItem>());
      expect(items[1].item.unitPrice, Price(BigInt.from(999)));
    });
  });
}
