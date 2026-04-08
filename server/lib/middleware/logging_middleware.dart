import 'package:shelf/shelf.dart';

Middleware loggingMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final watch = Stopwatch()..start();
      Response response;
      try {
        response = await innerHandler(request);
      } catch (e, st) {
        print('${DateTime.now().toIso8601String()} '
            '${request.method} ${request.requestedUri.path} '
            '500 ${watch.elapsedMilliseconds}ms ERROR: $e\n$st');
        rethrow;
      }
      watch.stop();
      print('${DateTime.now().toIso8601String()} '
          '${request.method} ${request.requestedUri.path} '
          '${response.statusCode} ${watch.elapsedMilliseconds}ms');
      return response;
    };
  };
}
