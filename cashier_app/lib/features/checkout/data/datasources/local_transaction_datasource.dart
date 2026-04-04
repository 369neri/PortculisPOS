import 'dart:convert';

import 'package:cashier_app/core/persistence/app_database.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/billing/domain/entities/invoice_status.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment.dart';
import 'package:cashier_app/features/checkout/domain/entities/payment_method.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction.dart';
import 'package:cashier_app/features/checkout/domain/entities/transaction_status.dart';
import 'package:cashier_app/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:drift/drift.dart';

class LocalTransactionDatasource implements TransactionRepository {
  LocalTransactionDatasource(this._dao);

  final TransactionsDao _dao;

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
