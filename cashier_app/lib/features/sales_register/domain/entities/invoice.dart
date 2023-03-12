import 'package:cashier_app/features/sales_register/domain/entities/status.dart';
import 'package:cashier_app/features/sales_register/domain/entities/invoice_item.dart';

class Invoice {
  final List<InvoiceItem> _items = [];

  Status _status = Status.active;

  Invoice() : super();

  void addInvoiceItem(InvoiceItem item) {
    _items.add(item);
  }

  void suspend() {
    _status = Status.pending;
  }

  void activate() {
    _status = Status.active;
  }
}