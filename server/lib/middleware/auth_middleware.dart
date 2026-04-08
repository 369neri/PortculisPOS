import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../auth/jwt.dart';
import '../db/database.dart';

/// Paths that do not require authentication.
const _publicPaths = {
  '/api/auth/login',
  '/api/auth/register',
  '/health',
};

bool _isPublic(String path) =>
    _publicPaths.contains(path) || path == '/' || path.startsWith('/api/auth/');

Middleware authMiddleware(String jwtSecret, Database db) {
  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method == 'OPTIONS' || _isPublic(request.requestedUri.path)) {
        return innerHandler(request);
      }

      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(401,
            body: jsonEncode({'error': 'Missing or invalid Authorization header'}),
            headers: {'content-type': 'application/json'});
      }

      final token = authHeader.substring(7);
      final payload = verifyToken(jwtSecret, token);
      if (payload == null) {
        return Response(401,
            body: jsonEncode({'error': 'Invalid or expired token'}),
            headers: {'content-type': 'application/json'});
      }

      // Attach user info to request context.
      final updatedRequest = request.change(context: {
        'userId': payload['sub'] as int,
        'tenantId': payload['tid'] as String,
        'username': payload['usr'] as String,
        'role': payload['rol'] as String,
      });

      return innerHandler(updatedRequest);
    };
  };
}
