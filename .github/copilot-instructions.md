# Portculis POS — Copilot Instructions

## Project overview

Portculis POS is an offline-first point-of-sale system. The Flutter app (`cashier_app/`) runs on Android, iOS, macOS, Linux, Windows, and web. The backend (`server/`) is a Dart Shelf REST API with PostgreSQL.

- **Package ID**: `com.portculis.pos`
- **Dart SDK**: `>=3.0.0 <4.0.0`
- **Linting**: `very_good_analysis` 7.x (strict). `public_member_api_docs` and `lines_longer_than_80_chars` are disabled.

## Architecture

### Offline-first

Local datasources (Drift/SQLite) are the **primary** data source. Remote datasources exist only for the sync engine. Never make remote calls the default path — the app must work fully offline.

### Feature folder structure

```
lib/features/<feature>/
  domain/
    entities/        # Immutable value objects
    repositories/    # Abstract interfaces
    services/        # Business logic
  data/
    datasources/     # Local (Drift) and Remote (HTTP) implementations
  presentation/
    pages/           # Widgets (screens)
    widgets/         # Reusable UI components
    state/           # Cubits + state classes
```

Do not put business logic in widgets. Do not put UI code in domain.

### DI — get_it

All dependency injection lives in `lib/core/di/service_locator.dart`:

```dart
final sl = GetIt.instance;
```

- `registerSingleton` — DB, repositories, long-lived cubits (Settings, Auth, Sync, Reports)
- `registerFactory` — per-use cubits (Checkout, Keypad, CashDrawer, Customer)
- `registerLazySingleton` — network clients (ApiClient, RemoteSyncDatasource)

## Dart conventions

### Money — never use `double`

All monetary values use `Price`, which wraps `BigInt` subunits (cents):

```dart
final price = Price(BigInt.from(1500)); // $15.00
final zero = Price(BigInt.zero);
```

Never use `double` or `int` for money. `Price` supports `+`, `-`, `*`, comparison, and formatting.

### Item — sealed class with three variants

```dart
sealed class Item extends Equatable {
  String? get sku;
  String? get label;
  Price get unitPrice;
}

final class TradeItem extends Item { ... }    // Physical goods with stock, GTIN
final class ServiceItem extends Item { ... }  // Services, no stock
final class KeyedPriceItem extends Item { ... } // Ad-hoc price entry
```

Use `switch (item) { TradeItem() => ..., ServiceItem() => ..., KeyedPriceItem() => ... }` for exhaustive matching.

### Entities — `@immutable` + `Equatable`

```dart
@immutable
class Customer extends Equatable {
  const Customer({required this.name, this.id, this.phone = ''});

  final int? id;
  final String name;
  final String phone;

  @override
  List<Object?> get props => [id, name, phone];
}
```

Rules:
- Always `@immutable` and `const` constructor
- All fields `final`
- Override `props` for value equality
- Simple enums (`PaymentMethod`, `InvoiceStatus`) do **not** extend Equatable

### State management — Cubit, not Bloc

```dart
class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(this._repository) : super(const CheckoutIdle());
  final TransactionRepository _repository;
}
```

State classes are `sealed`:

```dart
sealed class CheckoutState extends Equatable {
  const CheckoutState();
}
final class CheckoutIdle extends CheckoutState { ... }
final class CheckoutCollecting extends CheckoutState { ... }
final class CheckoutCompleted extends CheckoutState { ... }
final class CheckoutError extends CheckoutState { ... }
```

Rules:
- Use `Cubit<T>`, never `Bloc<Event, State>`
- Primary dependency is positional; optional deps are named
- Store dependencies as `final _privateField`
- Initial state is always `const`
- States can live in a separate file or be co-located in the cubit file

### Persistence — Drift

Database is in `lib/core/persistence/app_database.dart`. DAOs follow Drift patterns. Run `dart run build_runner build` after modifying any `@DriftDatabase` or `@DriftAccessor` annotations.

## Server conventions (`server/`)

- **Framework**: Dart Shelf + shelf_router
- **Database**: PostgreSQL via `package:postgres`
- **Auth**: JWT (jose_plus) + bcrypt password hashing
- **Multi-tenant**: `tenantId` attached to request context by auth middleware
- **Router**: `Router buildRouter(Database db)` mounts sub-routers at `/api/<resource>/`
- **Public paths**: `/api/auth/login`, `/api/auth/register`, `/health`

## Testing

- **Cashier app tests**: `cd cashier_app && flutter test`
- **Server tests**: `cd server && dart test`
- **HTTP mocking**: Use `MockClient` from `package:http/testing.dart` — not mockito — for remote datasource tests
- **Repository mocking**: Use `mockito` + `@GenerateNiceMocks` + `build_runner` for cubit/service tests
- **Cubit testing**: Use `bloc_test` package with `blocTest<Cubit, State>()`
- **No `const` with `BigInt`**: `BigInt.zero` is not const-evaluable, so `Price(BigInt.zero)` cannot appear inside a `const` constructor call

## Common mistakes to avoid

- Using `double` for money instead of `Price(BigInt)`
- Creating a `Bloc` with events instead of a `Cubit`
- Making remote datasource the primary data source
- Putting logic in widgets instead of domain services
- Using `registerFactory` for singletons or vice versa
- Forgetting `@override List<Object?> get props` on Equatable classes
- Using `const` keyword on expressions containing `BigInt` operations
