import 'dart:io';

import 'package:cashier_app/core/di/service_locator.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/items/presentation/pages/csv_import_page.dart';
import 'package:cashier_app/features/items/presentation/state/item_catalog_cubit.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// ---------------------------------------------------------------------------
// Predefined category presets
// ---------------------------------------------------------------------------

const _categoryPresets = <String>[
  'Electronics',
  'USB / Cables',
  'Food & Drinks',
  'Clothing',
  'Services',
  'Parts',
  'Accessories',
  'Stationery',
  'Other',
];

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// View (stateful for search + category filter)
// ---------------------------------------------------------------------------

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
      result = result
          .where((i) =>
              (i.label?.toLowerCase().contains(q) ?? false) ||
              (i.sku?.toLowerCase().contains(q) ?? false) ||
              i.category.toLowerCase().contains(q),)
          .toList();
    }
    if (_selectedCategory != null) {
      result =
          result.where((i) => i.category == _selectedCategory).toList();
    }
    return result;
  }

  Set<String> _extractCategories(List<Item> items) {
    return items
        .map((i) => i.category)
        .where((c) => c.isNotEmpty)
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ItemCatalogCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Catalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Import CSV',
            onPressed: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const CsvImportPage()),
              );
              if (context.mounted) cubit.load();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemForm(context, cubit: cubit),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      body: BlocBuilder<ItemCatalogCubit, ItemCatalogState>(
        builder: (context, state) {
          return switch (state) {
            ItemCatalogLoading() =>
              const Center(child: CircularProgressIndicator()),
            ItemCatalogError(message: final msg) =>
              Center(child: Text('Error: $msg')),
            ItemCatalogLoaded(items: final allItems) => _buildBody(
                context,
                allItems,
                cubit,
              ),
          };
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<Item> allItems,
    ItemCatalogCubit cubit,
  ) {
    final categories = _extractCategories(allItems);
    final filtered = _applyFilters(allItems);

    return Column(
      children: [
        // -- Search bar --
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search by name, SKU, or category\u2026',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () =>
                          setState(() => _searchQuery = ''),
                    )
                  : null,
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),

        // -- Category filter chips --
        if (categories.isNotEmpty)
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: _selectedCategory == null,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = null),
                  ),
                ),
                for (final cat in categories.toList()..sort())
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4),
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

        // -- Item count label --
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${filtered.length} item${filtered.length == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),

        // -- Item list --
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No items match'))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      _ItemTile(item: filtered[index], cubit: cubit),
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
}

// ---------------------------------------------------------------------------
// Item tile with visible edit / delete actions
// ---------------------------------------------------------------------------

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item, required this.cubit});

  final Item item;
  final ItemCatalogCubit cubit;

  @override
  Widget build(BuildContext context) {
    final stockText =
        item.stockQuantity >= 0 ? ' \u2022 Stock: ${item.stockQuantity}' : '';
    final catText =
        item.category.isNotEmpty ? '${item.category} \u2022 ' : '';
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            // -- Image or icon avatar --
            _itemAvatar(item),
            const SizedBox(width: 12),

            // -- Name / subtitle / price --
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.label ?? item.sku ?? 'Unknown',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      if (item.isFavorite)
                        const Icon(Icons.star, size: 18, color: Colors.amber),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$catText${item.sku ?? ""}$stockText',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.unitPrice.toString(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // -- Action buttons (always visible) --
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: () => _edit(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Delete',
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  void _edit(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ItemFormSheet(existing: item, cubit: cubit),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text(
          'Are you sure you want to delete "${item.label ?? item.sku ?? "this item"}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              if (item.sku != null) cubit.deleteBySku(item.sku!);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _itemAvatar(Item item) {
    if (item.imagePath != null && item.imagePath!.isNotEmpty) {
      final file = File(item.imagePath!);
      if (file.existsSync()) {
        return CircleAvatar(
          backgroundImage: FileImage(file),
          radius: 24,
        );
      }
    }
    return CircleAvatar(
      radius: 24,
      child: Icon(
        item is ServiceItem ? Icons.build : Icons.inventory_2,
      ),
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
  String? _imagePath;

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
    _imagePath = item?.imagePath;
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

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;
    if (picked.path == null) return;

    // Copy to app documents directory so it persists
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(appDir.path, 'item_images'));
    if (!imagesDir.existsSync()) imagesDir.createSync(recursive: true);

    final ext = p.extension(picked.path!);
    final destName = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final destPath = p.join(imagesDir.path, destName);
    await File(picked.path!).copy(destPath);

    setState(() => _imagePath = destPath);
  }

  void _removeImage() => setState(() => _imagePath = null);

  void _save() {
    if (!_formKey.currentState!.validate()) return;

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
            imagePath: _imagePath,
          )
        : TradeItem(
            sku: _skuCtrl.text.trim(),
            label: _labelCtrl.text.trim(),
            unitPrice: price,
            category: category,
            stockQuantity: stockQuantity,
            isFavorite: _isFavorite,
            imagePath: _imagePath,
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing == null ? 'Add Item' : 'Edit Item',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // -- Image picker --
              Center(child: _imagePickerWidget()),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(
                      value: 'trade', child: Text('Trade item'),),
                  DropdownMenuItem(
                      value: 'service', child: Text('Service'),),
                ],
                onChanged: (v) =>
                    setState(() => _type = v ?? 'trade'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _skuCtrl,
                decoration: const InputDecoration(labelText: 'SKU'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'SKU is required'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _labelCtrl,
                decoration: const InputDecoration(labelText: 'Label'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Label is required'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Unit price',
                  hintText: '0.00',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Price is required';
                  }
                  final parsed =
                      double.tryParse(v.replaceAll(',', '.'));
                  if (parsed == null || parsed < 0) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // -- Category with autocomplete --
              _categoryField(),
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
                child: Text(
                    widget.existing == null ? 'Add' : 'Save',),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -- Image picker widget with preview --
  Widget _imagePickerWidget() {
    if (_imagePath != null && _imagePath!.isNotEmpty) {
      final file = File(_imagePath!);
      if (file.existsSync()) {
        return Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                file,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
              ),
              onPressed: _removeImage,
            ),
          ],
        );
      }
    }
    return OutlinedButton.icon(
      onPressed: _pickImage,
      icon: const Icon(Icons.add_a_photo),
      label: const Text('Add Image'),
    );
  }

  // -- Category autocomplete with presets --
  Widget _categoryField() {
    return Autocomplete<String>(
      initialValue: _categoryCtrl.value,
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.toLowerCase();
        if (query.isEmpty) return _categoryPresets;
        return _categoryPresets
            .where((c) => c.toLowerCase().contains(query));
      },
      fieldViewBuilder:
          (context, controller, focusNode, onFieldSubmitted) {
        // Keep our state controller in sync
        controller.addListener(() {
          _categoryCtrl.text = controller.text;
        });
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Category',
            hintText: 'Select or type a category',
            suffixIcon: Icon(Icons.arrow_drop_down),
          ),
        );
      },
      onSelected: (selection) {
        _categoryCtrl.text = selection;
      },
    );
  }
}
