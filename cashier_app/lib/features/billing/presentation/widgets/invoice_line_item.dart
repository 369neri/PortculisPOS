import 'package:cashier_app/core/layout/responsive_layout.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:flutter/material.dart';

class InvoiceLineItemTile extends StatelessWidget {
  const InvoiceLineItemTile({
    required this.invoiceItem,
    required this.onRemove,
    this.onQuantityChanged,
    this.onDiscountChanged,
    super.key,
  });

  final InvoiceItem invoiceItem;
  final VoidCallback onRemove;
  final ValueChanged<int>? onQuantityChanged;

  /// Callback: (discountPercent, discountAmount).
  final void Function(double percent, Price? amount)? onDiscountChanged;

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
    final hasDiscount = invoiceItem.hasDiscount;

    return ListTile(
      onTap: onQuantityChanged != null
          ? () => _showQuantityDialog(context, qty)
          : null,
      onLongPress: onDiscountChanged != null
          ? () => _showDiscountDialog(context)
          : null,
      title: Text(label),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item is! KeyedPriceItem && item.sku != null)
            Text(item.sku!, style: Theme.of(context).textTheme.bodySmall),
          if (hasDiscount)
            Text(
              invoiceItem.discountAmount != null
                  ? '-${invoiceItem.discountAmount} off'
                  : '-${invoiceItem.discountPercent.toStringAsFixed(1)}%',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hasDiscount)
                  Text(
                    invoiceItem.grossTotal.toString(),
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                  ),
                Text(
                  lineTotal.toString(),
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: hasDiscount
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                ),
              ],
            ),
          ),
          if (onDiscountChanged != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                Icons.percent,
                size: 18,
                color: hasDiscount
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
              onPressed: () => _showDiscountDialog(context),
              tooltip: 'Set discount',
              visualDensity: VisualDensity.compact,
            ),
          ],
          if (showDeleteIcon) ...[
            const SizedBox(width: 4),
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

  void _showDiscountDialog(BuildContext context) {
    var mode = invoiceItem.discountAmount != null ? 1 : 0; // 0=%, 1=$
    final pctController = TextEditingController(
      text: invoiceItem.discountPercent > 0
          ? invoiceItem.discountPercent.toString()
          : '',
    );
    final amtController = TextEditingController(
      text: invoiceItem.discountAmount != null
          ? invoiceItem.discountAmount!.toString()
          : '',
    );

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Line discount'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('%')),
                  ButtonSegment(value: 1, label: Text(r'$')),
                ],
                selected: {mode},
                onSelectionChanged: (sel) =>
                    setDialogState(() => mode = sel.first),
              ),
              const SizedBox(height: 12),
              if (mode == 0)
                TextField(
                  controller: pctController,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Discount %',
                    suffixText: '%',
                    border: OutlineInputBorder(),
                  ),
                )
              else
                TextField(
                  controller: amtController,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Discount amount',
                    prefixText: r'$ ',
                    border: OutlineInputBorder(),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                onDiscountChanged?.call(0, null);
                Navigator.of(ctx).pop();
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (mode == 0) {
                  final pct =
                      double.tryParse(pctController.text.trim()) ?? 0.0;
                  final clamped = pct.clamp(0.0, 100.0);
                  onDiscountChanged?.call(clamped, null);
                } else {
                  final raw = amtController.text.trim();
                  if (raw.isEmpty) {
                    onDiscountChanged?.call(0, null);
                  } else {
                    final cents =
                        (double.tryParse(raw) ?? 0.0) * 100;
                    onDiscountChanged?.call(
                      0,
                      Price(BigInt.from(cents.round())),
                    );
                  }
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
