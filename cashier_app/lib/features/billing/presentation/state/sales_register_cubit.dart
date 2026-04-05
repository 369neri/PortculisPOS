import 'package:cashier_app/features/billing/domain/entities/invoice.dart';
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
    emit(state.copyWith(
      invoice: state.invoice.updateItemQuantity(index, quantity),
    ),);
  }

  /// Park the current invoice and start a fresh one.
  void holdInvoice() {
    if (state.invoice.items.isEmpty) return;
    final held = [...state.heldInvoices, state.invoice.suspend()];
    emit(state.copyWith(
      invoice: const Invoice(),
      heldInvoices: held,
    ),);
  }

  /// Recall a held invoice by index, parking the current one if non-empty.
  void recallInvoice(int index) {
    if (index < 0 || index >= state.heldInvoices.length) return;
    final held = [...state.heldInvoices];
    final recalled = held.removeAt(index).activate();

    // If current invoice has items, park it.
    if (state.invoice.items.isNotEmpty) {
      held.add(state.invoice.suspend());
    }

    emit(state.copyWith(
      invoice: recalled,
      heldInvoices: held,
    ),);
  }

  /// Remove a held invoice without recalling it.
  void discardHeldInvoice(int index) {
    if (index < 0 || index >= state.heldInvoices.length) return;
    final held = [...state.heldInvoices]..removeAt(index);
    emit(state.copyWith(heldInvoices: held));
  }


  void updateDiscount(
    int index, {
    double discountPercent = 0.0,
    Price? discountAmount,
  }) {
    emit(state.copyWith(
      invoice: state.invoice.updateItemDiscount(
        index,
        discountPercent: discountPercent,
        discountAmount: discountAmount,
      ),
    ),);
  }


  void clearInvoice() {
    emit(state.copyWith(invoice: const Invoice()));
  }
}
