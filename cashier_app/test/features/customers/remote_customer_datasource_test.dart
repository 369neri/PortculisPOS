import 'dart:convert';

import 'package:cashier_app/core/network/api_client.dart';
import 'package:cashier_app/features/customers/data/datasources/remote_customer_datasource.dart';
import 'package:cashier_app/features/customers/domain/entities/customer.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

ApiClient _fakeApi(Future<http.Response> Function(http.Request) handler) =>
    ApiClient(
      baseUrl: 'http://localhost:8080',
      httpClient: MockClient(handler),
    );

void main() {
  group('RemoteCustomerDatasource', () {
    test('getAll parses customer list', () async {
      final api = _fakeApi(
        (req) async => http.Response(
          jsonEncode({
            'customers': [
              {
                'id': 1,
                'name': 'Alice',
                'phone': '555-0001',
                'email': 'alice@example.com',
                'notes': 'VIP',
                'createdAt': '2025-01-01T00:00:00.000Z',
              },
              {
                'id': 2,
                'name': 'Bob',
                'phone': '',
                'email': '',
                'notes': '',
              },
            ],
          }),
          200,
        ),
      );
      final ds = RemoteCustomerDatasource(api);
      final customers = await ds.getAll();

      expect(customers, hasLength(2));
      expect(customers[0].name, 'Alice');
      expect(customers[0].phone, '555-0001');
      expect(customers[0].email, 'alice@example.com');
      expect(customers[0].createdAt, isNotNull);
      expect(customers[1].name, 'Bob');
    });

    test('findById returns customer on success', () async {
      final api = _fakeApi(
        (req) async => http.Response(
          jsonEncode({
            'id': 1,
            'name': 'Alice',
            'phone': '',
            'email': '',
            'notes': '',
          }),
          200,
        ),
      );
      final ds = RemoteCustomerDatasource(api);
      final cust = await ds.findById(1);
      expect(cust, isNotNull);
      expect(cust!.name, 'Alice');
    });

    test('findById returns null on 404', () async {
      final api = _fakeApi(
        (req) async =>
            http.Response(jsonEncode({'error': 'Not found'}), 404),
      );
      final ds = RemoteCustomerDatasource(api);
      expect(await ds.findById(999), isNull);
    });

    test('save sends correct JSON and returns id', () async {
      Map<String, dynamic>? sentBody;
      final api = _fakeApi((req) async {
        sentBody = jsonDecode(req.body) as Map<String, dynamic>;
        return http.Response(jsonEncode({'id': 42}), 201);
      });
      final ds = RemoteCustomerDatasource(api);
      final id = await ds.save(
        const Customer(name: 'Charlie', phone: '555-1234'),
      );
      expect(id, 42);
      expect(sentBody!['name'], 'Charlie');
      expect(sentBody!['phone'], '555-1234');
    });

    test('search passes query parameter', () async {
      String? requestedUrl;
      final api = _fakeApi((req) async {
        requestedUrl = req.url.toString();
        return http.Response(jsonEncode({'customers': []}), 200);
      });
      final ds = RemoteCustomerDatasource(api);
      await ds.search('alice');
      expect(requestedUrl, contains('q=alice'));
    });
  });
}
