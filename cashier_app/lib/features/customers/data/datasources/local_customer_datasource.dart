import 'package:cashier_app/core/persistence/app_database.dart';
import 'package:cashier_app/features/customers/domain/entities/customer.dart';
import 'package:cashier_app/features/customers/domain/repositories/customer_repository.dart';
import 'package:drift/drift.dart';

class LocalCustomerDatasource implements CustomerRepository {
  LocalCustomerDatasource(this._dao);

  final CustomersDao _dao;

  @override
  Future<List<Customer>> getAll() async {
    final rows = await _dao.getAll();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<Customer?> findById(int id) async {
    final row = await _dao.findById(id);
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<List<Customer>> search(String query) async {
    final rows = await _dao.search(query.trim());
    return rows.map(_toDomain).toList();
  }

  @override
  Future<int> save(Customer customer) => _dao.insertCustomer(
        CustomersTableCompanion.insert(
          name: customer.name,
          phone: Value(customer.phone),
          email: Value(customer.email),
          notes: Value(customer.notes),
          createdAt: customer.createdAt ?? DateTime.now(),
        ),
      );

  @override
  Future<void> update(Customer customer) {
    assert(customer.id != null, 'Cannot update a customer without an id');
    return _dao.updateCustomer(
      CustomersTableCompanion(
        id: Value(customer.id!),
        name: Value(customer.name),
        phone: Value(customer.phone),
        email: Value(customer.email),
        notes: Value(customer.notes),
      ),
    );
  }

  @override
  Future<void> delete(int id) => _dao.deleteCustomer(id);

  Customer _toDomain(CustomersTableData row) => Customer(
        id: row.id,
        name: row.name,
        phone: row.phone,
        email: row.email,
        notes: row.notes,
        createdAt: row.createdAt,
      );
}
