import 'dart:convert';

import 'package:cashier_app/core/persistence/app_database.dart';
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
import 'package:drift/drift.dart';

class LocalTransactionDatasource implements TransactionRepository {
  LocalTransactionDatasource(this._dao, {RefundsDao? refundsDao})
      : _refundsDao = refundsDao;

  final TransactionsDao _dao;
  final RefundsDao? _refundsDao;

  @override
  Future<List<Transaction>> getAll() async {
    final rows = await _dao.getAllTransactions();
    final results = <Transaction>[];
    for (final row in rows) {
      final payments = await _dao.paymentsForTransaction(row.id);
      results.add(_toDomain(row, payments));
    }
    return results;
  }

  @override
  Future<List<Transaction>> getPage(int limit, int offset) async {
    final rows = await _dao.getTransactionPage(limit, offset);
    final results = <Transaction>[];
    for (final row in rows) {
      final payments = await _dao.paymentsForTransaction(row.id);
      results.add(_toDomain(row, payments));
    }
    return results;
  }

  @override
  Future<Transaction?> findById(int id) async {
    final row = await _dao.findById(id);
    if (row == null) return null;
    final payments = await _dao.paymentsForTransaction(id);
    return _toDomain(row, payments);
  }

  @override
  Future<int> save(Transaction transaction) async {
    final invoiceNumber =
        transaction.invoiceNumber ?? await _dao.nextInvoiceNumber();
    final tx = TransactionsTableCompanion.insert(
      invoiceNumber: Value(invoiceNumber),
      invoiceJson: _encodeInvoice(transaction.invoice),
      status: transaction.status.name,
      createdAt: transaction.createdAt,
      customerId: Value(transaction.customerId),
    );

    final payments = transaction.payments
        .map(
          (p) => PaymentsTableCompanion.insert(
            transactionId: 0, // will be replaced by DAO
            method: p.method.name,
            amountSubunits: p.amount.value.toInt(),
          ),
        )
        .toList();

    return _dao.insertTransaction(tx, payments);
  }

  @override
  Future<void> voidTransaction(int id) =>
      _dao.updateStatus(id, TransactionStatus.voided.name);

  @override
  Future<void> refundTransaction(int id) =>
      _dao.updateStatus(id, TransactionStatus.refunded.name);

  @override
  Future<void> partialRefund(int id, List<RefundLineItem> items) async {
    final dao = _refundsDao;
    if (dao == null) throw StateError('RefundsDao not configured');
    final companions = items
        .map(
          (r) => RefundsTableCompanion.insert(
            originalTransactionId: id,
            lineIndex: r.lineIndex,
            quantity: r.quantity,
            amountSubunits: r.amountSubunits,
            reason: Value(r.reason),
            createdAt: DateTime.now(),
          ),
        )
        .toList();
    await dao.insertAll(companions);
    // Check if every line item is fully refunded → mark as refunded.
    final tx = await findById(id);
    if (tx != null) {
      final allRefunds = await dao.forTransaction(id);
      final refundedQtyPerLine = <int, int>{};
      for (final r in allRefunds) {
        refundedQtyPerLine[r.lineIndex] =
            (refundedQtyPerLine[r.lineIndex] ?? 0) + r.quantity;
      }
      final fullyRefunded = tx.invoice.items.asMap().entries.every(
            (e) => (refundedQtyPerLine[e.key] ?? 0) >= e.value.quantity,
          );
      if (fullyRefunded) {
        await _dao.updateStatus(id, TransactionStatus.refunded.name);
      }
    }
  }

  @override
  Future<List<RefundLineItem>> getRefunds(int transactionId) async {
    final dao = _refundsDao;
    if (dao == null) return [];
    final rows = await dao.forTransaction(transactionId);
    return rows
        .map(
          (r) => RefundLineItem(
            lineIndex: r.lineIndex,
            quantity: r.quantity,
            amountSubunits: r.amountSubunits,
            reason: r.reason,
          ),
        )
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Mapping helpers
  // ---------------------------------------------------------------------------

  Transaction _toDomain(
    TransactionsTableData row,
    List<PaymentsTableData> paymentRows,
  ) {
    return Transaction(
      id: row.id,
      invoiceNumber: row.invoiceNumber,
      invoice: _decodeInvoice(row.invoiceJson),
      payments: paymentRows.map(_paymentToDomain).toList(),
      status: TransactionStatus.values.byName(row.status),
      createdAt: row.createdAt,
      customerId: row.customerId,
    );
  }

  Payment _paymentToDomain(PaymentsTableData row) {
    return Payment(
      method: PaymentMethod.values.byName(row.method),
      amount: Price(BigInt.from(row.amountSubunits)),
    );
  }

  // ---------------------------------------------------------------------------
  // Invoice JSON serialization
  // ---------------------------------------------------------------------------

  String _encodeInvoice(Invoice invoice) {
    return jsonEncode({
      'version': 1,
      'status': invoice.status.name,
      'items': invoice.items.map(_encodeInvoiceItem).toList(),
    });
  }

  Map<String, dynamic> _encodeInvoiceItem(InvoiceItem item) {
    return {
      'quantity': item.quantity,
      'item': _encodeItem(item.item),
    };
  }

  Map<String, dynamic> _encodeItem(Item item) {
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

  Invoice _decodeInvoice(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    // version defaults to 1 for JSON written before versioning was added.
    final version = map['version'] as int? ?? 1;
    return switch (version) {
      1 => _decodeInvoiceV1(map),
      _ => throw ArgumentError('Unsupported invoice version: $version'),
    };
  }

  Invoice _decodeInvoiceV1(Map<String, dynamic> map) {
    final status = InvoiceStatus.values.byName(map['status'] as String);
    final items = (map['items'] as List<dynamic>)
        .map((e) => _decodeInvoiceItem(e as Map<String, dynamic>))
        .toList();
    return Invoice(items: items, status: status);
  }

  InvoiceItem _decodeInvoiceItem(Map<String, dynamic> map) {
    return InvoiceItem(
      item: _decodeItem(map['item'] as Map<String, dynamic>),
      quantity: map['quantity'] as int,
    );
  }

  Item _decodeItem(Map<String, dynamic> map) {
    final type = map['type'] as String;
    final subunits = BigInt.parse(map['unitPriceSubunits'] as String);
    final price = Price(subunits);

    return switch (type) {
      'trade' => TradeItem(
          sku: map['sku'] as String,
          label: map['label'] as String,
          unitPrice: price,
          gtin: map['gtin'] as String?,
        ),
      'service' => ServiceItem(
          sku: map['sku'] as String,
          label: map['label'] as String,
          unitPrice: price,
        ),
      'keyed' => KeyedPriceItem(price),
      _ => throw ArgumentError('Unknown item type: $type'),
    };
  }
}
