import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/services/price_calculator.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_cubit.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_state.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/receipts/receipt_pdf_builder.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:cashier_app/features/settings/presentation/state/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

/// Shows a modal bottom sheet to collect payments, then displays the receipt.
Future<bool> showCheckoutSheet(
  BuildContext context,
  Invoice invoice, {
  double taxRate = 0.0,
}) async {
  final cubit = context.read<CheckoutCubit>()
    ..startCheckout(invoice, taxRate: taxRate);

  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: const _CheckoutSheet(),
    ),
  );

  return result ?? false;
}

class _CheckoutSheet extends StatelessWidget {
  const _CheckoutSheet();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutCubit, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) => switch (state) {
        CheckoutCollecting() => _CollectingBody(state: state),
        CheckoutCompleted() => _ReceiptBody(state: state),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment collection body
// ─────────────────────────────────────────────────────────────────────────────

class _CollectingBody extends StatelessWidget {
  const _CollectingBody({required this.state});

  final CheckoutCollecting state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Checkout', style: textTheme.titleLarge),
          const SizedBox(height: 16),
          _TotalRow(label: 'Total', value: state.totalDue.toString()),
          _TotalRow(label: 'Paid', value: state.totalPaid.toString()),
          if (state.isFullyPaid)
            _TotalRow(
              label: 'Change',
              value: state.changeDue.toString(),
              highlight: true,
            )
          else
            _TotalRow(label: 'Remaining', value: state.remaining.toString()),
          const SizedBox(height: 12),
          if (state.payments.isNotEmpty) ...[
            ...List.generate(state.payments.length, (i) {
              final p = state.payments[i];
              return ListTile(
                dense: true,
                leading: Icon(_iconFor(p.method)),
                title: Text(p.method.name.toUpperCase()),
                trailing: Text(p.amount.toString()),
                onLongPress: () =>
                    context.read<CheckoutCubit>().removePayment(i),
              );
            }),
            const Divider(),
          ],
          Row(
            children: [
              for (final method in PaymentMethod.values)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _PaymentMethodButton(
                      method: method,
                      remaining: state.remaining,
                      enabled: !state.isFullyPaid,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: state.isFullyPaid
                ? () => context.read<CheckoutCubit>().completeCheckout()
                : null,
            icon: const Icon(Icons.check),
            label: const Text('Complete Sale'),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(PaymentMethod method) => switch (method) {
        PaymentMethod.cash => Icons.payments_outlined,
        PaymentMethod.card => Icons.credit_card,
        PaymentMethod.mobile => Icons.phone_android,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Receipt body
// ─────────────────────────────────────────────────────────────────────────────

class _ReceiptBody extends StatelessWidget {
  const _ReceiptBody({required this.state});

  final CheckoutCompleted state;

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsCubit>().state;
    final settings =
        settingsState is SettingsReady ? settingsState.settings : const AppSettings();

    final tx = state.transaction;
    final taxRate = state.taxRate;
    final subtotal = PriceCalculator.subtotal(tx.invoice);
    final tax = PriceCalculator.tax(tx.invoice, taxRate: taxRate);
    final grandTotal = PriceCalculator.grandTotal(tx.invoice, taxRate: taxRate);
    final changeDue = _changeDue(tx, grandTotal);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            settings.businessName,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(tx.createdAt),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (tx.invoiceNumber != null) ...[
            const SizedBox(height: 2),
            Text(
              tx.invoiceNumber!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const _Divider(),
          // Line items
          ...tx.invoice.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.item.label ?? "Item"} \u00d7${item.quantity}',
                    ),
                  ),
                  Text(item.lineTotal.toString()),
                ],
              ),
            ),
          ),
          const _Divider(),
          // Totals
          _ReceiptRow(label: 'Subtotal', value: subtotal.toString()),
          _ReceiptRow(
            label: taxRate > 0 ? 'Tax ($taxRate%)' : 'Tax',
            value: tax.toString(),
          ),
          _ReceiptRow(
            label: 'Total',
            value: grandTotal.toString(),
            bold: true,
          ),
          const _Divider(),
          // Payments
          ...tx.payments.map(
            (p) => _ReceiptRow(
              label: p.method.name.toUpperCase(),
              value: p.amount.toString(),
            ),
          ),
          if (changeDue.value > BigInt.zero)
            _ReceiptRow(
              label: 'Change',
              value: changeDue.toString(),
              highlight: true,
            ),
          const _Divider(),
          // Footer
          Text(
            settings.receiptFooter,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              final bytes = await ReceiptPdfBuilder.build(
                tx,
                settings,
                taxRate: taxRate,
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
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Done'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Price _changeDue(Transaction tx, Price grandTotal) {
    final totalPaid = tx.payments.fold(
      Price.from(0),
      (sum, p) => Price(sum.value + p.amount.value),
    );
    final diff = totalPaid.value - grandTotal.value;
    return diff > BigInt.zero ? Price(diff) : Price.from(0);
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final local = dt.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final mon = months[local.month - 1];
    final hr = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$day $mon ${local.year}  $hr:$min';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared layout helpers
// ─────────────────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Divider(height: 16, thickness: 1);
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool bold;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium;
    final style = (bold || highlight)
        ? base?.copyWith(
            fontWeight: bold ? FontWeight.bold : null,
            color: highlight ? Theme.of(context).colorScheme.primary : null,
          )
        : base;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final style = highlight
        ? Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: Theme.of(context).colorScheme.primary)
        : Theme.of(context).textTheme.bodyLarge;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment method button
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentMethodButton extends StatelessWidget {
  const _PaymentMethodButton({
    required this.method,
    required this.remaining,
    required this.enabled,
  });

  final PaymentMethod method;
  final Price remaining;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final icon = switch (method) {
      PaymentMethod.cash => Icons.payments_outlined,
      PaymentMethod.card => Icons.credit_card,
      PaymentMethod.mobile => Icons.phone_android,
    };

    return OutlinedButton.icon(
      onPressed: enabled
          ? () async {
              if (method == PaymentMethod.cash) {
                final amount = await _showCashEntryDialog(context, remaining);
                if (amount != null && context.mounted) {
                  context.read<CheckoutCubit>().addPayment(method, amount);
                }
              } else {
                context.read<CheckoutCubit>().addPayment(method, remaining);
              }
            }
          : null,
      icon: Icon(icon),
      label: Text(method.name[0].toUpperCase() + method.name.substring(1)),
    );
  }
}

Future<Price?> _showCashEntryDialog(
  BuildContext context,
  Price remaining,
) async {
  final major = remaining.value ~/ BigInt.from(100);
  final minor = (remaining.value % BigInt.from(100)).toInt().abs();
  final defaultText = '$major.${minor.toString().padLeft(2, '0')}';
  final controller = TextEditingController(text: defaultText)
    ..selection =
        TextSelection(baseOffset: 0, extentOffset: defaultText.length);

  return showDialog<Price>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Cash tendered'),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          hintText: '0.00',
          prefixIcon: Icon(Icons.payments_outlined),
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) {
          Navigator.of(ctx).pop(_parseCashAmount(controller.text));
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(ctx).pop(_parseCashAmount(controller.text)),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Price? _parseCashAmount(String text) {
  final parsed = double.tryParse(text.trim().replaceAll(',', '.'));
  if (parsed == null || parsed <= 0) return null;
  return Price(BigInt.from((parsed * 100).round()));
}
