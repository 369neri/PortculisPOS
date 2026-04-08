import 'dart:io';

import 'package:args/args.dart';
import 'package:dotenv/dotenv.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

import 'package:server/config.dart';
import 'package:server/db/database.dart';
import 'package:server/middleware/auth_middleware.dart';
import 'package:server/middleware/logging_middleware.dart';
import 'package:server/router.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '8080')
    ..addFlag('migrate', defaultsTo: false, help: 'Run DB migrations and exit');

  final results = parser.parse(args);

  // Load .env if present
  final envFile = File('.env');
  if (envFile.existsSync()) {
    final env = DotEnv(includePlatformEnvironment: true)..load(['.env']);
    AppConfig.init(env);
  } else {
    AppConfig.initFromPlatform();
  }

  final db = Database(AppConfig.instance);
  await db.connect();

  if (results['migrate'] as bool) {
    await db.migrate();
    print('Migrations complete.');
    await db.close();
    exit(0);
  }

  await db.migrate();

  final router = buildRouter(db);
  final handler = const Pipeline()
      .addMiddleware(loggingMiddleware())
      .addMiddleware(handleCors())
      .addMiddleware(authMiddleware(AppConfig.instance.jwtSecret, db))
      .addHandler(router.call);

  final port =
      int.parse(results['port'] as String? ?? AppConfig.instance.port);
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('Server running on http://${server.address.host}:${server.port}');
}

Middleware handleCors() {
  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders);
      }
      final response = await innerHandler(request);
      return response.change(headers: _corsHeaders);
    };
  };
}

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};
