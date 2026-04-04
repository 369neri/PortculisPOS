import 'package:cashier_app/features/cash_drawer/domain/entities/cash_drawer_session.dart';
import 'package:cashier_app/features/cash_drawer/presentation/state/cash_drawer_cubit.dart';
import 'package:cashier_app/features/cash_drawer/presentation/state/cash_drawer_state.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/settings/presentation/state/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CashDrawerPage extends StatelessWidget {
  const CashDrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CashDrawerCubit, CashDrawerState>(
      builder: (context, state) => switch (state) {
        CashDrawerInitial() => _OpenDrawerView(),
        CashDrawerLoading() =>
          const Center(child: CircularProgressIndicator()),
        CashDrawerOpen(:final session) => _ActiveDrawerView(session: session),
        CashDrawerClosed(:final session) =>
          _ClosedDrawerView(session: session),
        CashDrawerHistory(:final sessions) =>
          _HistoryView(sessions: sessions),
        CashDrawerError(:final message) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () =>
                      context.read<CashDrawerCubit>().load(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Open drawer view (no active session)
// ---------------------------------------------------------------------------

class _OpenDrawerView extends StatelessWidget {
  final _controller = TextEditingController(text: '0.00');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.point_of_sale,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Cash Drawer',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'No active session. Enter the opening float to begin.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Opening Float',
              prefixIcon: Icon(Icons.payments_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              final amount = _parseAmount(_controller.text);
              if (amount != null) {
                context.read<CashDrawerCubit>().openDrawer(amount);
              }
            },
            icon: const Icon(Icons.lock_open),
            label: const Text('Open Drawer'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () =>
                context.read<CashDrawerCubit>().loadHistory(),
            icon: const Icon(Icons.history),
            label: const Text('View History'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Active drawer view
// ---------------------------------------------------------------------------

class _ActiveDrawerView extends StatelessWidget {
  const _ActiveDrawerView({required this.session});

  final CashDrawerSession session;

  @override
  Widget build(BuildContext context) {
    final sym = _currencySymbol(context);
    final duration = DateTime.now().difference(session.openedAt);
    final hours = duration.inHours;
    final mins = duration.inMinutes % 60;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.lock_open,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Drawer Open',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Opened',
                    value: _formatDateTime(session.openedAt),
                  ),
                  _InfoRow(
                    label: 'Duration',
                    value: '${hours}h ${mins}m',
                  ),
                  _InfoRow(
                    label: 'Opening Float',
                    value: '$sym${session.openingBalance}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => _showCloseDialog(context, session),
            icon: const Icon(Icons.lock),
            label: const Text('Close Drawer'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Closed drawer summary
// ---------------------------------------------------------------------------

class _ClosedDrawerView extends StatelessWidget {
  const _ClosedDrawerView({required this.session});

  final CashDrawerSession session;

  @override
  Widget build(BuildContext context) {
    final sym = _currencySymbol(context);
    final expected = session.openingBalance;
    final counted = session.closingBalance ?? Price.from(0);
    final diff = Price(counted.value - expected.value);
    final isOver = diff.value > BigInt.zero;
    final isShort = diff.value < BigInt.zero;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.check_circle,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Drawer Closed',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Opening Float',
                    value: '$sym$expected',
                  ),
                  _InfoRow(
                    label: 'Counted Cash',
                    value: '$sym$counted',
                  ),
                  const Divider(height: 16),
                  _InfoRow(
                    label: isOver
                        ? 'Over'
                        : isShort
                            ? 'Short'
                            : 'Balanced',
                    value: isShort
                        ? '-$sym${Price(diff.value.abs())}'
                        : '$sym$diff',
                    valueColor: isOver
                        ? Colors.green
                        : isShort
                            ? Colors.red
                            : null,
                  ),
                  if (session.notes != null && session.notes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Notes: ${session.notes}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () =>
                context.read<CashDrawerCubit>().load(),
            icon: const Icon(Icons.refresh),
            label: const Text('New Session'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () =>
                context.read<CashDrawerCubit>().loadHistory(),
            icon: const Icon(Icons.history),
            label: const Text('View History'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// History view
// ---------------------------------------------------------------------------

class _HistoryView extends StatelessWidget {
  const _HistoryView({required this.sessions});

  final List<CashDrawerSession> sessions;

  @override
  Widget build(BuildContext context) {
    final sym = _currencySymbol(context);

    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No past sessions.'),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () =>
                  context.read<CashDrawerCubit>().load(),
              child: const Text('Back'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Session History',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () =>
                    context.read<CashDrawerCubit>().load(),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sessions.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final s = sessions[index];
              final diff = s.closingBalance != null
                  ? Price(
                      s.closingBalance!.value - s.openingBalance.value,
                    )
                  : null;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDateTime(s.openedAt),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      _InfoRow(
                        label: 'Float',
                        value: '$sym${s.openingBalance}',
                      ),
                      if (s.closingBalance != null)
                        _InfoRow(
                          label: 'Counted',
                          value: '$sym${s.closingBalance}',
                        ),
                      if (diff != null)
                        _InfoRow(
                          label:
                              diff.value > BigInt.zero
                                  ? 'Over'
                                  : diff.value < BigInt.zero
                                      ? 'Short'
                                      : 'Balanced',
                          value: diff.value < BigInt.zero
                              ? '-$sym${Price(diff.value.abs())}'
                              : '$sym$diff',
                          valueColor: diff.value > BigInt.zero
                              ? Colors.green
                              : diff.value < BigInt.zero
                                  ? Colors.red
                                  : null,
                        ),
                      if (s.isOpen)
                        Text(
                          'Still open',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (s.notes != null && s.notes!.isNotEmpty)
                        Text(
                          'Notes: ${s.notes}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: valueColor != null
                ? TextStyle(
                    color: valueColor,
                    fontWeight: FontWeight.bold,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

void _showCloseDialog(BuildContext context, CashDrawerSession session) {
  final amountController = TextEditingController();
  final notesController = TextEditingController();

  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Close Drawer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: amountController,
            autofocus: true,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Counted Cash',
              prefixIcon: Icon(Icons.payments_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              prefixIcon: Icon(Icons.notes),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final amount = _parseAmount(amountController.text);
            if (amount != null) {
              Navigator.of(ctx).pop();
              context.read<CashDrawerCubit>().closeDrawer(
                    amount,
                    notes: notesController.text.isNotEmpty
                        ? notesController.text
                        : null,
                  );
            }
          },
          child: const Text('Close Drawer'),
        ),
      ],
    ),
  );
}

Price? _parseAmount(String text) {
  final parsed = double.tryParse(text.trim().replaceAll(',', '.'));
  if (parsed == null || parsed < 0) return null;
  return Price(BigInt.from((parsed * 100).round()));
}

String _formatDateTime(DateTime dt) {
  final d = dt.toLocal();
  final day = d.day.toString().padLeft(2, '0');
  final mon = d.month.toString().padLeft(2, '0');
  final hr = d.hour.toString().padLeft(2, '0');
  final min = d.minute.toString().padLeft(2, '0');
  return '${d.year}-$mon-$day $hr:$min';
}

String _currencySymbol(BuildContext context) {
  final state = context.watch<SettingsCubit>().state;
  return state is SettingsReady ? state.settings.currencySymbol : r'$';
}
