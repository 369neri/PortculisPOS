import 'package:logger/logger.dart';

final appLogger = Logger(
  printer: PrettyPrinter(
    errorMethodCount: 5,
    lineLength: 80,
    noBoxingByDefault: true,
  ),
);
