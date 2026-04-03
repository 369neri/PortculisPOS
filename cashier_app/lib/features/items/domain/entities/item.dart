import 'package:cashier_app/features/items/domain/entities/validation_result.dart';
import 'package:cashier_app/features/pricing/domain/entities/price.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:gtin_toolkit/gtin_toolkit.dart' as gtin_tool;

part 'trade_item.dart';
part 'service_item.dart';
part 'keyed_price_item.dart';

@immutable
sealed class Item extends Equatable {
  const Item();

  String? get sku;
  String? get label;
  Price get unitPrice;

  ValidationResult validate();
}
