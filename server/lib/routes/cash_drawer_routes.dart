import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../db/database.dart';
import '../helpers.dart';

Router cashDrawerRouter(Database db) {
  final router = Router();

  /// GET /api/cash-drawer/sessions
  router.get('/sessions', (Request request) async {
    final tid = tenantId(request);
    final result = await db.pool.execute(
      Sql.named('''
        SELECT * FROM cash_drawer_sessions
        WHERE tenant_id = @tid ORDER BY opened_at DESC
      '''),
      parameters: {'tid': tid},
    );
    return jsonResponse(result.map(_sessionToMap).toList());
  });

  /// GET /api/cash-drawer/sessions/active
  router.get('/sessions/active', (Request request) async {
    final tid = tenantId(request);
    final result = await db.pool.execute(
      Sql.named('''
        SELECT * FROM cash_drawer_sessions
        WHERE tenant_id = @tid AND closed_at IS NULL
        ORDER BY opened_at DESC LIMIT 1
      '''),
      parameters: {'tid': tid},
    );
    if (result.isEmpty) {
      return Response.ok('null', headers: {'content-type': 'application/json'});
    }
    return jsonResponse(_sessionToMap(result.first));
  });

  /// POST /api/cash-drawer/sessions — open a new session
  router.post('/sessions', (Request request) async {
    final body = await readJson(request);
    if (body == null) return badRequest('Invalid JSON body');

    final tid = tenantId(request);
    final result = await db.pool.execute(
      Sql.named('''
        INSERT INTO cash_drawer_sessions (tenant_id, device_id, opened_at, opening_balance_subunits, notes)
        VALUES (@tid, @did, @opened, @balance, @notes)
        RETURNING *
      '''),
      parameters: {
        'tid': tid,
        'did': body['deviceId'],
        'opened': body['openedAt'] != null
            ? DateTime.parse(body['openedAt'] as String).toUtc()
            : DateTime.now().toUtc(),
        'balance': body['openingBalanceSubunits'] ?? 0,
        'notes': body['notes'],
      },
    );
    return jsonResponse(_sessionToMap(result.first), status: 201);
  });

  /// PATCH /api/cash-drawer/sessions/<id>/close
  router.patch('/sessions/<id>/close', (Request request) async {
    final id = int.tryParse(request.params['id']!);
    if (id == null) return badRequest('Invalid session ID');

    final body = await readJson(request);
    if (body == null) return badRequest('Invalid JSON body');

    final result = await db.pool.execute(
      Sql.named('''
        UPDATE cash_drawer_sessions SET
          closed_at = @closed,
          closing_balance_subunits = @balance,
          notes = COALESCE(@notes, notes)
        WHERE id = @id AND tenant_id = @tid AND closed_at IS NULL
        RETURNING *
      '''),
      parameters: {
        'id': id,
        'tid': tenantId(request),
        'closed': body['closedAt'] != null
            ? DateTime.parse(body['closedAt'] as String).toUtc()
            : DateTime.now().toUtc(),
        'balance': body['closingBalanceSubunits'],
        'notes': body['notes'],
      },
    );
    if (result.isEmpty) return notFound('Session not found or already closed');
    return jsonResponse(_sessionToMap(result.first));
  });

  /// GET /api/cash-drawer/sessions/<id>/movements
  router.get('/sessions/<id>/movements', (Request request) async {
    final id = int.tryParse(request.params['id']!);
    if (id == null) return badRequest('Invalid session ID');

    final result = await db.pool.execute(
      Sql.named('''
        SELECT cm.* FROM cash_movements cm
        JOIN cash_drawer_sessions s ON s.id = cm.session_id
        WHERE cm.session_id = @id AND s.tenant_id = @tid
        ORDER BY cm.created_at
      '''),
      parameters: {'id': id, 'tid': tenantId(request)},
    );
    return jsonResponse(result.map(_movementToMap).toList());
  });

  /// POST /api/cash-drawer/sessions/<id>/movements
  router.post('/sessions/<id>/movements', (Request request) async {
    final id = int.tryParse(request.params['id']!);
    if (id == null) return badRequest('Invalid session ID');

    final body = await readJson(request);
    if (body == null) return badRequest('Invalid JSON body');

    final result = await db.pool.execute(
      Sql.named('''
        INSERT INTO cash_movements (session_id, type, amount_subunits, note, created_at)
        SELECT @sid, @type, @amount, @note, @created
        FROM cash_drawer_sessions s
        WHERE s.id = @sid AND s.tenant_id = @tid AND s.closed_at IS NULL
        RETURNING *
      '''),
      parameters: {
        'sid': id,
        'tid': tenantId(request),
        'type': body['type'] ?? 'sale',
        'amount': body['amountSubunits'] ?? 0,
        'note': body['note'] ?? '',
        'created': body['createdAt'] != null
            ? DateTime.parse(body['createdAt'] as String).toUtc()
            : DateTime.now().toUtc(),
      },
    );
    if (result.isEmpty) return notFound('Session not found or is closed');
    return jsonResponse(_movementToMap(result.first), status: 201);
  });

  return router;
}

Map<String, dynamic> _sessionToMap(ResultRow row) {
  final s = row.toColumnMap();
  return {
    'id': s['id'],
    'deviceId': s['device_id'],
    'openedAt': (s['opened_at'] as DateTime?)?.toIso8601String(),
    'closedAt': (s['closed_at'] as DateTime?)?.toIso8601String(),
    'openingBalanceSubunits': s['opening_balance_subunits'],
    'closingBalanceSubunits': s['closing_balance_subunits'],
    'notes': s['notes'],
    'syncedAt': (s['synced_at'] as DateTime?)?.toIso8601String(),
  };
}

Map<String, dynamic> _movementToMap(ResultRow row) {
  final m = row.toColumnMap();
  return {
    'id': m['id'],
    'sessionId': m['session_id'],
    'type': m['type'],
    'amountSubunits': m['amount_subunits'],
    'note': m['note'],
    'createdAt': (m['created_at'] as DateTime?)?.toIso8601String(),
  };
}
