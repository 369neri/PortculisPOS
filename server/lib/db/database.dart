import 'package:postgres/postgres.dart';

import '../config.dart';

class Database {
  final AppConfig _config;
  late Pool _pool;

  Database(this._config);

  Pool get pool => _pool;

  Future<void> connect() async {
    _pool = Pool.withEndpoints(
      [
        Endpoint(
          host: _config.dbHost,
          port: _config.dbPort,
          database: _config.dbName,
          username: _config.dbUser,
          password: _config.dbPassword,
        ),
      ],
      settings: PoolSettings(
        maxConnectionCount: 10,
        sslMode: SslMode.disable,
      ),
    );
    // Verify connectivity.
    await _pool.execute('SELECT 1');
  }

  Future<void> close() async {
    await _pool.close();
  }

  Future<void> migrate() async {
    await _pool.execute('''
      CREATE TABLE IF NOT EXISTS _migrations (
        id SERIAL PRIMARY KEY,
        version INTEGER UNIQUE NOT NULL,
        applied_at TIMESTAMPTZ DEFAULT NOW()
      )
    ''');

    final result =
        await _pool.execute('SELECT COALESCE(MAX(version), 0) FROM _migrations');
    final currentVersion = result.first.first! as int;

    for (final m in _migrations) {
      if (m.version > currentVersion) {
        await _pool.execute(m.sql);
        await _pool.execute(
          Sql.named('INSERT INTO _migrations (version) VALUES (@v)'),
          parameters: {'v': m.version},
        );
        print('Applied migration v${m.version}');
      }
    }
  }
}

class _Migration {
  final int version;
  final String sql;
  const _Migration(this.version, this.sql);
}

const _migrations = [
  _Migration(1, '''
    CREATE TABLE IF NOT EXISTS tenants (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      name TEXT NOT NULL,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      tenant_id UUID NOT NULL REFERENCES tenants(id),
      username TEXT NOT NULL,
      display_name TEXT NOT NULL,
      pin TEXT NOT NULL,
      salt TEXT NOT NULL DEFAULT '',
      role TEXT NOT NULL DEFAULT 'cashier',
      is_active BOOLEAN NOT NULL DEFAULT true,
      failed_attempts INTEGER NOT NULL DEFAULT 0,
      locked_until TIMESTAMPTZ,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      UNIQUE(tenant_id, username)
    );

    CREATE TABLE IF NOT EXISTS items (
      id SERIAL PRIMARY KEY,
      tenant_id UUID NOT NULL REFERENCES tenants(id),
      sku TEXT NOT NULL,
      label TEXT NOT NULL,
      unit_price_subunits INTEGER NOT NULL DEFAULT 0,
      type TEXT NOT NULL DEFAULT 'trade',
      gtin TEXT,
      category TEXT NOT NULL DEFAULT '',
      stock_quantity INTEGER NOT NULL DEFAULT -1,
      is_favorite BOOLEAN NOT NULL DEFAULT false,
      image_path TEXT,
      item_tax_rate DOUBLE PRECISION,
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      UNIQUE(tenant_id, sku)
    );
    CREATE INDEX IF NOT EXISTS idx_items_tenant ON items(tenant_id);
    CREATE INDEX IF NOT EXISTS idx_items_gtin ON items(tenant_id, gtin);

    CREATE TABLE IF NOT EXISTS customers (
      id SERIAL PRIMARY KEY,
      tenant_id UUID NOT NULL REFERENCES tenants(id),
      name TEXT NOT NULL,
      phone TEXT NOT NULL DEFAULT '',
      email TEXT NOT NULL DEFAULT '',
      notes TEXT NOT NULL DEFAULT '',
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
    CREATE INDEX IF NOT EXISTS idx_customers_tenant ON customers(tenant_id);

    CREATE TABLE IF NOT EXISTS transactions (
      id SERIAL PRIMARY KEY,
      tenant_id UUID NOT NULL REFERENCES tenants(id),
      invoice_number TEXT,
      invoice_json TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'completed',
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      customer_id INTEGER REFERENCES customers(id),
      device_id TEXT,
      synced_at TIMESTAMPTZ
    );
    CREATE INDEX IF NOT EXISTS idx_transactions_tenant ON transactions(tenant_id);
    CREATE INDEX IF NOT EXISTS idx_transactions_created ON transactions(tenant_id, created_at);

    CREATE TABLE IF NOT EXISTS payments (
      id SERIAL PRIMARY KEY,
      transaction_id INTEGER NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
      method TEXT NOT NULL,
      amount_subunits INTEGER NOT NULL
    );

    CREATE TABLE IF NOT EXISTS refunds (
      id SERIAL PRIMARY KEY,
      original_transaction_id INTEGER NOT NULL REFERENCES transactions(id),
      line_index INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      amount_subunits INTEGER NOT NULL,
      reason TEXT NOT NULL DEFAULT '',
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS settings (
      tenant_id UUID PRIMARY KEY REFERENCES tenants(id),
      business_name TEXT NOT NULL DEFAULT 'My Business',
      tax_rate DOUBLE PRECISION NOT NULL DEFAULT 0.0,
      currency_symbol TEXT NOT NULL DEFAULT '\$',
      receipt_footer TEXT NOT NULL DEFAULT 'Thank you for your business!',
      last_z_report_at TIMESTAMPTZ,
      theme_mode TEXT NOT NULL DEFAULT 'system',
      logo_path TEXT,
      auto_backup_enabled BOOLEAN NOT NULL DEFAULT false,
      last_backup_at TIMESTAMPTZ,
      printer_type TEXT NOT NULL DEFAULT 'none',
      printer_address TEXT NOT NULL DEFAULT '',
      tax_inclusive BOOLEAN NOT NULL DEFAULT false,
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS cash_drawer_sessions (
      id SERIAL PRIMARY KEY,
      tenant_id UUID NOT NULL REFERENCES tenants(id),
      device_id TEXT,
      opened_at TIMESTAMPTZ NOT NULL,
      closed_at TIMESTAMPTZ,
      opening_balance_subunits INTEGER NOT NULL DEFAULT 0,
      closing_balance_subunits INTEGER,
      notes TEXT,
      synced_at TIMESTAMPTZ
    );
    CREATE INDEX IF NOT EXISTS idx_sessions_tenant ON cash_drawer_sessions(tenant_id);

    CREATE TABLE IF NOT EXISTS cash_movements (
      id SERIAL PRIMARY KEY,
      session_id INTEGER NOT NULL REFERENCES cash_drawer_sessions(id) ON DELETE CASCADE,
      type TEXT NOT NULL,
      amount_subunits INTEGER NOT NULL,
      note TEXT NOT NULL DEFAULT '',
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  '''),
];
