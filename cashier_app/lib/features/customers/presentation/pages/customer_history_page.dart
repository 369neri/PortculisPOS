import 'package:cashier_app/core/di/service_locator.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/customers/domain/entities/customer.dart';
import 'package:flutter/material.dart';

class CustomerHistoryPage extends StatefulWidget {
  const CustomerHistoryPage({required this.customer, super.key});

  final Customer customer;

  @override
  State<CustomerHistoryPage> createState() => _CustomerHistoryPageState();
}

class _CustomerHistoryPageState extends State<CustomerHistoryPage> {
  List<Transaction>? _transactions;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final repo = sl<TransactionRepository>();
    final all = await repo.getAll();
    final filtered = all
        .where((t) => t.customerId == widget.customer.id)
        .toList();
    if (mounted) setState(() => _transactions = filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.customer.name} — History'),
      ),
      body: _transactions == null
          ? const Center(child: CircularProgressIndicator())
          : _transactions!.isEmpty
              ? const Center(child: Text('No purchases yet'))
              : ListView.builder(
                  itemCount: _transactions!.length,
                  itemBuilder: (context, index) {
                    final tx = _transactions![index];
                    return ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text(
                        tx.invoiceNumber ?? 'INV-?????',
                      ),
                      subtitle: Text(
                        '${tx.createdAt.toLocal().toString().substring(0, 16)}'
                        ' — ${tx.status.name}',
                      ),
                      trailing: Text(
                        tx.invoice.total.toString(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    );
                  },
                ),
    );
  }
}
