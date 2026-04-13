import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Exception thrown when the API returns a non-success status code.
class ApiException implements Exception {
  ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Low-level HTTP client for the Portculis server API.
///
/// Manages the base URL, auth token, and provides typed JSON helpers.
class ApiClient {
  ApiClient({
    required String baseUrl,
    http.Client? httpClient,
  })  : _baseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl,
        _http = httpClient ?? http.Client();

  String _baseUrl;
  final http.Client _http;

  /// Update the base URL (e.g. when the user changes the server URL).
  String get baseUrl => _baseUrl;
  set baseUrl(String url) =>
      _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;

  /// The JWT auth token (set after login/register).
  String? token;

  /// Whether a token is currently set.
  bool get isAuthenticated => token != null;

  // ---------------------------------------------------------------------------
  // HTTP verbs
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _http.get(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final response = await _http.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _http.put(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final response = await _http.patch(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final response = await _http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: _headers(),
    );
    return _handleResponse(response);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, String> _headers() {
    final h = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
    };
    if (token != null) {
      h[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    return h;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw ApiException(
      response.statusCode,
      body['error']?.toString() ?? response.reasonPhrase ?? 'Unknown error',
    );
  }

  void dispose() => _http.close();
}
