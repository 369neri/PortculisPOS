import 'package:cashier_app/core/layout/responsive_layout.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:flutter/material.dart';

class InvoiceLineItemTile extends StatelessWidget {
  const InvoiceLineItemTile({
    required this.invoiceItem,
    required this.onRemove,
    this.onQuantityChanged,
    super.key,
  });

  final InvoiceItem invoiceItem;
  final VoidCallback onRemove;
  final ValueChanged<int>? onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final wide = isWideScreen(context);
    final tile = _buildTile(context, showDeleteIcon: wide);

    if (wide) return tile;

    return Dismissible(
      key: ObjectKey(invoiceItem),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Theme.of(context).colorScheme.error,
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      child: tile,
    );
  }

  Widget _buildTile(BuildContext context, {required bool showDeleteIcon}) {
    final item = invoiceItem.item;
    final label = item.label ?? item.sku ?? 'Keyed item';
    final qty = invoiceItem.quantity;
    final unitPrice = item.unitPrice;
    final lineTotal = invoiceItem.lineTotal;

    return ListTile(
      onTap: onQuantityChanged != null
          ? () => _showQuantityDialog(context, qty)
          : null,
      title: Text(label),
      subtitle: item is! KeyedPriceItem && item.sku != null
          ? Text(item.sku!, style: Theme.of(context).textTheme.bodySmall)
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$qty × $unitPrice',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: Text(
              lineTotal.toString(),
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ),
          if (showDeleteIcon) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onRemove,
              tooltip: 'Remove item',
            ),
          ],
        ],
      ),
    );
  }

  void _showQuantityDialog(BuildContext context, int currentQty) {
    final controller = TextEditingController(text: currentQty.toString());
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit quantity'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Quantity',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) {
            final qty = int.tryParse(controller.text.trim()) ?? 0;
            onQuantityChanged?.call(qty);
            Navigator.of(ctx).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final qty = int.tryParse(controller.text.trim()) ?? 0;
              onQuantityChanged?.call(qty);
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
