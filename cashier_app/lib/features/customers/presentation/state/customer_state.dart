part of 'customer_cubit.dart';

@immutable
sealed class CustomerState extends Equatable {
  const CustomerState();
}

final class CustomerLoading extends CustomerState {
  const CustomerLoading();

  @override
  List<Object?> get props => [];
}

final class CustomerLoaded extends CustomerState {
  const CustomerLoaded(this.customers);

  final List<Customer> customers;

  @override
  List<Object?> get props => [customers];
}

final class CustomerError extends CustomerState {
  const CustomerError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
