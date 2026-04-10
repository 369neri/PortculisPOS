import 'dart:async' show Timer, unawaited;

import 'package:cashier_app/core/di/service_locator.dart';
import 'package:cashier_app/core/layout/responsive_layout.dart';
import 'package:cashier_app/features/billing/presentation/state/sales_register_cubit.dart';
import 'package:cashier_app/features/billing/presentation/state/sales_register_state.dart';
import 'package:cashier_app/features/billing/presentation/widgets/invoice_line_item.dart';
import 'package:cashier_app/features/billing/presentation/widgets/invoice_summary.dart';
import 'package:cashier_app/features/cash_drawer/presentation/state/cash_drawer_cubit.dart';
import 'package:cashier_app/features/cash_drawer/presentation/state/cash_drawer_state.dart';
import 'package:cashier_app/features/checkout/presentation/pages/checkout_page.dart';
import 'package:cashier_app/features/checkout/presentation/state/checkout_cubit.dart';
import 'package:cashier_app/features/checkout/presentation/state/transaction_history_cubit.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/items/domain/repositories/item_repository.dart';
import 'package:cashier_app/features/items/presentation/state/item_lookup_cubit.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/pricing/presentation/state/keypad_cubit.dart';
import 'package:cashier_app/features/pricing/presentation/state/keypad_cubit_state.dart';
import 'package:cashier_app/features/pricing/presentation/widgets/keypad_display.dart';
import 'package:cashier_app/features/pricing/presentation/widgets/num_keypad.dart';
import 'package:cashier_app/features/scanning/presentation/pages/barcode_scanner_page.dart';
import 'package:cashier_app/features/settings/presentation/state/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
// SKU / barcode search bar with autofocus & global keyboard capture
// ---------------------------------------------------------------------------

class _SkuSearchBar extends StatefulWidget {
  const _SkuSearchBar();

  @override
  State<_SkuSearchBar> createState() => _SkuSearchBarState();
}

class _SkuSearchBarState extends State<_SkuSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  /// Buffer for capturing barcode scanner keystrokes when the text field
  /// does not have focus.  Scanners type very fast (< 50 ms between chars)
  /// and terminate with Enter.
  final _scanBuffer = StringBuffer();
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field on first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    unawaited(context.read<ItemLookupCubit>().lookupBySku(query));
  }

  Future<void> _showCatalogPicker(BuildContext context) async {
    final item = await showDialog<Item>(
      context: context,
      builder: (_) => const _CatalogPickerDialog(),
    );
    if (item != null && context.mounted) {
      context.read<SalesRegisterCubit>().addCatalogItem(item);
    }
  }

  Future<void> _openCameraScanner(BuildContext context) async {
    final barcode = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );
    if (barcode != null && barcode.isNotEmpty && context.mounted) {
      unawaited(context.read<ItemLookupCubit>().lookupBySku(barcode));
    }
  }

  /// Re-request focus so consecutive scans work seamlessly.
  void _refocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  // -----------------------------------------------------------------------
  // Global keyboard handler – captures barcode input when the TextField
  // does not have focus.
  // -----------------------------------------------------------------------

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    // Only act when the TextField itself does NOT have focus.
    if (_focusNode.hasFocus) return KeyEventResult.ignored;

    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    // Enter → submit whatever is in the buffer.
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (_scanBuffer.isNotEmpty) {
        _submit(_scanBuffer.toString());
        _scanBuffer.clear();
        _scanTimer?.cancel();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    // Accept printable characters.
    final char = event.character;
    if (char != null && char.length == 1) {
      _scanBuffer.write(char);
      // Reset the idle timer — if no keystroke arrives within 300 ms the
      // buffer is cleared (the user was probably just pressing random keys,
      // not using a scanner).
      _scanTimer?.cancel();
      _scanTimer = Timer(
        const Duration(milliseconds: 300),
        _scanBuffer.clear,
      );
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _onKeyEvent,
      child: BlocListener<ItemLookupCubit, ItemLookupState>(
        listener: (context, state) {
          if (state is ItemLookupFound) {
            context.read<SalesRegisterCubit>().addCatalogItem(state.item);
            _controller.clear();
            context.read<ItemLookupCubit>().reset();
            HapticFeedback.mediumImpact();
            _refocus();
          } else if (state is ItemLookupNotFound) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Item not found: ${state.query}')),
            );
            _controller.clear();
            context.read<ItemLookupCubit>().reset();
            _refocus();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.barcode_reader),
                    hintText: 'Scan barcode or enter SKU',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: _submit,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () => _showCatalogPicker(context),
                icon: const Icon(Icons.inventory_2_outlined),
                tooltip: 'Browse catalog',
              ),
              const SizedBox(width: 4),
              IconButton.filled(
                onPressed: () => _openCameraScanner(context),
                icon: const Icon(Icons.camera_alt_outlined),
                tooltip: 'Scan with camera',
              ),
            ],
          ),
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
                          onQuantityChanged: (qty) => context
                              .read<SalesRegisterCubit>()
                              .updateQuantity(index, qty),
                          onDiscountChanged: (pct, amt) => context
                              .read<SalesRegisterCubit>()
                              .updateDiscount(index,
                                  discountPercent: pct,
                                  discountAmount: amt,),
                        );
                      },
                    ),
            ),
            InvoiceSummary(invoice: state.invoice),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: items.isEmpty
                          ? null
                          : () => context
                              .read<SalesRegisterCubit>()
                              .holdInvoice(),
                      icon: const Icon(Icons.pause_circle_outline, size: 18),
                      label: const Text('Hold'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Badge(
                      isLabelVisible: state.heldInvoices.isNotEmpty,
                      label: Text('${state.heldInvoices.length}'),
                      child: OutlinedButton.icon(
                        onPressed: state.heldInvoices.isEmpty
                            ? null
                            : () => _showHeldInvoicesSheet(context),
                        icon: const Icon(Icons.replay, size: 18),
                        label: const Text('Recall'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: FilledButton.icon(
                onPressed: items.isEmpty
                    ? null
                    : () async {
                        // Check if cash drawer is open
                        final drawerState =
                            context.read<CashDrawerCubit>().state;
                        if (drawerState is! CashDrawerOpen &&
                            context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Open the cash drawer before checking out',
                              ),
                            ),
                          );
                          return;
                        }
                        final settingsState =
                            context.read<SettingsCubit>().state;
                        final taxRate = settingsState is SettingsReady
                            ? settingsState.settings.taxRate
                            : 0.0;
                        final taxInclusive = settingsState is SettingsReady && settingsState.settings.taxInclusive;
                        final completed = await showCheckoutSheet(
                          context,
                          state.invoice,
                          taxRate: taxRate,
                          taxInclusive: taxInclusive,
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

void _showHeldInvoicesSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    builder: (_) => BlocProvider.value(
      value: context.read<SalesRegisterCubit>(),
      child: BlocBuilder<SalesRegisterCubit, SalesRegisterState>(
        builder: (ctx, state) {
          final held = state.heldInvoices;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Held Invoices (${held.length})',
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (held.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('No held invoices')),
                  )
                else
                  ...List.generate(held.length, (i) {
                    final inv = held[i];
                    final itemCount = inv.items.length;
                    final total = inv.total;
                    return ListTile(
                      leading: CircleAvatar(child: Text('${i + 1}')),
                      title: Text(
                        '$itemCount item${itemCount == 1 ? '' : 's'}',
                      ),
                      subtitle: Text(total.toString()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FilledButton(
                            onPressed: () {
                              ctx
                                  .read<SalesRegisterCubit>()
                                  .recallInvoice(i);
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('Recall'),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => ctx
                                .read<SalesRegisterCubit>()
                                .discardHeldInvoice(i),
                            tooltip: 'Discard',
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Keypad panel
// ---------------------------------------------------------------------------

class _KeypadPanel extends StatelessWidget {
  const _KeypadPanel();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dialpad), text: 'Keypad'),
              Tab(icon: Icon(Icons.star), text: 'Favorites'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      KeypadDisplay(),
                      SizedBox(height: 8),
                      NumKeypad(),
                    ],
                  ),
                ),
                _FavoritesGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Favorites quick-add grid
// ---------------------------------------------------------------------------

class _FavoritesGrid extends StatefulWidget {
  @override
  State<_FavoritesGrid> createState() => _FavoritesGridState();
}

class _FavoritesGridState extends State<_FavoritesGrid> {
  List<Item> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await sl<ItemRepository>().getFavorites();
    if (!mounted) return;
    setState(() {
      _favorites = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_favorites.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No favorites yet.\nMark items as favorites in the Item Catalog.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final item = _favorites[index];
        return _FavoriteTile(
          item: item,
          onTap: () {
            context.read<SalesRegisterCubit>().addCatalogItem(item);
            HapticFeedback.mediumImpact();
          },
        );
      },
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({required this.item, required this.onTap});

  final Item item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.label ?? item.sku ?? '?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                item.unitPrice.toString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Catalog picker dialog
// ---------------------------------------------------------------------------

class _CatalogPickerDialog extends StatefulWidget {
  const _CatalogPickerDialog();

  @override
  State<_CatalogPickerDialog> createState() => _CatalogPickerDialogState();
}

class _CatalogPickerDialogState extends State<_CatalogPickerDialog> {
  final _searchController = TextEditingController();
  List<Item> _allItems = [];
  List<Item> _filtered = [];
  bool _loading = true;
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final items = await sl<ItemRepository>().getAll();
    if (!mounted) return;
    setState(() {
      _allItems = items;
      _loading = false;
      _applyFilters();
    });
  }

  List<String> get _categories {
    final cats = _allItems
        .map((e) => e.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return cats;
  }

  void _applyFilters() {
    final q = _searchController.text.toLowerCase();
    var items = _allItems;
    if (_selectedCategory.isNotEmpty) {
      items = items.where((i) => i.category == _selectedCategory).toList();
    }
    if (q.isNotEmpty) {
      items = items.where((item) {
        final label = item.label?.toLowerCase() ?? '';
        final sku = item.sku?.toLowerCase() ?? '';
        return label.contains(q) || sku.contains(q);
      }).toList();
    }
    _filtered = items;
  }

  void _filter(String query) {
    setState(_applyFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add from Catalog',
                  style: Theme.of(context).textTheme.titleMedium,),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search items...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: _filter,
              ),
              if (_categories.isNotEmpty) ...[
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _selectedCategory.isEmpty,
                        onSelected: (_) => setState(() {
                          _selectedCategory = '';
                          _applyFilters();
                        }),
                      ),
                      const SizedBox(width: 6),
                      ..._categories.map((cat) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: _selectedCategory == cat,
                              onSelected: (_) => setState(() {
                                _selectedCategory = cat;
                                _applyFilters();
                              }),
                            ),
                          ),),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Flexible(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _filtered.isEmpty
                        ? const Center(child: Text('No items found'))
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              final item = _filtered[index];
                              return _CatalogPickerTile(
                                item: item,
                                onTap: () =>
                                    Navigator.of(context).pop(item),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogPickerTile extends StatelessWidget {
  const _CatalogPickerTile({required this.item, required this.onTap});

  final Item item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = switch (item) {
      TradeItem() => Icons.shopping_bag_outlined,
      ServiceItem() => Icons.build_outlined,
      KeyedPriceItem() => Icons.attach_money,
    };

    return ListTile(
      leading: Icon(icon),
      title: Text(item.label ?? item.sku ?? 'Unknown'),
      subtitle: item.sku != null ? Text(item.sku!) : null,
      trailing: Text(
        item.unitPrice.toString(),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      onTap: onTap,
    );
  }
}
