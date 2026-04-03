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
  $TransactionsTableTable get transactionsTable =>
      attachedDatabase.transactionsTable;
  $PaymentsTableTable get paymentsTable => attachedDatabase.paymentsTable;
  TransactionsDaoManager get managers => TransactionsDaoManager(this);
}

class TransactionsDaoManager {
  final _$TransactionsDaoMixin _db;
  TransactionsDaoManager(this._db);
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
  @override
  List<GeneratedColumn> get $columns =>
      [id, sku, label, unitPriceSubunits, type, gtin];
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
  const ItemsTableData(
      {required this.id,
      required this.sku,
      required this.label,
      required this.unitPriceSubunits,
      required this.type,
      this.gtin});
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
    };
  }

  ItemsTableData copyWith(
          {int? id,
          String? sku,
          String? label,
          int? unitPriceSubunits,
          String? type,
          Value<String?> gtin = const Value.absent()}) =>
      ItemsTableData(
        id: id ?? this.id,
        sku: sku ?? this.sku,
        label: label ?? this.label,
        unitPriceSubunits: unitPriceSubunits ?? this.unitPriceSubunits,
        type: type ?? this.type,
        gtin: gtin.present ? gtin.value : this.gtin,
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
          ..write('gtin: $gtin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sku, label, unitPriceSubunits, type, gtin);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemsTableData &&
          other.id == this.id &&
          other.sku == this.sku &&
          other.label == this.label &&
          other.unitPriceSubunits == this.unitPriceSubunits &&
          other.type == this.type &&
          other.gtin == this.gtin);
}

class ItemsTableCompanion extends UpdateCompanion<ItemsTableData> {
  final Value<int> id;
  final Value<String> sku;
  final Value<String> label;
  final Value<int> unitPriceSubunits;
  final Value<String> type;
  final Value<String?> gtin;
  const ItemsTableCompanion({
    this.id = const Value.absent(),
    this.sku = const Value.absent(),
    this.label = const Value.absent(),
    this.unitPriceSubunits = const Value.absent(),
    this.type = const Value.absent(),
    this.gtin = const Value.absent(),
  });
  ItemsTableCompanion.insert({
    this.id = const Value.absent(),
    required String sku,
    required String label,
    required int unitPriceSubunits,
    required String type,
    this.gtin = const Value.absent(),
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
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sku != null) 'sku': sku,
      if (label != null) 'label': label,
      if (unitPriceSubunits != null) 'unit_price_subunits': unitPriceSubunits,
      if (type != null) 'type': type,
      if (gtin != null) 'gtin': gtin,
    });
  }

  ItemsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? sku,
      Value<String>? label,
      Value<int>? unitPriceSubunits,
      Value<String>? type,
      Value<String?>? gtin}) {
    return ItemsTableCompanion(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      label: label ?? this.label,
      unitPriceSubunits: unitPriceSubunits ?? this.unitPriceSubunits,
      type: type ?? this.type,
      gtin: gtin ?? this.gtin,
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
          ..write('gtin: $gtin')
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
  @override
  List<GeneratedColumn> get $columns =>
      [id, invoiceNumber, invoiceJson, status, createdAt];
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

  /// 'completed' | 'voided'
  final String status;
  final DateTime createdAt;
  const TransactionsTableData(
      {required this.id,
      this.invoiceNumber,
      required this.invoiceJson,
      required this.status,
      required this.createdAt});
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
    };
  }

  TransactionsTableData copyWith(
          {int? id,
          Value<String?> invoiceNumber = const Value.absent(),
          String? invoiceJson,
          String? status,
          DateTime? createdAt}) =>
      TransactionsTableData(
        id: id ?? this.id,
        invoiceNumber:
            invoiceNumber.present ? invoiceNumber.value : this.invoiceNumber,
        invoiceJson: invoiceJson ?? this.invoiceJson,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
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
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableData(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('invoiceJson: $invoiceJson, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, invoiceNumber, invoiceJson, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionsTableData &&
          other.id == this.id &&
          other.invoiceNumber == this.invoiceNumber &&
          other.invoiceJson == this.invoiceJson &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class TransactionsTableCompanion
    extends UpdateCompanion<TransactionsTableData> {
  final Value<int> id;
  final Value<String?> invoiceNumber;
  final Value<String> invoiceJson;
  final Value<String> status;
  final Value<DateTime> createdAt;
  const TransactionsTableCompanion({
    this.id = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.invoiceJson = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TransactionsTableCompanion.insert({
    this.id = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    required String invoiceJson,
    required String status,
    required DateTime createdAt,
  })  : invoiceJson = Value(invoiceJson),
        status = Value(status),
        createdAt = Value(createdAt);
  static Insertable<TransactionsTableData> custom({
    Expression<int>? id,
    Expression<String>? invoiceNumber,
    Expression<String>? invoiceJson,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (invoiceJson != null) 'invoice_json': invoiceJson,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TransactionsTableCompanion copyWith(
      {Value<int>? id,
      Value<String?>? invoiceNumber,
      Value<String>? invoiceJson,
      Value<String>? status,
      Value<DateTime>? createdAt}) {
    return TransactionsTableCompanion(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceJson: invoiceJson ?? this.invoiceJson,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableCompanion(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('invoiceJson: $invoiceJson, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
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
  @override
  List<GeneratedColumn> get $columns =>
      [id, businessName, taxRate, currencySymbol, receiptFooter, lastZReportAt];
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
  const SettingsTableData(
      {required this.id,
      required this.businessName,
      required this.taxRate,
      required this.currencySymbol,
      required this.receiptFooter,
      this.lastZReportAt});
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
    };
  }

  SettingsTableData copyWith(
          {int? id,
          String? businessName,
          double? taxRate,
          String? currencySymbol,
          String? receiptFooter,
          Value<String?> lastZReportAt = const Value.absent()}) =>
      SettingsTableData(
        id: id ?? this.id,
        businessName: businessName ?? this.businessName,
        taxRate: taxRate ?? this.taxRate,
        currencySymbol: currencySymbol ?? this.currencySymbol,
        receiptFooter: receiptFooter ?? this.receiptFooter,
        lastZReportAt:
            lastZReportAt.present ? lastZReportAt.value : this.lastZReportAt,
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
          ..write('lastZReportAt: $lastZReportAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, businessName, taxRate, currencySymbol, receiptFooter, lastZReportAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsTableData &&
          other.id == this.id &&
          other.businessName == this.businessName &&
          other.taxRate == this.taxRate &&
          other.currencySymbol == this.currencySymbol &&
          other.receiptFooter == this.receiptFooter &&
          other.lastZReportAt == this.lastZReportAt);
}

class SettingsTableCompanion extends UpdateCompanion<SettingsTableData> {
  final Value<int> id;
  final Value<String> businessName;
  final Value<double> taxRate;
  final Value<String> currencySymbol;
  final Value<String> receiptFooter;
  final Value<String?> lastZReportAt;
  const SettingsTableCompanion({
    this.id = const Value.absent(),
    this.businessName = const Value.absent(),
    this.taxRate = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.receiptFooter = const Value.absent(),
    this.lastZReportAt = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.businessName = const Value.absent(),
    this.taxRate = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.receiptFooter = const Value.absent(),
    this.lastZReportAt = const Value.absent(),
  });
  static Insertable<SettingsTableData> custom({
    Expression<int>? id,
    Expression<String>? businessName,
    Expression<double>? taxRate,
    Expression<String>? currencySymbol,
    Expression<String>? receiptFooter,
    Expression<String>? lastZReportAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessName != null) 'business_name': businessName,
      if (taxRate != null) 'tax_rate': taxRate,
      if (currencySymbol != null) 'currency_symbol': currencySymbol,
      if (receiptFooter != null) 'receipt_footer': receiptFooter,
      if (lastZReportAt != null) 'last_z_report_at': lastZReportAt,
    });
  }

  SettingsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? businessName,
      Value<double>? taxRate,
      Value<String>? currencySymbol,
      Value<String>? receiptFooter,
      Value<String?>? lastZReportAt}) {
    return SettingsTableCompanion(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      taxRate: taxRate ?? this.taxRate,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      lastZReportAt: lastZReportAt ?? this.lastZReportAt,
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
          ..write('lastZReportAt: $lastZReportAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ItemsTableTable itemsTable = $ItemsTableTable(this);
  late final $TransactionsTableTable transactionsTable =
      $TransactionsTableTable(this);
  late final $PaymentsTableTable paymentsTable = $PaymentsTableTable(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  late final ItemsDao itemsDao = ItemsDao(this as AppDatabase);
  late final TransactionsDao transactionsDao =
      TransactionsDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [itemsTable, transactionsTable, paymentsTable, settingsTable];
}

typedef $$ItemsTableTableCreateCompanionBuilder = ItemsTableCompanion Function({
  Value<int> id,
  required String sku,
  required String label,
  required int unitPriceSubunits,
  required String type,
  Value<String?> gtin,
});
typedef $$ItemsTableTableUpdateCompanionBuilder = ItemsTableCompanion Function({
  Value<int> id,
  Value<String> sku,
  Value<String> label,
  Value<int> unitPriceSubunits,
  Value<String> type,
  Value<String?> gtin,
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
          }) =>
              ItemsTableCompanion(
            id: id,
            sku: sku,
            label: label,
            unitPriceSubunits: unitPriceSubunits,
            type: type,
            gtin: gtin,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String sku,
            required String label,
            required int unitPriceSubunits,
            required String type,
            Value<String?> gtin = const Value.absent(),
          }) =>
              ItemsTableCompanion.insert(
            id: id,
            sku: sku,
            label: label,
            unitPriceSubunits: unitPriceSubunits,
            type: type,
            gtin: gtin,
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
typedef $$TransactionsTableTableCreateCompanionBuilder
    = TransactionsTableCompanion Function({
  Value<int> id,
  Value<String?> invoiceNumber,
  required String invoiceJson,
  required String status,
  required DateTime createdAt,
});
typedef $$TransactionsTableTableUpdateCompanionBuilder
    = TransactionsTableCompanion Function({
  Value<int> id,
  Value<String?> invoiceNumber,
  Value<String> invoiceJson,
  Value<String> status,
  Value<DateTime> createdAt,
});

final class $$TransactionsTableTableReferences extends BaseReferences<
    _$AppDatabase, $TransactionsTableTable, TransactionsTableData> {
  $$TransactionsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

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
    PrefetchHooks Function({bool paymentsTableRefs})> {
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
          }) =>
              TransactionsTableCompanion(
            id: id,
            invoiceNumber: invoiceNumber,
            invoiceJson: invoiceJson,
            status: status,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> invoiceNumber = const Value.absent(),
            required String invoiceJson,
            required String status,
            required DateTime createdAt,
          }) =>
              TransactionsTableCompanion.insert(
            id: id,
            invoiceNumber: invoiceNumber,
            invoiceJson: invoiceJson,
            status: status,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({paymentsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (paymentsTableRefs) db.paymentsTable
              ],
              addJoins: null,
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
    PrefetchHooks Function({bool paymentsTableRefs})>;
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
});
typedef $$SettingsTableTableUpdateCompanionBuilder = SettingsTableCompanion
    Function({
  Value<int> id,
  Value<String> businessName,
  Value<double> taxRate,
  Value<String> currencySymbol,
  Value<String> receiptFooter,
  Value<String?> lastZReportAt,
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
          }) =>
              SettingsTableCompanion(
            id: id,
            businessName: businessName,
            taxRate: taxRate,
            currencySymbol: currencySymbol,
            receiptFooter: receiptFooter,
            lastZReportAt: lastZReportAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> businessName = const Value.absent(),
            Value<double> taxRate = const Value.absent(),
            Value<String> currencySymbol = const Value.absent(),
            Value<String> receiptFooter = const Value.absent(),
            Value<String?> lastZReportAt = const Value.absent(),
          }) =>
              SettingsTableCompanion.insert(
            id: id,
            businessName: businessName,
            taxRate: taxRate,
            currencySymbol: currencySymbol,
            receiptFooter: receiptFooter,
            lastZReportAt: lastZReportAt,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ItemsTableTableTableManager get itemsTable =>
      $$ItemsTableTableTableManager(_db, _db.itemsTable);
  $$TransactionsTableTableTableManager get transactionsTable =>
      $$TransactionsTableTableTableManager(_db, _db.transactionsTable);
  $$PaymentsTableTableTableManager get paymentsTable =>
      $$PaymentsTableTableTableManager(_db, _db.paymentsTable);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
}
