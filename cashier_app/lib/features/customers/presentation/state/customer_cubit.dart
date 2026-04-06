import 'package:cashier_app/core/logging/app_logger.dart';
import 'package:cashier_app/features/customers/domain/entities/customer.dart';
import 'package:cashier_app/features/customers/domain/repositories/customer_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  CustomerCubit(this._repository) : super(const CustomerLoading()) {
    load();
  }

  final CustomerRepository _repository;

  Future<void> load() async {
    try {
      final customers = await _repository.getAll();
      emit(CustomerLoaded(customers));
    } on Exception catch (e, st) {
      appLogger.e('Failed to load customers', error: e, stackTrace: st);
      emit(const CustomerError('Unable to load customers. Please try again.'));
    }
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return load();
    try {
      final results = await _repository.search(query);
      emit(CustomerLoaded(results));
    } on Exception catch (e, st) {
      appLogger.e('Customer search failed', error: e, stackTrace: st);
      emit(const CustomerError('Search failed. Please try again.'));
    }
  }

  Future<void> save(Customer customer) async {
    try {
      if (customer.id != null) {
        await _repository.update(customer);
      } else {
        await _repository.save(customer);
      }
      await load();
    } on Exception catch (e, st) {
      appLogger.e('Failed to save customer', error: e, stackTrace: st);
      emit(const CustomerError('Unable to save customer. Please try again.'));
    }
  }

  Future<void> delete(int id) async {
    try {
      await _repository.delete(id);
      await load();
    } on Exception catch (e, st) {
      appLogger.e('Failed to delete customer', error: e, stackTrace: st);
      emit(const CustomerError('Unable to delete customer. Please try again.'));
    }
  }
}
