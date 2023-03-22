import 'invoice_item.dart';
import 'invoice_status.dart';

class Invoice {
  final List<InvoiceItem> _items = [];

  // ignore: unused_field
  InvoiceStatus _status = InvoiceStatus.active;
  InvoiceStatus get status => _status;

  Invoice() : super();

  void addInvoiceItem(InvoiceItem item) {
    _items.add(item);
  }

  void suspend() {
    _status = InvoiceStatus.pending;
  }

  void activate() {
    _status = InvoiceStatus.active;
  }
}