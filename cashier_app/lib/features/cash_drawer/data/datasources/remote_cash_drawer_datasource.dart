import 'package:cashier_app/core/network/api_client.dart';
import 'package:cashier_app/features/cash_drawer/domain/entities/cash_drawer_session.dart';
import 'package:cashier_app/features/cash_drawer/domain/entities/cash_movement.dart';
import 'package:cashier_app/features/cash_drawer/domain/repositories/cash_drawer_repository.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';

/// Remote datasource that proxies [CashDrawerRepository] calls to the server API.
class RemoteCashDrawerDatasource implements CashDrawerRepository {
  RemoteCashDrawerDatasource(this._api);

  final ApiClient _api;

  @override
  Future<int> openSession(CashDrawerSession session) async {
    final data = await _api.post('/api/cash-drawer/sessions', {
      'openingBalanceSubunits': session.openingBalance.value.toInt(),
    });
    return data['id'] as int;
  }

  @override
  Future<void> closeSession(int id, CashDrawerSession session) =>
      _api.patch('/api/cash-drawer/sessions/$id/close', {
        'closingBalanceSubunits':
            session.closingBalance?.value.toInt() ?? 0,
        'notes': session.notes,
      });

  @override
  Future<CashDrawerSession?> getActiveSession() async {
    try {
      final data = await _api.get('/api/cash-drawer/sessions/active');
      return _sessionFromJson(data);
    } on ApiException catch (e) {
      if (e.isNotFound) return null;
      rethrow;
    }
  }

  @override
  Future<List<CashDrawerSession>> getAllSessions() async {
    final data = await _api.get('/api/cash-drawer/sessions');
    final list = data['sessions'] as List? ?? [];
    return list
        .map((e) => _sessionFromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addMovement(CashMovement movement) =>
      _api.post('/api/cash-drawer/sessions/${movement.sessionId}/movements', {
        'type': movement.type.name,
        'amountSubunits': movement.amountSubunits,
        'note': movement.note,
      });

  @override
  Future<List<CashMovement>> getMovements(int sessionId) async {
    final data =
        await _api.get('/api/cash-drawer/sessions/$sessionId/movements');
    final list = data['movements'] as List? ?? [];
    return list
        .map((e) => _movementFromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // JSON helpers
  // ---------------------------------------------------------------------------

  static CashDrawerSession _sessionFromJson(Map<String, dynamic> m) =>
      CashDrawerSession(
        id: m['id'] as int?,
        openedAt: m['openedAt'] != null
            ? DateTime.parse(m['openedAt'] as String)
            : DateTime.now(),
        closedAt: m['closedAt'] != null
            ? DateTime.parse(m['closedAt'] as String)
            : null,
        openingBalance:
            Price(BigInt.from((m['openingBalanceSubunits'] as num?) ?? 0)),
        closingBalance: m['closingBalanceSubunits'] != null
            ? Price(BigInt.from(m['closingBalanceSubunits'] as num))
            : null,
        notes: m['notes'] as String?,
      );

  static CashMovement _movementFromJson(Map<String, dynamic> m) =>
      CashMovement(
        id: m['id'] as int?,
        sessionId: m['sessionId'] as int? ?? 0,
        type: CashMovementType.values.firstWhere(
          (t) => t.name == (m['type'] as String? ?? 'adjustment'),
          orElse: () => CashMovementType.adjustment,
        ),
        amountSubunits: (m['amountSubunits'] as num?)?.toInt() ?? 0,
        note: m['note'] as String? ?? '',
        createdAt: m['createdAt'] != null
            ? DateTime.parse(m['createdAt'] as String)
            : DateTime.now(),
      );
}
