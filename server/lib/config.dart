import 'dart:io';

import 'package:dotenv/dotenv.dart';

class AppConfig {
  final String dbHost;
  final int dbPort;
  final String dbName;
  final String dbUser;
  final String dbPassword;
  final String jwtSecret;
  final String port;

  AppConfig({
    required this.dbHost,
    required this.dbPort,
    required this.dbName,
    required this.dbUser,
    required this.dbPassword,
    required this.jwtSecret,
    this.port = '8080',
  });

  static late AppConfig instance;

  static void init(DotEnv env) {
    instance = AppConfig(
      dbHost: env['DATABASE_HOST'] ?? 'localhost',
      dbPort: int.parse(env['DATABASE_PORT'] ?? '5432'),
      dbName: env['DATABASE_NAME'] ?? 'portculis',
      dbUser: env['DATABASE_USER'] ?? 'portculis',
      dbPassword: env['DATABASE_PASSWORD'] ?? '',
      jwtSecret: env['JWT_SECRET'] ?? _defaultSecret(),
      port: env['PORT'] ?? '8080',
    );
  }

  static void initFromPlatform() {
    final env = Platform.environment;
    instance = AppConfig(
      dbHost: env['DATABASE_HOST'] ?? 'localhost',
      dbPort: int.parse(env['DATABASE_PORT'] ?? '5432'),
      dbName: env['DATABASE_NAME'] ?? 'portculis',
      dbUser: env['DATABASE_USER'] ?? 'portculis',
      dbPassword: env['DATABASE_PASSWORD'] ?? '',
      jwtSecret: env['JWT_SECRET'] ?? _defaultSecret(),
      port: env['PORT'] ?? '8080',
    );
  }

  /// For tests only.
  static void initForTest({
    String dbHost = 'localhost',
    int dbPort = 5432,
    String dbName = 'portculis_test',
    String dbUser = 'portculis',
    String dbPassword = '',
    String jwtSecret = 'test-secret',
  }) {
    instance = AppConfig(
      dbHost: dbHost,
      dbPort: dbPort,
      dbName: dbName,
      dbUser: dbUser,
      dbPassword: dbPassword,
      jwtSecret: jwtSecret,
    );
  }

  static String _defaultSecret() {
    stderr.writeln('WARNING: JWT_SECRET not set, using insecure default');
    return 'insecure-default-change-me';
  }
}
