import 'dart:convert';

import 'package:cashier_app/core/network/api_client.dart';
import 'package:cashier_app/features/cash_drawer/data/datasources/remote_cash_drawer_datasource.dart';
import 'package:cashier_app/features/cash_drawer/domain/entities/cash_drawer_session.dart';
import 'package:cashier_app/features/cash_drawer/domain/entities/cash_movement.dart';
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
  group('RemoteCashDrawerDatasource', () {
    test('openSession posts opening balance and returns id', () async {
      http.Request? captured;
      final api = _fakeApi((req) async {
        captured = req;
        return http.Response(jsonEncode({'id': 42}), 200);
      });
      final ds = RemoteCashDrawerDatasource(api);
      final session = CashDrawerSession(
        openedAt: DateTime(2025),
        openingBalance: Price(BigInt.from(5000)),
      );
      final id = await ds.openSession(session);

      expect(id, 42);
      final body = jsonDecode(captured!.body) as Map<String, dynamic>;
      expect(body['openingBalanceSubunits'], 5000);
    });

    test('closeSession sends PATCH', () async {
      http.Request? captured;
      final api = _fakeApi((req) async {
        captured = req;
        return http.Response(jsonEncode({}), 200);
      });
      final ds = RemoteCashDrawerDatasource(api);
      final session = CashDrawerSession(
        openedAt: DateTime(2025),
        openingBalance: Price(BigInt.from(5000)),
        closingBalance: Price(BigInt.from(7500)),
        notes: 'Good day',
      );
      await ds.closeSession(42, session);

      expect(captured!.method, 'PATCH');
      expect(captured!.url.path, '/api/cash-drawer/sessions/42/close');
      final body = jsonDecode(captured!.body) as Map<String, dynamic>;
      expect(body['closingBalanceSubunits'], 7500);
      expect(body['notes'], 'Good day');
    });

    test('getActiveSession parses response', () async {
      final api = _fakeApi(
        (req) async => http.Response(
          jsonEncode({
            'id': 1,
            'openedAt': '2025-06-01T08:00:00.000Z',
            'closedAt': null,
            'openingBalanceSubunits': 10000,
            'closingBalanceSubunits': null,
            'notes': null,
          }),
          200,
        ),
      );
      final ds = RemoteCashDrawerDatasource(api);
      final session = await ds.getActiveSession();

      expect(session, isNotNull);
      expect(session!.id, 1);
      expect(session.openingBalance, Price(BigInt.from(10000)));
      expect(session.isOpen, isTrue);
    });

    test('getActiveSession returns null on 404', () async {
      final api = _fakeApi(
        (req) async => http.Response(
          jsonEncode({'error': 'not found'}),
          404,
        ),
      );
      final ds = RemoteCashDrawerDatasource(api);
      final session = await ds.getActiveSession();
      expect(session, isNull);
    });

    test('getAllSessions parses list', () async {
      final api = _fakeApi(
        (req) async => http.Response(
          jsonEncode({
            'sessions': [
              {
                'id': 1,
                'openedAt': '2025-06-01T08:00:00.000Z',
                'openingBalanceSubunits': 5000,
              },
              {
                'id': 2,
                'openedAt': '2025-06-02T08:00:00.000Z',
                'openingBalanceSubunits': 6000,
                'closedAt': '2025-06-02T18:00:00.000Z',
                'closingBalanceSubunits': 9000,
              },
            ],
          }),
          200,
        ),
      );
      final ds = RemoteCashDrawerDatasource(api);
      final sessions = await ds.getAllSessions();

      expect(sessions, hasLength(2));
      expect(sessions[0].isOpen, isTrue);
      expect(sessions[1].isOpen, isFalse);
    });

    test('addMovement posts to correct session endpoint', () async {
      http.Request? captured;
      final api = _fakeApi((req) async {
        captured = req;
        return http.Response(jsonEncode({}), 200);
      });
      final ds = RemoteCashDrawerDatasource(api);
      await ds.addMovement(CashMovement(
        sessionId: 7,
        type: CashMovementType.sale,
        amountSubunits: 1500,
        createdAt: DateTime(2025),
        note: 'Cash sale',
      ));

      expect(
        captured!.url.path,
        '/api/cash-drawer/sessions/7/movements',
      );
      final body = jsonDecode(captured!.body) as Map<String, dynamic>;
      expect(body['type'], 'sale');
      expect(body['amountSubunits'], 1500);
      expect(body['note'], 'Cash sale');
    });

    test('getMovements parses movement list', () async {
      final api = _fakeApi(
        (req) async => http.Response(
          jsonEncode({
            'movements': [
              {
                'id': 1,
                'sessionId': 7,
                'type': 'sale',
                'amountSubunits': 2000,
                'note': '',
                'createdAt': '2025-06-01T10:00:00.000Z',
              },
              {
                'id': 2,
                'sessionId': 7,
                'type': 'refund',
                'amountSubunits': -500,
                'note': 'Return',
                'createdAt': '2025-06-01T11:00:00.000Z',
              },
            ],
          }),
          200,
        ),
      );
      final ds = RemoteCashDrawerDatasource(api);
      final movements = await ds.getMovements(7);

      expect(movements, hasLength(2));
      expect(movements[0].type, CashMovementType.sale);
      expect(movements[0].amountSubunits, 2000);
      expect(movements[1].type, CashMovementType.refund);
      expect(movements[1].note, 'Return');
    });
  });
}
