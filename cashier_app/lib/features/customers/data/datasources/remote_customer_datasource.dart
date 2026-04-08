import 'package:cashier_app/core/network/api_client.dart';
import 'package:cashier_app/features/customers/domain/entities/customer.dart';
import 'package:cashier_app/features/customers/domain/repositories/customer_repository.dart';

/// Remote datasource that proxies [CustomerRepository] calls to the server API.
class RemoteCustomerDatasource implements CustomerRepository {
  RemoteCustomerDatasource(this._api);

  final ApiClient _api;

  @override
  Future<List<Customer>> getAll() async {
    final data = await _api.get('/api/customers/');
    final list = data['customers'] as List? ?? [];
    return list.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Customer?> findById(int id) async {
    try {
      final data = await _api.get('/api/customers/$id');
      return _fromJson(data);
    } on ApiException catch (e) {
      if (e.isNotFound) return null;
      rethrow;
    }
  }

  @override
  Future<List<Customer>> search(String query) async {
    final data = await _api.get(
      '/api/customers/?q=${Uri.encodeQueryComponent(query.trim())}',
    );
    final list = data['customers'] as List? ?? [];
    return list.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<int> save(Customer customer) async {
    final data = await _api.post('/api/customers/', _toJson(customer));
    return data['id'] as int;
  }

  @override
  Future<void> update(Customer customer) async {
    assert(customer.id != null, 'Cannot update a customer without an id');
    await _api.put('/api/customers/${customer.id}', _toJson(customer));
  }

  @override
  Future<void> delete(int id) => _api.delete('/api/customers/$id');

  // ---------------------------------------------------------------------------
  // JSON helpers
  // ---------------------------------------------------------------------------

  static Customer _fromJson(Map<String, dynamic> m) => Customer(
        id: m['id'] as int?,
        name: m['name'] as String? ?? '',
        phone: m['phone'] as String? ?? '',
        email: m['email'] as String? ?? '',
        notes: m['notes'] as String? ?? '',
        createdAt: m['createdAt'] != null
            ? DateTime.tryParse(m['createdAt'] as String)
            : null,
      );

  static Map<String, dynamic> _toJson(Customer c) => {
        'name': c.name,
        'phone': c.phone,
        'email': c.email,
        'notes': c.notes,
      };
}
