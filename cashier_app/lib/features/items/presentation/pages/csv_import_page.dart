import 'dart:io';

import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/items/domain/repositories/item_repository.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CsvImportPage extends StatefulWidget {
  const CsvImportPage({super.key});

  @override
  State<CsvImportPage> createState() => _CsvImportPageState();
}

class _CsvImportPageState extends State<CsvImportPage> {
  List<List<dynamic>>? _rows;
  List<String> _headers = [];
  String? _error;
  bool _importing = false;
  int _imported = 0;
  int _skipped = 0;

  // Column mapping (index in CSV → field)
  int? _skuCol;
  int? _labelCol;
  int? _priceCol;
  int? _categoryCol;
  int? _stockCol;
  int? _typeCol;

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt'],
    );
    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;

    try {
      final content = await File(path).readAsString();
      final parsed = const CsvToListConverter().convert(content);
      if (parsed.isEmpty) {
        setState(() {
          _error = 'CSV file is empty';
          _rows = null;
        });
        return;
      }

      final headers =
          parsed.first.map((e) => e.toString().trim()).toList();
      setState(() {
        _headers = headers;
        _rows = parsed.length > 1 ? parsed.sublist(1) : [];
        _error = null;
        _imported = 0;
        _skipped = 0;
        _autoMapColumns(headers);
      });
    } on Exception catch (e) {
      setState(() {
        _error = 'Failed to parse CSV: $e';
        _rows = null;
      });
    }
  }

  void _autoMapColumns(List<String> headers) {
    _skuCol = _labelCol = _priceCol = _categoryCol = _stockCol = _typeCol = null;

    for (var i = 0; i < headers.length; i++) {
      final h = headers[i].toLowerCase();
      if (h.contains('sku') || h.contains('barcode') || h.contains('code')) {
        _skuCol ??= i;
      } else if (h.contains('name') || h.contains('label') || h.contains('description')) {
        _labelCol ??= i;
      } else if (h.contains('price') || h.contains('cost') || h.contains('amount')) {
        _priceCol ??= i;
      } else if (h.contains('category') || h.contains('cat') || h.contains('group')) {
        _categoryCol ??= i;
      } else if (h.contains('stock') || h.contains('qty') || h.contains('quantity')) {
        _stockCol ??= i;
      } else if (h.contains('type')) {
        _typeCol ??= i;
      }
    }
  }

  Future<void> _runImport() async {
    if (_rows == null || _skuCol == null || _labelCol == null || _priceCol == null) return;
    setState(() {
      _importing = true;
      _imported = 0;
      _skipped = 0;
    });

    final repo = GetIt.instance<ItemRepository>();
    for (final row in _rows!) {
      try {
        final sku = _cellStr(row, _skuCol!);
        final label = _cellStr(row, _labelCol!);
        final priceStr = _cellStr(row, _priceCol!).replaceAll(',', '.');
        if (sku.isEmpty || label.isEmpty) {
          _skipped++;
          continue;
        }
        final priceDouble = double.tryParse(priceStr) ?? 0;
        final subunits = BigInt.from((priceDouble * 100).round());
        final price = Price(subunits);
        final category = _categoryCol != null ? _cellStr(row, _categoryCol!) : '';
        final stockStr = _stockCol != null ? _cellStr(row, _stockCol!) : '';
        final stockQty = stockStr.isEmpty ? -1 : (int.tryParse(stockStr) ?? -1);
        final typeStr = _typeCol != null ? _cellStr(row, _typeCol!).toLowerCase() : 'trade';

        final Item item;
        if (typeStr == 'service') {
          item = ServiceItem(
            sku: sku,
            label: label,
            unitPrice: price,
            category: category,
          );
        } else {
          item = TradeItem(
            sku: sku,
            label: label,
            unitPrice: price,
            category: category,
            stockQuantity: stockQty,
          );
        }
        await repo.save(item);
        _imported++;
      } on Exception {
        _skipped++;
      }
    }

    setState(() => _importing = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Imported $_imported items ($_skipped skipped)'),
      ),
    );
  }

  String _cellStr(List<dynamic> row, int index) {
    if (index >= row.length) return '';
    return row[index].toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Items from CSV')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: _importing ? null : _pickFile,
              icon: const Icon(Icons.file_open),
              label: const Text('Select CSV file'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            if (_rows != null) ...[
              const SizedBox(height: 16),
              Text(
                '${_rows!.length} row${_rows!.length == 1 ? "" : "s"} found',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),

              // Column mapping
              Text('Column mapping',
                  style: Theme.of(context).textTheme.titleSmall,),
              const SizedBox(height: 8),
              _ColumnMapper(
                headers: _headers,
                skuCol: _skuCol,
                labelCol: _labelCol,
                priceCol: _priceCol,
                categoryCol: _categoryCol,
                stockCol: _stockCol,
                typeCol: _typeCol,
                onChanged: (sku, label, price, category, stock, type) {
                  setState(() {
                    _skuCol = sku;
                    _labelCol = label;
                    _priceCol = price;
                    _categoryCol = category;
                    _stockCol = stock;
                    _typeCol = type;
                  });
                },
              ),
              const SizedBox(height: 12),

              // Preview
              Expanded(child: _buildPreviewTable()),

              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: (_importing ||
                        _skuCol == null ||
                        _labelCol == null ||
                        _priceCol == null)
                    ? null
                    : _runImport,
                icon: _importing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload),
                label: Text(_importing
                    ? 'Importing\u2026'
                    : 'Import ${_rows!.length} items',),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewTable() {
    if (_rows == null || _rows!.isEmpty) {
      return const Center(child: Text('No data rows'));
    }
    final previewRows = _rows!.take(50).toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: [
            for (final h in _headers) DataColumn(label: Text(h)),
          ],
          rows: [
            for (final row in previewRows)
              DataRow(
                cells: [
                  for (int i = 0; i < _headers.length; i++)
                    DataCell(Text(
                      i < row.length ? row[i].toString() : '',
                      overflow: TextOverflow.ellipsis,
                    ),),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Column mapper widget
// ---------------------------------------------------------------------------

class _ColumnMapper extends StatelessWidget {
  const _ColumnMapper({
    required this.headers,
    required this.skuCol,
    required this.labelCol,
    required this.priceCol,
    required this.categoryCol,
    required this.stockCol,
    required this.typeCol,
    required this.onChanged,
  });

  final List<String> headers;
  final int? skuCol;
  final int? labelCol;
  final int? priceCol;
  final int? categoryCol;
  final int? stockCol;
  final int? typeCol;
  final void Function(
    int? sku,
    int? label,
    int? price,
    int? category,
    int? stock,
    int? type,
  ) onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _dropdown('SKU *', skuCol, (v) => onChanged(v, labelCol, priceCol, categoryCol, stockCol, typeCol)),
        _dropdown('Label *', labelCol, (v) => onChanged(skuCol, v, priceCol, categoryCol, stockCol, typeCol)),
        _dropdown('Price *', priceCol, (v) => onChanged(skuCol, labelCol, v, categoryCol, stockCol, typeCol)),
        _dropdown('Category', categoryCol, (v) => onChanged(skuCol, labelCol, priceCol, v, stockCol, typeCol)),
        _dropdown('Stock', stockCol, (v) => onChanged(skuCol, labelCol, priceCol, categoryCol, v, typeCol)),
        _dropdown('Type', typeCol, (v) => onChanged(skuCol, labelCol, priceCol, categoryCol, stockCol, v)),
      ],
    );
  }

  Widget _dropdown(String label, int? value, ValueChanged<int?> onChanged) {
    return SizedBox(
      width: 160,
      child: DropdownButtonFormField<int?>(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
        initialValue: value,
        items: [
          const DropdownMenuItem<int?>(child: Text('—')),
          for (int i = 0; i < headers.length; i++)
            DropdownMenuItem(value: i, child: Text(headers[i])),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
