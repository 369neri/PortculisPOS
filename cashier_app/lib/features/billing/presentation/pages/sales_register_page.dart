import 'dart:async' show unawaited;

import 'package:cashier_app/core/layout/responsive_layout.dart';
import 'package:cashier_app/features/billing/presentation/state/sales_register_cubit.dart';
import 'package:cashier_app/features/billing/presentation/state/sales_register_state.dart';
import 'package:cashier_app/features/billing/presentation/widgets/invoice_line_item.dart';
import 'package:cashier_app/features/billing/presentation/widgets/invoice_summary.dart';
import 'package:cashier_app/features/checkout/presentation/pages/checkout_page.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_cubit.dart';
import 'package:cashier_app/features/checkout/presentation/state/transaction_history_cubit.dart';
import 'package:cashier_app/features/items/presentation/state/item_lookup_cubit.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/pricing/presentation/state/keypad_cubit.dart';
import 'package:cashier_app/features/pricing/presentation/state/keypad_cubit_state.dart';
import 'package:cashier_app/features/pricing/presentation/widgets/keypad_display.dart';
import 'package:cashier_app/features/pricing/presentation/widgets/num_keypad.dart';
import 'package:cashier_app/features/settings/presentation/state/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SalesRegisterPage extends StatelessWidget {
  const SalesRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<KeypadCubit, KeypadState>(
      listener: (context, state) {
        if (state is KeypadResultState && state.value.isNotEmpty) {
          final parsed = BigInt.tryParse(state.value);
          if (parsed != null && parsed > BigInt.zero) {
            context.read<SalesRegisterCubit>().addKeyedItem(Price(parsed));
            context.read<KeypadCubit>().clear();
          }
        }
      },
      child: isWideScreen(context)
          ? const _WideLayout()
          : const _NarrowLayout(),
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SkuSearchBar(),
        Expanded(child: _InvoicePanel()),
        const _KeypadPanel(),
      ],
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              const _SkuSearchBar(),
              Expanded(child: _InvoicePanel()),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        const SizedBox(
          width: 420,
          child: _KeypadPanel(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// SKU search bar
// ---------------------------------------------------------------------------

class _SkuSearchBar extends StatefulWidget {
  const _SkuSearchBar();

  @override
  State<_SkuSearchBar> createState() => _SkuSearchBarState();
}

class _SkuSearchBarState extends State<_SkuSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String value) {
    context.read<ItemLookupCubit>().lookupBySku(value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItemLookupCubit, ItemLookupState>(
      listener: (context, state) {
        if (state is ItemLookupFound) {
          context.read<SalesRegisterCubit>().addCatalogItem(state.item);
          _controller.clear();
          context.read<ItemLookupCubit>().reset();
        } else if (state is ItemLookupNotFound) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Item not found: ${state.query}')),
          );
          _controller.clear();
          context.read<ItemLookupCubit>().reset();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Scan barcode or enter SKU',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _submit,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Invoice panel
// ---------------------------------------------------------------------------

class _InvoicePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesRegisterCubit, SalesRegisterState>(
      builder: (context, state) {
        final items = state.invoice.items;

        return Column(
          children: [
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No items yet'))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return InvoiceLineItemTile(
                          invoiceItem: items[index],
                          onRemove: () => context
                              .read<SalesRegisterCubit>()
                              .removeItem(index),
                        );
                      },
                    ),
            ),
            InvoiceSummary(invoice: state.invoice),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: FilledButton.icon(
                onPressed: items.isEmpty
                    ? null
                    : () async {
                        final settingsState =
                            context.read<SettingsCubit>().state;
                        final taxRate = settingsState is SettingsReady
                            ? settingsState.settings.taxRate
                            : 0.0;
                        final completed = await showCheckoutSheet(
                          context,
                          state.invoice,
                          taxRate: taxRate,
                        );
                        if (completed && context.mounted) {
                          context.read<SalesRegisterCubit>().clearInvoice();
                          context.read<CheckoutCubit>().reset();
                          unawaited(
                            context
                                .read<TransactionHistoryCubit>()
                                .load(),
                          );
                        }
                      },
                icon: const Icon(Icons.point_of_sale),
                label: const Text('Checkout'),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Keypad panel
// ---------------------------------------------------------------------------

class _KeypadPanel extends StatelessWidget {
  const _KeypadPanel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          KeypadDisplay(),
          SizedBox(height: 8),
          NumKeypad(),
        ],
      ),
    );
  }
}
