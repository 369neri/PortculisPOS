import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../db/database.dart';
import '../helpers.dart';

Router customersRouter(Database db) {
  final router = Router();

  /// GET /api/customers
  router.get('/', (Request request) async {
    final tid = tenantId(request);
    final query = request.requestedUri.queryParameters['q'];

    String sql;
    Map<String, dynamic> params;

    if (query != null && query.isNotEmpty) {
      sql = '''
        SELECT * FROM customers
        WHERE tenant_id = @tid AND (
          name ILIKE @q OR phone ILIKE @q OR email ILIKE @q
        )
        ORDER BY name
      ''';
      params = {'tid': tid, 'q': '%$query%'};
    } else {
      sql = 'SELECT * FROM customers WHERE tenant_id = @tid ORDER BY name';
      params = {'tid': tid};
    }

    final result = await db.pool.execute(Sql.named(sql), parameters: params);
    return jsonResponse(result.map(_rowToMap).toList());
  });

  /// GET /api/customers/<id>
  router.get('/<id>', (Request request) async {
    final id = int.tryParse(request.params['id']!);
    if (id == null) return badRequest('Invalid customer ID');

    final result = await db.pool.execute(
      Sql.named('SELECT * FROM customers WHERE id = @id AND tenant_id = @tid'),
      parameters: {'id': id, 'tid': tenantId(request)},
    );
    if (result.isEmpty) return notFound('Customer not found');
    return jsonResponse(_rowToMap(result.first));
  });

  /// POST /api/customers
  router.post('/', (Request request) async {
    final body = await readJson(request);
    if (body == null) return badRequest('Invalid JSON body');

    final name = body['name'] as String?;
    if (name == null || name.isEmpty) return badRequest('Missing name');

    final result = await db.pool.execute(
      Sql.named('''
        INSERT INTO customers (tenant_id, name, phone, email, notes)
        VALUES (@tid, @name, @phone, @email, @notes)
        RETURNING *
      '''),
      parameters: {
        'tid': tenantId(request),
        'name': name,
        'phone': body['phone'] ?? '',
        'email': body['email'] ?? '',
        'notes': body['notes'] ?? '',
      },
    );
    return jsonResponse(_rowToMap(result.first), status: 201);
  });

  /// PUT /api/customers/<id>
  router.put('/<id>', (Request request) async {
    final id = int.tryParse(request.params['id']!);
    if (id == null) return badRequest('Invalid customer ID');

    final body = await readJson(request);
    if (body == null) return badRequest('Invalid JSON body');

    final result = await db.pool.execute(
      Sql.named('''
        UPDATE customers SET
          name = COALESCE(@name, name),
          phone = COALESCE(@phone, phone),
          email = COALESCE(@email, email),
          notes = COALESCE(@notes, notes),
          updated_at = NOW()
        WHERE id = @id AND tenant_id = @tid
        RETURNING *
      '''),
      parameters: {
        'id': id,
        'tid': tenantId(request),
        'name': body['name'],
        'phone': body['phone'],
        'email': body['email'],
        'notes': body['notes'],
      },
    );
    if (result.isEmpty) return notFound('Customer not found');
    return jsonResponse(_rowToMap(result.first));
  });

  /// DELETE /api/customers/<id>
  router.delete('/<id>', (Request request) async {
    final id = int.tryParse(request.params['id']!);
    if (id == null) return badRequest('Invalid customer ID');

    await db.pool.execute(
      Sql.named('DELETE FROM customers WHERE id = @id AND tenant_id = @tid'),
      parameters: {'id': id, 'tid': tenantId(request)},
    );
    return jsonResponse({'deleted': true});
  });

  return router;
}

Map<String, dynamic> _rowToMap(ResultRow row) {
  final schema = row.toColumnMap();
  return {
    'id': schema['id'],
    'name': schema['name'],
    'phone': schema['phone'],
    'email': schema['email'],
    'notes': schema['notes'],
    'createdAt': (schema['created_at'] as DateTime?)?.toIso8601String(),
    'updatedAt': (schema['updated_at'] as DateTime?)?.toIso8601String(),
  };
}
