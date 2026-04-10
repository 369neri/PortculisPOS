import 'dart:convert';

import 'package:cashier_app/core/network/api_client.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_status.dart';
import 'package:cashier_app/features/cash_drawer/domain/entities/cash_drawer_session.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/customers/domain/entities/customer.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:cashier_app/features/settings/domain/entities/app_settings.dart';

/// Data transferred in a single sync push/pull cycle.
class SyncPayload {
  const SyncPayload({
    this.items = const [],
    this.customers = const [],
    this.transactions = const [],
    this.cashDrawerSessions = const [],
    this.settings,
    this.syncedAt,
  });

  final List<Item> items;
  final List<Customer> customers;
  final List<Transaction> transactions;
  final List<CashDrawerSession> cashDrawerSessions;
  final AppSettings? settings;
  final DateTime? syncedAt;
}

/// Remote datasource for the bulk sync push/pull endpoints.
class RemoteSyncDatasource {
  RemoteSyncDatasource(this._api);

  final ApiClient _api;

  /// Push local changes to the server.
  ///
  /// Returns the server's sync timestamp to store as lastSyncedAt.
  Future<DateTime> push({
    required String deviceId,
    List<Item> items = const [],
    List<Customer> customers = const [],
    List<Transaction> transactions = const [],
    List<CashDrawerSession> cashDrawerSessions = const [],
    AppSettings? settings,
  }) async {
    final body = <String, dynamic>{
      'deviceId': deviceId,
      'items': items.map(_encodeItem).toList(),
      'customers': customers.map(_encodeCustomer).toList(),
      'transactions': transactions.map(_encodeTransaction).toList(),
      'cashDrawerSessions':
          cashDrawerSessions.map(_encodeCashDrawerSession).toList(),
      if (settings != null) 'settings': _encodeSettings(settings),
    };

    final data = await _api.post('/api/sync/push', body);
    return DateTime.parse(data['syncedAt'] as String);
  }

  /// Pull remote changes since [since].
  ///
  /// Pass `null` for a full pull.
  Future<SyncPayload> pull({
    required String deviceId,
    DateTime? since,
  }) async {
    final data = await _api.post('/api/sync/pull', {
      'deviceId': deviceId,
      'since': since?.toUtc().toIso8601String(),
    });

    final items = (data['items'] as List? ?? [])
        .map((e) => _decodeItem(e as Map<String, dynamic>))
        .toList();

    final customers = (data['customers'] as List? ?? [])
        .map((e) => _decodeCustomer(e as Map<String, dynamic>))
        .toList();

    final transactions = (data['transactions'] as List? ?? [])
        .map((e) => _decodeTransaction(e as Map<String, dynamic>))
        .toList();

    final settingsMap = data['settings'] as Map<String, dynamic>?;
    final settings =
        settingsMap != null ? _decodeSettings(settingsMap) : null;

    return SyncPayload(
      items: items,
      customers: customers,
      transactions: transactions,
      settings: settings,
      syncedAt: data['syncedAt'] != null
          ? DateTime.parse(data['syncedAt'] as String)
          : null,
    );
  }

  // ---------------------------------------------------------------------------
  // Item encode/decode
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> _encodeItem(Item item) => {
        'sku': item.sku,
        'label': item.label,
        'unitPriceSubunits': item.unitPrice.value.toInt(),
        'type': switch (item) {
          ServiceItem() => 'service',
          TradeItem() => 'trade',
          KeyedPriceItem() => 'keyed',
        },
        if (item is TradeItem) 'gtin': item.gtin,
        'category': item.category,
        'stockQuantity': item.stockQuantity,
        'isFavorite': item.isFavorite,
        'imagePath': item.imagePath,
        'itemTaxRate': item.itemTaxRate,
      };

  static Item _decodeItem(Map<String, dynamic> m) {
    final price = Price(BigInt.from((m['unitPriceSubunits'] as num?) ?? 0));
    final type = m['type'] as String? ?? 'trade';
    if (type == 'service') {
      return ServiceItem(
        sku: m['sku'] as String? ?? '',
        label: m['label'] as String? ?? '',
        unitPrice: price,
        category: m['category'] as String? ?? '',
        isFavorite: m['isFavorite'] as bool? ?? false,
        imagePath: m['imagePath'] as String?,
        itemTaxRate: (m['itemTaxRate'] as num?)?.toDouble(),
      );
    }
    return TradeItem(
      sku: m['sku'] as String? ?? '',
      label: m['label'] as String? ?? '',
      unitPrice: price,
      gtin: m['gtin'] as String?,
      category: m['category'] as String? ?? '',
      stockQuantity: (m['stockQuantity'] as num?)?.toInt() ?? -1,
      isFavorite: m['isFavorite'] as bool? ?? false,
      imagePath: m['imagePath'] as String?,
      itemTaxRate: (m['itemTaxRate'] as num?)?.toDouble(),
    );
  }

  // ---------------------------------------------------------------------------
  // Customer encode/decode
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> _encodeCustomer(Customer c) => {
        'id': c.id,
        'name': c.name,
        'phone': c.phone,
        'email': c.email,
        'notes': c.notes,
      };

  static Customer _decodeCustomer(Map<String, dynamic> m) => Customer(
        id: m['id'] as int?,
        name: m['name'] as String? ?? '',
        phone: m['phone'] as String? ?? '',
        email: m['email'] as String? ?? '',
        notes: m['notes'] as String? ?? '',
        createdAt: m['createdAt'] != null
            ? DateTime.tryParse(m['createdAt'] as String)
            : null,
      );

  // ---------------------------------------------------------------------------
  // Transaction encode/decode
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> _encodeTransaction(Transaction txn) => {
        'invoiceNumber': txn.invoiceNumber,
        'invoiceJson': _encodeInvoice(txn.invoice),
        'status': txn.status.name,
        'createdAt': txn.createdAt.toUtc().toIso8601String(),
        'customerId': txn.customerId,
        'payments': txn.payments
            .map((p) => {
                  'method': p.method.name,
                  'amountSubunits': p.amount.value.toInt(),
                },)
            .toList(),
      };

  static String _encodeInvoice(Invoice invoice) => jsonEncode({
        'version': 1,
        'status': invoice.status.name,
        'items': invoice.items
            .map((li) => {
                  'quantity': li.quantity,
                  'item': _encodeInvoiceItem(li.item),
                },)
            .toList(),
      });

  static Map<String, dynamic> _encodeInvoiceItem(Item item) => switch (item) {
        TradeItem(:final sku, :final label, :final unitPrice, :final gtin) => {
            'type': 'trade',
            'sku': sku,
            'label': label,
            'unitPriceSubunits': unitPrice.value.toString(),
            'gtin': gtin,
          },
        ServiceItem(:final sku, :final label, :final unitPrice) => {
            'type': 'service',
            'sku': sku,
            'label': label,
            'unitPriceSubunits': unitPrice.value.toString(),
          },
        KeyedPriceItem(:final unitPrice) => {
            'type': 'keyed',
            'unitPriceSubunits': unitPrice.value.toString(),
          },
      };

  static Transaction _decodeTransaction(Map<String, dynamic> m) {
    final invoiceJson = m['invoiceJson'] as String?;
    final invoice = invoiceJson != null
        ? _decodeInvoiceJson(invoiceJson)
        : const Invoice();

    final paymentsRaw = m['payments'] as List? ?? [];
    final payments = paymentsRaw.map((p) {
      final pm = p as Map<String, dynamic>;
      return Payment(
        method: PaymentMethod.values.firstWhere(
          (v) => v.name == (pm['method'] as String? ?? 'cash'),
          orElse: () => PaymentMethod.cash,
        ),
        amount: Price(BigInt.from((pm['amountSubunits'] as num?) ?? 0)),
      );
    }).toList();

    return Transaction(
      id: m['id'] as int?,
      invoiceNumber: m['invoiceNumber'] as String?,
      invoice: invoice,
      payments: payments,
      status: TransactionStatus.values.firstWhere(
        (s) => s.name == (m['status'] as String? ?? 'completed'),
        orElse: () => TransactionStatus.completed,
      ),
      createdAt: m['createdAt'] != null
          ? DateTime.parse(m['createdAt'] as String)
          : DateTime.now(),
      customerId: m['customerId'] as int?,
    );
  }

  static Invoice _decodeInvoiceJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    final status = InvoiceStatus.values.firstWhere(
      (s) => s.name == (map['status'] as String? ?? 'processed'),
      orElse: () => InvoiceStatus.processed,
    );
    final items = (map['items'] as List<dynamic>?)
            ?.map((e) {
              final m = e as Map<String, dynamic>;
              final itemMap = m['item'] as Map<String, dynamic>;
              return InvoiceItem(
                item: _decodeInvoiceItemJson(itemMap),
                quantity: m['quantity'] as int? ?? 1,
              );
            })
            .toList() ??
        [];
    return Invoice(items: items, status: status);
  }

  static Item _decodeInvoiceItemJson(Map<String, dynamic> m) {
    final type = m['type'] as String? ?? 'trade';
    final subunits =
        BigInt.tryParse(m['unitPriceSubunits']?.toString() ?? '0') ??
            BigInt.zero;
    final price = Price(subunits);
    return switch (type) {
      'trade' => TradeItem(
          sku: m['sku'] as String? ?? '',
          label: m['label'] as String? ?? '',
          unitPrice: price,
          gtin: m['gtin'] as String?,
        ),
      'service' => ServiceItem(
          sku: m['sku'] as String? ?? '',
          label: m['label'] as String? ?? '',
          unitPrice: price,
        ),
      _ => KeyedPriceItem(price),
    };
  }

  // ---------------------------------------------------------------------------
  // Cash drawer session encode
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> _encodeCashDrawerSession(
    CashDrawerSession s,
  ) =>
      {
        'openedAt': s.openedAt.toUtc().toIso8601String(),
        'closedAt': s.closedAt?.toUtc().toIso8601String(),
        'openingBalanceSubunits': s.openingBalance.value.toInt(),
        'closingBalanceSubunits': s.closingBalance?.value.toInt(),
        'notes': s.notes,
      };

  // ---------------------------------------------------------------------------
  // Settings encode/decode
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> _encodeSettings(AppSettings s) => {
        'businessName': s.businessName,
        'taxRate': s.taxRate,
        'currencySymbol': s.currencySymbol,
        'receiptFooter': s.receiptFooter,
        'themeMode': s.themeMode,
        'printerType': s.printerType,
        'printerAddress': s.printerAddress,
        'taxInclusive': s.taxInclusive,
      };

  static AppSettings _decodeSettings(Map<String, dynamic> m) => AppSettings(
        businessName: m['businessName'] as String? ?? 'My Business',
        taxRate: (m['taxRate'] as num?)?.toDouble() ?? 0.0,
        currencySymbol: m['currencySymbol'] as String? ?? r'$',
        receiptFooter:
            m['receiptFooter'] as String? ?? 'Thank you for your business!',
        themeMode: m['themeMode'] as String? ?? 'system',
        taxInclusive: m['taxInclusive'] as bool? ?? false,
      );
}
