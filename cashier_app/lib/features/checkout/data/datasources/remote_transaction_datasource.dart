import 'dart:convert';

import 'package:cashier_app/core/network/api_client.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_status.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/refund_line_item.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';

/// Remote datasource that proxies [TransactionRepository] calls to the server API.
class RemoteTransactionDatasource implements TransactionRepository {
  RemoteTransactionDatasource(this._api);

  final ApiClient _api;

  @override
  Future<List<Transaction>> getAll() async {
    final data = await _api.get('/api/transactions/');
    final list = data['transactions'] as List? ?? [];
    return list.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Transaction>> getPage(int limit, int offset) async {
    final data = await _api.get('/api/transactions/?limit=$limit&offset=$offset');
    final list = data['transactions'] as List? ?? [];
    return list.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Transaction?> findById(int id) async {
    try {
      final data = await _api.get('/api/transactions/$id');
      return _fromJson(data);
    } on ApiException catch (e) {
      if (e.isNotFound) return null;
      rethrow;
    }
  }

  @override
  Future<int> save(Transaction transaction) async {
    final data = await _api.post('/api/transactions/', {
      'invoiceJson': _encodeInvoice(transaction.invoice),
      'payments': transaction.payments
          .map((p) => {
                'method': p.method.name,
                'amountSubunits': p.amount.value.toInt(),
              },)
          .toList(),
      'customerId': transaction.customerId,
    });
    return data['id'] as int;
  }

  @override
  Future<void> voidTransaction(int id) =>
      _api.patch('/api/transactions/$id/void');

  @override
  Future<void> refundTransaction(int id) async {
    // Full refund = refund all lines. Fetch the transaction to determine lines.
    final tx = await findById(id);
    if (tx == null) return;
    await _api.post('/api/transactions/$id/refund', {
      'items': tx.invoice.items.asMap().entries.map((e) => {
            'lineIndex': e.key,
            'quantity': e.value.quantity,
            'amountSubunits': e.value.lineTotal.value.toInt(),
            'reason': 'Full refund',
          },).toList(),
    });
  }

  @override
  Future<void> partialRefund(int id, List<RefundLineItem> items) =>
      _api.post('/api/transactions/$id/refund', {
        'items': items
            .map((r) => {
                  'lineIndex': r.lineIndex,
                  'quantity': r.quantity,
                  'amountSubunits': r.amountSubunits,
                  'reason': r.reason,
                },)
            .toList(),
      });

  @override
  Future<List<RefundLineItem>> getRefunds(int transactionId) async {
    final data = await _api.get('/api/transactions/$transactionId');
    final refunds = data['refunds'] as List? ?? [];
    return refunds
        .map((r) {
          final m = r as Map<String, dynamic>;
          return RefundLineItem(
            lineIndex: m['lineIndex'] as int,
            quantity: m['quantity'] as int,
            amountSubunits: m['amountSubunits'] as int,
            reason: m['reason'] as String? ?? '',
          );
        })
        .toList();
  }

  // ---------------------------------------------------------------------------
  // JSON helpers
  // ---------------------------------------------------------------------------

  static Transaction _fromJson(Map<String, dynamic> m) {
    final invoiceJson = m['invoiceJson'] as String?;
    final invoice =
        invoiceJson != null ? _decodeInvoice(invoiceJson) : const Invoice();

    final paymentsRaw = m['payments'] as List? ?? [];
    final payments = paymentsRaw.map((p) {
      final pm = p as Map<String, dynamic>;
      return Payment(
        method: PaymentMethod.values.firstWhere(
          (v) => v.name == pm['method'],
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

  static String _encodeInvoice(Invoice invoice) {
    return jsonEncode({
      'version': 1,
      'status': invoice.status.name,
      'items': invoice.items
          .map((li) => {
                'quantity': li.quantity,
                'item': _encodeItem(li.item),
              },)
          .toList(),
    });
  }

  static Map<String, dynamic> _encodeItem(Item item) {
    return switch (item) {
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
  }

  static Invoice _decodeInvoice(String json) {
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
                item: _decodeItem(itemMap),
                quantity: m['quantity'] as int? ?? 1,
              );
            })
            .toList() ??
        [];
    return Invoice(items: items, status: status);
  }

  static Item _decodeItem(Map<String, dynamic> m) {
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
}
