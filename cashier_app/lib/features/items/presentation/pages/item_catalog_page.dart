import 'package:cashier_app/core/di/service_locator.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/items/presentation/state/item_catalog_cubit.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemCatalogPage extends StatelessWidget {
  const ItemCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ItemCatalogCubit>(
      create: (_) => sl<ItemCatalogCubit>()..load(),
      child: const _ItemCatalogView(),
    );
  }
}

class _ItemCatalogView extends StatefulWidget {
  const _ItemCatalogView();

  @override
  State<_ItemCatalogView> createState() => _ItemCatalogViewState();
}

class _ItemCatalogViewState extends State<_ItemCatalogView> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Item> _applyFilter(List<Item> items) {
    if (_query.isEmpty) return items;
    final q = _query.toLowerCase();
    return items.where((item) {
      final label = item.label?.toLowerCase() ?? '';
      final sku = item.sku?.toLowerCase() ?? '';
      final gtin = (item is TradeItem) ? (item.gtin?.toLowerCase() ?? '') : '';
      return label.contains(q) || sku.contains(q) || gtin.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Catalog')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemForm(context, cubit: context.read()),
        tooltip: 'Add item',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search by name, SKU, or GTIN...',
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          Expanded(
            child: BlocBuilder<ItemCatalogCubit, ItemCatalogState>(
              builder: (context, state) {
                return switch (state) {
                  ItemCatalogLoading() =>
                    const Center(child: CircularProgressIndicator()),
                  ItemCatalogError(message: final msg) =>
                    Center(child: Text('Error: $msg')),
                  ItemCatalogLoaded(items: final items) => () {
                      final filtered = _applyFilter(items);
                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(
                            _query.isEmpty
                                ? 'No items in catalog'
                                : 'No items match "$_query"',
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return ListTile(
                            leading: Icon(_iconFor(item)),
                            title:
                                Text(item.label ?? item.sku ?? 'Unknown'),
                            subtitle: _buildSubtitle(context, item),
                            trailing: Text(
                              item.unitPrice.toString(),
                              style:
                                  Theme.of(context).textTheme.bodyLarge,
                            ),
                            onTap: () => _showItemForm(
                              context,
                              item: item,
                              cubit: context.read(),
                            ),
                            onLongPress: () => _confirmDelete(
                              context,
                              item: item,
                              cubit: context.read(),
                            ),
                          );
                        },
                      );
                    }(),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildSubtitle(BuildContext context, Item item) {
    final parts = <String>[];
    if (item.sku != null) parts.add(item.sku!);
    if (item is TradeItem && item.gtin != null) parts.add('GTIN: ${item.gtin}');
    if (parts.isEmpty) return null;
    return Text(
      parts.join('  ·  '),
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  IconData _iconFor(Item item) => switch (item) {
        ServiceItem() => Icons.home_repair_service_outlined,
        TradeItem() => Icons.inventory_2_outlined,
        KeyedPriceItem() => Icons.keyboard,
      };

  void _showItemForm(
    BuildContext context, {
    required ItemCatalogCubit cubit,
    Item? item,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ItemFormSheet(existing: item, cubit: cubit),
    );
  }

  void _confirmDelete(
    BuildContext context, {
    required ItemCatalogCubit cubit,
    required Item item,
  }) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text(item.label ?? item.sku ?? 'This item'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (item.sku != null) {
                cubit.deleteBySku(item.sku!);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Item form bottom sheet (with GTIN field for trade items)
// ---------------------------------------------------------------------------

class _ItemFormSheet extends StatefulWidget {
  const _ItemFormSheet({required this.cubit, this.existing});

  final Item? existing;
  final ItemCatalogCubit cubit;

  @override
  State<_ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends State<_ItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _skuCtrl;
  late final TextEditingController _labelCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _gtinCtrl;
  String _type = 'trade';

  @override
  void initState() {
    super.initState();
    final item = widget.existing;
    _skuCtrl = TextEditingController(text: item?.sku ?? '');
    _labelCtrl = TextEditingController(text: item?.label ?? '');
    _priceCtrl = TextEditingController(
      text: item != null ? item.unitPrice.toString() : '',
    );
    _gtinCtrl = TextEditingController(
      text: (item is TradeItem) ? (item.gtin ?? '') : '',
    );
    if (item is ServiceItem) _type = 'service';
  }

  @override
  void dispose() {
    _skuCtrl.dispose();
    _labelCtrl.dispose();
    _priceCtrl.dispose();
    _gtinCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // Parse price: user enters decimal (e.g. "3.50") -> store as subunits (350)
    final priceText = _priceCtrl.text.trim().replaceAll(',', '.');
    final priceDouble = double.tryParse(priceText) ?? 0;
    final subunits = BigInt.from((priceDouble * 100).round());
    final price = Price(subunits);

    final gtinText = _gtinCtrl.text.trim();

    final newItem = _type == 'service'
        ? ServiceItem(
            sku: _skuCtrl.text.trim(),
            label: _labelCtrl.text.trim(),
            unitPrice: price,
          )
        : TradeItem(
            sku: _skuCtrl.text.trim(),
            label: _labelCtrl.text.trim(),
            unitPrice: price,
            gtin: gtinText.isNotEmpty ? gtinText : null,
          );

    widget.cubit.save(newItem);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? 'Add Item' : 'Edit Item',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: const [
                DropdownMenuItem(value: 'trade', child: Text('Trade item')),
                DropdownMenuItem(value: 'service', child: Text('Service')),
              ],
              onChanged: (v) => setState(() => _type = v ?? 'trade'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _skuCtrl,
              decoration: const InputDecoration(labelText: 'SKU'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'SKU is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _labelCtrl,
              decoration: const InputDecoration(labelText: 'Label'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Label is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceCtrl,
              decoration: const InputDecoration(
                labelText: 'Unit price',
                hintText: '0.00',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Price is required';
                final parsed = double.tryParse(v.replaceAll(',', '.'));
                if (parsed == null || parsed < 0) return 'Enter a valid price';
                return null;
              },
            ),
            if (_type == 'trade') ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _gtinCtrl,
                decoration: const InputDecoration(
                  labelText: 'GTIN / Barcode',
                  hintText: 'e.g. 5901234123457',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _save,
              child: Text(widget.existing == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
