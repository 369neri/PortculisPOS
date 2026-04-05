import 'dart:async';

import 'package:cashier_app/core/di/service_locator.dart';
import 'package:cashier_app/features/archive/domain/services/archive_service.dart';
import 'package:cashier_app/features/cash_drawer/presentation/pages/cash_drawer_page.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/presentation/state/transaction_history_cubit.dart';
import 'package:cashier_app/features/checkout/presentation/state/transaction_history_state.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/receipts/report_pdf_builder.dart';
import 'package:cashier_app/features/reports/domain/entities/sales_report.dart';
import 'package:cashier_app/features/reports/domain/services/csv_exporter.dart';
import 'package:cashier_app/features/reports/presentation/state/reports_cubit.dart';
import 'package:cashier_app/features/reports/presentation/state/reports_state.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:cashier_app/features/settings/presentation/state/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.bar_chart), text: 'Summary'),
              Tab(icon: Icon(Icons.receipt_long), text: 'Transactions'),
              Tab(icon: Icon(Icons.point_of_sale), text: 'Cash Drawer'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SummaryTab(),
            _TransactionsTab(),
            CashDrawerPage(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary tab
// ---------------------------------------------------------------------------

class _SummaryTab extends StatelessWidget {
  const _SummaryTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        return switch (state) {
          ReportsInitial() || ReportsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
          ReportsError(:final message) => _ErrorView(
              message: message,
              onRetry: () => context.read<ReportsCubit>().load(),
            ),
          ReportsReady(:final report, :final lastZAt) => RefreshIndicator(
              onRefresh: () => context.read<ReportsCubit>().load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _PeriodCard(lastZAt: lastZAt, periodEnd: report.periodEnd),
                  const SizedBox(height: 16),
                  _ReportActions(report: report, lastZAt: lastZAt),
                  const SizedBox(height: 24),
                  _StatsGrid(report: report),
                  const SizedBox(height: 16),
                  _PaymentBreakdown(
                    breakdown: report.paymentBreakdown,
                    currencySymbol: _symbol(context),
                  ),
                ],
              ),
            ),
        };
      },
    );
  }

  String _symbol(BuildContext context) {
    final state = context.watch<SettingsCubit>().state;
    return state is SettingsReady ? state.settings.currencySymbol : r'$';
  }
}

// ---------------------------------------------------------------------------
// Period card
// ---------------------------------------------------------------------------

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({required this.lastZAt, required this.periodEnd});

  final DateTime? lastZAt;
  final DateTime periodEnd;

  @override
  Widget build(BuildContext context) {
    final from =
        lastZAt != null ? 'Since ${_fmt(lastZAt!)}' : 'All time';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.date_range, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Period',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(from),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats grid
// ---------------------------------------------------------------------------

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.report});

  final SalesReport report;

  @override
  Widget build(BuildContext context) {
    final symbol = context.watch<SettingsCubit>().state is SettingsReady
        ? (context.watch<SettingsCubit>().state as SettingsReady)
            .settings
            .currencySymbol
        : r'$';

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 3,
      children: [
        _StatCard(
          label: 'Transactions',
          value: report.transactionCount.toString(),
          icon: Icons.receipt,
        ),
        _StatCard(
          label: 'Voided',
          value: report.voidedCount.toString(),
          icon: Icons.block,
          valueColor: report.voidedCount > 0 ? Colors.red : null,
        ),
        _StatCard(
          label: 'Gross Sales',
          value: '$symbol${report.grossSales}',
          icon: Icons.attach_money,
        ),
        _StatCard(
          label: 'Net Sales',
          value: '$symbol${report.netSales}',
          icon: Icons.trending_up,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: valueColor),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Payment breakdown
// ---------------------------------------------------------------------------

class _PaymentBreakdown extends StatelessWidget {
  const _PaymentBreakdown({
    required this.breakdown,
    required this.currencySymbol,
  });

  final Map<PaymentMethod, Price> breakdown;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    if (breakdown.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Methods',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Divider(height: 16),
            for (final entry in breakdown.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key.name.toUpperCase()),
                    Text('$currencySymbol${entry.value}'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Report action buttons
// ---------------------------------------------------------------------------

class _ReportActions extends StatelessWidget {
  const _ReportActions({required this.report, this.lastZAt});

  final SalesReport report;
  final DateTime? lastZAt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => _showReportSheet(context, report, isZ: false),
          icon: const Icon(Icons.print_outlined),
          label: const Text('X Report'),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => _showReportSheet(context, report, isZ: true),
          icon: const Icon(Icons.lock_clock),
          label: const Text('Z Report — Close Day'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _exportCsv(context),
          icon: const Icon(Icons.file_download_outlined),
          label: const Text('Export CSV'),
        ),
      ],
    );
  }

  Future<void> _exportCsv(BuildContext context) async {
    final txState = context.read<TransactionHistoryCubit>().state;
    if (txState is! TransactionHistoryLoaded) return;
    try {
      await CsvExporter.exportAndShare(txState.transactions);
    } on Exception catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: \$e')),
      );
    }
  }



  void _showReportSheet(
    BuildContext context,
    SalesReport report, {
    required bool isZ,
  }) {
    final cubit = context.read<ReportsCubit>();
    final settingsState = context.read<SettingsCubit>().state;
    final settings =
        settingsState is SettingsReady ? settingsState.settings : const AppSettings();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => BlocProvider.value(
        value: cubit,
        child: _ReportSheet(
          report: report,
          settings: settings,
          isZ: isZ,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Report detail sheet
// ---------------------------------------------------------------------------

class _ReportSheet extends StatelessWidget {
  const _ReportSheet({
    required this.report,
    required this.settings,
    required this.isZ,
  });

  final SalesReport report;
  final AppSettings settings;
  final bool isZ;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) {
        return ListView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              isZ ? 'Z Report — End of Day' : 'X Report',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            Text(
              settings.businessName,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Period: ${report.periodStart != null ? _fmt(report.periodStart!) : "All time"}'
              ' → ${_fmt(report.periodEnd)}',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const Divider(height: 24),
            _Row('Transactions', report.transactionCount.toString()),
            _Row('Voided', report.voidedCount.toString()),
            const Divider(height: 16),
            _Row('Gross Sales', '${settings.currencySymbol}${report.grossSales}'),
            _Row(
              'Tax (est.)',
              '${settings.currencySymbol}${report.taxEstimated}',
            ),
            _Row(
              'Net Sales',
              '${settings.currencySymbol}${report.netSales}',
              bold: true,
            ),
            const Divider(height: 16),
            if (report.paymentBreakdown.isNotEmpty) ...[
              Text(
                'By Payment Method',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              for (final e in report.paymentBreakdown.entries)
                _Row(
                  e.key.name.toUpperCase(),
                  '${settings.currencySymbol}${e.value}',
                ),
              const Divider(height: 16),
            ],
            Text(
              settings.receiptFooter,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            if (isZ)
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<ReportsCubit>().closeDay();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Day closed. Z report complete.')),
                  );
                },
                icon: const Icon(Icons.lock),
                label: const Text('Confirm — Close Day'),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final bytes = await ReportPdfBuilder.build(
                  report,
                  settings,
                  isZ: isZ,
                );
                await Printing.layoutPdf(
                  name: isZ ? 'Z Report' : 'X Report',
                  onLayout: (_) async => bytes,
                );
              },
              icon: const Icon(Icons.print_outlined),
              label: const Text('Print'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                try {
                  final bytes = await ReportPdfBuilder.build(
                    report,
                    settings,
                    isZ: isZ,
                  );
                  await sl<ArchiveService>().saveReportPdf(
                    bytes,
                    report,
                    isZ: isZ,
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
                final bytes = await ReportPdfBuilder.build(
                  report,
                  settings,
                  isZ: isZ,
                );
                final prefix = isZ ? 'z' : 'x';
                await Printing.sharePdf(
                  bytes: bytes,
                  filename: '${prefix}_report.pdf',
                );
              },
              icon: const Icon(Icons.share_outlined),
              label: const Text('Share / Email'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? const TextStyle(fontWeight: FontWeight.bold)
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
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

// ---------------------------------------------------------------------------
// Transactions tab
// ---------------------------------------------------------------------------

class _TransactionsTab extends StatelessWidget {
  const _TransactionsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionHistoryCubit, TransactionHistoryState>(
      builder: (context, state) {
        return switch (state) {
          TransactionHistoryInitial() ||
          TransactionHistoryLoading() =>
            const Center(child: CircularProgressIndicator()),
          TransactionHistoryError(:final message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () =>
                        context.read<TransactionHistoryCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          TransactionHistoryLoaded(:final transactions)
              when transactions.isEmpty =>
            const Center(child: Text('No transactions yet')),
          TransactionHistoryLoaded(:final transactions) =>
            RefreshIndicator(
              onRefresh: () async {
                unawaited(context.read<TransactionHistoryCubit>().load());
                unawaited(context.read<ReportsCubit>().load());
              },
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (ctx, i) {
                  final tx = transactions[i];
                  final label = tx.invoiceNumber ?? '#${tx.id}';
                  final settingsState = ctx.watch<SettingsCubit>().state;
                  final currencySymbol = settingsState is SettingsReady
                      ? settingsState.settings.currencySymbol
                      : r'$';
                  return ListTile(
                    leading: Icon(
                      tx.status.name == 'voided'
                          ? Icons.block
                          : Icons.receipt_long_outlined,
                    ),
                    title: Text(label),
                    subtitle: Text(_fmt(tx.createdAt)),
                    trailing: Text('$currencySymbol${tx.invoice.total}'),
                  );
                },
              ),
            ),
        };
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Error view
// ---------------------------------------------------------------------------

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
// Date format helper
// ---------------------------------------------------------------------------

String _fmt(DateTime dt) {
  final y = dt.year;
  final mo = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final h = dt.hour.toString().padLeft(2, '0');
  final mi = dt.minute.toString().padLeft(2, '0');
  return '$y-$mo-$d $h:$mi';
}
