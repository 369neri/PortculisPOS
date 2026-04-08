import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../db/database.dart';
import '../helpers.dart';

/// Sync endpoints for push/pull replication.
///
/// The sync model is master-replica:
/// - Primary device pushes catalog, settings, users (server wins on conflict)
/// - Register devices push transactions, cash drawer sessions (client wins)
/// - All devices pull everything since their last sync timestamp
Router syncRouter(Database db) {
  final router = Router();

  /// POST /api/sync/push — push local changes to server
  ///
  /// Body: {
  ///   deviceId: String,
  ///   items: [...],
  ///   customers: [...],
  ///   transactions: [...],
  ///   cashDrawerSessions: [...],
  ///   cashMovements: [...],
  ///   settings: {...} (optional, primary device only)
  /// }
  router.post('/push', (Request request) async {
    final body = await readJson(request);
    if (body == null) return badRequest('Invalid JSON body');

    final tid = tenantId(request);
    final deviceId = body['deviceId'] as String? ?? 'unknown';
    final counts = <String, int>{};

    // Upsert items.
    final items = body['items'] as List? ?? [];
    for (final item in items) {
      final m = item as Map<String, dynamic>;
      await db.pool.execute(
        Sql.named('''
          INSERT INTO items (tenant_id, sku, label, unit_price_subunits, type, gtin,
            category, stock_quantity, is_favorite, image_path, item_tax_rate, updated_at)
          VALUES (@tid, @sku, @label, @price, @type, @gtin,
            @category, @stock, @fav, @img, @tax, NOW())
          ON CONFLICT (tenant_id, sku) DO UPDATE SET
            label = EXCLUDED.label,
            unit_price_subunits = EXCLUDED.unit_price_subunits,
            type = EXCLUDED.type,
            gtin = EXCLUDED.gtin,
            category = EXCLUDED.category,
            stock_quantity = EXCLUDED.stock_quantity,
            is_favorite = EXCLUDED.is_favorite,
            image_path = EXCLUDED.image_path,
            item_tax_rate = EXCLUDED.item_tax_rate,
            updated_at = NOW()
        '''),
        parameters: {
          'tid': tid,
          'sku': m['sku'],
          'label': m['label'],
          'price': m['unitPriceSubunits'] ?? 0,
          'type': m['type'] ?? 'trade',
          'gtin': m['gtin'],
          'category': m['category'] ?? '',
          'stock': m['stockQuantity'] ?? -1,
          'fav': m['isFavorite'] ?? false,
          'img': m['imagePath'],
          'tax': m['itemTaxRate'],
        },
      );
    }
    counts['items'] = items.length;

    // Upsert customers.
    final customers = body['customers'] as List? ?? [];
    for (final c in customers) {
      final m = c as Map<String, dynamic>;
      if (m['id'] != null) {
        // Try update first.
        final updated = await db.pool.execute(
          Sql.named('''
            UPDATE customers SET
              name = @name, phone = @phone, email = @email, notes = @notes, updated_at = NOW()
            WHERE id = @id AND tenant_id = @tid
            RETURNING id
          '''),
          parameters: {
            'id': m['id'],
            'tid': tid,
            'name': m['name'],
            'phone': m['phone'] ?? '',
            'email': m['email'] ?? '',
            'notes': m['notes'] ?? '',
          },
        );
        if (updated.isEmpty) {
          // Insert if update didn't match.
          await db.pool.execute(
            Sql.named('''
              INSERT INTO customers (tenant_id, name, phone, email, notes)
              VALUES (@tid, @name, @phone, @email, @notes)
            '''),
            parameters: {
              'tid': tid,
              'name': m['name'],
              'phone': m['phone'] ?? '',
              'email': m['email'] ?? '',
              'notes': m['notes'] ?? '',
            },
          );
        }
      } else {
        await db.pool.execute(
          Sql.named('''
            INSERT INTO customers (tenant_id, name, phone, email, notes)
            VALUES (@tid, @name, @phone, @email, @notes)
          '''),
          parameters: {
            'tid': tid,
            'name': m['name'],
            'phone': m['phone'] ?? '',
            'email': m['email'] ?? '',
            'notes': m['notes'] ?? '',
          },
        );
      }
    }
    counts['customers'] = customers.length;

    // Insert transactions (client wins — if invoice_number already exists, skip).
    final transactions = body['transactions'] as List? ?? [];
    for (final t in transactions) {
      final m = t as Map<String, dynamic>;
      final invoiceNumber = m['invoiceNumber'] as String?;

      // Check for duplicate by invoice number.
      if (invoiceNumber != null) {
        final existing = await db.pool.execute(
          Sql.named('''
            SELECT id FROM transactions
            WHERE tenant_id = @tid AND invoice_number = @inv
          '''),
          parameters: {'tid': tid, 'inv': invoiceNumber},
        );
        if (existing.isNotEmpty) continue; // Already synced.
      }

      final invoiceJson = m['invoiceJson'] as String?;
      if (invoiceJson == null) continue;

      // Validate JSON
      try {
        jsonDecode(invoiceJson);
      } catch (_) {
        continue;
      }

      final txnResult = await db.pool.execute(
        Sql.named('''
          INSERT INTO transactions (tenant_id, invoice_number, invoice_json, status, created_at, customer_id, device_id, synced_at)
          VALUES (@tid, @inv, @json, @status, @created, @cid, @did, NOW())
          RETURNING id
        '''),
        parameters: {
          'tid': tid,
          'inv': invoiceNumber,
          'json': invoiceJson,
          'status': m['status'] ?? 'completed',
          'created': m['createdAt'] != null
              ? DateTime.parse(m['createdAt'] as String).toUtc()
              : DateTime.now().toUtc(),
          'cid': m['customerId'],
          'did': deviceId,
        },
      );
      final txnId = txnResult.first.first! as int;

      // Insert payments.
      final payments = m['payments'] as List? ?? [];
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

      // Insert refunds if present.
      final refunds = m['refunds'] as List? ?? [];
      for (final r in refunds) {
        final rm = r as Map<String, dynamic>;
        await db.pool.execute(
          Sql.named('''
            INSERT INTO refunds (original_transaction_id, line_index, quantity, amount_subunits, reason)
            VALUES (@txn, @idx, @qty, @amt, @reason)
          '''),
          parameters: {
            'txn': txnId,
            'idx': rm['lineIndex'],
            'qty': rm['quantity'],
            'amt': rm['amountSubunits'],
            'reason': rm['reason'] ?? '',
          },
        );
      }
    }
    counts['transactions'] = transactions.length;

    // Sync cash drawer sessions.
    final sessions = body['cashDrawerSessions'] as List? ?? [];
    for (final s in sessions) {
      final m = s as Map<String, dynamic>;
      await db.pool.execute(
        Sql.named('''
          INSERT INTO cash_drawer_sessions (tenant_id, device_id, opened_at, closed_at,
            opening_balance_subunits, closing_balance_subunits, notes, synced_at)
          VALUES (@tid, @did, @opened, @closed, @opening, @closing, @notes, NOW())
        '''),
        parameters: {
          'tid': tid,
          'did': deviceId,
          'opened': DateTime.parse(m['openedAt'] as String).toUtc(),
          'closed': m['closedAt'] != null
              ? DateTime.parse(m['closedAt'] as String).toUtc()
              : null,
          'opening': m['openingBalanceSubunits'] ?? 0,
          'closing': m['closingBalanceSubunits'],
          'notes': m['notes'],
        },
      );
    }
    counts['cashDrawerSessions'] = sessions.length;

    // Update settings if provided (primary device only).
    final settings = body['settings'] as Map<String, dynamic>?;
    if (settings != null && userRole(request) == 'admin') {
      await db.pool.execute(
        Sql.named('''
          UPDATE settings SET
            business_name = COALESCE(@bname, business_name),
            tax_rate = COALESCE(@tax, tax_rate),
            currency_symbol = COALESCE(@curr, currency_symbol),
            receipt_footer = COALESCE(@footer, receipt_footer),
            theme_mode = COALESCE(@theme, theme_mode),
            printer_type = COALESCE(@ptype, printer_type),
            printer_address = COALESCE(@paddr, printer_address),
            tax_inclusive = COALESCE(@taxincl, tax_inclusive),
            updated_at = NOW()
          WHERE tenant_id = @tid
        '''),
        parameters: {
          'tid': tid,
          'bname': settings['businessName'],
          'tax': settings['taxRate'],
          'curr': settings['currencySymbol'],
          'footer': settings['receiptFooter'],
          'theme': settings['themeMode'],
          'ptype': settings['printerType'],
          'paddr': settings['printerAddress'],
          'taxincl': settings['taxInclusive'],
        },
      );
    }

    return jsonResponse({
      'synced': counts,
      'syncedAt': DateTime.now().toUtc().toIso8601String(),
    });
  });

  /// POST /api/sync/pull — pull changes since last sync
  ///
  /// Body: { since: ISO8601 timestamp (null for full pull), deviceId: String }
  router.post('/pull', (Request request) async {
    final body = await readJson(request);
    if (body == null) return badRequest('Invalid JSON body');

    final tid = tenantId(request);
    final since = body['since'] != null
        ? DateTime.parse(body['since'] as String).toUtc()
        : DateTime.utc(2000);

    // Pull items updated since.
    final itemsResult = await db.pool.execute(
      Sql.named('''
        SELECT * FROM items WHERE tenant_id = @tid AND updated_at > @since
        ORDER BY id
      '''),
      parameters: {'tid': tid, 'since': since},
    );

    // Pull customers updated since.
    final customersResult = await db.pool.execute(
      Sql.named('''
        SELECT * FROM customers WHERE tenant_id = @tid AND updated_at > @since
        ORDER BY id
      '''),
      parameters: {'tid': tid, 'since': since},
    );

    // Pull transactions created since.
    final txnsResult = await db.pool.execute(
      Sql.named('''
        SELECT t.*, array_agg(
          json_build_object('method', p.method, 'amountSubunits', p.amount_subunits)
        ) FILTER (WHERE p.id IS NOT NULL) AS payments_json
        FROM transactions t
        LEFT JOIN payments p ON p.transaction_id = t.id
        WHERE t.tenant_id = @tid AND t.created_at > @since
        GROUP BY t.id ORDER BY t.id
      '''),
      parameters: {'tid': tid, 'since': since},
    );

    // Pull settings.
    final settingsResult = await db.pool.execute(
      Sql.named('SELECT * FROM settings WHERE tenant_id = @tid'),
      parameters: {'tid': tid},
    );

    // Pull users (without pins).
    final usersResult = await db.pool.execute(
      Sql.named('''
        SELECT id, username, display_name, role, is_active, created_at
        FROM users WHERE tenant_id = @tid ORDER BY id
      '''),
      parameters: {'tid': tid},
    );

    return jsonResponse({
      'items': itemsResult.map((r) {
        final s = r.toColumnMap();
        return {
          'id': s['id'],
          'sku': s['sku'],
          'label': s['label'],
          'unitPriceSubunits': s['unit_price_subunits'],
          'type': s['type'],
          'gtin': s['gtin'],
          'category': s['category'],
          'stockQuantity': s['stock_quantity'],
          'isFavorite': s['is_favorite'],
          'imagePath': s['image_path'],
          'itemTaxRate': s['item_tax_rate'],
          'updatedAt': (s['updated_at'] as DateTime?)?.toIso8601String(),
        };
      }).toList(),
      'customers': customersResult.map((r) {
        final s = r.toColumnMap();
        return {
          'id': s['id'],
          'name': s['name'],
          'phone': s['phone'],
          'email': s['email'],
          'notes': s['notes'],
          'createdAt': (s['created_at'] as DateTime?)?.toIso8601String(),
          'updatedAt': (s['updated_at'] as DateTime?)?.toIso8601String(),
        };
      }).toList(),
      'transactions': txnsResult.map((r) {
        final s = r.toColumnMap();
        List<Map<String, dynamic>>? payments;
        final pRaw = s['payments_json'];
        if (pRaw is List) {
          payments = pRaw.map((e) {
            if (e is Map<String, dynamic>) return e;
            if (e is String) return jsonDecode(e) as Map<String, dynamic>;
            return <String, dynamic>{};
          }).toList();
        }
        return {
          'id': s['id'],
          'invoiceNumber': s['invoice_number'],
          'invoiceJson': s['invoice_json'],
          'status': s['status'],
          'createdAt': (s['created_at'] as DateTime?)?.toIso8601String(),
          'customerId': s['customer_id'],
          'deviceId': s['device_id'],
          'payments': payments ?? [],
        };
      }).toList(),
      'settings': settingsResult.isNotEmpty
          ? () {
              final s = settingsResult.first.toColumnMap();
              return {
                'businessName': s['business_name'],
                'taxRate': s['tax_rate'],
                'currencySymbol': s['currency_symbol'],
                'receiptFooter': s['receipt_footer'],
                'themeMode': s['theme_mode'],
                'taxInclusive': s['tax_inclusive'],
                'updatedAt':
                    (s['updated_at'] as DateTime?)?.toIso8601String(),
              };
            }()
          : null,
      'users': usersResult.map((r) => {
            'id': r[0],
            'username': r[1],
            'displayName': r[2],
            'role': r[3],
            'isActive': r[4],
            'createdAt': (r[5] as DateTime).toIso8601String(),
          }).toList(),
      'syncedAt': DateTime.now().toUtc().toIso8601String(),
    });
  });

  return router;
}
