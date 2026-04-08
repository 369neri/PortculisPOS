import 'dart:convert';
import 'dart:math';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../auth/jwt.dart';
import '../db/database.dart';
import '../helpers.dart';

Router authRouter(Database db, String jwtSecret) {
  final router = Router();

  /// POST /api/auth/register
  /// Creates a new tenant + admin user. Body: {business, username, displayName, pin}
  router.post('/register', (Request request) async {
    final body = await readJson(request);
    if (body == null) return badRequest('Invalid JSON body');

    final business = body['business'] as String?;
    final username = body['username'] as String?;
    final displayName = body['displayName'] as String?;
    final pin = body['pin'] as String?;

    if (business == null || username == null || displayName == null || pin == null) {
      return badRequest('Missing required fields: business, username, displayName, pin');
    }
    if (pin.length < 4) return badRequest('PIN must be at least 4 characters');

    // Create tenant.
    final tenantResult = await db.pool.execute(
      Sql.named('INSERT INTO tenants (name) VALUES (@name) RETURNING id'),
      parameters: {'name': business},
    );
    final tenantIdValue = tenantResult.first.first! as String;

    // Create default settings for tenant.
    await db.pool.execute(
      Sql.named('INSERT INTO settings (tenant_id, business_name) VALUES (@tid, @name)'),
      parameters: {'tid': tenantIdValue, 'name': business},
    );

    // Create admin user.
    final salt = _generateSalt();
    final hashedPin = hashPin(pin, salt);
    final userResult = await db.pool.execute(
      Sql.named('''
        INSERT INTO users (tenant_id, username, display_name, pin, salt, role)
        VALUES (@tid, @username, @display_name, @pin, @salt, 'admin')
        RETURNING id
      '''),
      parameters: {
        'tid': tenantIdValue,
        'username': username,
        'display_name': displayName,
        'pin': hashedPin,
        'salt': salt,
      },
    );
    final userIdValue = userResult.first.first! as int;

    final token = createToken(
      jwtSecret,
      userId: userIdValue,
      tenantId: tenantIdValue,
      username: username,
      role: 'admin',
    );

    return jsonResponse({
      'token': token,
      'user': {
        'id': userIdValue,
        'username': username,
        'displayName': displayName,
        'role': 'admin',
      },
      'tenantId': tenantIdValue,
    }, status: 201);
  });

  /// POST /api/auth/login
  /// Body: {tenantId, username, pin}
  router.post('/login', (Request request) async {
    final body = await readJson(request);
    if (body == null) return badRequest('Invalid JSON body');

    final tid = body['tenantId'] as String?;
    final username = body['username'] as String?;
    final pin = body['pin'] as String?;

    if (tid == null || username == null || pin == null) {
      return badRequest('Missing required fields: tenantId, username, pin');
    }

    final result = await db.pool.execute(
      Sql.named('''
        SELECT id, display_name, pin, salt, role, is_active, failed_attempts, locked_until
        FROM users WHERE tenant_id = @tid AND username = @username
      '''),
      parameters: {'tid': tid, 'username': username},
    );

    if (result.isEmpty) {
      return jsonResponse({'error': 'Invalid credentials'}, status: 401);
    }

    final row = result.first;
    final userIdValue = row[0] as int;
    final displayName = row[1] as String;
    final storedPin = row[2] as String;
    final salt = row[3] as String;
    final role = row[4] as String;
    final isActive = row[5] as bool;
    final failedAttempts = row[6] as int;
    final lockedUntil = row[7] as DateTime?;

    if (!isActive) {
      return jsonResponse({'error': 'Account disabled'}, status: 403);
    }

    if (lockedUntil != null && lockedUntil.isAfter(DateTime.now().toUtc())) {
      return jsonResponse({
        'error': 'Account locked',
        'lockedUntil': lockedUntil.toIso8601String(),
      }, status: 423);
    }

    final hashed = hashPin(pin, salt);
    if (hashed != storedPin) {
      final newAttempts = failedAttempts + 1;
      DateTime? lockTime;
      if (newAttempts >= 3) {
        lockTime = DateTime.now().toUtc().add(const Duration(seconds: 30));
      }
      await db.pool.execute(
        Sql.named('''
          UPDATE users SET failed_attempts = @fa, locked_until = @lu
          WHERE id = @id
        '''),
        parameters: {
          'fa': newAttempts,
          'lu': lockTime?.toUtc(),
          'id': userIdValue,
        },
      );
      return jsonResponse({'error': 'Invalid credentials'}, status: 401);
    }

    // Reset failed attempts on success.
    if (failedAttempts > 0) {
      await db.pool.execute(
        Sql.named('UPDATE users SET failed_attempts = 0, locked_until = NULL WHERE id = @id'),
        parameters: {'id': userIdValue},
      );
    }

    final token = createToken(
      jwtSecret,
      userId: userIdValue,
      tenantId: tid,
      username: username,
      role: role,
    );

    return jsonResponse({
      'token': token,
      'user': {
        'id': userIdValue,
        'username': username,
        'displayName': displayName,
        'role': role,
      },
    });
  });

  /// POST /api/auth/users — create a new user (admin only)
  router.post('/users', (Request request) async {
    if (userRole(request) != 'admin') return forbidden('Admin only');

    final body = await readJson(request);
    if (body == null) return badRequest('Invalid JSON body');

    final username = body['username'] as String?;
    final displayName = body['displayName'] as String?;
    final pin = body['pin'] as String?;
    final role = body['role'] as String? ?? 'cashier';

    if (username == null || displayName == null || pin == null) {
      return badRequest('Missing required fields: username, displayName, pin');
    }

    final tid = tenantId(request);
    final salt = _generateSalt();
    final hashedPin = hashPin(pin, salt);

    try {
      final result = await db.pool.execute(
        Sql.named('''
          INSERT INTO users (tenant_id, username, display_name, pin, salt, role)
          VALUES (@tid, @username, @dn, @pin, @salt, @role)
          RETURNING id, created_at
        '''),
        parameters: {
          'tid': tid,
          'username': username,
          'dn': displayName,
          'pin': hashedPin,
          'salt': salt,
          'role': role,
        },
      );
      final row = result.first;
      return jsonResponse({
        'id': row[0],
        'username': username,
        'displayName': displayName,
        'role': role,
        'isActive': true,
        'createdAt': (row[1] as DateTime).toIso8601String(),
      }, status: 201);
    } on ServerException catch (e) {
      if (e.toString().contains('unique') || e.toString().contains('duplicate')) {
        return badRequest('Username already exists');
      }
      rethrow;
    }
  });

  /// GET /api/auth/users — list users for tenant
  router.get('/users', (Request request) async {
    final tid = tenantId(request);
    final result = await db.pool.execute(
      Sql.named('''
        SELECT id, username, display_name, role, is_active, created_at
        FROM users WHERE tenant_id = @tid ORDER BY id
      '''),
      parameters: {'tid': tid},
    );
    final users = result.map((r) => {
          'id': r[0],
          'username': r[1],
          'displayName': r[2],
          'role': r[3],
          'isActive': r[4],
          'createdAt': (r[5] as DateTime).toIso8601String(),
        }).toList();
    return jsonResponse(users);
  });

  /// DELETE /api/auth/users/<id>
  router.delete('/users/<id>', (Request request) async {
    if (userRole(request) != 'admin') return forbidden('Admin only');
    final id = int.tryParse(request.params['id']!);
    if (id == null) return badRequest('Invalid user ID');

    await db.pool.execute(
      Sql.named('DELETE FROM users WHERE id = @id AND tenant_id = @tid'),
      parameters: {'id': id, 'tid': tenantId(request)},
    );
    return jsonResponse({'deleted': true});
  });

  return router;
}

String _generateSalt() {
  final random = Random.secure();
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  return base64Url.encode(bytes);
}
