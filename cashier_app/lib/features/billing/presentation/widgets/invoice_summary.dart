import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/services/price_calculator.dart';
import 'package:cashier_app/features/settings/presentation/state/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InvoiceSummary extends StatelessWidget {
  const InvoiceSummary({required this.invoice, super.key});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SettingsCubit, SettingsState,
        ({double taxRate, bool taxInclusive})>(
      selector: (state) => state is SettingsReady
          ? (
              taxRate: state.settings.taxRate,
              taxInclusive: state.settings.taxInclusive,
            )
          : (taxRate: 0.0, taxInclusive: false),
      builder: (context, s) {
        final subtotal = PriceCalculator.subtotal(invoice);
        final tax = PriceCalculator.tax(invoice,
            taxRate: s.taxRate, taxInclusive: s.taxInclusive);
        final grandTotal = PriceCalculator.grandTotal(invoice,
            taxRate: s.taxRate, taxInclusive: s.taxInclusive);
        final textTheme = Theme.of(context).textTheme;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const Divider(),
              _SummaryRow(
                label: 'Subtotal',
                value: subtotal.toString(),
                style: textTheme.bodyLarge,
              ),
              _SummaryRow(
                label: s.taxInclusive
                    ? 'Tax incl. (${s.taxRate}%)'
                    : s.taxRate > 0
                        ? 'Tax (${s.taxRate}%)'
                        : 'Tax',
                value: tax.toString(),
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              _SummaryRow(
                label: 'Total',
                value: grandTotal.toString(),
                style: textTheme.titleLarge?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.style,
  });

  final String label;
  final String value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
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
