import 'package:cashier_app/core/di/service_locator.dart';
import 'package:cashier_app/core/extensions/format_helpers.dart';
import 'package:cashier_app/core/printing/esc_pos_receipt_builder.dart';
import 'package:cashier_app/core/printing/thermal_printer_service.dart';
import 'package:cashier_app/features/archive/domain/services/archive_service.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/services/price_calculator.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_cubit.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_state.dart';
import 'package:cashier_app/features/customers/domain/entities/customer.dart';
import 'package:cashier_app/features/customers/domain/repositories/customer_repository.dart';
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
  bool taxInclusive = false,
}) async {
  final cubit = context.read<CheckoutCubit>()
    ..startCheckout(invoice, taxRate: taxRate, taxInclusive: taxInclusive);

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
          const SizedBox(height: 12),
          _CustomerChip(
            customerId: state.customerId,
            customerName: state.customerName,
          ),
          const SizedBox(height: 12),
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

class _ReceiptBody extends StatefulWidget {
  const _ReceiptBody({required this.state});

  final CheckoutCompleted state;

  @override
  State<_ReceiptBody> createState() => _ReceiptBodyState();
}

class _ReceiptBodyState extends State<_ReceiptBody> {
  bool _autoPrinted = false;

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsCubit>().state;
    final settings =
        settingsState is SettingsReady ? settingsState.settings : const AppSettings();

    // Auto-print once when thermal printer is configured.
    if (!_autoPrinted &&
        settings.printerType != 'none' &&
        settings.printerAddress.isNotEmpty) {
      _autoPrinted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _printReceipt(context, widget.state.transaction, settings,
            widget.state.taxRate,
            taxInclusive: widget.state.taxInclusive);
      });
    }

    final tx = widget.state.transaction;
    final taxRate = widget.state.taxRate;
    final taxInclusive = widget.state.taxInclusive;
    final subtotal = PriceCalculator.subtotal(tx.invoice);
    final tax = PriceCalculator.tax(tx.invoice,
        taxRate: taxRate, taxInclusive: taxInclusive);
    final grandTotal = PriceCalculator.grandTotal(tx.invoice,
        taxRate: taxRate, taxInclusive: taxInclusive);
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
            label: taxInclusive
                ? 'Tax incl. ($taxRate%)'
                : taxRate > 0
                    ? 'Tax ($taxRate%)'
                    : 'Tax',
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
              await _printReceipt(context, tx, settings, taxRate,
                  taxInclusive: taxInclusive);
            },
            icon: const Icon(Icons.print_outlined),
            label: const Text('Print Receipt'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              try {
                final bytes = await ReceiptPdfBuilder.build(
                  tx,
                  settings,
                  taxRate: taxRate,
                  taxInclusive: taxInclusive,
                );
                await sl<ArchiveService>().saveReceiptPdf(bytes, tx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved to archive')),
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
                tx,
                settings,
                taxRate: taxRate,
                taxInclusive: taxInclusive,
              );
              await Printing.sharePdf(
                bytes: bytes,
                filename: 'receipt_${tx.invoiceNumber ?? tx.id.toString()}.pdf',
              );
            },
            icon: const Icon(Icons.share_outlined),
            label: const Text('Share / Email'),
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

  String _formatDate(DateTime dt) => Fmt.receiptDate(dt);
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

/// Prints a receipt: thermal first (if configured), PDF fallback.
Future<void> _printReceipt(
  BuildContext context,
  Transaction tx,
  AppSettings settings,
  double taxRate, {
  bool taxInclusive = false,
}) async {
  // Try thermal printer first.
  final pType = PrinterType.values.byName(settings.printerType);
  if (pType != PrinterType.none && settings.printerAddress.isNotEmpty) {
    try {
      final escBytes = await EscPosReceiptBuilder.build(
        tx,
        settings,
        taxRate: taxRate,
        taxInclusive: taxInclusive,
      );
      await ThermalPrinterService.send(
        escBytes,
        type: pType,
        address: settings.printerAddress,
      );
      return; // Thermal print succeeded.
    } on Exception {
      // Fall through to PDF printing.
    }
  }

  // PDF fallback.
  final pdfBytes = await ReceiptPdfBuilder.build(tx, settings,
      taxRate: taxRate, taxInclusive: taxInclusive);
  await Printing.layoutPdf(name: 'Receipt', onLayout: (_) async => pdfBytes);
}


// ─────────────────────────────────────────────────────────────────────────────
// Customer picker chip
// ─────────────────────────────────────────────────────────────────────────────

class _CustomerChip extends StatelessWidget {
  const _CustomerChip({this.customerId, this.customerName});

  final int? customerId;
  final String? customerName;

  @override
  Widget build(BuildContext context) {
    if (customerId != null) {
      return InputChip(
        avatar: const Icon(Icons.person, size: 18),
        label: Text(customerName ?? 'Customer #$customerId'),
        onDeleted: () =>
            context.read<CheckoutCubit>().setCustomer(),
        deleteButtonTooltipMessage: 'Remove customer',
      );
    }
    return ActionChip(
      avatar: const Icon(Icons.person_add_alt_1, size: 18),
      label: const Text('Add Customer'),
      onPressed: () => _showCustomerSearchDialog(context),
    );
  }
}

Future<void> _showCustomerSearchDialog(BuildContext context) async {
  final cubit = context.read<CheckoutCubit>();
  final customer = await showDialog<Customer>(
    context: context,
    builder: (_) => const _CustomerSearchDialog(),
  );
  if (customer != null) {
    cubit.setCustomer(id: customer.id, name: customer.name);
  }
}

class _CustomerSearchDialog extends StatefulWidget {
  const _CustomerSearchDialog();

  @override
  State<_CustomerSearchDialog> createState() => _CustomerSearchDialogState();
}

class _CustomerSearchDialogState extends State<_CustomerSearchDialog> {
  final _controller = TextEditingController();
  List<Customer> _results = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = sl<CustomerRepository>();
    final all = await repo.getAll();
    if (mounted) setState(() => _results = all);
  }

  Future<void> _search(String query) async {
    final repo = sl<CustomerRepository>();
    final results =
        query.isEmpty ? await repo.getAll() : await repo.search(query);
    if (mounted) setState(() => _results = results);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Customer'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search by name, phone, or email',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _search,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: _results.isEmpty
                  ? const Center(child: Text('No customers found'))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _results.length,
                      itemBuilder: (_, i) {
                        final c = _results[i];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              c.name.isNotEmpty
                                  ? c.name[0].toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(c.name),
                          subtitle: Text(
                            [
                              if (c.phone.isNotEmpty) c.phone,
                              if (c.email.isNotEmpty) c.email,
                            ].join(' \u2022 '),
                          ),
                          onTap: () => Navigator.of(context).pop(c),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
