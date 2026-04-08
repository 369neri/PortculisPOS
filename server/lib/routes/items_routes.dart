import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../db/database.dart';
import '../helpers.dart';

Router itemsRouter(Database db) {
  final router = Router();

  /// GET /api/items
  router.get('/', (Request request) async {
    final tid = tenantId(request);
    final result = await db.pool.execute(
      Sql.named('SELECT * FROM items WHERE tenant_id = @tid ORDER BY label'),
      parameters: {'tid': tid},
    );
    return jsonResponse(result.map(_rowToMap).toList());
  });

  /// GET /api/items/<id>
  router.get('/<id>', (Request request) async {
    final id = int.tryParse(request.params['id']!);
    if (id == null) return badRequest('Invalid item ID');

    final result = await db.pool.execute(
      Sql.named('SELECT * FROM items WHERE id = @id AND tenant_id = @tid'),
      parameters: {'id': id, 'tid': tenantId(request)},
    );
    if (result.isEmpty) return notFound('Item not found');
    return jsonResponse(_rowToMap(result.first));
  });

  /// POST /api/items
  router.post('/', (Request request) async {
    final body = await readJson(request);
    if (body == null) return badRequest('Invalid JSON body');

    final tid = tenantId(request);
    final sku = body['sku'] as String?;
    final label = body['label'] as String?;
    if (sku == null || label == null) {
      return badRequest('Missing required fields: sku, label');
    }

    try {
      final result = await db.pool.execute(
        Sql.named('''
          INSERT INTO items (tenant_id, sku, label, unit_price_subunits, type, gtin,
            category, stock_quantity, is_favorite, image_path, item_tax_rate)
          VALUES (@tid, @sku, @label, @price, @type, @gtin,
            @category, @stock, @fav, @img, @tax)
          RETURNING *
        '''),
        parameters: {
          'tid': tid,
          'sku': sku,
          'label': label,
          'price': body['unitPriceSubunits'] ?? 0,
          'type': body['type'] ?? 'trade',
          'gtin': body['gtin'],
          'category': body['category'] ?? '',
          'stock': body['stockQuantity'] ?? -1,
          'fav': body['isFavorite'] ?? false,
          'img': body['imagePath'],
          'tax': body['itemTaxRate'],
        },
      );
      return jsonResponse(_rowToMap(result.first), status: 201);
    } on ServerException catch (e) {
      if (e.toString().contains('unique') || e.toString().contains('duplicate')) {
        return badRequest('SKU already exists');
      }
      rethrow;
    }
  });

  /// PUT /api/items/<id> — full upsert by ID
  router.put('/<id>', (Request request) async {
    final id = int.tryParse(request.params['id']!);
    if (id == null) return badRequest('Invalid item ID');

    final body = await readJson(request);
    if (body == null) return badRequest('Invalid JSON body');

    final tid = tenantId(request);
    final result = await db.pool.execute(
      Sql.named('''
        UPDATE items SET
          sku = COALESCE(@sku, sku),
          label = COALESCE(@label, label),
          unit_price_subunits = COALESCE(@price, unit_price_subunits),
          type = COALESCE(@type, type),
          gtin = @gtin,
          category = COALESCE(@category, category),
          stock_quantity = COALESCE(@stock, stock_quantity),
          is_favorite = COALESCE(@fav, is_favorite),
          image_path = @img,
          item_tax_rate = @tax,
          updated_at = NOW()
        WHERE id = @id AND tenant_id = @tid
        RETURNING *
      '''),
      parameters: {
        'id': id,
        'tid': tid,
        'sku': body['sku'],
        'label': body['label'],
        'price': body['unitPriceSubunits'],
        'type': body['type'],
        'gtin': body['gtin'],
        'category': body['category'],
        'stock': body['stockQuantity'],
        'fav': body['isFavorite'],
        'img': body['imagePath'],
        'tax': body['itemTaxRate'],
      },
    );
    if (result.isEmpty) return notFound('Item not found');
    return jsonResponse(_rowToMap(result.first));
  });

  /// DELETE /api/items/<id>
  router.delete('/<id>', (Request request) async {
    final id = int.tryParse(request.params['id']!);
    if (id == null) return badRequest('Invalid item ID');

    await db.pool.execute(
      Sql.named('DELETE FROM items WHERE id = @id AND tenant_id = @tid'),
      parameters: {'id': id, 'tid': tenantId(request)},
    );
    return jsonResponse({'deleted': true});
  });

  /// PATCH /api/items/<id>/stock — adjust stock
  router.patch('/<id>/stock', (Request request) async {
    final id = int.tryParse(request.params['id']!);
    if (id == null) return badRequest('Invalid item ID');

    final body = await readJson(request);
    if (body == null) return badRequest('Invalid JSON body');
    final delta = body['delta'] as int?;
    if (delta == null) return badRequest('Missing delta');

    final result = await db.pool.execute(
      Sql.named('''
        UPDATE items SET stock_quantity = stock_quantity + @delta, updated_at = NOW()
        WHERE id = @id AND tenant_id = @tid AND stock_quantity >= 0
        RETURNING *
      '''),
      parameters: {'id': id, 'tid': tenantId(request), 'delta': delta},
    );
    if (result.isEmpty) return notFound('Item not found or stock not tracked');
    return jsonResponse(_rowToMap(result.first));
  });

  return router;
}

Map<String, dynamic> _rowToMap(ResultRow row) {
  final schema = row.toColumnMap();
  return {
    'id': schema['id'],
    'sku': schema['sku'],
    'label': schema['label'],
    'unitPriceSubunits': schema['unit_price_subunits'],
    'type': schema['type'],
    'gtin': schema['gtin'],
    'category': schema['category'],
    'stockQuantity': schema['stock_quantity'],
    'isFavorite': schema['is_favorite'],
    'imagePath': schema['image_path'],
    'itemTaxRate': schema['item_tax_rate'],
    'updatedAt': (schema['updated_at'] as DateTime?)?.toIso8601String(),
  };
}
