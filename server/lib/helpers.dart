import 'dart:convert';

import 'package:shelf/shelf.dart';

/// Reads the request body as a JSON map. Returns null on parse error.
Future<Map<String, dynamic>?> readJson(Request request) async {
  try {
    final body = await request.readAsString();
    if (body.isEmpty) return null;
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  } catch (_) {
    return null;
  }
}

/// Returns a JSON response.
Response jsonResponse(Object body, {int status = 200}) {
  return Response(status,
      body: jsonEncode(body),
      headers: {'content-type': 'application/json'});
}

/// Returns a 400 Bad Request.
Response badRequest(String message) =>
    jsonResponse({'error': message}, status: 400);

/// Returns a 404 Not Found.
Response notFound(String message) =>
    jsonResponse({'error': message}, status: 404);

/// Returns a 403 Forbidden.
Response forbidden(String message) =>
    jsonResponse({'error': message}, status: 403);

/// Extracts the tenant ID from the request context.
String tenantId(Request request) => request.context['tenantId'] as String;

/// Extracts the user ID from the request context.
int userId(Request request) => request.context['userId'] as int;

/// Extracts the role from the request context.
String userRole(Request request) => request.context['role'] as String;
