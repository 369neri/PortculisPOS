import 'package:bloc_test/bloc_test.dart';
import 'package:cashier_app/features/customers/domain/entities/customer.dart';
import 'package:cashier_app/features/customers/domain/repositories/customer_repository.dart';
import 'package:cashier_app/features/customers/presentation/state/customer_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements CustomerRepository {
  final List<Customer> _store = [];
  int _nextId = 1;

  @override
  Future<List<Customer>> getAll() async =>
      List.of(_store)..sort((a, b) => a.name.compareTo(b.name));

  @override
  Future<Customer?> findById(int id) async =>
      _store.where((c) => c.id == id).firstOrNull;

  @override
  Future<List<Customer>> search(String query) async {
    final q = query.toLowerCase();
    return _store
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.phone.toLowerCase().contains(q) ||
              c.email.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Future<int> save(Customer customer) async {
    final id = _nextId++;
    _store.add(customer.copyWith(id: id));
    return id;
  }

  @override
  Future<void> update(Customer customer) async {
    _store
      ..removeWhere((c) => c.id == customer.id)
      ..add(customer);
  }

  @override
  Future<void> delete(int id) async {
    _store.removeWhere((c) => c.id == id);
  }
}

void main() {
  late _FakeRepo repo;

  setUp(() {
    repo = _FakeRepo();
  });

  blocTest<CustomerCubit, CustomerState>(
    'emits CustomerLoaded on creation',
    build: () => CustomerCubit(repo),
    expect: () => [
      isA<CustomerLoaded>().having((s) => s.customers, 'customers', isEmpty),
    ],
  );

  blocTest<CustomerCubit, CustomerState>(
    'save adds a customer and reloads',
    build: () => CustomerCubit(repo),
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      await cubit.save(const Customer(name: 'Alice', phone: '555-1234'));
    },
    expect: () => [
      isA<CustomerLoaded>(), // initial empty
      isA<CustomerLoaded>().having(
        (s) => s.customers.length,
        'count',
        1,
      ),
    ],
  );

  blocTest<CustomerCubit, CustomerState>(
    'search filters customers',
    build: () => CustomerCubit(repo),
    seed: () {
      repo._store..add(const Customer(id: 1, name: 'Alice'))
        ..add(const Customer(id: 2, name: 'Bob'));
      return const CustomerLoaded([]);
    },
    act: (cubit) async {
      await cubit.search('ali');
    },
    expect: () => [
      isA<CustomerLoaded>().having(
        (s) => s.customers.length,
        'count',
        1,
      ),
    ],
  );

  blocTest<CustomerCubit, CustomerState>(
    'delete removes customer and reloads',
    build: () => CustomerCubit(repo),
    seed: () {
      repo._store.add(const Customer(id: 1, name: 'Alice'));
      return const CustomerLoaded(
        [Customer(id: 1, name: 'Alice')],
      );
    },
    act: (cubit) async {
      await cubit.delete(1);
    },
    expect: () => [
      isA<CustomerLoaded>().having(
        (s) => s.customers,
        'customers',
        isEmpty,
      ),
    ],
  );
}
