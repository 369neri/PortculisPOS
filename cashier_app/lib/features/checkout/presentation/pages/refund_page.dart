import 'package:cashier_app/core/extensions/format_helpers.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/checkout/domain/entities/refund_line_item.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/presentation/state/transaction_history_cubit.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Page allowing the user to select individual line items and quantities to
/// refund from a completed transaction.
class RefundPage extends StatefulWidget {
  const RefundPage({
    required this.transaction,
    required this.settings,
    required this.existingRefunds,
    super.key,
  });

  final Transaction transaction;
  final AppSettings settings;
  final List<RefundLineItem> existingRefunds;

  @override
  State<RefundPage> createState() => _RefundPageState();
}

class _RefundPageState extends State<RefundPage> {
  late List<int> _maxRefundable;
  late List<int> _refundQty;
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Compute how many units are still refundable per line.
    final items = widget.transaction.invoice.items;
    final alreadyRefunded = <int, int>{};
    for (final r in widget.existingRefunds) {
      alreadyRefunded[r.lineIndex] =
          (alreadyRefunded[r.lineIndex] ?? 0) + r.quantity;
    }
    _maxRefundable = List.generate(
      items.length,
      (i) => items[i].quantity - (alreadyRefunded[i] ?? 0),
    );
    _refundQty = List.filled(items.length, 0);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  BigInt _computeRefundTotal() {
    var total = BigInt.zero;
    final items = widget.transaction.invoice.items;
    for (var i = 0; i < items.length; i++) {
      if (_refundQty[i] > 0) {
        total += _lineRefundSubunits(items[i], _refundQty[i]);
      }
    }
    return total;
  }

  BigInt _lineRefundSubunits(InvoiceItem invoiceItem, int qty) {
    // Pro-rata: (lineTotal / originalQty) * refundQty
    final lineTotal = invoiceItem.lineTotal.value;
    return lineTotal * BigInt.from(qty) ~/ BigInt.from(invoiceItem.quantity);
  }

  bool get _hasSelection => _refundQty.any((q) => q > 0);

  void _submit() {
    if (!_hasSelection) return;
    final items = widget.transaction.invoice.items;
    final refundItems = <RefundLineItem>[];
    final reason = _reasonController.text.trim();
    for (var i = 0; i < items.length; i++) {
      if (_refundQty[i] > 0) {
        refundItems.add(RefundLineItem(
          lineIndex: i,
          quantity: _refundQty[i],
          amountSubunits: _lineRefundSubunits(items[i], _refundQty[i]).toInt(),
          reason: reason,
        ));
      }
    }
    final txId = widget.transaction.id;
    if (txId != null) {
      context.read<TransactionHistoryCubit>().partialRefund(txId, refundItems);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.transaction.invoice.items;
    final cs = widget.settings.currencySymbol;
    final refundTotal = _computeRefundTotal();
    final refundPrice = Price(refundTotal);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partial Refund'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final maxQty = _maxRefundable[index];
                final alreadyRefundedQty =
                    item.quantity - maxQty;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.item.label ?? 'Item',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                'Qty: ${item.quantity}  ·  ${item.lineTotal.fmt(cs)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (alreadyRefundedQty > 0)
                                Text(
                                  'Already refunded: $alreadyRefundedQty',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (maxQty > 0) ...[
                          IconButton(
                            onPressed: _refundQty[index] > 0
                                ? () => setState(
                                    () => _refundQty[index]--)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          SizedBox(
                            width: 32,
                            child: Text(
                              '${_refundQty[index]}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          IconButton(
                            onPressed: _refundQty[index] < maxQty
                                ? () => setState(
                                    () => _refundQty[index]++)
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ] else
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Fully refunded',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Reason field + total + confirm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Refund Total',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  refundPrice.fmt(cs),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                onPressed: _hasSelection ? _submit : null,
                icon: const Icon(Icons.undo),
                label: const Text('Confirm Refund'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
