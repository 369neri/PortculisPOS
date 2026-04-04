import 'package:cashier_app/features/customers/domain/entities/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getAll();
  Future<Customer?> findById(int id);
  Future<List<Customer>> search(String query);
  Future<int> save(Customer customer);
  Future<void> update(Customer customer);
  Future<void> delete(int id);
}
