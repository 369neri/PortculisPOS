// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
mixin _$ItemsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ItemsTableTable get itemsTable => attachedDatabase.itemsTable;
  ItemsDaoManager get managers => ItemsDaoManager(this);
}

class ItemsDaoManager {
  final _$ItemsDaoMixin _db;
  ItemsDaoManager(this._db);
  $$ItemsTableTableTableManager get itemsTable =>
      $$ItemsTableTableTableManager(_db.attachedDatabase, _db.itemsTable);
}

mixin _$TransactionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTableTable get customersTable => attachedDatabase.customersTable;
  $TransactionsTableTable get transactionsTable =>
      attachedDatabase.transactionsTable;
  $PaymentsTableTable get paymentsTable => attachedDatabase.paymentsTable;
  TransactionsDaoManager get managers => TransactionsDaoManager(this);
}

class TransactionsDaoManager {
  final _$TransactionsDaoMixin _db;
  TransactionsDaoManager(this._db);
  $$CustomersTableTableTableManager get customersTable =>
      $$CustomersTableTableTableManager(
          _db.attachedDatabase, _db.customersTable);
  $$TransactionsTableTableTableManager get transactionsTable =>
      $$TransactionsTableTableTableManager(
          _db.attachedDatabase, _db.transactionsTable);
  $$PaymentsTableTableTableManager get paymentsTable =>
      $$PaymentsTableTableTableManager(_db.attachedDatabase, _db.paymentsTable);
}

mixin _$SettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SettingsTableTable get settingsTable => attachedDatabase.settingsTable;
  SettingsDaoManager get managers => SettingsDaoManager(this);
}

class SettingsDaoManager {
  final _$SettingsDaoMixin _db;
  SettingsDaoManager(this._db);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db.attachedDatabase, _db.settingsTable);
}

mixin _$CashDrawerDaoMixin on DatabaseAccessor<AppDatabase> {
  $CashDrawerSessionsTableTable get cashDrawerSessionsTable =>
      attachedDatabase.cashDrawerSessionsTable;
  CashDrawerDaoManager get managers => CashDrawerDaoManager(this);
}

class CashDrawerDaoManager {
  final _$CashDrawerDaoMixin _db;
  CashDrawerDaoManager(this._db);
  $$CashDrawerSessionsTableTableTableManager get cashDrawerSessionsTable =>
      $$CashDrawerSessionsTableTableTableManager(
          _db.attachedDatabase, _db.cashDrawerSessionsTable);
}

mixin _$CustomersDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTableTable get customersTable => attachedDatabase.customersTable;
  CustomersDaoManager get managers => CustomersDaoManager(this);
}

class CustomersDaoManager {
  final _$CustomersDaoMixin _db;
  CustomersDaoManager(this._db);
  $$CustomersTableTableTableManager get customersTable =>
      $$CustomersTableTableTableManager(
          _db.attachedDatabase, _db.customersTable);
}

mixin _$UsersDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTableTable get usersTable => attachedDatabase.usersTable;
  UsersDaoManager get managers => UsersDaoManager(this);
}

class UsersDaoManager {
  final _$UsersDaoMixin _db;
  UsersDaoManager(this._db);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db.attachedDatabase, _db.usersTable);
}

mixin _$RefundsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTableTable get customersTable => attachedDatabase.customersTable;
  $TransactionsTableTable get transactionsTable =>
      attachedDatabase.transactionsTable;
  $RefundsTableTable get refundsTable => attachedDatabase.refundsTable;
  RefundsDaoManager get managers => RefundsDaoManager(this);
}

class RefundsDaoManager {
  final _$RefundsDaoMixin _db;
  RefundsDaoManager(this._db);
  $$CustomersTableTableTableManager get customersTable =>
      $$CustomersTableTableTableManager(
          _db.attachedDatabase, _db.customersTable);
  $$TransactionsTableTableTableManager get transactionsTable =>
      $$TransactionsTableTableTableManager(
          _db.attachedDatabase, _db.transactionsTable);
  $$RefundsTableTableTableManager get refundsTable =>
      $$RefundsTableTableTableManager(_db.attachedDatabase, _db.refundsTable);
}

mixin _$CashMovementsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CashDrawerSessionsTableTable get cashDrawerSessionsTable =>
      attachedDatabase.cashDrawerSessionsTable;
  $CashMovementsTableTable get cashMovementsTable =>
      attachedDatabase.cashMovementsTable;
  CashMovementsDaoManager get managers => CashMovementsDaoManager(this);
}

class CashMovementsDaoManager {
  final _$CashMovementsDaoMixin _db;
  CashMovementsDaoManager(this._db);
  $$CashDrawerSessionsTableTableTableManager get cashDrawerSessionsTable =>
      $$CashDrawerSessionsTableTableTableManager(
          _db.attachedDatabase, _db.cashDrawerSessionsTable);
  $$CashMovementsTableTableTableManager get cashMovementsTable =>
      $$CashMovementsTableTableTableManager(
          _db.attachedDatabase, _db.cashMovementsTable);
}

class $ItemsTableTable extends ItemsTable
    with TableInfo<$ItemsTableTable, ItemsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitPriceSubunitsMeta =
      const VerificationMeta('unitPriceSubunits');
  @override
  late final GeneratedColumn<int> unitPriceSubunits = GeneratedColumn<int>(
      'unit_price_subunits', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gtinMeta = const VerificationMeta('gtin');
  @override
  late final GeneratedColumn<String> gtin = GeneratedColumn<String>(
      'gtin', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _stockQuantityMeta =
      const VerificationMeta('stockQuantity');
  @override
  late final GeneratedColumn<int> stockQuantity = GeneratedColumn<int>(
      'stock_quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(-1));
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _itemTaxRateMeta =
      const VerificationMeta('itemTaxRate');
  @override
  late final GeneratedColumn<double> itemTaxRate = GeneratedColumn<double>(
      'item_tax_rate', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sku,
        label,
        unitPriceSubunits,
        type,
        gtin,
        category,
        stockQuantity,
        isFavorite,
        imagePath,
        itemTaxRate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(Insertable<ItemsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('unit_price_subunits')) {
      context.handle(
          _unitPriceSubunitsMeta,
          unitPriceSubunits.isAcceptableOrUnknown(
              data['unit_price_subunits']!, _unitPriceSubunitsMeta));
    } else if (isInserting) {
      context.missing(_unitPriceSubunitsMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('gtin')) {
      context.handle(
          _gtinMeta, gtin.isAcceptableOrUnknown(data['gtin']!, _gtinMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('stock_quantity')) {
      context.handle(
          _stockQuantityMeta,
          stockQuantity.isAcceptableOrUnknown(
              data['stock_quantity']!, _stockQuantityMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('item_tax_rate')) {
      context.handle(
          _itemTaxRateMeta,
          itemTaxRate.isAcceptableOrUnknown(
              data['item_tax_rate']!, _itemTaxRateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      unitPriceSubunits: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}unit_price_subunits'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      gtin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gtin']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      stockQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stock_quantity'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      itemTaxRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}item_tax_rate']),
    );
  }

  @override
  $ItemsTableTable createAlias(String alias) {
    return $ItemsTableTable(attachedDatabase, alias);
  }
}

class ItemsTableData extends DataClass implements Insertable<ItemsTableData> {
  final int id;
  final String sku;
  final String label;
  final int unitPriceSubunits;
  final String type;
  final String? gtin;
  final String category;
  final int stockQuantity;
  final bool isFavorite;
  final String? imagePath;
  final double? itemTaxRate;
  const ItemsTableData(
      {required this.id,
      required this.sku,
      required this.label,
      required this.unitPriceSubunits,
      required this.type,
      this.gtin,
      required this.category,
      required this.stockQuantity,
      required this.isFavorite,
      this.imagePath,
      this.itemTaxRate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sku'] = Variable<String>(sku);
    map['label'] = Variable<String>(label);
    map['unit_price_subunits'] = Variable<int>(unitPriceSubunits);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || gtin != null) {
      map['gtin'] = Variable<String>(gtin);
    }
    map['category'] = Variable<String>(category);
    map['stock_quantity'] = Variable<int>(stockQuantity);
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || itemTaxRate != null) {
      map['item_tax_rate'] = Variable<double>(itemTaxRate);
    }
    return map;
  }

  ItemsTableCompanion toCompanion(bool nullToAbsent) {
    return ItemsTableCompanion(
      id: Value(id),
      sku: Value(sku),
      label: Value(label),
      unitPriceSubunits: Value(unitPriceSubunits),
      type: Value(type),
      gtin: gtin == null && nullToAbsent ? const Value.absent() : Value(gtin),
      category: Value(category),
      stockQuantity: Value(stockQuantity),
      isFavorite: Value(isFavorite),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      itemTaxRate: itemTaxRate == null && nullToAbsent
          ? const Value.absent()
          : Value(itemTaxRate),
    );
  }

  factory ItemsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemsTableData(
      id: serializer.fromJson<int>(json['id']),
      sku: serializer.fromJson<String>(json['sku']),
      label: serializer.fromJson<String>(json['label']),
      unitPriceSubunits: serializer.fromJson<int>(json['unitPriceSubunits']),
      type: serializer.fromJson<String>(json['type']),
      gtin: serializer.fromJson<String?>(json['gtin']),
      category: serializer.fromJson<String>(json['category']),
      stockQuantity: serializer.fromJson<int>(json['stockQuantity']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      itemTaxRate: serializer.fromJson<double?>(json['itemTaxRate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sku': serializer.toJson<String>(sku),
      'label': serializer.toJson<String>(label),
      'unitPriceSubunits': serializer.toJson<int>(unitPriceSubunits),
      'type': serializer.toJson<String>(type),
      'gtin': serializer.toJson<String?>(gtin),
      'category': serializer.toJson<String>(category),
      'stockQuantity': serializer.toJson<int>(stockQuantity),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'imagePath': serializer.toJson<String?>(imagePath),
      'itemTaxRate': serializer.toJson<double?>(itemTaxRate),
    };
  }

  ItemsTableData copyWith(
          {int? id,
          String? sku,
          String? label,
          int? unitPriceSubunits,
          String? type,
          Value<String?> gtin = const Value.absent(),
          String? category,
          int? stockQuantity,
          bool? isFavorite,
          Value<String?> imagePath = const Value.absent(),
          Value<double?> itemTaxRate = const Value.absent()}) =>
      ItemsTableData(
        id: id ?? this.id,
        sku: sku ?? this.sku,
        label: label ?? this.label,
        unitPriceSubunits: unitPriceSubunits ?? this.unitPriceSubunits,
        type: type ?? this.type,
        gtin: gtin.present ? gtin.value : this.gtin,
        category: category ?? this.category,
        stockQuantity: stockQuantity ?? this.stockQuantity,
        isFavorite: isFavorite ?? this.isFavorite,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        itemTaxRate: itemTaxRate.present ? itemTaxRate.value : this.itemTaxRate,
      );
  ItemsTableData copyWithCompanion(ItemsTableCompanion data) {
    return ItemsTableData(
      id: data.id.present ? data.id.value : this.id,
      sku: data.sku.present ? data.sku.value : this.sku,
      label: data.label.present ? data.label.value : this.label,
      unitPriceSubunits: data.unitPriceSubunits.present
          ? data.unitPriceSubunits.value
          : this.unitPriceSubunits,
      type: data.type.present ? data.type.value : this.type,
      gtin: data.gtin.present ? data.gtin.value : this.gtin,
      category: data.category.present ? data.category.value : this.category,
      stockQuantity: data.stockQuantity.present
          ? data.stockQuantity.value
          : this.stockQuantity,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      itemTaxRate:
          data.itemTaxRate.present ? data.itemTaxRate.value : this.itemTaxRate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemsTableData(')
          ..write('id: $id, ')
          ..write('sku: $sku, ')
          ..write('label: $label, ')
          ..write('unitPriceSubunits: $unitPriceSubunits, ')
          ..write('type: $type, ')
          ..write('gtin: $gtin, ')
          ..write('category: $category, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('imagePath: $imagePath, ')
          ..write('itemTaxRate: $itemTaxRate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sku, label, unitPriceSubunits, type, gtin,
      category, stockQuantity, isFavorite, imagePath, itemTaxRate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemsTableData &&
          other.id == this.id &&
          other.sku == this.sku &&
          other.label == this.label &&
          other.unitPriceSubunits == this.unitPriceSubunits &&
          other.type == this.type &&
          other.gtin == this.gtin &&
          other.category == this.category &&
          other.stockQuantity == this.stockQuantity &&
          other.isFavorite == this.isFavorite &&
          other.imagePath == this.imagePath &&
          other.itemTaxRate == this.itemTaxRate);
}

class ItemsTableCompanion extends UpdateCompanion<ItemsTableData> {
  final Value<int> id;
  final Value<String> sku;
  final Value<String> label;
  final Value<int> unitPriceSubunits;
  final Value<String> type;
  final Value<String?> gtin;
  final Value<String> category;
  final Value<int> stockQuantity;
  final Value<bool> isFavorite;
  final Value<String?> imagePath;
  final Value<double?> itemTaxRate;
  const ItemsTableCompanion({
    this.id = const Value.absent(),
    this.sku = const Value.absent(),
    this.label = const Value.absent(),
    this.unitPriceSubunits = const Value.absent(),
    this.type = const Value.absent(),
    this.gtin = const Value.absent(),
    this.category = const Value.absent(),
    this.stockQuantity = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.itemTaxRate = const Value.absent(),
  });
  ItemsTableCompanion.insert({
    this.id = const Value.absent(),
    required String sku,
    required String label,
    required int unitPriceSubunits,
    required String type,
    this.gtin = const Value.absent(),
    this.category = const Value.absent(),
    this.stockQuantity = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.itemTaxRate = const Value.absent(),
  })  : sku = Value(sku),
        label = Value(label),
        unitPriceSubunits = Value(unitPriceSubunits),
        type = Value(type);
  static Insertable<ItemsTableData> custom({
    Expression<int>? id,
    Expression<String>? sku,
    Expression<String>? label,
    Expression<int>? unitPriceSubunits,
    Expression<String>? type,
    Expression<String>? gtin,
    Expression<String>? category,
    Expression<int>? stockQuantity,
    Expression<bool>? isFavorite,
    Expression<String>? imagePath,
    Expression<double>? itemTaxRate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sku != null) 'sku': sku,
      if (label != null) 'label': label,
      if (unitPriceSubunits != null) 'unit_price_subunits': unitPriceSubunits,
      if (type != null) 'type': type,
      if (gtin != null) 'gtin': gtin,
      if (category != null) 'category': category,
      if (stockQuantity != null) 'stock_quantity': stockQuantity,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (imagePath != null) 'image_path': imagePath,
      if (itemTaxRate != null) 'item_tax_rate': itemTaxRate,
    });
  }

  ItemsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? sku,
      Value<String>? label,
      Value<int>? unitPriceSubunits,
      Value<String>? type,
      Value<String?>? gtin,
      Value<String>? category,
      Value<int>? stockQuantity,
      Value<bool>? isFavorite,
      Value<String?>? imagePath,
      Value<double?>? itemTaxRate}) {
    return ItemsTableCompanion(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      label: label ?? this.label,
      unitPriceSubunits: unitPriceSubunits ?? this.unitPriceSubunits,
      type: type ?? this.type,
      gtin: gtin ?? this.gtin,
      category: category ?? this.category,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isFavorite: isFavorite ?? this.isFavorite,
      imagePath: imagePath ?? this.imagePath,
      itemTaxRate: itemTaxRate ?? this.itemTaxRate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (unitPriceSubunits.present) {
      map['unit_price_subunits'] = Variable<int>(unitPriceSubunits.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (gtin.present) {
      map['gtin'] = Variable<String>(gtin.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (stockQuantity.present) {
      map['stock_quantity'] = Variable<int>(stockQuantity.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (itemTaxRate.present) {
      map['item_tax_rate'] = Variable<double>(itemTaxRate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('sku: $sku, ')
          ..write('label: $label, ')
          ..write('unitPriceSubunits: $unitPriceSubunits, ')
          ..write('type: $type, ')
          ..write('gtin: $gtin, ')
          ..write('category: $category, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('imagePath: $imagePath, ')
          ..write('itemTaxRate: $itemTaxRate')
          ..write(')'))
        .toString();
  }
}

class $CustomersTableTable extends CustomersTable
    with TableInfo<$CustomersTableTable, CustomersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, phone, email, notes, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(Insertable<CustomersTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomersTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CustomersTableTable createAlias(String alias) {
    return $CustomersTableTable(attachedDatabase, alias);
  }
}

class CustomersTableData extends DataClass
    implements Insertable<CustomersTableData> {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String notes;
  final DateTime createdAt;
  const CustomersTableData(
      {required this.id,
      required this.name,
      required this.phone,
      required this.email,
      required this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    map['email'] = Variable<String>(email);
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomersTableCompanion toCompanion(bool nullToAbsent) {
    return CustomersTableCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      email: Value(email),
      notes: Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory CustomersTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomersTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String>(json['email']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String>(email),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CustomersTableData copyWith(
          {int? id,
          String? name,
          String? phone,
          String? email,
          String? notes,
          DateTime? createdAt}) =>
      CustomersTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  CustomersTableData copyWithCompanion(CustomersTableCompanion data) {
    return CustomersTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomersTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, phone, email, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomersTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class CustomersTableCompanion extends UpdateCompanion<CustomersTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<String> email;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  const CustomersTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CustomersTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
  })  : name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<CustomersTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CustomersTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? phone,
      Value<String>? email,
      Value<String>? notes,
      Value<DateTime>? createdAt}) {
    return CustomersTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTableTable extends TransactionsTable
    with TableInfo<$TransactionsTableTable, TransactionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _invoiceNumberMeta =
      const VerificationMeta('invoiceNumber');
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
      'invoice_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _invoiceJsonMeta =
      const VerificationMeta('invoiceJson');
  @override
  late final GeneratedColumn<String> invoiceJson = GeneratedColumn<String>(
      'invoice_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
      'customer_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES customers (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, invoiceNumber, invoiceJson, status, createdAt, customerId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
      Insertable<TransactionsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
          _invoiceNumberMeta,
          invoiceNumber.isAcceptableOrUnknown(
              data['invoice_number']!, _invoiceNumberMeta));
    }
    if (data.containsKey('invoice_json')) {
      context.handle(
          _invoiceJsonMeta,
          invoiceJson.isAcceptableOrUnknown(
              data['invoice_json']!, _invoiceJsonMeta));
    } else if (isInserting) {
      context.missing(_invoiceJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      invoiceNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_number']),
      invoiceJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_json'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}customer_id']),
    );
  }

  @override
  $TransactionsTableTable createAlias(String alias) {
    return $TransactionsTableTable(attachedDatabase, alias);
  }
}

class TransactionsTableData extends DataClass
    implements Insertable<TransactionsTableData> {
  final int id;

  /// Human-readable invoice number, e.g. INV-00001. Nullable for legacy rows.
  final String? invoiceNumber;

  /// JSON-encoded invoice snapshot.
  final String invoiceJson;

  /// 'completed' | 'voided' | 'refunded'
  final String status;
  final DateTime createdAt;

  /// Optional customer association.
  final int? customerId;
  const TransactionsTableData(
      {required this.id,
      this.invoiceNumber,
      required this.invoiceJson,
      required this.status,
      required this.createdAt,
      this.customerId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || invoiceNumber != null) {
      map['invoice_number'] = Variable<String>(invoiceNumber);
    }
    map['invoice_json'] = Variable<String>(invoiceJson);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<int>(customerId);
    }
    return map;
  }

  TransactionsTableCompanion toCompanion(bool nullToAbsent) {
    return TransactionsTableCompanion(
      id: Value(id),
      invoiceNumber: invoiceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceNumber),
      invoiceJson: Value(invoiceJson),
      status: Value(status),
      createdAt: Value(createdAt),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
    );
  }

  factory TransactionsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionsTableData(
      id: serializer.fromJson<int>(json['id']),
      invoiceNumber: serializer.fromJson<String?>(json['invoiceNumber']),
      invoiceJson: serializer.fromJson<String>(json['invoiceJson']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      customerId: serializer.fromJson<int?>(json['customerId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'invoiceNumber': serializer.toJson<String?>(invoiceNumber),
      'invoiceJson': serializer.toJson<String>(invoiceJson),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'customerId': serializer.toJson<int?>(customerId),
    };
  }

  TransactionsTableData copyWith(
          {int? id,
          Value<String?> invoiceNumber = const Value.absent(),
          String? invoiceJson,
          String? status,
          DateTime? createdAt,
          Value<int?> customerId = const Value.absent()}) =>
      TransactionsTableData(
        id: id ?? this.id,
        invoiceNumber:
            invoiceNumber.present ? invoiceNumber.value : this.invoiceNumber,
        invoiceJson: invoiceJson ?? this.invoiceJson,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        customerId: customerId.present ? customerId.value : this.customerId,
      );
  TransactionsTableData copyWithCompanion(TransactionsTableCompanion data) {
    return TransactionsTableData(
      id: data.id.present ? data.id.value : this.id,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      invoiceJson:
          data.invoiceJson.present ? data.invoiceJson.value : this.invoiceJson,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableData(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('invoiceJson: $invoiceJson, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('customerId: $customerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, invoiceNumber, invoiceJson, status, createdAt, customerId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionsTableData &&
          other.id == this.id &&
          other.invoiceNumber == this.invoiceNumber &&
          other.invoiceJson == this.invoiceJson &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.customerId == this.customerId);
}

class TransactionsTableCompanion
    extends UpdateCompanion<TransactionsTableData> {
  final Value<int> id;
  final Value<String?> invoiceNumber;
  final Value<String> invoiceJson;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int?> customerId;
  const TransactionsTableCompanion({
    this.id = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.invoiceJson = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.customerId = const Value.absent(),
  });
  TransactionsTableCompanion.insert({
    this.id = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    required String invoiceJson,
    required String status,
    required DateTime createdAt,
    this.customerId = const Value.absent(),
  })  : invoiceJson = Value(invoiceJson),
        status = Value(status),
        createdAt = Value(createdAt);
  static Insertable<TransactionsTableData> custom({
    Expression<int>? id,
    Expression<String>? invoiceNumber,
    Expression<String>? invoiceJson,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? customerId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (invoiceJson != null) 'invoice_json': invoiceJson,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (customerId != null) 'customer_id': customerId,
    });
  }

  TransactionsTableCompanion copyWith(
      {Value<int>? id,
      Value<String?>? invoiceNumber,
      Value<String>? invoiceJson,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<int?>? customerId}) {
    return TransactionsTableCompanion(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceJson: invoiceJson ?? this.invoiceJson,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      customerId: customerId ?? this.customerId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (invoiceJson.present) {
      map['invoice_json'] = Variable<String>(invoiceJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableCompanion(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('invoiceJson: $invoiceJson, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('customerId: $customerId')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTableTable extends PaymentsTable
    with TableInfo<$PaymentsTableTable, PaymentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
      'transaction_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES transactions (id)'));
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountSubunitsMeta =
      const VerificationMeta('amountSubunits');
  @override
  late final GeneratedColumn<int> amountSubunits = GeneratedColumn<int>(
      'amount_subunits', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, transactionId, method, amountSubunits];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(Insertable<PaymentsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta,
          method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('amount_subunits')) {
      context.handle(
          _amountSubunitsMeta,
          amountSubunits.isAcceptableOrUnknown(
              data['amount_subunits']!, _amountSubunitsMeta));
    } else if (isInserting) {
      context.missing(_amountSubunitsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_id'])!,
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method'])!,
      amountSubunits: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_subunits'])!,
    );
  }

  @override
  $PaymentsTableTable createAlias(String alias) {
    return $PaymentsTableTable(attachedDatabase, alias);
  }
}

class PaymentsTableData extends DataClass
    implements Insertable<PaymentsTableData> {
  final int id;
  final int transactionId;
  final String method;
  final int amountSubunits;
  const PaymentsTableData(
      {required this.id,
      required this.transactionId,
      required this.method,
      required this.amountSubunits});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<int>(transactionId);
    map['method'] = Variable<String>(method);
    map['amount_subunits'] = Variable<int>(amountSubunits);
    return map;
  }

  PaymentsTableCompanion toCompanion(bool nullToAbsent) {
    return PaymentsTableCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      method: Value(method),
      amountSubunits: Value(amountSubunits),
    );
  }

  factory PaymentsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentsTableData(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      method: serializer.fromJson<String>(json['method']),
      amountSubunits: serializer.fromJson<int>(json['amountSubunits']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<int>(transactionId),
      'method': serializer.toJson<String>(method),
      'amountSubunits': serializer.toJson<int>(amountSubunits),
    };
  }

  PaymentsTableData copyWith(
          {int? id, int? transactionId, String? method, int? amountSubunits}) =>
      PaymentsTableData(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        method: method ?? this.method,
        amountSubunits: amountSubunits ?? this.amountSubunits,
      );
  PaymentsTableData copyWithCompanion(PaymentsTableCompanion data) {
    return PaymentsTableData(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      method: data.method.present ? data.method.value : this.method,
      amountSubunits: data.amountSubunits.present
          ? data.amountSubunits.value
          : this.amountSubunits,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsTableData(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('method: $method, ')
          ..write('amountSubunits: $amountSubunits')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, transactionId, method, amountSubunits);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentsTableData &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.method == this.method &&
          other.amountSubunits == this.amountSubunits);
}

class PaymentsTableCompanion extends UpdateCompanion<PaymentsTableData> {
  final Value<int> id;
  final Value<int> transactionId;
  final Value<String> method;
  final Value<int> amountSubunits;
  const PaymentsTableCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.method = const Value.absent(),
    this.amountSubunits = const Value.absent(),
  });
  PaymentsTableCompanion.insert({
    this.id = const Value.absent(),
    required int transactionId,
    required String method,
    required int amountSubunits,
  })  : transactionId = Value(transactionId),
        method = Value(method),
        amountSubunits = Value(amountSubunits);
  static Insertable<PaymentsTableData> custom({
    Expression<int>? id,
    Expression<int>? transactionId,
    Expression<String>? method,
    Expression<int>? amountSubunits,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (method != null) 'method': method,
      if (amountSubunits != null) 'amount_subunits': amountSubunits,
    });
  }

  PaymentsTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? transactionId,
      Value<String>? method,
      Value<int>? amountSubunits}) {
    return PaymentsTableCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      method: method ?? this.method,
      amountSubunits: amountSubunits ?? this.amountSubunits,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (amountSubunits.present) {
      map['amount_subunits'] = Variable<int>(amountSubunits.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsTableCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('method: $method, ')
          ..write('amountSubunits: $amountSubunits')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, SettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _businessNameMeta =
      const VerificationMeta('businessName');
  @override
  late final GeneratedColumn<String> businessName = GeneratedColumn<String>(
      'business_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('My Business'));
  static const VerificationMeta _taxRateMeta =
      const VerificationMeta('taxRate');
  @override
  late final GeneratedColumn<double> taxRate = GeneratedColumn<double>(
      'tax_rate', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant<double>(0));
  static const VerificationMeta _currencySymbolMeta =
      const VerificationMeta('currencySymbol');
  @override
  late final GeneratedColumn<String> currencySymbol = GeneratedColumn<String>(
      'currency_symbol', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(r'$'));
  static const VerificationMeta _receiptFooterMeta =
      const VerificationMeta('receiptFooter');
  @override
  late final GeneratedColumn<String> receiptFooter = GeneratedColumn<String>(
      'receipt_footer', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Thank you for your business!'));
  static const VerificationMeta _lastZReportAtMeta =
      const VerificationMeta('lastZReportAt');
  @override
  late final GeneratedColumn<String> lastZReportAt = GeneratedColumn<String>(
      'last_z_report_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _themeModeMeta =
      const VerificationMeta('themeMode');
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
      'theme_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('system'));
  static const VerificationMeta _logoPathMeta =
      const VerificationMeta('logoPath');
  @override
  late final GeneratedColumn<String> logoPath = GeneratedColumn<String>(
      'logo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _autoBackupEnabledMeta =
      const VerificationMeta('autoBackupEnabled');
  @override
  late final GeneratedColumn<bool> autoBackupEnabled = GeneratedColumn<bool>(
      'auto_backup_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("auto_backup_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastBackupAtMeta =
      const VerificationMeta('lastBackupAt');
  @override
  late final GeneratedColumn<String> lastBackupAt = GeneratedColumn<String>(
      'last_backup_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _printerTypeMeta =
      const VerificationMeta('printerType');
  @override
  late final GeneratedColumn<String> printerType = GeneratedColumn<String>(
      'printer_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('none'));
  static const VerificationMeta _printerAddressMeta =
      const VerificationMeta('printerAddress');
  @override
  late final GeneratedColumn<String> printerAddress = GeneratedColumn<String>(
      'printer_address', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _taxInclusiveMeta =
      const VerificationMeta('taxInclusive');
  @override
  late final GeneratedColumn<bool> taxInclusive = GeneratedColumn<bool>(
      'tax_inclusive', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("tax_inclusive" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        businessName,
        taxRate,
        currencySymbol,
        receiptFooter,
        lastZReportAt,
        themeMode,
        logoPath,
        autoBackupEnabled,
        lastBackupAt,
        printerType,
        printerAddress,
        taxInclusive
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<SettingsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('business_name')) {
      context.handle(
          _businessNameMeta,
          businessName.isAcceptableOrUnknown(
              data['business_name']!, _businessNameMeta));
    }
    if (data.containsKey('tax_rate')) {
      context.handle(_taxRateMeta,
          taxRate.isAcceptableOrUnknown(data['tax_rate']!, _taxRateMeta));
    }
    if (data.containsKey('currency_symbol')) {
      context.handle(
          _currencySymbolMeta,
          currencySymbol.isAcceptableOrUnknown(
              data['currency_symbol']!, _currencySymbolMeta));
    }
    if (data.containsKey('receipt_footer')) {
      context.handle(
          _receiptFooterMeta,
          receiptFooter.isAcceptableOrUnknown(
              data['receipt_footer']!, _receiptFooterMeta));
    }
    if (data.containsKey('last_z_report_at')) {
      context.handle(
          _lastZReportAtMeta,
          lastZReportAt.isAcceptableOrUnknown(
              data['last_z_report_at']!, _lastZReportAtMeta));
    }
    if (data.containsKey('theme_mode')) {
      context.handle(_themeModeMeta,
          themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta));
    }
    if (data.containsKey('logo_path')) {
      context.handle(_logoPathMeta,
          logoPath.isAcceptableOrUnknown(data['logo_path']!, _logoPathMeta));
    }
    if (data.containsKey('auto_backup_enabled')) {
      context.handle(
          _autoBackupEnabledMeta,
          autoBackupEnabled.isAcceptableOrUnknown(
              data['auto_backup_enabled']!, _autoBackupEnabledMeta));
    }
    if (data.containsKey('last_backup_at')) {
      context.handle(
          _lastBackupAtMeta,
          lastBackupAt.isAcceptableOrUnknown(
              data['last_backup_at']!, _lastBackupAtMeta));
    }
    if (data.containsKey('printer_type')) {
      context.handle(
          _printerTypeMeta,
          printerType.isAcceptableOrUnknown(
              data['printer_type']!, _printerTypeMeta));
    }
    if (data.containsKey('printer_address')) {
      context.handle(
          _printerAddressMeta,
          printerAddress.isAcceptableOrUnknown(
              data['printer_address']!, _printerAddressMeta));
    }
    if (data.containsKey('tax_inclusive')) {
      context.handle(
          _taxInclusiveMeta,
          taxInclusive.isAcceptableOrUnknown(
              data['tax_inclusive']!, _taxInclusiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      businessName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}business_name'])!,
      taxRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tax_rate'])!,
      currencySymbol: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}currency_symbol'])!,
      receiptFooter: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}receipt_footer'])!,
      lastZReportAt: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_z_report_at']),
      themeMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme_mode'])!,
      logoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}logo_path']),
      autoBackupEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}auto_backup_enabled'])!,
      lastBackupAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_backup_at']),
      printerType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}printer_type'])!,
      printerAddress: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}printer_address'])!,
      taxInclusive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}tax_inclusive'])!,
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }
}

class SettingsTableData extends DataClass
    implements Insertable<SettingsTableData> {
  final int id;
  final String businessName;
  final double taxRate;
  final String currencySymbol;
  final String receiptFooter;
  final String? lastZReportAt;
  final String themeMode;
  final String? logoPath;
  final bool autoBackupEnabled;
  final String? lastBackupAt;
  final String printerType;
  final String printerAddress;
  final bool taxInclusive;
  const SettingsTableData(
      {required this.id,
      required this.businessName,
      required this.taxRate,
      required this.currencySymbol,
      required this.receiptFooter,
      this.lastZReportAt,
      required this.themeMode,
      this.logoPath,
      required this.autoBackupEnabled,
      this.lastBackupAt,
      required this.printerType,
      required this.printerAddress,
      required this.taxInclusive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['business_name'] = Variable<String>(businessName);
    map['tax_rate'] = Variable<double>(taxRate);
    map['currency_symbol'] = Variable<String>(currencySymbol);
    map['receipt_footer'] = Variable<String>(receiptFooter);
    if (!nullToAbsent || lastZReportAt != null) {
      map['last_z_report_at'] = Variable<String>(lastZReportAt);
    }
    map['theme_mode'] = Variable<String>(themeMode);
    if (!nullToAbsent || logoPath != null) {
      map['logo_path'] = Variable<String>(logoPath);
    }
    map['auto_backup_enabled'] = Variable<bool>(autoBackupEnabled);
    if (!nullToAbsent || lastBackupAt != null) {
      map['last_backup_at'] = Variable<String>(lastBackupAt);
    }
    map['printer_type'] = Variable<String>(printerType);
    map['printer_address'] = Variable<String>(printerAddress);
    map['tax_inclusive'] = Variable<bool>(taxInclusive);
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(
      id: Value(id),
      businessName: Value(businessName),
      taxRate: Value(taxRate),
      currencySymbol: Value(currencySymbol),
      receiptFooter: Value(receiptFooter),
      lastZReportAt: lastZReportAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastZReportAt),
      themeMode: Value(themeMode),
      logoPath: logoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(logoPath),
      autoBackupEnabled: Value(autoBackupEnabled),
      lastBackupAt: lastBackupAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBackupAt),
      printerType: Value(printerType),
      printerAddress: Value(printerAddress),
      taxInclusive: Value(taxInclusive),
    );
  }

  factory SettingsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsTableData(
      id: serializer.fromJson<int>(json['id']),
      businessName: serializer.fromJson<String>(json['businessName']),
      taxRate: serializer.fromJson<double>(json['taxRate']),
      currencySymbol: serializer.fromJson<String>(json['currencySymbol']),
      receiptFooter: serializer.fromJson<String>(json['receiptFooter']),
      lastZReportAt: serializer.fromJson<String?>(json['lastZReportAt']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      logoPath: serializer.fromJson<String?>(json['logoPath']),
      autoBackupEnabled: serializer.fromJson<bool>(json['autoBackupEnabled']),
      lastBackupAt: serializer.fromJson<String?>(json['lastBackupAt']),
      printerType: serializer.fromJson<String>(json['printerType']),
      printerAddress: serializer.fromJson<String>(json['printerAddress']),
      taxInclusive: serializer.fromJson<bool>(json['taxInclusive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'businessName': serializer.toJson<String>(businessName),
      'taxRate': serializer.toJson<double>(taxRate),
      'currencySymbol': serializer.toJson<String>(currencySymbol),
      'receiptFooter': serializer.toJson<String>(receiptFooter),
      'lastZReportAt': serializer.toJson<String?>(lastZReportAt),
      'themeMode': serializer.toJson<String>(themeMode),
      'logoPath': serializer.toJson<String?>(logoPath),
      'autoBackupEnabled': serializer.toJson<bool>(autoBackupEnabled),
      'lastBackupAt': serializer.toJson<String?>(lastBackupAt),
      'printerType': serializer.toJson<String>(printerType),
      'printerAddress': serializer.toJson<String>(printerAddress),
      'taxInclusive': serializer.toJson<bool>(taxInclusive),
    };
  }

  SettingsTableData copyWith(
          {int? id,
          String? businessName,
          double? taxRate,
          String? currencySymbol,
          String? receiptFooter,
          Value<String?> lastZReportAt = const Value.absent(),
          String? themeMode,
          Value<String?> logoPath = const Value.absent(),
          bool? autoBackupEnabled,
          Value<String?> lastBackupAt = const Value.absent(),
          String? printerType,
          String? printerAddress,
          bool? taxInclusive}) =>
      SettingsTableData(
        id: id ?? this.id,
        businessName: businessName ?? this.businessName,
        taxRate: taxRate ?? this.taxRate,
        currencySymbol: currencySymbol ?? this.currencySymbol,
        receiptFooter: receiptFooter ?? this.receiptFooter,
        lastZReportAt:
            lastZReportAt.present ? lastZReportAt.value : this.lastZReportAt,
        themeMode: themeMode ?? this.themeMode,
        logoPath: logoPath.present ? logoPath.value : this.logoPath,
        autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
        lastBackupAt:
            lastBackupAt.present ? lastBackupAt.value : this.lastBackupAt,
        printerType: printerType ?? this.printerType,
        printerAddress: printerAddress ?? this.printerAddress,
        taxInclusive: taxInclusive ?? this.taxInclusive,
      );
  SettingsTableData copyWithCompanion(SettingsTableCompanion data) {
    return SettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      businessName: data.businessName.present
          ? data.businessName.value
          : this.businessName,
      taxRate: data.taxRate.present ? data.taxRate.value : this.taxRate,
      currencySymbol: data.currencySymbol.present
          ? data.currencySymbol.value
          : this.currencySymbol,
      receiptFooter: data.receiptFooter.present
          ? data.receiptFooter.value
          : this.receiptFooter,
      lastZReportAt: data.lastZReportAt.present
          ? data.lastZReportAt.value
          : this.lastZReportAt,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      logoPath: data.logoPath.present ? data.logoPath.value : this.logoPath,
      autoBackupEnabled: data.autoBackupEnabled.present
          ? data.autoBackupEnabled.value
          : this.autoBackupEnabled,
      lastBackupAt: data.lastBackupAt.present
          ? data.lastBackupAt.value
          : this.lastBackupAt,
      printerType:
          data.printerType.present ? data.printerType.value : this.printerType,
      printerAddress: data.printerAddress.present
          ? data.printerAddress.value
          : this.printerAddress,
      taxInclusive: data.taxInclusive.present
          ? data.taxInclusive.value
          : this.taxInclusive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableData(')
          ..write('id: $id, ')
          ..write('businessName: $businessName, ')
          ..write('taxRate: $taxRate, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('receiptFooter: $receiptFooter, ')
          ..write('lastZReportAt: $lastZReportAt, ')
          ..write('themeMode: $themeMode, ')
          ..write('logoPath: $logoPath, ')
          ..write('autoBackupEnabled: $autoBackupEnabled, ')
          ..write('lastBackupAt: $lastBackupAt, ')
          ..write('printerType: $printerType, ')
          ..write('printerAddress: $printerAddress, ')
          ..write('taxInclusive: $taxInclusive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      businessName,
      taxRate,
      currencySymbol,
      receiptFooter,
      lastZReportAt,
      themeMode,
      logoPath,
      autoBackupEnabled,
      lastBackupAt,
      printerType,
      printerAddress,
      taxInclusive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsTableData &&
          other.id == this.id &&
          other.businessName == this.businessName &&
          other.taxRate == this.taxRate &&
          other.currencySymbol == this.currencySymbol &&
          other.receiptFooter == this.receiptFooter &&
          other.lastZReportAt == this.lastZReportAt &&
          other.themeMode == this.themeMode &&
          other.logoPath == this.logoPath &&
          other.autoBackupEnabled == this.autoBackupEnabled &&
          other.lastBackupAt == this.lastBackupAt &&
          other.printerType == this.printerType &&
          other.printerAddress == this.printerAddress &&
          other.taxInclusive == this.taxInclusive);
}

class SettingsTableCompanion extends UpdateCompanion<SettingsTableData> {
  final Value<int> id;
  final Value<String> businessName;
  final Value<double> taxRate;
  final Value<String> currencySymbol;
  final Value<String> receiptFooter;
  final Value<String?> lastZReportAt;
  final Value<String> themeMode;
  final Value<String?> logoPath;
  final Value<bool> autoBackupEnabled;
  final Value<String?> lastBackupAt;
  final Value<String> printerType;
  final Value<String> printerAddress;
  final Value<bool> taxInclusive;
  const SettingsTableCompanion({
    this.id = const Value.absent(),
    this.businessName = const Value.absent(),
    this.taxRate = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.receiptFooter = const Value.absent(),
    this.lastZReportAt = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.autoBackupEnabled = const Value.absent(),
    this.lastBackupAt = const Value.absent(),
    this.printerType = const Value.absent(),
    this.printerAddress = const Value.absent(),
    this.taxInclusive = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.businessName = const Value.absent(),
    this.taxRate = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.receiptFooter = const Value.absent(),
    this.lastZReportAt = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.autoBackupEnabled = const Value.absent(),
    this.lastBackupAt = const Value.absent(),
    this.printerType = const Value.absent(),
    this.printerAddress = const Value.absent(),
    this.taxInclusive = const Value.absent(),
  });
  static Insertable<SettingsTableData> custom({
    Expression<int>? id,
    Expression<String>? businessName,
    Expression<double>? taxRate,
    Expression<String>? currencySymbol,
    Expression<String>? receiptFooter,
    Expression<String>? lastZReportAt,
    Expression<String>? themeMode,
    Expression<String>? logoPath,
    Expression<bool>? autoBackupEnabled,
    Expression<String>? lastBackupAt,
    Expression<String>? printerType,
    Expression<String>? printerAddress,
    Expression<bool>? taxInclusive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessName != null) 'business_name': businessName,
      if (taxRate != null) 'tax_rate': taxRate,
      if (currencySymbol != null) 'currency_symbol': currencySymbol,
      if (receiptFooter != null) 'receipt_footer': receiptFooter,
      if (lastZReportAt != null) 'last_z_report_at': lastZReportAt,
      if (themeMode != null) 'theme_mode': themeMode,
      if (logoPath != null) 'logo_path': logoPath,
      if (autoBackupEnabled != null) 'auto_backup_enabled': autoBackupEnabled,
      if (lastBackupAt != null) 'last_backup_at': lastBackupAt,
      if (printerType != null) 'printer_type': printerType,
      if (printerAddress != null) 'printer_address': printerAddress,
      if (taxInclusive != null) 'tax_inclusive': taxInclusive,
    });
  }

  SettingsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? businessName,
      Value<double>? taxRate,
      Value<String>? currencySymbol,
      Value<String>? receiptFooter,
      Value<String?>? lastZReportAt,
      Value<String>? themeMode,
      Value<String?>? logoPath,
      Value<bool>? autoBackupEnabled,
      Value<String?>? lastBackupAt,
      Value<String>? printerType,
      Value<String>? printerAddress,
      Value<bool>? taxInclusive}) {
    return SettingsTableCompanion(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      taxRate: taxRate ?? this.taxRate,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      lastZReportAt: lastZReportAt ?? this.lastZReportAt,
      themeMode: themeMode ?? this.themeMode,
      logoPath: logoPath ?? this.logoPath,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      printerType: printerType ?? this.printerType,
      printerAddress: printerAddress ?? this.printerAddress,
      taxInclusive: taxInclusive ?? this.taxInclusive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (businessName.present) {
      map['business_name'] = Variable<String>(businessName.value);
    }
    if (taxRate.present) {
      map['tax_rate'] = Variable<double>(taxRate.value);
    }
    if (currencySymbol.present) {
      map['currency_symbol'] = Variable<String>(currencySymbol.value);
    }
    if (receiptFooter.present) {
      map['receipt_footer'] = Variable<String>(receiptFooter.value);
    }
    if (lastZReportAt.present) {
      map['last_z_report_at'] = Variable<String>(lastZReportAt.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (logoPath.present) {
      map['logo_path'] = Variable<String>(logoPath.value);
    }
    if (autoBackupEnabled.present) {
      map['auto_backup_enabled'] = Variable<bool>(autoBackupEnabled.value);
    }
    if (lastBackupAt.present) {
      map['last_backup_at'] = Variable<String>(lastBackupAt.value);
    }
    if (printerType.present) {
      map['printer_type'] = Variable<String>(printerType.value);
    }
    if (printerAddress.present) {
      map['printer_address'] = Variable<String>(printerAddress.value);
    }
    if (taxInclusive.present) {
      map['tax_inclusive'] = Variable<bool>(taxInclusive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('businessName: $businessName, ')
          ..write('taxRate: $taxRate, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('receiptFooter: $receiptFooter, ')
          ..write('lastZReportAt: $lastZReportAt, ')
          ..write('themeMode: $themeMode, ')
          ..write('logoPath: $logoPath, ')
          ..write('autoBackupEnabled: $autoBackupEnabled, ')
          ..write('lastBackupAt: $lastBackupAt, ')
          ..write('printerType: $printerType, ')
          ..write('printerAddress: $printerAddress, ')
          ..write('taxInclusive: $taxInclusive')
          ..write(')'))
        .toString();
  }
}

class $CashDrawerSessionsTableTable extends CashDrawerSessionsTable
    with TableInfo<$CashDrawerSessionsTableTable, CashDrawerSessionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashDrawerSessionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _openedAtMeta =
      const VerificationMeta('openedAt');
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
      'opened_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _closedAtMeta =
      const VerificationMeta('closedAt');
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
      'closed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _openingBalanceSubunitsMeta =
      const VerificationMeta('openingBalanceSubunits');
  @override
  late final GeneratedColumn<int> openingBalanceSubunits = GeneratedColumn<int>(
      'opening_balance_subunits', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _closingBalanceSubunitsMeta =
      const VerificationMeta('closingBalanceSubunits');
  @override
  late final GeneratedColumn<int> closingBalanceSubunits = GeneratedColumn<int>(
      'closing_balance_subunits', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        openedAt,
        closedAt,
        openingBalanceSubunits,
        closingBalanceSubunits,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_drawer_sessions';
  @override
  VerificationContext validateIntegrity(
      Insertable<CashDrawerSessionsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('opened_at')) {
      context.handle(_openedAtMeta,
          openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta));
    } else if (isInserting) {
      context.missing(_openedAtMeta);
    }
    if (data.containsKey('closed_at')) {
      context.handle(_closedAtMeta,
          closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta));
    }
    if (data.containsKey('opening_balance_subunits')) {
      context.handle(
          _openingBalanceSubunitsMeta,
          openingBalanceSubunits.isAcceptableOrUnknown(
              data['opening_balance_subunits']!, _openingBalanceSubunitsMeta));
    } else if (isInserting) {
      context.missing(_openingBalanceSubunitsMeta);
    }
    if (data.containsKey('closing_balance_subunits')) {
      context.handle(
          _closingBalanceSubunitsMeta,
          closingBalanceSubunits.isAcceptableOrUnknown(
              data['closing_balance_subunits']!, _closingBalanceSubunitsMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashDrawerSessionsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashDrawerSessionsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      openedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}opened_at'])!,
      closedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}closed_at']),
      openingBalanceSubunits: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}opening_balance_subunits'])!,
      closingBalanceSubunits: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}closing_balance_subunits']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $CashDrawerSessionsTableTable createAlias(String alias) {
    return $CashDrawerSessionsTableTable(attachedDatabase, alias);
  }
}

class CashDrawerSessionsTableData extends DataClass
    implements Insertable<CashDrawerSessionsTableData> {
  final int id;
  final DateTime openedAt;
  final DateTime? closedAt;
  final int openingBalanceSubunits;
  final int? closingBalanceSubunits;
  final String? notes;
  const CashDrawerSessionsTableData(
      {required this.id,
      required this.openedAt,
      this.closedAt,
      required this.openingBalanceSubunits,
      this.closingBalanceSubunits,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['opened_at'] = Variable<DateTime>(openedAt);
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    map['opening_balance_subunits'] = Variable<int>(openingBalanceSubunits);
    if (!nullToAbsent || closingBalanceSubunits != null) {
      map['closing_balance_subunits'] = Variable<int>(closingBalanceSubunits);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  CashDrawerSessionsTableCompanion toCompanion(bool nullToAbsent) {
    return CashDrawerSessionsTableCompanion(
      id: Value(id),
      openedAt: Value(openedAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      openingBalanceSubunits: Value(openingBalanceSubunits),
      closingBalanceSubunits: closingBalanceSubunits == null && nullToAbsent
          ? const Value.absent()
          : Value(closingBalanceSubunits),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory CashDrawerSessionsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashDrawerSessionsTableData(
      id: serializer.fromJson<int>(json['id']),
      openedAt: serializer.fromJson<DateTime>(json['openedAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
      openingBalanceSubunits:
          serializer.fromJson<int>(json['openingBalanceSubunits']),
      closingBalanceSubunits:
          serializer.fromJson<int?>(json['closingBalanceSubunits']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'openedAt': serializer.toJson<DateTime>(openedAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
      'openingBalanceSubunits': serializer.toJson<int>(openingBalanceSubunits),
      'closingBalanceSubunits': serializer.toJson<int?>(closingBalanceSubunits),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  CashDrawerSessionsTableData copyWith(
          {int? id,
          DateTime? openedAt,
          Value<DateTime?> closedAt = const Value.absent(),
          int? openingBalanceSubunits,
          Value<int?> closingBalanceSubunits = const Value.absent(),
          Value<String?> notes = const Value.absent()}) =>
      CashDrawerSessionsTableData(
        id: id ?? this.id,
        openedAt: openedAt ?? this.openedAt,
        closedAt: closedAt.present ? closedAt.value : this.closedAt,
        openingBalanceSubunits:
            openingBalanceSubunits ?? this.openingBalanceSubunits,
        closingBalanceSubunits: closingBalanceSubunits.present
            ? closingBalanceSubunits.value
            : this.closingBalanceSubunits,
        notes: notes.present ? notes.value : this.notes,
      );
  CashDrawerSessionsTableData copyWithCompanion(
      CashDrawerSessionsTableCompanion data) {
    return CashDrawerSessionsTableData(
      id: data.id.present ? data.id.value : this.id,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      openingBalanceSubunits: data.openingBalanceSubunits.present
          ? data.openingBalanceSubunits.value
          : this.openingBalanceSubunits,
      closingBalanceSubunits: data.closingBalanceSubunits.present
          ? data.closingBalanceSubunits.value
          : this.closingBalanceSubunits,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashDrawerSessionsTableData(')
          ..write('id: $id, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('openingBalanceSubunits: $openingBalanceSubunits, ')
          ..write('closingBalanceSubunits: $closingBalanceSubunits, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, openedAt, closedAt,
      openingBalanceSubunits, closingBalanceSubunits, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashDrawerSessionsTableData &&
          other.id == this.id &&
          other.openedAt == this.openedAt &&
          other.closedAt == this.closedAt &&
          other.openingBalanceSubunits == this.openingBalanceSubunits &&
          other.closingBalanceSubunits == this.closingBalanceSubunits &&
          other.notes == this.notes);
}

class CashDrawerSessionsTableCompanion
    extends UpdateCompanion<CashDrawerSessionsTableData> {
  final Value<int> id;
  final Value<DateTime> openedAt;
  final Value<DateTime?> closedAt;
  final Value<int> openingBalanceSubunits;
  final Value<int?> closingBalanceSubunits;
  final Value<String?> notes;
  const CashDrawerSessionsTableCompanion({
    this.id = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.openingBalanceSubunits = const Value.absent(),
    this.closingBalanceSubunits = const Value.absent(),
    this.notes = const Value.absent(),
  });
  CashDrawerSessionsTableCompanion.insert({
    this.id = const Value.absent(),
    required DateTime openedAt,
    this.closedAt = const Value.absent(),
    required int openingBalanceSubunits,
    this.closingBalanceSubunits = const Value.absent(),
    this.notes = const Value.absent(),
  })  : openedAt = Value(openedAt),
        openingBalanceSubunits = Value(openingBalanceSubunits);
  static Insertable<CashDrawerSessionsTableData> custom({
    Expression<int>? id,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? closedAt,
    Expression<int>? openingBalanceSubunits,
    Expression<int>? closingBalanceSubunits,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (openedAt != null) 'opened_at': openedAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (openingBalanceSubunits != null)
        'opening_balance_subunits': openingBalanceSubunits,
      if (closingBalanceSubunits != null)
        'closing_balance_subunits': closingBalanceSubunits,
      if (notes != null) 'notes': notes,
    });
  }

  CashDrawerSessionsTableCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? openedAt,
      Value<DateTime?>? closedAt,
      Value<int>? openingBalanceSubunits,
      Value<int?>? closingBalanceSubunits,
      Value<String?>? notes}) {
    return CashDrawerSessionsTableCompanion(
      id: id ?? this.id,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      openingBalanceSubunits:
          openingBalanceSubunits ?? this.openingBalanceSubunits,
      closingBalanceSubunits:
          closingBalanceSubunits ?? this.closingBalanceSubunits,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (openingBalanceSubunits.present) {
      map['opening_balance_subunits'] =
          Variable<int>(openingBalanceSubunits.value);
    }
    if (closingBalanceSubunits.present) {
      map['closing_balance_subunits'] =
          Variable<int>(closingBalanceSubunits.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashDrawerSessionsTableCompanion(')
          ..write('id: $id, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('openingBalanceSubunits: $openingBalanceSubunits, ')
          ..write('closingBalanceSubunits: $closingBalanceSubunits, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $UsersTableTable extends UsersTable
    with TableInfo<$UsersTableTable, UsersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pinMeta = const VerificationMeta('pin');
  @override
  late final GeneratedColumn<String> pin = GeneratedColumn<String>(
      'pin', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<String> salt = GeneratedColumn<String>(
      'salt', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('cashier'));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _failedAttemptsMeta =
      const VerificationMeta('failedAttempts');
  @override
  late final GeneratedColumn<int> failedAttempts = GeneratedColumn<int>(
      'failed_attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lockedUntilMeta =
      const VerificationMeta('lockedUntil');
  @override
  late final GeneratedColumn<DateTime> lockedUntil = GeneratedColumn<DateTime>(
      'locked_until', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        username,
        displayName,
        pin,
        salt,
        role,
        isActive,
        failedAttempts,
        lockedUntil,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<UsersTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('pin')) {
      context.handle(
          _pinMeta, pin.isAcceptableOrUnknown(data['pin']!, _pinMeta));
    } else if (isInserting) {
      context.missing(_pinMeta);
    }
    if (data.containsKey('salt')) {
      context.handle(
          _saltMeta, salt.isAcceptableOrUnknown(data['salt']!, _saltMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('failed_attempts')) {
      context.handle(
          _failedAttemptsMeta,
          failedAttempts.isAcceptableOrUnknown(
              data['failed_attempts']!, _failedAttemptsMeta));
    }
    if (data.containsKey('locked_until')) {
      context.handle(
          _lockedUntilMeta,
          lockedUntil.isAcceptableOrUnknown(
              data['locked_until']!, _lockedUntilMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UsersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsersTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      pin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pin'])!,
      salt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}salt'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      failedAttempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}failed_attempts'])!,
      lockedUntil: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}locked_until']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $UsersTableTable createAlias(String alias) {
    return $UsersTableTable(attachedDatabase, alias);
  }
}

class UsersTableData extends DataClass implements Insertable<UsersTableData> {
  final int id;
  final String username;
  final String displayName;
  final String pin;
  final String salt;
  final String role;
  final bool isActive;
  final int failedAttempts;
  final DateTime? lockedUntil;
  final DateTime createdAt;
  const UsersTableData(
      {required this.id,
      required this.username,
      required this.displayName,
      required this.pin,
      required this.salt,
      required this.role,
      required this.isActive,
      required this.failedAttempts,
      this.lockedUntil,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    map['display_name'] = Variable<String>(displayName);
    map['pin'] = Variable<String>(pin);
    map['salt'] = Variable<String>(salt);
    map['role'] = Variable<String>(role);
    map['is_active'] = Variable<bool>(isActive);
    map['failed_attempts'] = Variable<int>(failedAttempts);
    if (!nullToAbsent || lockedUntil != null) {
      map['locked_until'] = Variable<DateTime>(lockedUntil);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersTableCompanion toCompanion(bool nullToAbsent) {
    return UsersTableCompanion(
      id: Value(id),
      username: Value(username),
      displayName: Value(displayName),
      pin: Value(pin),
      salt: Value(salt),
      role: Value(role),
      isActive: Value(isActive),
      failedAttempts: Value(failedAttempts),
      lockedUntil: lockedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(lockedUntil),
      createdAt: Value(createdAt),
    );
  }

  factory UsersTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsersTableData(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      displayName: serializer.fromJson<String>(json['displayName']),
      pin: serializer.fromJson<String>(json['pin']),
      salt: serializer.fromJson<String>(json['salt']),
      role: serializer.fromJson<String>(json['role']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      failedAttempts: serializer.fromJson<int>(json['failedAttempts']),
      lockedUntil: serializer.fromJson<DateTime?>(json['lockedUntil']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'displayName': serializer.toJson<String>(displayName),
      'pin': serializer.toJson<String>(pin),
      'salt': serializer.toJson<String>(salt),
      'role': serializer.toJson<String>(role),
      'isActive': serializer.toJson<bool>(isActive),
      'failedAttempts': serializer.toJson<int>(failedAttempts),
      'lockedUntil': serializer.toJson<DateTime?>(lockedUntil),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UsersTableData copyWith(
          {int? id,
          String? username,
          String? displayName,
          String? pin,
          String? salt,
          String? role,
          bool? isActive,
          int? failedAttempts,
          Value<DateTime?> lockedUntil = const Value.absent(),
          DateTime? createdAt}) =>
      UsersTableData(
        id: id ?? this.id,
        username: username ?? this.username,
        displayName: displayName ?? this.displayName,
        pin: pin ?? this.pin,
        salt: salt ?? this.salt,
        role: role ?? this.role,
        isActive: isActive ?? this.isActive,
        failedAttempts: failedAttempts ?? this.failedAttempts,
        lockedUntil: lockedUntil.present ? lockedUntil.value : this.lockedUntil,
        createdAt: createdAt ?? this.createdAt,
      );
  UsersTableData copyWithCompanion(UsersTableCompanion data) {
    return UsersTableData(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      pin: data.pin.present ? data.pin.value : this.pin,
      salt: data.salt.present ? data.salt.value : this.salt,
      role: data.role.present ? data.role.value : this.role,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      failedAttempts: data.failedAttempts.present
          ? data.failedAttempts.value
          : this.failedAttempts,
      lockedUntil:
          data.lockedUntil.present ? data.lockedUntil.value : this.lockedUntil,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsersTableData(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('pin: $pin, ')
          ..write('salt: $salt, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('failedAttempts: $failedAttempts, ')
          ..write('lockedUntil: $lockedUntil, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, username, displayName, pin, salt, role,
      isActive, failedAttempts, lockedUntil, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsersTableData &&
          other.id == this.id &&
          other.username == this.username &&
          other.displayName == this.displayName &&
          other.pin == this.pin &&
          other.salt == this.salt &&
          other.role == this.role &&
          other.isActive == this.isActive &&
          other.failedAttempts == this.failedAttempts &&
          other.lockedUntil == this.lockedUntil &&
          other.createdAt == this.createdAt);
}

class UsersTableCompanion extends UpdateCompanion<UsersTableData> {
  final Value<int> id;
  final Value<String> username;
  final Value<String> displayName;
  final Value<String> pin;
  final Value<String> salt;
  final Value<String> role;
  final Value<bool> isActive;
  final Value<int> failedAttempts;
  final Value<DateTime?> lockedUntil;
  final Value<DateTime> createdAt;
  const UsersTableCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.pin = const Value.absent(),
    this.salt = const Value.absent(),
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.failedAttempts = const Value.absent(),
    this.lockedUntil = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UsersTableCompanion.insert({
    this.id = const Value.absent(),
    required String username,
    required String displayName,
    required String pin,
    this.salt = const Value.absent(),
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.failedAttempts = const Value.absent(),
    this.lockedUntil = const Value.absent(),
    required DateTime createdAt,
  })  : username = Value(username),
        displayName = Value(displayName),
        pin = Value(pin),
        createdAt = Value(createdAt);
  static Insertable<UsersTableData> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<String>? displayName,
    Expression<String>? pin,
    Expression<String>? salt,
    Expression<String>? role,
    Expression<bool>? isActive,
    Expression<int>? failedAttempts,
    Expression<DateTime>? lockedUntil,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (pin != null) 'pin': pin,
      if (salt != null) 'salt': salt,
      if (role != null) 'role': role,
      if (isActive != null) 'is_active': isActive,
      if (failedAttempts != null) 'failed_attempts': failedAttempts,
      if (lockedUntil != null) 'locked_until': lockedUntil,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UsersTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? username,
      Value<String>? displayName,
      Value<String>? pin,
      Value<String>? salt,
      Value<String>? role,
      Value<bool>? isActive,
      Value<int>? failedAttempts,
      Value<DateTime?>? lockedUntil,
      Value<DateTime>? createdAt}) {
    return UsersTableCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      pin: pin ?? this.pin,
      salt: salt ?? this.salt,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (pin.present) {
      map['pin'] = Variable<String>(pin.value);
    }
    if (salt.present) {
      map['salt'] = Variable<String>(salt.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (failedAttempts.present) {
      map['failed_attempts'] = Variable<int>(failedAttempts.value);
    }
    if (lockedUntil.present) {
      map['locked_until'] = Variable<DateTime>(lockedUntil.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersTableCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('pin: $pin, ')
          ..write('salt: $salt, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('failedAttempts: $failedAttempts, ')
          ..write('lockedUntil: $lockedUntil, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RefundsTableTable extends RefundsTable
    with TableInfo<$RefundsTableTable, RefundsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RefundsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _originalTransactionIdMeta =
      const VerificationMeta('originalTransactionId');
  @override
  late final GeneratedColumn<int> originalTransactionId = GeneratedColumn<int>(
      'original_transaction_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES transactions (id)'));
  static const VerificationMeta _lineIndexMeta =
      const VerificationMeta('lineIndex');
  @override
  late final GeneratedColumn<int> lineIndex = GeneratedColumn<int>(
      'line_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _amountSubunitsMeta =
      const VerificationMeta('amountSubunits');
  @override
  late final GeneratedColumn<int> amountSubunits = GeneratedColumn<int>(
      'amount_subunits', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        originalTransactionId,
        lineIndex,
        quantity,
        amountSubunits,
        reason,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'refunds';
  @override
  VerificationContext validateIntegrity(Insertable<RefundsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('original_transaction_id')) {
      context.handle(
          _originalTransactionIdMeta,
          originalTransactionId.isAcceptableOrUnknown(
              data['original_transaction_id']!, _originalTransactionIdMeta));
    } else if (isInserting) {
      context.missing(_originalTransactionIdMeta);
    }
    if (data.containsKey('line_index')) {
      context.handle(_lineIndexMeta,
          lineIndex.isAcceptableOrUnknown(data['line_index']!, _lineIndexMeta));
    } else if (isInserting) {
      context.missing(_lineIndexMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('amount_subunits')) {
      context.handle(
          _amountSubunitsMeta,
          amountSubunits.isAcceptableOrUnknown(
              data['amount_subunits']!, _amountSubunitsMeta));
    } else if (isInserting) {
      context.missing(_amountSubunitsMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RefundsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RefundsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      originalTransactionId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}original_transaction_id'])!,
      lineIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}line_index'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      amountSubunits: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_subunits'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $RefundsTableTable createAlias(String alias) {
    return $RefundsTableTable(attachedDatabase, alias);
  }
}

class RefundsTableData extends DataClass
    implements Insertable<RefundsTableData> {
  final int id;
  final int originalTransactionId;
  final int lineIndex;
  final int quantity;
  final int amountSubunits;
  final String reason;
  final DateTime createdAt;
  const RefundsTableData(
      {required this.id,
      required this.originalTransactionId,
      required this.lineIndex,
      required this.quantity,
      required this.amountSubunits,
      required this.reason,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['original_transaction_id'] = Variable<int>(originalTransactionId);
    map['line_index'] = Variable<int>(lineIndex);
    map['quantity'] = Variable<int>(quantity);
    map['amount_subunits'] = Variable<int>(amountSubunits);
    map['reason'] = Variable<String>(reason);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RefundsTableCompanion toCompanion(bool nullToAbsent) {
    return RefundsTableCompanion(
      id: Value(id),
      originalTransactionId: Value(originalTransactionId),
      lineIndex: Value(lineIndex),
      quantity: Value(quantity),
      amountSubunits: Value(amountSubunits),
      reason: Value(reason),
      createdAt: Value(createdAt),
    );
  }

  factory RefundsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RefundsTableData(
      id: serializer.fromJson<int>(json['id']),
      originalTransactionId:
          serializer.fromJson<int>(json['originalTransactionId']),
      lineIndex: serializer.fromJson<int>(json['lineIndex']),
      quantity: serializer.fromJson<int>(json['quantity']),
      amountSubunits: serializer.fromJson<int>(json['amountSubunits']),
      reason: serializer.fromJson<String>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'originalTransactionId': serializer.toJson<int>(originalTransactionId),
      'lineIndex': serializer.toJson<int>(lineIndex),
      'quantity': serializer.toJson<int>(quantity),
      'amountSubunits': serializer.toJson<int>(amountSubunits),
      'reason': serializer.toJson<String>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RefundsTableData copyWith(
          {int? id,
          int? originalTransactionId,
          int? lineIndex,
          int? quantity,
          int? amountSubunits,
          String? reason,
          DateTime? createdAt}) =>
      RefundsTableData(
        id: id ?? this.id,
        originalTransactionId:
            originalTransactionId ?? this.originalTransactionId,
        lineIndex: lineIndex ?? this.lineIndex,
        quantity: quantity ?? this.quantity,
        amountSubunits: amountSubunits ?? this.amountSubunits,
        reason: reason ?? this.reason,
        createdAt: createdAt ?? this.createdAt,
      );
  RefundsTableData copyWithCompanion(RefundsTableCompanion data) {
    return RefundsTableData(
      id: data.id.present ? data.id.value : this.id,
      originalTransactionId: data.originalTransactionId.present
          ? data.originalTransactionId.value
          : this.originalTransactionId,
      lineIndex: data.lineIndex.present ? data.lineIndex.value : this.lineIndex,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      amountSubunits: data.amountSubunits.present
          ? data.amountSubunits.value
          : this.amountSubunits,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RefundsTableData(')
          ..write('id: $id, ')
          ..write('originalTransactionId: $originalTransactionId, ')
          ..write('lineIndex: $lineIndex, ')
          ..write('quantity: $quantity, ')
          ..write('amountSubunits: $amountSubunits, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, originalTransactionId, lineIndex,
      quantity, amountSubunits, reason, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RefundsTableData &&
          other.id == this.id &&
          other.originalTransactionId == this.originalTransactionId &&
          other.lineIndex == this.lineIndex &&
          other.quantity == this.quantity &&
          other.amountSubunits == this.amountSubunits &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt);
}

class RefundsTableCompanion extends UpdateCompanion<RefundsTableData> {
  final Value<int> id;
  final Value<int> originalTransactionId;
  final Value<int> lineIndex;
  final Value<int> quantity;
  final Value<int> amountSubunits;
  final Value<String> reason;
  final Value<DateTime> createdAt;
  const RefundsTableCompanion({
    this.id = const Value.absent(),
    this.originalTransactionId = const Value.absent(),
    this.lineIndex = const Value.absent(),
    this.quantity = const Value.absent(),
    this.amountSubunits = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RefundsTableCompanion.insert({
    this.id = const Value.absent(),
    required int originalTransactionId,
    required int lineIndex,
    required int quantity,
    required int amountSubunits,
    this.reason = const Value.absent(),
    required DateTime createdAt,
  })  : originalTransactionId = Value(originalTransactionId),
        lineIndex = Value(lineIndex),
        quantity = Value(quantity),
        amountSubunits = Value(amountSubunits),
        createdAt = Value(createdAt);
  static Insertable<RefundsTableData> custom({
    Expression<int>? id,
    Expression<int>? originalTransactionId,
    Expression<int>? lineIndex,
    Expression<int>? quantity,
    Expression<int>? amountSubunits,
    Expression<String>? reason,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (originalTransactionId != null)
        'original_transaction_id': originalTransactionId,
      if (lineIndex != null) 'line_index': lineIndex,
      if (quantity != null) 'quantity': quantity,
      if (amountSubunits != null) 'amount_subunits': amountSubunits,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RefundsTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? originalTransactionId,
      Value<int>? lineIndex,
      Value<int>? quantity,
      Value<int>? amountSubunits,
      Value<String>? reason,
      Value<DateTime>? createdAt}) {
    return RefundsTableCompanion(
      id: id ?? this.id,
      originalTransactionId:
          originalTransactionId ?? this.originalTransactionId,
      lineIndex: lineIndex ?? this.lineIndex,
      quantity: quantity ?? this.quantity,
      amountSubunits: amountSubunits ?? this.amountSubunits,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (originalTransactionId.present) {
      map['original_transaction_id'] =
          Variable<int>(originalTransactionId.value);
    }
    if (lineIndex.present) {
      map['line_index'] = Variable<int>(lineIndex.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (amountSubunits.present) {
      map['amount_subunits'] = Variable<int>(amountSubunits.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RefundsTableCompanion(')
          ..write('id: $id, ')
          ..write('originalTransactionId: $originalTransactionId, ')
          ..write('lineIndex: $lineIndex, ')
          ..write('quantity: $quantity, ')
          ..write('amountSubunits: $amountSubunits, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CashMovementsTableTable extends CashMovementsTable
    with TableInfo<$CashMovementsTableTable, CashMovementsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashMovementsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
      'session_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES cash_drawer_sessions (id)'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountSubunitsMeta =
      const VerificationMeta('amountSubunits');
  @override
  late final GeneratedColumn<int> amountSubunits = GeneratedColumn<int>(
      'amount_subunits', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, sessionId, type, amountSubunits, note, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_movements';
  @override
  VerificationContext validateIntegrity(
      Insertable<CashMovementsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount_subunits')) {
      context.handle(
          _amountSubunitsMeta,
          amountSubunits.isAcceptableOrUnknown(
              data['amount_subunits']!, _amountSubunitsMeta));
    } else if (isInserting) {
      context.missing(_amountSubunitsMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashMovementsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashMovementsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      amountSubunits: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_subunits'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CashMovementsTableTable createAlias(String alias) {
    return $CashMovementsTableTable(attachedDatabase, alias);
  }
}

class CashMovementsTableData extends DataClass
    implements Insertable<CashMovementsTableData> {
  final int id;
  final int sessionId;
  final String type;
  final int amountSubunits;
  final String note;
  final DateTime createdAt;
  const CashMovementsTableData(
      {required this.id,
      required this.sessionId,
      required this.type,
      required this.amountSubunits,
      required this.note,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['type'] = Variable<String>(type);
    map['amount_subunits'] = Variable<int>(amountSubunits);
    map['note'] = Variable<String>(note);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CashMovementsTableCompanion toCompanion(bool nullToAbsent) {
    return CashMovementsTableCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      type: Value(type),
      amountSubunits: Value(amountSubunits),
      note: Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory CashMovementsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashMovementsTableData(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      type: serializer.fromJson<String>(json['type']),
      amountSubunits: serializer.fromJson<int>(json['amountSubunits']),
      note: serializer.fromJson<String>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'type': serializer.toJson<String>(type),
      'amountSubunits': serializer.toJson<int>(amountSubunits),
      'note': serializer.toJson<String>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CashMovementsTableData copyWith(
          {int? id,
          int? sessionId,
          String? type,
          int? amountSubunits,
          String? note,
          DateTime? createdAt}) =>
      CashMovementsTableData(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        type: type ?? this.type,
        amountSubunits: amountSubunits ?? this.amountSubunits,
        note: note ?? this.note,
        createdAt: createdAt ?? this.createdAt,
      );
  CashMovementsTableData copyWithCompanion(CashMovementsTableCompanion data) {
    return CashMovementsTableData(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      type: data.type.present ? data.type.value : this.type,
      amountSubunits: data.amountSubunits.present
          ? data.amountSubunits.value
          : this.amountSubunits,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashMovementsTableData(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('type: $type, ')
          ..write('amountSubunits: $amountSubunits, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, type, amountSubunits, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashMovementsTableData &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.type == this.type &&
          other.amountSubunits == this.amountSubunits &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class CashMovementsTableCompanion
    extends UpdateCompanion<CashMovementsTableData> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> type;
  final Value<int> amountSubunits;
  final Value<String> note;
  final Value<DateTime> createdAt;
  const CashMovementsTableCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.type = const Value.absent(),
    this.amountSubunits = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CashMovementsTableCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String type,
    required int amountSubunits,
    this.note = const Value.absent(),
    required DateTime createdAt,
  })  : sessionId = Value(sessionId),
        type = Value(type),
        amountSubunits = Value(amountSubunits),
        createdAt = Value(createdAt);
  static Insertable<CashMovementsTableData> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? type,
    Expression<int>? amountSubunits,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (type != null) 'type': type,
      if (amountSubunits != null) 'amount_subunits': amountSubunits,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CashMovementsTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? sessionId,
      Value<String>? type,
      Value<int>? amountSubunits,
      Value<String>? note,
      Value<DateTime>? createdAt}) {
    return CashMovementsTableCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      amountSubunits: amountSubunits ?? this.amountSubunits,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amountSubunits.present) {
      map['amount_subunits'] = Variable<int>(amountSubunits.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashMovementsTableCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('type: $type, ')
          ..write('amountSubunits: $amountSubunits, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ItemsTableTable itemsTable = $ItemsTableTable(this);
  late final $CustomersTableTable customersTable = $CustomersTableTable(this);
  late final $TransactionsTableTable transactionsTable =
      $TransactionsTableTable(this);
  late final $PaymentsTableTable paymentsTable = $PaymentsTableTable(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  late final $CashDrawerSessionsTableTable cashDrawerSessionsTable =
      $CashDrawerSessionsTableTable(this);
  late final $UsersTableTable usersTable = $UsersTableTable(this);
  late final $RefundsTableTable refundsTable = $RefundsTableTable(this);
  late final $CashMovementsTableTable cashMovementsTable =
      $CashMovementsTableTable(this);
  late final ItemsDao itemsDao = ItemsDao(this as AppDatabase);
  late final TransactionsDao transactionsDao =
      TransactionsDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final CashDrawerDao cashDrawerDao = CashDrawerDao(this as AppDatabase);
  late final CustomersDao customersDao = CustomersDao(this as AppDatabase);
  late final UsersDao usersDao = UsersDao(this as AppDatabase);
  late final RefundsDao refundsDao = RefundsDao(this as AppDatabase);
  late final CashMovementsDao cashMovementsDao =
      CashMovementsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        itemsTable,
        customersTable,
        transactionsTable,
        paymentsTable,
        settingsTable,
        cashDrawerSessionsTable,
        usersTable,
        refundsTable,
        cashMovementsTable
      ];
}

typedef $$ItemsTableTableCreateCompanionBuilder = ItemsTableCompanion Function({
  Value<int> id,
  required String sku,
  required String label,
  required int unitPriceSubunits,
  required String type,
  Value<String?> gtin,
  Value<String> category,
  Value<int> stockQuantity,
  Value<bool> isFavorite,
  Value<String?> imagePath,
  Value<double?> itemTaxRate,
});
typedef $$ItemsTableTableUpdateCompanionBuilder = ItemsTableCompanion Function({
  Value<int> id,
  Value<String> sku,
  Value<String> label,
  Value<int> unitPriceSubunits,
  Value<String> type,
  Value<String?> gtin,
  Value<String> category,
  Value<int> stockQuantity,
  Value<bool> isFavorite,
  Value<String?> imagePath,
  Value<double?> itemTaxRate,
});

class $$ItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ItemsTableTable> {
  $$ItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unitPriceSubunits => $composableBuilder(
      column: $table.unitPriceSubunits,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gtin => $composableBuilder(
      column: $table.gtin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stockQuantity => $composableBuilder(
      column: $table.stockQuantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get itemTaxRate => $composableBuilder(
      column: $table.itemTaxRate, builder: (column) => ColumnFilters(column));
}

class $$ItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTableTable> {
  $$ItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unitPriceSubunits => $composableBuilder(
      column: $table.unitPriceSubunits,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gtin => $composableBuilder(
      column: $table.gtin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stockQuantity => $composableBuilder(
      column: $table.stockQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get itemTaxRate => $composableBuilder(
      column: $table.itemTaxRate, builder: (column) => ColumnOrderings(column));
}

class $$ItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTableTable> {
  $$ItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get unitPriceSubunits => $composableBuilder(
      column: $table.unitPriceSubunits, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get gtin =>
      $composableBuilder(column: $table.gtin, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get stockQuantity => $composableBuilder(
      column: $table.stockQuantity, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<double> get itemTaxRate => $composableBuilder(
      column: $table.itemTaxRate, builder: (column) => column);
}

class $$ItemsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemsTableTable,
    ItemsTableData,
    $$ItemsTableTableFilterComposer,
    $$ItemsTableTableOrderingComposer,
    $$ItemsTableTableAnnotationComposer,
    $$ItemsTableTableCreateCompanionBuilder,
    $$ItemsTableTableUpdateCompanionBuilder,
    (
      ItemsTableData,
      BaseReferences<_$AppDatabase, $ItemsTableTable, ItemsTableData>
    ),
    ItemsTableData,
    PrefetchHooks Function()> {
  $$ItemsTableTableTableManager(_$AppDatabase db, $ItemsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> sku = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<int> unitPriceSubunits = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> gtin = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<int> stockQuantity = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<double?> itemTaxRate = const Value.absent(),
          }) =>
              ItemsTableCompanion(
            id: id,
            sku: sku,
            label: label,
            unitPriceSubunits: unitPriceSubunits,
            type: type,
            gtin: gtin,
            category: category,
            stockQuantity: stockQuantity,
            isFavorite: isFavorite,
            imagePath: imagePath,
            itemTaxRate: itemTaxRate,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String sku,
            required String label,
            required int unitPriceSubunits,
            required String type,
            Value<String?> gtin = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<int> stockQuantity = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<double?> itemTaxRate = const Value.absent(),
          }) =>
              ItemsTableCompanion.insert(
            id: id,
            sku: sku,
            label: label,
            unitPriceSubunits: unitPriceSubunits,
            type: type,
            gtin: gtin,
            category: category,
            stockQuantity: stockQuantity,
            isFavorite: isFavorite,
            imagePath: imagePath,
            itemTaxRate: itemTaxRate,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ItemsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItemsTableTable,
    ItemsTableData,
    $$ItemsTableTableFilterComposer,
    $$ItemsTableTableOrderingComposer,
    $$ItemsTableTableAnnotationComposer,
    $$ItemsTableTableCreateCompanionBuilder,
    $$ItemsTableTableUpdateCompanionBuilder,
    (
      ItemsTableData,
      BaseReferences<_$AppDatabase, $ItemsTableTable, ItemsTableData>
    ),
    ItemsTableData,
    PrefetchHooks Function()>;
typedef $$CustomersTableTableCreateCompanionBuilder = CustomersTableCompanion
    Function({
  Value<int> id,
  required String name,
  Value<String> phone,
  Value<String> email,
  Value<String> notes,
  required DateTime createdAt,
});
typedef $$CustomersTableTableUpdateCompanionBuilder = CustomersTableCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> phone,
  Value<String> email,
  Value<String> notes,
  Value<DateTime> createdAt,
});

final class $$CustomersTableTableReferences extends BaseReferences<
    _$AppDatabase, $CustomersTableTable, CustomersTableData> {
  $$CustomersTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTableTable,
      List<TransactionsTableData>> _transactionsTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.transactionsTable,
          aliasName: $_aliasNameGenerator(
              db.customersTable.id, db.transactionsTable.customerId));

  $$TransactionsTableTableProcessedTableManager get transactionsTableRefs {
    final manager =
        $$TransactionsTableTableTableManager($_db, $_db.transactionsTable)
            .filter((f) => f.customerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_transactionsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CustomersTableTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTableTable> {
  $$CustomersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> transactionsTableRefs(
      Expression<bool> Function($$TransactionsTableTableFilterComposer f) f) {
    final $$TransactionsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactionsTable,
        getReferencedColumn: (t) => t.customerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableTableFilterComposer(
              $db: $db,
              $table: $db.transactionsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CustomersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTableTable> {
  $$CustomersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CustomersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTableTable> {
  $$CustomersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> transactionsTableRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableTableAnnotationComposer a) f) {
    final $$TransactionsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.transactionsTable,
            getReferencedColumn: (t) => t.customerId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.transactionsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$CustomersTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomersTableTable,
    CustomersTableData,
    $$CustomersTableTableFilterComposer,
    $$CustomersTableTableOrderingComposer,
    $$CustomersTableTableAnnotationComposer,
    $$CustomersTableTableCreateCompanionBuilder,
    $$CustomersTableTableUpdateCompanionBuilder,
    (CustomersTableData, $$CustomersTableTableReferences),
    CustomersTableData,
    PrefetchHooks Function({bool transactionsTableRefs})> {
  $$CustomersTableTableTableManager(
      _$AppDatabase db, $CustomersTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              CustomersTableCompanion(
            id: id,
            name: name,
            phone: phone,
            email: email,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> phone = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> notes = const Value.absent(),
            required DateTime createdAt,
          }) =>
              CustomersTableCompanion.insert(
            id: id,
            name: name,
            phone: phone,
            email: email,
            notes: notes,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CustomersTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({transactionsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionsTableRefs) db.transactionsTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsTableRefs)
                    await $_getPrefetchedData<CustomersTableData,
                            $CustomersTableTable, TransactionsTableData>(
                        currentTable: table,
                        referencedTable: $$CustomersTableTableReferences
                            ._transactionsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CustomersTableTableReferences(db, table, p0)
                                .transactionsTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.customerId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CustomersTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CustomersTableTable,
    CustomersTableData,
    $$CustomersTableTableFilterComposer,
    $$CustomersTableTableOrderingComposer,
    $$CustomersTableTableAnnotationComposer,
    $$CustomersTableTableCreateCompanionBuilder,
    $$CustomersTableTableUpdateCompanionBuilder,
    (CustomersTableData, $$CustomersTableTableReferences),
    CustomersTableData,
    PrefetchHooks Function({bool transactionsTableRefs})>;
typedef $$TransactionsTableTableCreateCompanionBuilder
    = TransactionsTableCompanion Function({
  Value<int> id,
  Value<String?> invoiceNumber,
  required String invoiceJson,
  required String status,
  required DateTime createdAt,
  Value<int?> customerId,
});
typedef $$TransactionsTableTableUpdateCompanionBuilder
    = TransactionsTableCompanion Function({
  Value<int> id,
  Value<String?> invoiceNumber,
  Value<String> invoiceJson,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<int?> customerId,
});

final class $$TransactionsTableTableReferences extends BaseReferences<
    _$AppDatabase, $TransactionsTableTable, TransactionsTableData> {
  $$TransactionsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTableTable _customerIdTable(_$AppDatabase db) =>
      db.customersTable.createAlias($_aliasNameGenerator(
          db.transactionsTable.customerId, db.customersTable.id));

  $$CustomersTableTableProcessedTableManager? get customerId {
    final $_column = $_itemColumn<int>('customer_id');
    if ($_column == null) return null;
    final manager = $$CustomersTableTableTableManager($_db, $_db.customersTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$PaymentsTableTable, List<PaymentsTableData>>
      _paymentsTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.paymentsTable,
              aliasName: $_aliasNameGenerator(
                  db.transactionsTable.id, db.paymentsTable.transactionId));

  $$PaymentsTableTableProcessedTableManager get paymentsTableRefs {
    final manager = $$PaymentsTableTableTableManager($_db, $_db.paymentsTable)
        .filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RefundsTableTable, List<RefundsTableData>>
      _refundsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.refundsTable,
          aliasName: $_aliasNameGenerator(
              db.transactionsTable.id, db.refundsTable.originalTransactionId));

  $$RefundsTableTableProcessedTableManager get refundsTableRefs {
    final manager = $$RefundsTableTableTableManager($_db, $_db.refundsTable)
        .filter((f) =>
            f.originalTransactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_refundsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TransactionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceJson => $composableBuilder(
      column: $table.invoiceJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$CustomersTableTableFilterComposer get customerId {
    final $$CustomersTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customersTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableTableFilterComposer(
              $db: $db,
              $table: $db.customersTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> paymentsTableRefs(
      Expression<bool> Function($$PaymentsTableTableFilterComposer f) f) {
    final $$PaymentsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.paymentsTable,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableTableFilterComposer(
              $db: $db,
              $table: $db.paymentsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> refundsTableRefs(
      Expression<bool> Function($$RefundsTableTableFilterComposer f) f) {
    final $$RefundsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.refundsTable,
        getReferencedColumn: (t) => t.originalTransactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RefundsTableTableFilterComposer(
              $db: $db,
              $table: $db.refundsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TransactionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceJson => $composableBuilder(
      column: $table.invoiceJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$CustomersTableTableOrderingComposer get customerId {
    final $$CustomersTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customersTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableTableOrderingComposer(
              $db: $db,
              $table: $db.customersTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => column);

  GeneratedColumn<String> get invoiceJson => $composableBuilder(
      column: $table.invoiceJson, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CustomersTableTableAnnotationComposer get customerId {
    final $$CustomersTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.customerId,
        referencedTable: $db.customersTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomersTableTableAnnotationComposer(
              $db: $db,
              $table: $db.customersTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> paymentsTableRefs<T extends Object>(
      Expression<T> Function($$PaymentsTableTableAnnotationComposer a) f) {
    final $$PaymentsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.paymentsTable,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.paymentsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> refundsTableRefs<T extends Object>(
      Expression<T> Function($$RefundsTableTableAnnotationComposer a) f) {
    final $$RefundsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.refundsTable,
        getReferencedColumn: (t) => t.originalTransactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RefundsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.refundsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TransactionsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTableTable,
    TransactionsTableData,
    $$TransactionsTableTableFilterComposer,
    $$TransactionsTableTableOrderingComposer,
    $$TransactionsTableTableAnnotationComposer,
    $$TransactionsTableTableCreateCompanionBuilder,
    $$TransactionsTableTableUpdateCompanionBuilder,
    (TransactionsTableData, $$TransactionsTableTableReferences),
    TransactionsTableData,
    PrefetchHooks Function(
        {bool customerId, bool paymentsTableRefs, bool refundsTableRefs})> {
  $$TransactionsTableTableTableManager(
      _$AppDatabase db, $TransactionsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> invoiceNumber = const Value.absent(),
            Value<String> invoiceJson = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int?> customerId = const Value.absent(),
          }) =>
              TransactionsTableCompanion(
            id: id,
            invoiceNumber: invoiceNumber,
            invoiceJson: invoiceJson,
            status: status,
            createdAt: createdAt,
            customerId: customerId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> invoiceNumber = const Value.absent(),
            required String invoiceJson,
            required String status,
            required DateTime createdAt,
            Value<int?> customerId = const Value.absent(),
          }) =>
              TransactionsTableCompanion.insert(
            id: id,
            invoiceNumber: invoiceNumber,
            invoiceJson: invoiceJson,
            status: status,
            createdAt: createdAt,
            customerId: customerId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {customerId = false,
              paymentsTableRefs = false,
              refundsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (paymentsTableRefs) db.paymentsTable,
                if (refundsTableRefs) db.refundsTable
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (customerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.customerId,
                    referencedTable:
                        $$TransactionsTableTableReferences._customerIdTable(db),
                    referencedColumn: $$TransactionsTableTableReferences
                        ._customerIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (paymentsTableRefs)
                    await $_getPrefetchedData<TransactionsTableData,
                            $TransactionsTableTable, PaymentsTableData>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableTableReferences
                            ._paymentsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableTableReferences(db, table, p0)
                                .paymentsTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.transactionId == item.id),
                        typedResults: items),
                  if (refundsTableRefs)
                    await $_getPrefetchedData<TransactionsTableData,
                            $TransactionsTableTable, RefundsTableData>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableTableReferences
                            ._refundsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableTableReferences(db, table, p0)
                                .refundsTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems.where(
                                (e) => e.originalTransactionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TransactionsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTableTable,
    TransactionsTableData,
    $$TransactionsTableTableFilterComposer,
    $$TransactionsTableTableOrderingComposer,
    $$TransactionsTableTableAnnotationComposer,
    $$TransactionsTableTableCreateCompanionBuilder,
    $$TransactionsTableTableUpdateCompanionBuilder,
    (TransactionsTableData, $$TransactionsTableTableReferences),
    TransactionsTableData,
    PrefetchHooks Function(
        {bool customerId, bool paymentsTableRefs, bool refundsTableRefs})>;
typedef $$PaymentsTableTableCreateCompanionBuilder = PaymentsTableCompanion
    Function({
  Value<int> id,
  required int transactionId,
  required String method,
  required int amountSubunits,
});
typedef $$PaymentsTableTableUpdateCompanionBuilder = PaymentsTableCompanion
    Function({
  Value<int> id,
  Value<int> transactionId,
  Value<String> method,
  Value<int> amountSubunits,
});

final class $$PaymentsTableTableReferences extends BaseReferences<_$AppDatabase,
    $PaymentsTableTable, PaymentsTableData> {
  $$PaymentsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTableTable _transactionIdTable(_$AppDatabase db) =>
      db.transactionsTable.createAlias($_aliasNameGenerator(
          db.paymentsTable.transactionId, db.transactionsTable.id));

  $$TransactionsTableTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<int>('transaction_id')!;

    final manager =
        $$TransactionsTableTableTableManager($_db, $_db.transactionsTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PaymentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountSubunits => $composableBuilder(
      column: $table.amountSubunits,
      builder: (column) => ColumnFilters(column));

  $$TransactionsTableTableFilterComposer get transactionId {
    final $$TransactionsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactionsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableTableFilterComposer(
              $db: $db,
              $table: $db.transactionsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountSubunits => $composableBuilder(
      column: $table.amountSubunits,
      builder: (column) => ColumnOrderings(column));

  $$TransactionsTableTableOrderingComposer get transactionId {
    final $$TransactionsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactionsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableTableOrderingComposer(
              $db: $db,
              $table: $db.transactionsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<int> get amountSubunits => $composableBuilder(
      column: $table.amountSubunits, builder: (column) => column);

  $$TransactionsTableTableAnnotationComposer get transactionId {
    final $$TransactionsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.transactionId,
            referencedTable: $db.transactionsTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.transactionsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$PaymentsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaymentsTableTable,
    PaymentsTableData,
    $$PaymentsTableTableFilterComposer,
    $$PaymentsTableTableOrderingComposer,
    $$PaymentsTableTableAnnotationComposer,
    $$PaymentsTableTableCreateCompanionBuilder,
    $$PaymentsTableTableUpdateCompanionBuilder,
    (PaymentsTableData, $$PaymentsTableTableReferences),
    PaymentsTableData,
    PrefetchHooks Function({bool transactionId})> {
  $$PaymentsTableTableTableManager(_$AppDatabase db, $PaymentsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> transactionId = const Value.absent(),
            Value<String> method = const Value.absent(),
            Value<int> amountSubunits = const Value.absent(),
          }) =>
              PaymentsTableCompanion(
            id: id,
            transactionId: transactionId,
            method: method,
            amountSubunits: amountSubunits,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int transactionId,
            required String method,
            required int amountSubunits,
          }) =>
              PaymentsTableCompanion.insert(
            id: id,
            transactionId: transactionId,
            method: method,
            amountSubunits: amountSubunits,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PaymentsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({transactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (transactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.transactionId,
                    referencedTable:
                        $$PaymentsTableTableReferences._transactionIdTable(db),
                    referencedColumn: $$PaymentsTableTableReferences
                        ._transactionIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PaymentsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PaymentsTableTable,
    PaymentsTableData,
    $$PaymentsTableTableFilterComposer,
    $$PaymentsTableTableOrderingComposer,
    $$PaymentsTableTableAnnotationComposer,
    $$PaymentsTableTableCreateCompanionBuilder,
    $$PaymentsTableTableUpdateCompanionBuilder,
    (PaymentsTableData, $$PaymentsTableTableReferences),
    PaymentsTableData,
    PrefetchHooks Function({bool transactionId})>;
typedef $$SettingsTableTableCreateCompanionBuilder = SettingsTableCompanion
    Function({
  Value<int> id,
  Value<String> businessName,
  Value<double> taxRate,
  Value<String> currencySymbol,
  Value<String> receiptFooter,
  Value<String?> lastZReportAt,
  Value<String> themeMode,
  Value<String?> logoPath,
  Value<bool> autoBackupEnabled,
  Value<String?> lastBackupAt,
  Value<String> printerType,
  Value<String> printerAddress,
  Value<bool> taxInclusive,
});
typedef $$SettingsTableTableUpdateCompanionBuilder = SettingsTableCompanion
    Function({
  Value<int> id,
  Value<String> businessName,
  Value<double> taxRate,
  Value<String> currencySymbol,
  Value<String> receiptFooter,
  Value<String?> lastZReportAt,
  Value<String> themeMode,
  Value<String?> logoPath,
  Value<bool> autoBackupEnabled,
  Value<String?> lastBackupAt,
  Value<String> printerType,
  Value<String> printerAddress,
  Value<bool> taxInclusive,
});

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get businessName => $composableBuilder(
      column: $table.businessName, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get taxRate => $composableBuilder(
      column: $table.taxRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receiptFooter => $composableBuilder(
      column: $table.receiptFooter, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastZReportAt => $composableBuilder(
      column: $table.lastZReportAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get logoPath => $composableBuilder(
      column: $table.logoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get autoBackupEnabled => $composableBuilder(
      column: $table.autoBackupEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastBackupAt => $composableBuilder(
      column: $table.lastBackupAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get printerType => $composableBuilder(
      column: $table.printerType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get printerAddress => $composableBuilder(
      column: $table.printerAddress,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get taxInclusive => $composableBuilder(
      column: $table.taxInclusive, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get businessName => $composableBuilder(
      column: $table.businessName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get taxRate => $composableBuilder(
      column: $table.taxRate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receiptFooter => $composableBuilder(
      column: $table.receiptFooter,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastZReportAt => $composableBuilder(
      column: $table.lastZReportAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get logoPath => $composableBuilder(
      column: $table.logoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoBackupEnabled => $composableBuilder(
      column: $table.autoBackupEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastBackupAt => $composableBuilder(
      column: $table.lastBackupAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get printerType => $composableBuilder(
      column: $table.printerType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get printerAddress => $composableBuilder(
      column: $table.printerAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get taxInclusive => $composableBuilder(
      column: $table.taxInclusive,
      builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessName => $composableBuilder(
      column: $table.businessName, builder: (column) => column);

  GeneratedColumn<double> get taxRate =>
      $composableBuilder(column: $table.taxRate, builder: (column) => column);

  GeneratedColumn<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol, builder: (column) => column);

  GeneratedColumn<String> get receiptFooter => $composableBuilder(
      column: $table.receiptFooter, builder: (column) => column);

  GeneratedColumn<String> get lastZReportAt => $composableBuilder(
      column: $table.lastZReportAt, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<String> get logoPath =>
      $composableBuilder(column: $table.logoPath, builder: (column) => column);

  GeneratedColumn<bool> get autoBackupEnabled => $composableBuilder(
      column: $table.autoBackupEnabled, builder: (column) => column);

  GeneratedColumn<String> get lastBackupAt => $composableBuilder(
      column: $table.lastBackupAt, builder: (column) => column);

  GeneratedColumn<String> get printerType => $composableBuilder(
      column: $table.printerType, builder: (column) => column);

  GeneratedColumn<String> get printerAddress => $composableBuilder(
      column: $table.printerAddress, builder: (column) => column);

  GeneratedColumn<bool> get taxInclusive => $composableBuilder(
      column: $table.taxInclusive, builder: (column) => column);
}

class $$SettingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTableTable,
    SettingsTableData,
    $$SettingsTableTableFilterComposer,
    $$SettingsTableTableOrderingComposer,
    $$SettingsTableTableAnnotationComposer,
    $$SettingsTableTableCreateCompanionBuilder,
    $$SettingsTableTableUpdateCompanionBuilder,
    (
      SettingsTableData,
      BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsTableData>
    ),
    SettingsTableData,
    PrefetchHooks Function()> {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> businessName = const Value.absent(),
            Value<double> taxRate = const Value.absent(),
            Value<String> currencySymbol = const Value.absent(),
            Value<String> receiptFooter = const Value.absent(),
            Value<String?> lastZReportAt = const Value.absent(),
            Value<String> themeMode = const Value.absent(),
            Value<String?> logoPath = const Value.absent(),
            Value<bool> autoBackupEnabled = const Value.absent(),
            Value<String?> lastBackupAt = const Value.absent(),
            Value<String> printerType = const Value.absent(),
            Value<String> printerAddress = const Value.absent(),
            Value<bool> taxInclusive = const Value.absent(),
          }) =>
              SettingsTableCompanion(
            id: id,
            businessName: businessName,
            taxRate: taxRate,
            currencySymbol: currencySymbol,
            receiptFooter: receiptFooter,
            lastZReportAt: lastZReportAt,
            themeMode: themeMode,
            logoPath: logoPath,
            autoBackupEnabled: autoBackupEnabled,
            lastBackupAt: lastBackupAt,
            printerType: printerType,
            printerAddress: printerAddress,
            taxInclusive: taxInclusive,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> businessName = const Value.absent(),
            Value<double> taxRate = const Value.absent(),
            Value<String> currencySymbol = const Value.absent(),
            Value<String> receiptFooter = const Value.absent(),
            Value<String?> lastZReportAt = const Value.absent(),
            Value<String> themeMode = const Value.absent(),
            Value<String?> logoPath = const Value.absent(),
            Value<bool> autoBackupEnabled = const Value.absent(),
            Value<String?> lastBackupAt = const Value.absent(),
            Value<String> printerType = const Value.absent(),
            Value<String> printerAddress = const Value.absent(),
            Value<bool> taxInclusive = const Value.absent(),
          }) =>
              SettingsTableCompanion.insert(
            id: id,
            businessName: businessName,
            taxRate: taxRate,
            currencySymbol: currencySymbol,
            receiptFooter: receiptFooter,
            lastZReportAt: lastZReportAt,
            themeMode: themeMode,
            logoPath: logoPath,
            autoBackupEnabled: autoBackupEnabled,
            lastBackupAt: lastBackupAt,
            printerType: printerType,
            printerAddress: printerAddress,
            taxInclusive: taxInclusive,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTableTable,
    SettingsTableData,
    $$SettingsTableTableFilterComposer,
    $$SettingsTableTableOrderingComposer,
    $$SettingsTableTableAnnotationComposer,
    $$SettingsTableTableCreateCompanionBuilder,
    $$SettingsTableTableUpdateCompanionBuilder,
    (
      SettingsTableData,
      BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsTableData>
    ),
    SettingsTableData,
    PrefetchHooks Function()>;
typedef $$CashDrawerSessionsTableTableCreateCompanionBuilder
    = CashDrawerSessionsTableCompanion Function({
  Value<int> id,
  required DateTime openedAt,
  Value<DateTime?> closedAt,
  required int openingBalanceSubunits,
  Value<int?> closingBalanceSubunits,
  Value<String?> notes,
});
typedef $$CashDrawerSessionsTableTableUpdateCompanionBuilder
    = CashDrawerSessionsTableCompanion Function({
  Value<int> id,
  Value<DateTime> openedAt,
  Value<DateTime?> closedAt,
  Value<int> openingBalanceSubunits,
  Value<int?> closingBalanceSubunits,
  Value<String?> notes,
});

final class $$CashDrawerSessionsTableTableReferences extends BaseReferences<
    _$AppDatabase, $CashDrawerSessionsTableTable, CashDrawerSessionsTableData> {
  $$CashDrawerSessionsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CashMovementsTableTable,
      List<CashMovementsTableData>> _cashMovementsTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.cashMovementsTable,
          aliasName: $_aliasNameGenerator(
              db.cashDrawerSessionsTable.id, db.cashMovementsTable.sessionId));

  $$CashMovementsTableTableProcessedTableManager get cashMovementsTableRefs {
    final manager =
        $$CashMovementsTableTableTableManager($_db, $_db.cashMovementsTable)
            .filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_cashMovementsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CashDrawerSessionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CashDrawerSessionsTableTable> {
  $$CashDrawerSessionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
      column: $table.openedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
      column: $table.closedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get openingBalanceSubunits => $composableBuilder(
      column: $table.openingBalanceSubunits,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get closingBalanceSubunits => $composableBuilder(
      column: $table.closingBalanceSubunits,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  Expression<bool> cashMovementsTableRefs(
      Expression<bool> Function($$CashMovementsTableTableFilterComposer f) f) {
    final $$CashMovementsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.cashMovementsTable,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CashMovementsTableTableFilterComposer(
              $db: $db,
              $table: $db.cashMovementsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CashDrawerSessionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CashDrawerSessionsTableTable> {
  $$CashDrawerSessionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
      column: $table.openedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
      column: $table.closedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get openingBalanceSubunits => $composableBuilder(
      column: $table.openingBalanceSubunits,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get closingBalanceSubunits => $composableBuilder(
      column: $table.closingBalanceSubunits,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$CashDrawerSessionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashDrawerSessionsTableTable> {
  $$CashDrawerSessionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<int> get openingBalanceSubunits => $composableBuilder(
      column: $table.openingBalanceSubunits, builder: (column) => column);

  GeneratedColumn<int> get closingBalanceSubunits => $composableBuilder(
      column: $table.closingBalanceSubunits, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> cashMovementsTableRefs<T extends Object>(
      Expression<T> Function($$CashMovementsTableTableAnnotationComposer a) f) {
    final $$CashMovementsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.cashMovementsTable,
            getReferencedColumn: (t) => t.sessionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$CashMovementsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.cashMovementsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$CashDrawerSessionsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CashDrawerSessionsTableTable,
    CashDrawerSessionsTableData,
    $$CashDrawerSessionsTableTableFilterComposer,
    $$CashDrawerSessionsTableTableOrderingComposer,
    $$CashDrawerSessionsTableTableAnnotationComposer,
    $$CashDrawerSessionsTableTableCreateCompanionBuilder,
    $$CashDrawerSessionsTableTableUpdateCompanionBuilder,
    (CashDrawerSessionsTableData, $$CashDrawerSessionsTableTableReferences),
    CashDrawerSessionsTableData,
    PrefetchHooks Function({bool cashMovementsTableRefs})> {
  $$CashDrawerSessionsTableTableTableManager(
      _$AppDatabase db, $CashDrawerSessionsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashDrawerSessionsTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CashDrawerSessionsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashDrawerSessionsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> openedAt = const Value.absent(),
            Value<DateTime?> closedAt = const Value.absent(),
            Value<int> openingBalanceSubunits = const Value.absent(),
            Value<int?> closingBalanceSubunits = const Value.absent(),
            Value<String?> notes = const Value.absent(),
          }) =>
              CashDrawerSessionsTableCompanion(
            id: id,
            openedAt: openedAt,
            closedAt: closedAt,
            openingBalanceSubunits: openingBalanceSubunits,
            closingBalanceSubunits: closingBalanceSubunits,
            notes: notes,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime openedAt,
            Value<DateTime?> closedAt = const Value.absent(),
            required int openingBalanceSubunits,
            Value<int?> closingBalanceSubunits = const Value.absent(),
            Value<String?> notes = const Value.absent(),
          }) =>
              CashDrawerSessionsTableCompanion.insert(
            id: id,
            openedAt: openedAt,
            closedAt: closedAt,
            openingBalanceSubunits: openingBalanceSubunits,
            closingBalanceSubunits: closingBalanceSubunits,
            notes: notes,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CashDrawerSessionsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({cashMovementsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (cashMovementsTableRefs) db.cashMovementsTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cashMovementsTableRefs)
                    await $_getPrefetchedData<
                            CashDrawerSessionsTableData,
                            $CashDrawerSessionsTableTable,
                            CashMovementsTableData>(
                        currentTable: table,
                        referencedTable:
                            $$CashDrawerSessionsTableTableReferences
                                ._cashMovementsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CashDrawerSessionsTableTableReferences(
                                    db, table, p0)
                                .cashMovementsTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sessionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CashDrawerSessionsTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $CashDrawerSessionsTableTable,
        CashDrawerSessionsTableData,
        $$CashDrawerSessionsTableTableFilterComposer,
        $$CashDrawerSessionsTableTableOrderingComposer,
        $$CashDrawerSessionsTableTableAnnotationComposer,
        $$CashDrawerSessionsTableTableCreateCompanionBuilder,
        $$CashDrawerSessionsTableTableUpdateCompanionBuilder,
        (CashDrawerSessionsTableData, $$CashDrawerSessionsTableTableReferences),
        CashDrawerSessionsTableData,
        PrefetchHooks Function({bool cashMovementsTableRefs})>;
typedef $$UsersTableTableCreateCompanionBuilder = UsersTableCompanion Function({
  Value<int> id,
  required String username,
  required String displayName,
  required String pin,
  Value<String> salt,
  Value<String> role,
  Value<bool> isActive,
  Value<int> failedAttempts,
  Value<DateTime?> lockedUntil,
  required DateTime createdAt,
});
typedef $$UsersTableTableUpdateCompanionBuilder = UsersTableCompanion Function({
  Value<int> id,
  Value<String> username,
  Value<String> displayName,
  Value<String> pin,
  Value<String> salt,
  Value<String> role,
  Value<bool> isActive,
  Value<int> failedAttempts,
  Value<DateTime?> lockedUntil,
  Value<DateTime> createdAt,
});

class $$UsersTableTableFilterComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pin => $composableBuilder(
      column: $table.pin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get salt => $composableBuilder(
      column: $table.salt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get failedAttempts => $composableBuilder(
      column: $table.failedAttempts,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lockedUntil => $composableBuilder(
      column: $table.lockedUntil, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$UsersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pin => $composableBuilder(
      column: $table.pin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get salt => $composableBuilder(
      column: $table.salt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get failedAttempts => $composableBuilder(
      column: $table.failedAttempts,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lockedUntil => $composableBuilder(
      column: $table.lockedUntil, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get pin =>
      $composableBuilder(column: $table.pin, builder: (column) => column);

  GeneratedColumn<String> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get failedAttempts => $composableBuilder(
      column: $table.failedAttempts, builder: (column) => column);

  GeneratedColumn<DateTime> get lockedUntil => $composableBuilder(
      column: $table.lockedUntil, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UsersTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTableTable,
    UsersTableData,
    $$UsersTableTableFilterComposer,
    $$UsersTableTableOrderingComposer,
    $$UsersTableTableAnnotationComposer,
    $$UsersTableTableCreateCompanionBuilder,
    $$UsersTableTableUpdateCompanionBuilder,
    (
      UsersTableData,
      BaseReferences<_$AppDatabase, $UsersTableTable, UsersTableData>
    ),
    UsersTableData,
    PrefetchHooks Function()> {
  $$UsersTableTableTableManager(_$AppDatabase db, $UsersTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String> pin = const Value.absent(),
            Value<String> salt = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> failedAttempts = const Value.absent(),
            Value<DateTime?> lockedUntil = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              UsersTableCompanion(
            id: id,
            username: username,
            displayName: displayName,
            pin: pin,
            salt: salt,
            role: role,
            isActive: isActive,
            failedAttempts: failedAttempts,
            lockedUntil: lockedUntil,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String username,
            required String displayName,
            required String pin,
            Value<String> salt = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> failedAttempts = const Value.absent(),
            Value<DateTime?> lockedUntil = const Value.absent(),
            required DateTime createdAt,
          }) =>
              UsersTableCompanion.insert(
            id: id,
            username: username,
            displayName: displayName,
            pin: pin,
            salt: salt,
            role: role,
            isActive: isActive,
            failedAttempts: failedAttempts,
            lockedUntil: lockedUntil,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTableTable,
    UsersTableData,
    $$UsersTableTableFilterComposer,
    $$UsersTableTableOrderingComposer,
    $$UsersTableTableAnnotationComposer,
    $$UsersTableTableCreateCompanionBuilder,
    $$UsersTableTableUpdateCompanionBuilder,
    (
      UsersTableData,
      BaseReferences<_$AppDatabase, $UsersTableTable, UsersTableData>
    ),
    UsersTableData,
    PrefetchHooks Function()>;
typedef $$RefundsTableTableCreateCompanionBuilder = RefundsTableCompanion
    Function({
  Value<int> id,
  required int originalTransactionId,
  required int lineIndex,
  required int quantity,
  required int amountSubunits,
  Value<String> reason,
  required DateTime createdAt,
});
typedef $$RefundsTableTableUpdateCompanionBuilder = RefundsTableCompanion
    Function({
  Value<int> id,
  Value<int> originalTransactionId,
  Value<int> lineIndex,
  Value<int> quantity,
  Value<int> amountSubunits,
  Value<String> reason,
  Value<DateTime> createdAt,
});

final class $$RefundsTableTableReferences extends BaseReferences<_$AppDatabase,
    $RefundsTableTable, RefundsTableData> {
  $$RefundsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTableTable _originalTransactionIdTable(
          _$AppDatabase db) =>
      db.transactionsTable.createAlias($_aliasNameGenerator(
          db.refundsTable.originalTransactionId, db.transactionsTable.id));

  $$TransactionsTableTableProcessedTableManager get originalTransactionId {
    final $_column = $_itemColumn<int>('original_transaction_id')!;

    final manager =
        $$TransactionsTableTableTableManager($_db, $_db.transactionsTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item =
        $_typedResult.readTableOrNull(_originalTransactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RefundsTableTableFilterComposer
    extends Composer<_$AppDatabase, $RefundsTableTable> {
  $$RefundsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lineIndex => $composableBuilder(
      column: $table.lineIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountSubunits => $composableBuilder(
      column: $table.amountSubunits,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$TransactionsTableTableFilterComposer get originalTransactionId {
    final $$TransactionsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.originalTransactionId,
        referencedTable: $db.transactionsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableTableFilterComposer(
              $db: $db,
              $table: $db.transactionsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RefundsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RefundsTableTable> {
  $$RefundsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lineIndex => $composableBuilder(
      column: $table.lineIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountSubunits => $composableBuilder(
      column: $table.amountSubunits,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$TransactionsTableTableOrderingComposer get originalTransactionId {
    final $$TransactionsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.originalTransactionId,
        referencedTable: $db.transactionsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableTableOrderingComposer(
              $db: $db,
              $table: $db.transactionsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RefundsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RefundsTableTable> {
  $$RefundsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lineIndex =>
      $composableBuilder(column: $table.lineIndex, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get amountSubunits => $composableBuilder(
      column: $table.amountSubunits, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TransactionsTableTableAnnotationComposer get originalTransactionId {
    final $$TransactionsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.originalTransactionId,
            referencedTable: $db.transactionsTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TransactionsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.transactionsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$RefundsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RefundsTableTable,
    RefundsTableData,
    $$RefundsTableTableFilterComposer,
    $$RefundsTableTableOrderingComposer,
    $$RefundsTableTableAnnotationComposer,
    $$RefundsTableTableCreateCompanionBuilder,
    $$RefundsTableTableUpdateCompanionBuilder,
    (RefundsTableData, $$RefundsTableTableReferences),
    RefundsTableData,
    PrefetchHooks Function({bool originalTransactionId})> {
  $$RefundsTableTableTableManager(_$AppDatabase db, $RefundsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RefundsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RefundsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RefundsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> originalTransactionId = const Value.absent(),
            Value<int> lineIndex = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> amountSubunits = const Value.absent(),
            Value<String> reason = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              RefundsTableCompanion(
            id: id,
            originalTransactionId: originalTransactionId,
            lineIndex: lineIndex,
            quantity: quantity,
            amountSubunits: amountSubunits,
            reason: reason,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int originalTransactionId,
            required int lineIndex,
            required int quantity,
            required int amountSubunits,
            Value<String> reason = const Value.absent(),
            required DateTime createdAt,
          }) =>
              RefundsTableCompanion.insert(
            id: id,
            originalTransactionId: originalTransactionId,
            lineIndex: lineIndex,
            quantity: quantity,
            amountSubunits: amountSubunits,
            reason: reason,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RefundsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({originalTransactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (originalTransactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.originalTransactionId,
                    referencedTable: $$RefundsTableTableReferences
                        ._originalTransactionIdTable(db),
                    referencedColumn: $$RefundsTableTableReferences
                        ._originalTransactionIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RefundsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RefundsTableTable,
    RefundsTableData,
    $$RefundsTableTableFilterComposer,
    $$RefundsTableTableOrderingComposer,
    $$RefundsTableTableAnnotationComposer,
    $$RefundsTableTableCreateCompanionBuilder,
    $$RefundsTableTableUpdateCompanionBuilder,
    (RefundsTableData, $$RefundsTableTableReferences),
    RefundsTableData,
    PrefetchHooks Function({bool originalTransactionId})>;
typedef $$CashMovementsTableTableCreateCompanionBuilder
    = CashMovementsTableCompanion Function({
  Value<int> id,
  required int sessionId,
  required String type,
  required int amountSubunits,
  Value<String> note,
  required DateTime createdAt,
});
typedef $$CashMovementsTableTableUpdateCompanionBuilder
    = CashMovementsTableCompanion Function({
  Value<int> id,
  Value<int> sessionId,
  Value<String> type,
  Value<int> amountSubunits,
  Value<String> note,
  Value<DateTime> createdAt,
});

final class $$CashMovementsTableTableReferences extends BaseReferences<
    _$AppDatabase, $CashMovementsTableTable, CashMovementsTableData> {
  $$CashMovementsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CashDrawerSessionsTableTable _sessionIdTable(_$AppDatabase db) =>
      db.cashDrawerSessionsTable.createAlias($_aliasNameGenerator(
          db.cashMovementsTable.sessionId, db.cashDrawerSessionsTable.id));

  $$CashDrawerSessionsTableTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$CashDrawerSessionsTableTableTableManager(
            $_db, $_db.cashDrawerSessionsTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CashMovementsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CashMovementsTableTable> {
  $$CashMovementsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountSubunits => $composableBuilder(
      column: $table.amountSubunits,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$CashDrawerSessionsTableTableFilterComposer get sessionId {
    final $$CashDrawerSessionsTableTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.sessionId,
            referencedTable: $db.cashDrawerSessionsTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$CashDrawerSessionsTableTableFilterComposer(
                  $db: $db,
                  $table: $db.cashDrawerSessionsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$CashMovementsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CashMovementsTableTable> {
  $$CashMovementsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountSubunits => $composableBuilder(
      column: $table.amountSubunits,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$CashDrawerSessionsTableTableOrderingComposer get sessionId {
    final $$CashDrawerSessionsTableTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.sessionId,
            referencedTable: $db.cashDrawerSessionsTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$CashDrawerSessionsTableTableOrderingComposer(
                  $db: $db,
                  $table: $db.cashDrawerSessionsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$CashMovementsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashMovementsTableTable> {
  $$CashMovementsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amountSubunits => $composableBuilder(
      column: $table.amountSubunits, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CashDrawerSessionsTableTableAnnotationComposer get sessionId {
    final $$CashDrawerSessionsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.sessionId,
            referencedTable: $db.cashDrawerSessionsTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$CashDrawerSessionsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.cashDrawerSessionsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$CashMovementsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CashMovementsTableTable,
    CashMovementsTableData,
    $$CashMovementsTableTableFilterComposer,
    $$CashMovementsTableTableOrderingComposer,
    $$CashMovementsTableTableAnnotationComposer,
    $$CashMovementsTableTableCreateCompanionBuilder,
    $$CashMovementsTableTableUpdateCompanionBuilder,
    (CashMovementsTableData, $$CashMovementsTableTableReferences),
    CashMovementsTableData,
    PrefetchHooks Function({bool sessionId})> {
  $$CashMovementsTableTableTableManager(
      _$AppDatabase db, $CashMovementsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashMovementsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashMovementsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashMovementsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> sessionId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> amountSubunits = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              CashMovementsTableCompanion(
            id: id,
            sessionId: sessionId,
            type: type,
            amountSubunits: amountSubunits,
            note: note,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int sessionId,
            required String type,
            required int amountSubunits,
            Value<String> note = const Value.absent(),
            required DateTime createdAt,
          }) =>
              CashMovementsTableCompanion.insert(
            id: id,
            sessionId: sessionId,
            type: type,
            amountSubunits: amountSubunits,
            note: note,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CashMovementsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sessionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sessionId,
                    referencedTable:
                        $$CashMovementsTableTableReferences._sessionIdTable(db),
                    referencedColumn: $$CashMovementsTableTableReferences
                        ._sessionIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CashMovementsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CashMovementsTableTable,
    CashMovementsTableData,
    $$CashMovementsTableTableFilterComposer,
    $$CashMovementsTableTableOrderingComposer,
    $$CashMovementsTableTableAnnotationComposer,
    $$CashMovementsTableTableCreateCompanionBuilder,
    $$CashMovementsTableTableUpdateCompanionBuilder,
    (CashMovementsTableData, $$CashMovementsTableTableReferences),
    CashMovementsTableData,
    PrefetchHooks Function({bool sessionId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ItemsTableTableTableManager get itemsTable =>
      $$ItemsTableTableTableManager(_db, _db.itemsTable);
  $$CustomersTableTableTableManager get customersTable =>
      $$CustomersTableTableTableManager(_db, _db.customersTable);
  $$TransactionsTableTableTableManager get transactionsTable =>
      $$TransactionsTableTableTableManager(_db, _db.transactionsTable);
  $$PaymentsTableTableTableManager get paymentsTable =>
      $$PaymentsTableTableTableManager(_db, _db.paymentsTable);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
  $$CashDrawerSessionsTableTableTableManager get cashDrawerSessionsTable =>
      $$CashDrawerSessionsTableTableTableManager(
          _db, _db.cashDrawerSessionsTable);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db, _db.usersTable);
  $$RefundsTableTableTableManager get refundsTable =>
      $$RefundsTableTableTableManager(_db, _db.refundsTable);
  $$CashMovementsTableTableTableManager get cashMovementsTable =>
      $$CashMovementsTableTableTableManager(_db, _db.cashMovementsTable);
}
