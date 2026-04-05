import 'dart:convert';
import 'dart:io';

import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/items/domain/repositories/item_repository.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  BackupService(this._itemRepo, this._transactionRepo);

  final ItemRepository _itemRepo;
  final TransactionRepository _transactionRepo;

  /// Export items + transactions to a JSON file and share it.
  Future<String> exportBackup() async {
    final items = await _itemRepo.getAll();
    final transactions = await _transactionRepo.getAll();

    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'items': items.map(_encodeItem).toList(),
      'transactionCount': transactions.length,
    };

    final json = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final stamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
        '_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    final path = '${dir.path}/portculis_backup_$stamp.json';
    await File(path).writeAsString(json);
    return path;
  }

  Future<void> exportAndShare() async {
    final path = await exportBackup();
    await Share.shareXFiles([XFile(path)]);
  }

  /// Import items from a JSON backup file. Returns the count of items imported.
  Future<int> importBackup(String filePath) async {
    final content = await File(filePath).readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;

    final version = data['version'] as int? ?? 0;
    if (version != 1) {
      throw FormatException('Unsupported backup version: $version');
    }

    final itemsJson = data['items'] as List<dynamic>? ?? [];
    var count = 0;

    for (final raw in itemsJson) {
      final map = raw as Map<String, dynamic>;
      final item = _decodeItem(map);
      if (item != null) {
        await _itemRepo.save(item);
        count++;
      }
    }

    return count;
  }

  Map<String, dynamic> _encodeItem(Item item) {
    return switch (item) {
      TradeItem(
        :final sku,
        :final label,
        :final unitPrice,
        :final gtin,
        :final category,
        :final stockQuantity,
        :final isFavorite,
      ) =>
        {
          'type': 'trade',
          'sku': sku,
          'label': label,
          'unitPrice': unitPrice.value.toString(),
          'gtin': gtin,
          'category': category,
          'stockQuantity': stockQuantity,
          'isFavorite': isFavorite,
        },
      ServiceItem(
        :final sku,
        :final label,
        :final unitPrice,
        :final category,
        :final isFavorite,
      ) =>
        {
          'type': 'service',
          'sku': sku,
          'label': label,
          'unitPrice': unitPrice.value.toString(),
          'category': category,
          'isFavorite': isFavorite,
        },
      KeyedPriceItem(:final unitPrice) => {
          'type': 'keyed',
          'unitPrice': unitPrice.value.toString(),
        },
    };
  }

  Item? _decodeItem(Map<String, dynamic> map) {
    final type = map['type'] as String?;
    final priceVal = BigInt.tryParse(map['unitPrice']?.toString() ?? '0') ??
        BigInt.zero;
    final price = Price(priceVal);

    if (type == 'trade') {
      return TradeItem(
        sku: map['sku'] as String? ?? '',
        label: map['label'] as String? ?? '',
        unitPrice: price,
        gtin: map['gtin'] as String?,
        category: map['category'] as String? ?? '',
        stockQuantity: map['stockQuantity'] as int? ?? -1,
        isFavorite: map['isFavorite'] as bool? ?? false,
      );
    } else if (type == 'service') {
      return ServiceItem(
        sku: map['sku'] as String? ?? '',
        label: map['label'] as String? ?? '',
        unitPrice: price,
        category: map['category'] as String? ?? '',
        isFavorite: map['isFavorite'] as bool? ?? false,
      );
    }
    return null;
  }
}
