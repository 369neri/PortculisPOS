import 'dart:convert';
import 'dart:io';

import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_status.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/customers/domain/entities/customer.dart';
import 'package:cashier_app/features/customers/domain/repositories/customer_repository.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/items/domain/repositories/item_repository.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';
import 'package:cashier_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  BackupService(
    this._itemRepo,
    this._transactionRepo,
    this._customerRepo,
    this._settingsRepo,
  );

  final ItemRepository _itemRepo;
  final TransactionRepository _transactionRepo;
  final CustomerRepository _customerRepo;
  final SettingsRepository _settingsRepo;

  @visibleForTesting
  Map<String, dynamic> encodeItemForTest(Item item) => _encodeItem(item);

  @visibleForTesting
  Item? decodeItemForTest(Map<String, dynamic> map) => _decodeItem(map);

  // -----------------------------------------------------------------------
  // Export
  // -----------------------------------------------------------------------

  /// Export all data to a JSON file and return its path.
  Future<String> exportBackup() async {
    final items = await _itemRepo.getAll();
    final transactions = await _transactionRepo.getAll();
    final customers = await _customerRepo.getAll();
    final settings = await _settingsRepo.getSettings();

    final data = {
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'items': items.map(_encodeItem).toList(),
      'transactions': transactions.map(_encodeTransaction).toList(),
      'customers': customers.map(_encodeCustomer).toList(),
      'settings': _encodeSettings(settings),
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

  // -----------------------------------------------------------------------
  // Import
  // -----------------------------------------------------------------------

  /// Import data from a JSON backup file. Returns the count of items imported.
  Future<int> importBackup(String filePath) async {
    final content = await File(filePath).readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;

    final version = data['version'] as int? ?? 0;
    if (version < 1 || version > 2) {
      throw FormatException('Unsupported backup version: $version');
    }

    var count = 0;

    // Items (v1 + v2)
    final itemsJson = data['items'] as List<dynamic>? ?? [];
    for (final raw in itemsJson) {
      final map = raw as Map<String, dynamic>;
      final item = _decodeItem(map);
      if (item != null) {
        await _itemRepo.save(item);
        count++;
      }
    }

    // Transactions (v2 only)
    if (version >= 2) {
      final txnsJson = data['transactions'] as List<dynamic>? ?? [];
      for (final raw in txnsJson) {
        final txn = _decodeTransaction(raw as Map<String, dynamic>);
        if (txn != null) {
          await _transactionRepo.save(txn);
          count++;
        }
      }

      // Customers
      final customersJson = data['customers'] as List<dynamic>? ?? [];
      for (final raw in customersJson) {
        final customer = _decodeCustomer(raw as Map<String, dynamic>);
        if (customer != null) {
          await _customerRepo.save(customer);
          count++;
        }
      }

      // Settings
      if (data.containsKey('settings') && data['settings'] != null) {
        final settings =
            _decodeSettings(data['settings'] as Map<String, dynamic>);
        if (settings != null) {
          await _settingsRepo.saveSettings(settings);
        }
      }
    }

    return count;
  }

  // -----------------------------------------------------------------------
  // Item encode / decode
  // -----------------------------------------------------------------------

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

  // -----------------------------------------------------------------------
  // Transaction encode / decode
  // -----------------------------------------------------------------------

  Map<String, dynamic> _encodeTransaction(Transaction txn) => {
        'invoiceNumber': txn.invoiceNumber,
        'status': txn.status.name,
        'createdAt': txn.createdAt.toIso8601String(),
        'invoiceItems': txn.invoice.items.map((li) => {
              'item': _encodeItem(li.item),
              'quantity': li.quantity,
            },).toList(),
        'invoiceStatus': txn.invoice.status.name,
        'payments': txn.payments.map((p) => {
              'method': p.method.name,
              'amount': p.amount.value.toString(),
            },).toList(),
      };

  Transaction? _decodeTransaction(Map<String, dynamic> map) {
    try {
      final lineItems = (map['invoiceItems'] as List<dynamic>)
          .map((li) {
            final liMap = li as Map<String, dynamic>;
            final item = _decodeItem(liMap['item'] as Map<String, dynamic>);
            if (item == null) return null;
            return InvoiceItem(
              item: item,
              quantity: liMap['quantity'] as int? ?? 1,
            );
          })
          .whereType<InvoiceItem>()
          .toList();

      final invoiceStatus = InvoiceStatus.values.firstWhere(
        (s) => s.name == (map['invoiceStatus'] as String? ?? 'processed'),
        orElse: () => InvoiceStatus.processed,
      );

      final payments = (map['payments'] as List<dynamic>?)
              ?.map((p) {
                final pMap = p as Map<String, dynamic>;
                final method = PaymentMethod.values.firstWhere(
                  (m) => m.name == pMap['method'],
                  orElse: () => PaymentMethod.cash,
                );
                final amount = Price(
                  BigInt.tryParse(pMap['amount']?.toString() ?? '0') ??
                      BigInt.zero,
                );
                return Payment(method: method, amount: amount);
              })
              .toList() ??
          [];

      final status = TransactionStatus.values.firstWhere(
        (s) => s.name == (map['status'] as String? ?? 'completed'),
        orElse: () => TransactionStatus.completed,
      );

      return Transaction(
        invoiceNumber: map['invoiceNumber'] as String?,
        invoice: Invoice(items: lineItems, status: invoiceStatus),
        payments: payments,
        status: status,
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
    } on Object catch (_) {
      return null;
    }
  }

  // -----------------------------------------------------------------------
  // Customer encode / decode
  // -----------------------------------------------------------------------

  Map<String, dynamic> _encodeCustomer(Customer c) => {
        'name': c.name,
        'phone': c.phone,
        'email': c.email,
        'notes': c.notes,
        'createdAt': c.createdAt?.toIso8601String(),
      };

  Customer? _decodeCustomer(Map<String, dynamic> map) {
    final name = map['name'] as String?;
    if (name == null || name.isEmpty) return null;
    return Customer(
      name: name,
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
    );
  }

  // -----------------------------------------------------------------------
  // Settings encode / decode
  // -----------------------------------------------------------------------

  Map<String, dynamic> _encodeSettings(AppSettings s) => {
        'businessName': s.businessName,
        'taxRate': s.taxRate,
        'currencySymbol': s.currencySymbol,
        'receiptFooter': s.receiptFooter,
        'lastZReportAt': s.lastZReportAt?.toIso8601String(),
      };

  AppSettings? _decodeSettings(Map<String, dynamic> map) {
    try {
      return AppSettings(
        businessName: map['businessName'] as String? ?? 'My Business',
        taxRate: (map['taxRate'] as num?)?.toDouble() ?? 0.0,
        currencySymbol: map['currencySymbol'] as String? ?? r'$',
        receiptFooter:
            map['receiptFooter'] as String? ?? 'Thank you for your business!',
        lastZReportAt:
            DateTime.tryParse(map['lastZReportAt'] as String? ?? ''),
      );
    } on Object catch (_) {
      return null;
    }
  }
}
