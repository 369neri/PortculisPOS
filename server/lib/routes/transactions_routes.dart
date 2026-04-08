import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../db/database.dart';
import '../helpers.dart';

Router transactionsRouter(Database db) {
  final router = Router();

  /// GET /api/transactions?limit=50&offset=0
  router.get('/', (Request request) async {
    final tid = tenantId(request);
    final limit =
        int.tryParse(request.requestedUri.queryParameters['limit'] ?? '') ?? 50;
    final offset =
        int.tryParse(request.requestedUri.queryParameters['offset'] ?? '') ?? 0;

    final result = await db.pool.execute(
      Sql.named('''
        SELECT t.*, array_agg(
          json_build_object('method', p.method, 'amountSubunits', p.amount_subunits)
        ) FILTER (WHERE p.id IS NOT NULL) AS payments_json
        FROM transactions t
        LEFT JOIN payments p ON p.transaction_id = t.id
        WHERE t.tenant_id = @tid
        GROUP BY t.id
        ORDER BY t.created_at DESC
        LIMIT @limit OFFSET @offset
      '''),
      parameters: {'tid': tid, 'limit': limit, 'offset': offset},
    );
    return jsonResponse(result.map(_txnRowToMap).toList());
  });

  /// GET /api/transactions/<id>
  router.get('/<id>', (Request request) async {
    final id = int.tryParse(request.params['id']!);
    if (id == null) return badRequest('Invalid transaction ID');

    final result = await db.pool.execute(
      Sql.named('''
        SELECT t.*, array_agg(
          json_build_object('method', p.method, 'amountSubunits', p.amount_subunits)
        ) FILTER (WHERE p.id IS NOT NULL) AS payments_json
        FROM transactions t
        LEFT JOIN payments p ON p.transaction_id = t.id
        WHERE t.id = @id AND t.tenant_id = @tid
        GROUP BY t.id
      '''),
      parameters: {'id': id, 'tid': tenantId(request)},
    );
    if (result.isEmpty) return notFound('Transaction not found');

    // Also fetch refunds for this transaction.
    final refunds = await db.pool.execute(
      Sql.named('''
        SELECT line_index, quantity, amount_subunits, reason, created_at
        FROM refunds WHERE original_transaction_id = @id ORDER BY id
      '''),
      parameters: {'id': id},
    );

    final txn = _txnRowToMap(result.first);
    txn['refunds'] = refunds
        .map((r) => {
              'lineIndex': r[0],
              'quantity': r[1],
              'amountSubunits': r[2],
              'reason': r[3],
              'createdAt': (r[4] as DateTime).toIso8601String(),
            })
        .toList();
    return jsonResponse(txn);
  });

  /// POST /api/transactions — create a new transaction
  router.post('/', (Request request) async {
    final body = await readJson(request);
    if (body == null) return badRequest('Invalid JSON body');

    final tid = tenantId(request);
    final invoiceJson = body['invoiceJson'] as String?;
    if (invoiceJson == null) return badRequest('Missing invoiceJson');

    // Validate JSON
    try {
      jsonDecode(invoiceJson);
    } catch (_) {
      return badRequest('invoiceJson is not valid JSON');
    }

    final payments = body['payments'] as List?;
    if (payments == null || payments.isEmpty) {
      return badRequest('At least one payment required');
    }

    final txnResult = await db.pool.execute(
      Sql.named('''
        INSERT INTO transactions (tenant_id, invoice_number, invoice_json, status, created_at, customer_id, device_id)
        VALUES (@tid, @inv, @json, @status, @created, @cid, @did)
        RETURNING id
      '''),
      parameters: {
        'tid': tid,
        'inv': body['invoiceNumber'],
        'json': invoiceJson,
        'status': body['status'] ?? 'completed',
        'created': body['createdAt'] != null
            ? DateTime.parse(body['createdAt'] as String).toUtc()
            : DateTime.now().toUtc(),
        'cid': body['customerId'],
        'did': body['deviceId'],
      },
    );
    final txnId = txnResult.first.first! as int;

    // Insert payments.
    for (final p in payments) {
      final pm = p as Map<String, dynamic>;
      await db.pool.execute(
        Sql.named('''
          INSERT INTO payments (transaction_id, method, amount_subunits)
          VALUES (@tid, @method, @amount)
        '''),
        parameters: {
          'tid': txnId,
          'method': pm['method'],
          'amount': pm['amountSubunits'],
        },
      );
    }

    return jsonResponse({'id': txnId}, status: 201);
  });

  /// PATCH /api/transactions/<id>/void
  router.patch('/<id>/void', (Request request) async {
    final id = int.tryParse(request.params['id']!);
    if (id == null) return badRequest('Invalid transaction ID');

    final result = await db.pool.execute(
      Sql.named('''
        UPDATE transactions SET status = 'voided'
        WHERE id = @id AND tenant_id = @tid AND status = 'completed'
        RETURNING id
      '''),
      parameters: {'id': id, 'tid': tenantId(request)},
    );
    if (result.isEmpty) return notFound('Transaction not found or already voided');
    return jsonResponse({'id': id, 'status': 'voided'});
  });

  /// POST /api/transactions/<id>/refund — partial refund
  router.post('/<id>/refund', (Request request) async {
    final id = int.tryParse(request.params['id']!);
    if (id == null) return badRequest('Invalid transaction ID');

    final body = await readJson(request);
    if (body == null) return badRequest('Invalid JSON body');

    final items = body['items'] as List?;
    if (items == null || items.isEmpty) {
      return badRequest('At least one refund item required');
    }

    final tid = tenantId(request);

    // Verify transaction exists and is completed.
    final check = await db.pool.execute(
      Sql.named('SELECT status FROM transactions WHERE id = @id AND tenant_id = @tid'),
      parameters: {'id': id, 'tid': tid},
    );
    if (check.isEmpty) return notFound('Transaction not found');
    final status = check.first.first as String;
    if (status == 'voided') return badRequest('Cannot refund a voided transaction');

    for (final item in items) {
      final ri = item as Map<String, dynamic>;
      await db.pool.execute(
        Sql.named('''
          INSERT INTO refunds (original_transaction_id, line_index, quantity, amount_subunits, reason)
          VALUES (@txn, @idx, @qty, @amt, @reason)
        '''),
        parameters: {
          'txn': id,
          'idx': ri['lineIndex'],
          'qty': ri['quantity'],
          'amt': ri['amountSubunits'],
          'reason': ri['reason'] ?? '',
        },
      );
    }

    // Mark as refunded.
    await db.pool.execute(
      Sql.named("UPDATE transactions SET status = 'refunded' WHERE id = @id"),
      parameters: {'id': id},
    );

    return jsonResponse({'id': id, 'status': 'refunded'});
  });

  return router;
}

Map<String, dynamic> _txnRowToMap(ResultRow row) {
  final schema = row.toColumnMap();
  // payments_json comes as a PostgreSQL array of jsonb
  List<Map<String, dynamic>>? payments;
  final paymentsRaw = schema['payments_json'];
  if (paymentsRaw != null) {
    if (paymentsRaw is List) {
      payments = paymentsRaw.map((e) {
        if (e is Map<String, dynamic>) return e;
        if (e is String) return jsonDecode(e) as Map<String, dynamic>;
        return <String, dynamic>{};
      }).toList();
    }
  }

  return {
    'id': schema['id'],
    'invoiceNumber': schema['invoice_number'],
    'invoiceJson': schema['invoice_json'],
    'status': schema['status'],
    'createdAt': (schema['created_at'] as DateTime?)?.toIso8601String(),
    'customerId': schema['customer_id'],
    'deviceId': schema['device_id'],
    'syncedAt': (schema['synced_at'] as DateTime?)?.toIso8601String(),
    'payments': payments ?? [],
  };
}
