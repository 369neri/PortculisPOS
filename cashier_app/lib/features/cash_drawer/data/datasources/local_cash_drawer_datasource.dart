import 'package:cashier_app/core/persistence/app_database.dart';
import 'package:cashier_app/features/cash_drawer/domain/entities/cash_drawer_session.dart';
import 'package:cashier_app/features/cash_drawer/domain/repositories/cash_drawer_repository.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';

class LocalCashDrawerDatasource implements CashDrawerRepository {
  LocalCashDrawerDatasource(this._dao);

  final CashDrawerDao _dao;

  @override
  Future<int> openSession(CashDrawerSession session) =>
      _dao.openSession(session.openingBalance.value.toInt());

  @override
  Future<void> closeSession(int id, CashDrawerSession session) =>
      _dao.closeSession(
        id,
        session.closingBalance?.value.toInt() ?? 0,
        notes: session.notes,
      );

  @override
  Future<CashDrawerSession?> getActiveSession() async {
    final row = await _dao.getActiveSession();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<List<CashDrawerSession>> getAllSessions() async {
    final rows = await _dao.getAllSessions();
    return rows.map(_toDomain).toList();
  }

  CashDrawerSession _toDomain(CashDrawerSessionsTableData row) {
    return CashDrawerSession(
      id: row.id,
      openedAt: row.openedAt,
      closedAt: row.closedAt,
      openingBalance: Price(BigInt.from(row.openingBalanceSubunits)),
      closingBalance: row.closingBalanceSubunits != null
          ? Price(BigInt.from(row.closingBalanceSubunits!))
          : null,
      notes: row.notes,
    );
  }
}
