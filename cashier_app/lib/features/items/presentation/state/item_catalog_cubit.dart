import 'package:cashier_app/features/items/domain/entities/item.dart';
import 'package:cashier_app/features/items/domain/repositories/item_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

@immutable
sealed class ItemCatalogState extends Equatable {
  const ItemCatalogState();
  @override
  List<Object?> get props => [];
}

class ItemCatalogLoading extends ItemCatalogState {
  const ItemCatalogLoading();
}

class ItemCatalogLoaded extends ItemCatalogState {
  const ItemCatalogLoaded(this.items);
  final List<Item> items;
  @override
  List<Object?> get props => [items];
}

class ItemCatalogError extends ItemCatalogState {
  const ItemCatalogError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

class ItemCatalogCubit extends Cubit<ItemCatalogState> {
  ItemCatalogCubit(this._repo) : super(const ItemCatalogLoading());

  final ItemRepository _repo;

  Future<void> load() async {
    emit(const ItemCatalogLoading());
    try {
      final items = await _repo.getAll();
      emit(ItemCatalogLoaded(items));
    } on Exception catch (e) {
      emit(ItemCatalogError(e.toString()));
    }
  }

  Future<void> save(Item item) async {
    try {
      await _repo.save(item);
      await load();
    } on Exception catch (e) {
      emit(ItemCatalogError(e.toString()));
    }
  }

  Future<void> deleteById(int id) async {
    try {
      await _repo.deleteById(id);
      await load();
    } on Exception catch (e) {
      emit(ItemCatalogError(e.toString()));
    }
  }

  Future<void> deleteBySku(String sku) async {
    try {
      await _repo.deleteBySku(sku);
      await load();
    } on Exception catch (e) {
      emit(ItemCatalogError(e.toString()));
    }
  }
}
