import 'package:cashier_app/features/cash_drawer/domain/entities/cash_drawer_session.dart';

abstract interface class CashDrawerRepository {
  Future<int> openSession(CashDrawerSession session);
  Future<void> closeSession(int id, CashDrawerSession session);
  Future<CashDrawerSession?> getActiveSession();
  Future<List<CashDrawerSession>> getAllSessions();
}
