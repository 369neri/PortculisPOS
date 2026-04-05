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
  String _searchQuery = '';
  String? _selectedCategory;

  List<Item> _applyFilters(List<Item> items) {
    var result = items;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((item) {
        final label = item.label?.toLowerCase() ?? '';
        final sku = item.sku?.toLowerCase() ?? '';
        final category = item.category.toLowerCase();
        return label.contains(q) || sku.contains(q) || category.contains(q);
      }).toList();
    }
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      result = result.where((item) => item.category == _selectedCategory).toList();
    }
    return result;
  }

  Set<String> _extractCategories(List<Item> items) {
    return items.map((i) => i.category).where((c) => c.isNotEmpty).toSet();
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
      body: BlocBuilder<ItemCatalogCubit, ItemCatalogState>(
        builder: (context, state) {
          return switch (state) {
            ItemCatalogLoading() =>
              const Center(child: CircularProgressIndicator()),
            ItemCatalogError(message: final msg) =>
              Center(child: Text('Error: $msg')),
            ItemCatalogLoaded(items: final allItems) => _buildList(context, allItems),
          };
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Item> allItems) {
    final categories = _extractCategories(allItems);
    final filtered = _applyFilters(allItems);

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        // Category filter chips
        if (categories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: _selectedCategory == null,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = null),
                    ),
                  ),
                  for (final cat in categories.toList()..sort())
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(cat),
                        selected: _selectedCategory == cat,
                        onSelected: (_) => setState(
                          () => _selectedCategory =
                              _selectedCategory == cat ? null : cat,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 4),
        // Item count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${filtered.length} item${filtered.length == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // List
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No items found'))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _ItemTile(
                      item: item,
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
                ),
        ),
      ],
    );
  }

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
// Item tile
// ---------------------------------------------------------------------------

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  final Item item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final stockText =
        item.stockQuantity >= 0 ? ' • Stock: ${item.stockQuantity}' : '';
    final catText = item.category.isNotEmpty ? '${item.category} • ' : '';
    final icon = switch (item) {
      ServiceItem() => Icons.home_repair_service_outlined,
      TradeItem() => Icons.inventory_2_outlined,
      KeyedPriceItem() => Icons.keyboard,
    };

    return ListTile(
      leading: Icon(icon),
      title: Row(
        children: [
          Expanded(child: Text(item.label ?? item.sku ?? 'Unknown')),
          if (item.isFavorite)
            const Icon(Icons.star, size: 18, color: Colors.amber),
        ],
      ),
      subtitle: Text('$catText${item.sku ?? ""}$stockText'),
      trailing: Text(
        item.unitPrice.toString(),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}

// ---------------------------------------------------------------------------
// Item form bottom sheet
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
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _stockCtrl;
  String _type = 'trade';
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    final item = widget.existing;
    _skuCtrl = TextEditingController(text: item?.sku ?? '');
    _labelCtrl = TextEditingController(text: item?.label ?? '');
    _priceCtrl = TextEditingController(
      text: item != null ? item.unitPrice.toString() : '',
    );
    _categoryCtrl = TextEditingController(text: item?.category ?? '');
    _stockCtrl = TextEditingController(
      text: item != null && item.stockQuantity >= 0
          ? item.stockQuantity.toString()
          : '',
    );
    if (item is ServiceItem) _type = 'service';
    _isFavorite = item?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _skuCtrl.dispose();
    _labelCtrl.dispose();
    _priceCtrl.dispose();
    _categoryCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // Parse price: user enters decimal (e.g. "3.50") -> store as subunits (350)
    final priceText = _priceCtrl.text.trim().replaceAll(',', '.');
    final priceDouble = double.tryParse(priceText) ?? 0;
    final subunits = BigInt.from((priceDouble * 100).round());
    final price = Price(subunits);
    final category = _categoryCtrl.text.trim();
    final stockText = _stockCtrl.text.trim();
    final stockQuantity =
        stockText.isEmpty ? -1 : (int.tryParse(stockText) ?? -1);

    final newItem = _type == 'service'
        ? ServiceItem(
            sku: _skuCtrl.text.trim(),
            label: _labelCtrl.text.trim(),
            unitPrice: price,
            category: category,
            isFavorite: _isFavorite,
          )
        : TradeItem(
            sku: _skuCtrl.text.trim(),
            label: _labelCtrl.text.trim(),
            unitPrice: price,
            category: category,
            stockQuantity: stockQuantity,
            isFavorite: _isFavorite,
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
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(
                labelText: 'Category (optional)',
                hintText: 'e.g. Drinks, Food, Parts',
              ),
            ),
            const SizedBox(height: 12),
            if (_type == 'trade')
              TextFormField(
                controller: _stockCtrl,
                decoration: const InputDecoration(
                  labelText: 'Stock quantity (blank = untracked)',
                  hintText: 'Leave empty to disable tracking',
                ),
                keyboardType: TextInputType.number,
              ),
            if (_type == 'trade') const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Favorite (quick-add)'),
              value: _isFavorite,
              onChanged: (v) => setState(() => _isFavorite = v),
            ),
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
