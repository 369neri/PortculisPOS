import 'package:cashier_app/features/customers/domain/entities/customer.dart';
import 'package:cashier_app/features/customers/presentation/pages/customer_form_page.dart';
import 'package:cashier_app/features/customers/presentation/pages/customer_history_page.dart';
import 'package:cashier_app/features/customers/presentation/state/customer_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by name, phone, or email',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (q) =>
                  context.read<CustomerCubit>().search(q),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.person_add),
      ),
      body: BlocBuilder<CustomerCubit, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CustomerError) {
            return Center(child: Text(state.message));
          }
          final customers = (state as CustomerLoaded).customers;
          if (customers.isEmpty) {
            return const Center(child: Text('No customers yet'));
          }
          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final c = customers[index];
              return _CustomerTile(
                customer: c,
                onTap: () => _openHistory(context, c),
                onEdit: () => _openForm(context, customer: c),
                onDelete: () => _confirmDelete(context, c),
              );
            },
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context, {Customer? customer}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<CustomerCubit>(),
          child: CustomerFormPage(customer: customer),
        ),
      ),
    );
  }

  void _openHistory(BuildContext context, Customer customer) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CustomerHistoryPage(customer: customer),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Customer customer) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete customer?'),
        content: Text('Remove "${customer.name}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<CustomerCubit>().delete(customer.id!);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  const _CustomerTile({
    required this.customer,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Customer customer;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (customer.phone.isNotEmpty) customer.phone,
      if (customer.email.isNotEmpty) customer.email,
    ].join(' • ');

    return ListTile(
      leading: CircleAvatar(
        child: Text(customer.name.isNotEmpty ? customer.name[0] : '?'),
      ),
      title: Text(customer.name),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      onTap: onTap,
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') onEdit();
          if (value == 'delete') onDelete();
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }
}
