
import 'package:cashier_app/core/di/service_locator.dart';
import 'package:cashier_app/features/archive/domain/services/archive_service.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/checkout/presentation/state/transaction_history_cubit.dart';
import 'package:cashier_app/features/checkout/presentation/state/transaction_history_state.dart';
import 'package:cashier_app/features/receipts/receipt_pdf_builder.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:cashier_app/features/settings/presentation/state/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() =>
      _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final _searchController = TextEditingController();
  String _query = '';
  String _statusFilter = 'all'; // all | completed | voided

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Transaction> _applyFilters(List<Transaction> transactions) {
    var result = transactions;

    // Status filter
    if (_statusFilter == 'completed') {
      result = result
          .where((tx) => tx.status == TransactionStatus.completed)
          .toList();
    } else if (_statusFilter == 'voided') {
      result = result
          .where((tx) => tx.status == TransactionStatus.voided)
          .toList();
    }

    // Text search
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      result = result.where((tx) {
        final inv = tx.invoiceNumber?.toLowerCase() ?? '';
        final id = tx.id?.toString() ?? '';
        final total = tx.invoice.total.toString().toLowerCase();
        final methods = tx.payments
            .map((p) => p.method.name.toLowerCase())
            .join(' ');
        return inv.contains(q) ||
            id.contains(q) ||
            total.contains(q) ||
            methods.contains(q);
      }).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search by invoice#, amount, method...',
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _statusFilter == 'all',
                  onSelected: () =>
                      setState(() => _statusFilter = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Completed',
                  selected: _statusFilter == 'completed',
                  onSelected: () =>
                      setState(() => _statusFilter = 'completed'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Voided',
                  selected: _statusFilter == 'voided',
                  onSelected: () =>
                      setState(() => _statusFilter = 'voided'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: BlocBuilder<TransactionHistoryCubit,
                TransactionHistoryState>(
              builder: (context, state) {
                return switch (state) {
                  TransactionHistoryInitial() ||
                  TransactionHistoryLoading() =>
                    const Center(child: CircularProgressIndicator()),
                  TransactionHistoryError(:final message) => _ErrorView(
                      message: message,
                      onRetry: () =>
                          context.read<TransactionHistoryCubit>().load(),
                    ),
                  TransactionHistoryLoaded(:final transactions) => () {
                      final filtered = _applyFilters(transactions);
                      if (transactions.isEmpty) return const _EmptyView();
                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text('No matching transactions'),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () =>
                            context.read<TransactionHistoryCubit>().load(),
                        child:
                            _TransactionList(transactions: filtered),
                      );
                    }(),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty / Error views
// ---------------------------------------------------------------------------

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No transactions yet'),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Transaction list
// ---------------------------------------------------------------------------

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.transactions});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsCubit>().state;
    final settings = settingsState is SettingsReady
        ? settingsState.settings
        : const AppSettings();

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return _TransactionTile(
          transaction: tx,
          currencySymbol: settings.currencySymbol,
          onTap: () => _showDetail(context, tx, settings),
        );
      },
    );
  }

  void _showDetail(
    BuildContext context,
    Transaction transaction,
    AppSettings settings,
  ) {
    final cubit = context.read<TransactionHistoryCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _TransactionDetailSheet(
          transaction: transaction,
          settings: settings,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Transaction tile
// ---------------------------------------------------------------------------

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.currencySymbol,
    required this.onTap,
  });

  final Transaction transaction;
  final String currencySymbol;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isVoided = transaction.status == TransactionStatus.voided;
    final label = transaction.invoiceNumber ?? '#${transaction.id}';
    final total = transaction.invoice.total;
    final methods = transaction.payments
        .map((p) => p.method.name.toUpperCase())
        .toSet()
        .join(' + ');

    return ListTile(
      leading: Icon(
        isVoided ? Icons.block : Icons.receipt_long_outlined,
        color: isVoided ? Colors.red : null,
      ),
      title: Text(label),
      subtitle: Text('${_fmtDate(transaction.createdAt)}  $methods'),
      trailing: Text(
        '$currencySymbol$total',
        style: TextStyle(
          decoration: isVoided ? TextDecoration.lineThrough : null,
          color: isVoided ? Colors.grey : null,
        ),
      ),
      onTap: onTap,
    );
  }
}

// ---------------------------------------------------------------------------
// Detail sheet
// ---------------------------------------------------------------------------

class _TransactionDetailSheet extends StatelessWidget {
  const _TransactionDetailSheet({
    required this.transaction,
    required this.settings,
  });

  final Transaction transaction;
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final isVoided = transaction.status == TransactionStatus.voided;
    final label = transaction.invoiceNumber ?? '#${transaction.id}';

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.35,
      maxChildSize: 0.95,
      expand: false,
      builder: (sheetContext, controller) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            controller: controller,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header row: invoice# + status chip
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(_fmtDate(transaction.createdAt)),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      isVoided ? 'Voided' : 'Completed',
                      style: TextStyle(
                        color: isVoided ? Colors.red : Colors.green,
                      ),
                    ),
                    backgroundColor:
                        isVoided ? Colors.red.shade50 : Colors.green.shade50,
                  ),
                ],
              ),
              const Divider(height: 24),
              // Items section
              Text('Items', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              for (final item in transaction.invoice.items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('\u00d7${item.quantity}  '),
                      Expanded(child: Text(item.item.label ?? 'Item')),
                      Text(
                        '${settings.currencySymbol}${item.lineTotal}',
                      ),
                    ],
                  ),
                ),
              const Divider(height: 24),
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total'),
                  Text(
                    '${settings.currencySymbol}${transaction.invoice.total}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Payments section
              Text(
                'Payments',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              for (final p in transaction.payments)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(child: Text(p.method.name.toUpperCase())),
                      Text('${settings.currencySymbol}${p.amount}'),
                    ],
                  ),
                ),
              if (transaction.changeDue.value > BigInt.zero) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Change'),
                    Text(
                      '${settings.currencySymbol}${transaction.changeDue}',
                    ),
                  ],
                ),
              ],
              OutlinedButton.icon(
                onPressed: () async {
                  final bytes = await ReceiptPdfBuilder.build(
                    transaction,
                    settings,
                  );
                  await Printing.layoutPdf(
                    name: 'Receipt',
                    onLayout: (_) async => bytes,
                  );
                },
                icon: const Icon(Icons.print_outlined),
                label: const Text('Print Receipt'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final bytes = await ReceiptPdfBuilder.build(
                      transaction,
                      settings,
                    );
                    await sl<ArchiveService>().saveReceiptPdf(
                      bytes,
                      transaction,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Saved to archive'),
                        ),
                      );
                    }
                  } on Exception catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Save failed: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save to Archive'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final bytes = await ReceiptPdfBuilder.build(
                    transaction,
                    settings,
                  );
                  await Printing.sharePdf(
                    bytes: bytes,
                    filename:
                        'receipt_${transaction.invoiceNumber ?? transaction.id.toString()}.pdf',
                  );
                },
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share / Email'),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 24),
              // Void button (completed only)
              if (!isVoided)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  onPressed: () => _confirmVoid(context),
                  icon: const Icon(Icons.block),
                  label: const Text('Void Transaction'),
                ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _confirmVoid(BuildContext context) {
    final cubit = context.read<TransactionHistoryCubit>();
    final txId = transaction.id;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Void Transaction'),
        content: const Text(
          'This cannot be undone. Mark this transaction as voided?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
              if (txId != null) {
                cubit.voidTransaction(txId);
              }
            },
            child: const Text('Void'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Date formatting helper
// ---------------------------------------------------------------------------

String _fmtDate(DateTime dt) {
  final y = dt.year;
  final mo = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final h = dt.hour.toString().padLeft(2, '0');
  final mi = dt.minute.toString().padLeft(2, '0');
  return '$y-$mo-$d $h:$mi';
}
