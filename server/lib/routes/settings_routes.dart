import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../db/database.dart';
import '../helpers.dart';

Router settingsRouter(Database db) {
  final router = Router();

  /// GET /api/settings
  router.get('/', (Request request) async {
    final tid = tenantId(request);
    final result = await db.pool.execute(
      Sql.named('SELECT * FROM settings WHERE tenant_id = @tid'),
      parameters: {'tid': tid},
    );
    if (result.isEmpty) return notFound('Settings not found');
    return jsonResponse(_rowToMap(result.first));
  });

  /// PUT /api/settings — update settings
  router.put('/', (Request request) async {
    if (userRole(request) != 'admin') return forbidden('Admin only');

    final body = await readJson(request);
    if (body == null) return badRequest('Invalid JSON body');

    final tid = tenantId(request);
    final result = await db.pool.execute(
      Sql.named('''
        UPDATE settings SET
          business_name = COALESCE(@bname, business_name),
          tax_rate = COALESCE(@tax, tax_rate),
          currency_symbol = COALESCE(@curr, currency_symbol),
          receipt_footer = COALESCE(@footer, receipt_footer),
          last_z_report_at = COALESCE(@zreport, last_z_report_at),
          theme_mode = COALESCE(@theme, theme_mode),
          logo_path = @logo,
          auto_backup_enabled = COALESCE(@backup, auto_backup_enabled),
          last_backup_at = COALESCE(@backupat, last_backup_at),
          printer_type = COALESCE(@ptype, printer_type),
          printer_address = COALESCE(@paddr, printer_address),
          tax_inclusive = COALESCE(@taxincl, tax_inclusive),
          updated_at = NOW()
        WHERE tenant_id = @tid
        RETURNING *
      '''),
      parameters: {
        'tid': tid,
        'bname': body['businessName'],
        'tax': body['taxRate'],
        'curr': body['currencySymbol'],
        'footer': body['receiptFooter'],
        'zreport': body['lastZReportAt'] != null
            ? DateTime.parse(body['lastZReportAt'] as String).toUtc()
            : null,
        'theme': body['themeMode'],
        'logo': body['logoPath'],
        'backup': body['autoBackupEnabled'],
        'backupat': body['lastBackupAt'] != null
            ? DateTime.parse(body['lastBackupAt'] as String).toUtc()
            : null,
        'ptype': body['printerType'],
        'paddr': body['printerAddress'],
        'taxincl': body['taxInclusive'],
      },
    );
    if (result.isEmpty) return notFound('Settings not found');
    return jsonResponse(_rowToMap(result.first));
  });

  return router;
}

Map<String, dynamic> _rowToMap(ResultRow row) {
  final schema = row.toColumnMap();
  return {
    'businessName': schema['business_name'],
    'taxRate': schema['tax_rate'],
    'currencySymbol': schema['currency_symbol'],
    'receiptFooter': schema['receipt_footer'],
    'lastZReportAt': (schema['last_z_report_at'] as DateTime?)?.toIso8601String(),
    'themeMode': schema['theme_mode'],
    'logoPath': schema['logo_path'],
    'autoBackupEnabled': schema['auto_backup_enabled'],
    'lastBackupAt': (schema['last_backup_at'] as DateTime?)?.toIso8601String(),
    'printerType': schema['printer_type'],
    'printerAddress': schema['printer_address'],
    'taxInclusive': schema['tax_inclusive'],
    'updatedAt': (schema['updated_at'] as DateTime?)?.toIso8601String(),
  };
}
