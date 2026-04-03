import 'package:cashier_app/features/billing/domain/entities/invoice_item.dart';
import 'package:cashier_app/features/billing/presentation/state/sales_register_state.dart';
import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SalesRegisterCubit extends Cubit<SalesRegisterState> {
  SalesRegisterCubit() : super(const SalesRegisterState());

  void addKeyedItem(Price price, {int quantity = 1}) {
    final item = InvoiceItem(
      item: KeyedPriceItem(price),
      quantity: quantity,
    );
    emit(state.copyWith(invoice: state.invoice.addItem(item)));
  }

  void addCatalogItem(Item item, {int quantity = 1}) {
    final invoiceItem = InvoiceItem(item: item, quantity: quantity);
    emit(state.copyWith(invoice: state.invoice.addItem(invoiceItem)));
  }

  void removeItem(int index) {
    emit(state.copyWith(invoice: state.invoice.removeItemAt(index)));
  }

  void updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeItem(index);
      return;
    }
    emit(state.copyWith(invoice: state.invoice.updateItemQuantity(index, quantity)));
  }

  void clearInvoice() {
    emit(const SalesRegisterState());
  }
}
