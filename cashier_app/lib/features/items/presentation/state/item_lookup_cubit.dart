import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/items/domain/repositories/item_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

@immutable
sealed class ItemLookupState extends Equatable {
  const ItemLookupState();
  @override
  List<Object?> get props => [];
}

class ItemLookupIdle extends ItemLookupState {
  const ItemLookupIdle();
}

class ItemLookupLoading extends ItemLookupState {
  const ItemLookupLoading();
}

class ItemLookupFound extends ItemLookupState {
  const ItemLookupFound(this.item);
  final Item item;
  @override
  List<Object?> get props => [item];
}

class ItemLookupNotFound extends ItemLookupState {
  const ItemLookupNotFound(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class ItemLookupError extends ItemLookupState {
  const ItemLookupError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

class ItemLookupCubit extends Cubit<ItemLookupState> {
  ItemLookupCubit(this._repo) : super(const ItemLookupIdle());

  final ItemRepository _repo;

  /// Looks up an item by SKU first, then falls back to GTIN.
  Future<void> lookupBySku(String sku) async {
    final query = sku.trim();
    if (query.isEmpty) {
      emit(const ItemLookupIdle());
      return;
    }
    emit(const ItemLookupLoading());
    try {
      var item = await _repo.findBySku(query);
      item ??= await _repo.findByGtin(query);
      if (item != null) {
        emit(ItemLookupFound(item));
      } else {
        emit(ItemLookupNotFound(query));
      }
    } on Exception catch (e) {
      emit(ItemLookupError(e.toString()));
    }
  }

  void reset() => emit(const ItemLookupIdle());
}
