import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'config.dart';
import 'db/database.dart';
import 'helpers.dart';
import 'routes/auth_routes.dart';
import 'routes/cash_drawer_routes.dart';
import 'routes/customers_routes.dart';
import 'routes/items_routes.dart';
import 'routes/settings_routes.dart';
import 'routes/sync_routes.dart';
import 'routes/transactions_routes.dart';

Router buildRouter(Database db) {
  final router = Router();

  // Health check (public).
  router.get('/health', (Request request) => jsonResponse({'status': 'ok'}));

  // Mount sub-routers.
  router.mount('/api/auth/', authRouter(db, AppConfig.instance.jwtSecret).call);
  router.mount('/api/items/', itemsRouter(db).call);
  router.mount('/api/customers/', customersRouter(db).call);
  router.mount('/api/transactions/', transactionsRouter(db).call);
  router.mount('/api/settings/', settingsRouter(db).call);
  router.mount('/api/cash-drawer/', cashDrawerRouter(db).call);
  router.mount('/api/sync/', syncRouter(db).call);

  // Catch-all 404.
  router.all('/<ignored|.*>', (Request request) {
    return notFound('Route not found: ${request.method} ${request.requestedUri.path}');
  });

  return router;
}
