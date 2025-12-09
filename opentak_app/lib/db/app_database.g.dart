// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BuildingRowsTable extends BuildingRows
    with TableInfo<$BuildingRowsTable, BuildingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BuildingRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _floorHeightMeta = const VerificationMeta(
    'floorHeight',
  );
  @override
  late final GeneratedColumn<double> floorHeight = GeneratedColumn<double>(
    'floor_height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseHeightMeta = const VerificationMeta(
    'baseHeight',
  );
  @override
  late final GeneratedColumn<double> baseHeight = GeneratedColumn<double>(
    'base_height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minLatMeta = const VerificationMeta('minLat');
  @override
  late final GeneratedColumn<double> minLat = GeneratedColumn<double>(
    'min_lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxLatMeta = const VerificationMeta('maxLat');
  @override
  late final GeneratedColumn<double> maxLat = GeneratedColumn<double>(
    'max_lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minLngMeta = const VerificationMeta('minLng');
  @override
  late final GeneratedColumn<double> minLng = GeneratedColumn<double>(
    'min_lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxLngMeta = const VerificationMeta('maxLng');
  @override
  late final GeneratedColumn<double> maxLng = GeneratedColumn<double>(
    'max_lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    floorHeight,
    baseHeight,
    minLat,
    maxLat,
    minLng,
    maxLng,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'building_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<BuildingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('floor_height')) {
      context.handle(
        _floorHeightMeta,
        floorHeight.isAcceptableOrUnknown(
          data['floor_height']!,
          _floorHeightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_floorHeightMeta);
    }
    if (data.containsKey('base_height')) {
      context.handle(
        _baseHeightMeta,
        baseHeight.isAcceptableOrUnknown(data['base_height']!, _baseHeightMeta),
      );
    } else if (isInserting) {
      context.missing(_baseHeightMeta);
    }
    if (data.containsKey('min_lat')) {
      context.handle(
        _minLatMeta,
        minLat.isAcceptableOrUnknown(data['min_lat']!, _minLatMeta),
      );
    } else if (isInserting) {
      context.missing(_minLatMeta);
    }
    if (data.containsKey('max_lat')) {
      context.handle(
        _maxLatMeta,
        maxLat.isAcceptableOrUnknown(data['max_lat']!, _maxLatMeta),
      );
    } else if (isInserting) {
      context.missing(_maxLatMeta);
    }
    if (data.containsKey('min_lng')) {
      context.handle(
        _minLngMeta,
        minLng.isAcceptableOrUnknown(data['min_lng']!, _minLngMeta),
      );
    } else if (isInserting) {
      context.missing(_minLngMeta);
    }
    if (data.containsKey('max_lng')) {
      context.handle(
        _maxLngMeta,
        maxLng.isAcceptableOrUnknown(data['max_lng']!, _maxLngMeta),
      );
    } else if (isInserting) {
      context.missing(_maxLngMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BuildingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BuildingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      floorHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}floor_height'],
      )!,
      baseHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}base_height'],
      )!,
      minLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_lat'],
      )!,
      maxLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_lat'],
      )!,
      minLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_lng'],
      )!,
      maxLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_lng'],
      )!,
    );
  }

  @override
  $BuildingRowsTable createAlias(String alias) {
    return $BuildingRowsTable(attachedDatabase, alias);
  }
}

class BuildingRow extends DataClass implements Insertable<BuildingRow> {
  final int id;
  final String name;
  final double floorHeight;
  final double baseHeight;
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;
  const BuildingRow({
    required this.id,
    required this.name,
    required this.floorHeight,
    required this.baseHeight,
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['floor_height'] = Variable<double>(floorHeight);
    map['base_height'] = Variable<double>(baseHeight);
    map['min_lat'] = Variable<double>(minLat);
    map['max_lat'] = Variable<double>(maxLat);
    map['min_lng'] = Variable<double>(minLng);
    map['max_lng'] = Variable<double>(maxLng);
    return map;
  }

  BuildingRowsCompanion toCompanion(bool nullToAbsent) {
    return BuildingRowsCompanion(
      id: Value(id),
      name: Value(name),
      floorHeight: Value(floorHeight),
      baseHeight: Value(baseHeight),
      minLat: Value(minLat),
      maxLat: Value(maxLat),
      minLng: Value(minLng),
      maxLng: Value(maxLng),
    );
  }

  factory BuildingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BuildingRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      floorHeight: serializer.fromJson<double>(json['floorHeight']),
      baseHeight: serializer.fromJson<double>(json['baseHeight']),
      minLat: serializer.fromJson<double>(json['minLat']),
      maxLat: serializer.fromJson<double>(json['maxLat']),
      minLng: serializer.fromJson<double>(json['minLng']),
      maxLng: serializer.fromJson<double>(json['maxLng']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'floorHeight': serializer.toJson<double>(floorHeight),
      'baseHeight': serializer.toJson<double>(baseHeight),
      'minLat': serializer.toJson<double>(minLat),
      'maxLat': serializer.toJson<double>(maxLat),
      'minLng': serializer.toJson<double>(minLng),
      'maxLng': serializer.toJson<double>(maxLng),
    };
  }

  BuildingRow copyWith({
    int? id,
    String? name,
    double? floorHeight,
    double? baseHeight,
    double? minLat,
    double? maxLat,
    double? minLng,
    double? maxLng,
  }) => BuildingRow(
    id: id ?? this.id,
    name: name ?? this.name,
    floorHeight: floorHeight ?? this.floorHeight,
    baseHeight: baseHeight ?? this.baseHeight,
    minLat: minLat ?? this.minLat,
    maxLat: maxLat ?? this.maxLat,
    minLng: minLng ?? this.minLng,
    maxLng: maxLng ?? this.maxLng,
  );
  BuildingRow copyWithCompanion(BuildingRowsCompanion data) {
    return BuildingRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      floorHeight: data.floorHeight.present
          ? data.floorHeight.value
          : this.floorHeight,
      baseHeight: data.baseHeight.present
          ? data.baseHeight.value
          : this.baseHeight,
      minLat: data.minLat.present ? data.minLat.value : this.minLat,
      maxLat: data.maxLat.present ? data.maxLat.value : this.maxLat,
      minLng: data.minLng.present ? data.minLng.value : this.minLng,
      maxLng: data.maxLng.present ? data.maxLng.value : this.maxLng,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BuildingRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('floorHeight: $floorHeight, ')
          ..write('baseHeight: $baseHeight, ')
          ..write('minLat: $minLat, ')
          ..write('maxLat: $maxLat, ')
          ..write('minLng: $minLng, ')
          ..write('maxLng: $maxLng')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    floorHeight,
    baseHeight,
    minLat,
    maxLat,
    minLng,
    maxLng,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BuildingRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.floorHeight == this.floorHeight &&
          other.baseHeight == this.baseHeight &&
          other.minLat == this.minLat &&
          other.maxLat == this.maxLat &&
          other.minLng == this.minLng &&
          other.maxLng == this.maxLng);
}

class BuildingRowsCompanion extends UpdateCompanion<BuildingRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> floorHeight;
  final Value<double> baseHeight;
  final Value<double> minLat;
  final Value<double> maxLat;
  final Value<double> minLng;
  final Value<double> maxLng;
  const BuildingRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.floorHeight = const Value.absent(),
    this.baseHeight = const Value.absent(),
    this.minLat = const Value.absent(),
    this.maxLat = const Value.absent(),
    this.minLng = const Value.absent(),
    this.maxLng = const Value.absent(),
  });
  BuildingRowsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double floorHeight,
    required double baseHeight,
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
  }) : name = Value(name),
       floorHeight = Value(floorHeight),
       baseHeight = Value(baseHeight),
       minLat = Value(minLat),
       maxLat = Value(maxLat),
       minLng = Value(minLng),
       maxLng = Value(maxLng);
  static Insertable<BuildingRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? floorHeight,
    Expression<double>? baseHeight,
    Expression<double>? minLat,
    Expression<double>? maxLat,
    Expression<double>? minLng,
    Expression<double>? maxLng,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (floorHeight != null) 'floor_height': floorHeight,
      if (baseHeight != null) 'base_height': baseHeight,
      if (minLat != null) 'min_lat': minLat,
      if (maxLat != null) 'max_lat': maxLat,
      if (minLng != null) 'min_lng': minLng,
      if (maxLng != null) 'max_lng': maxLng,
    });
  }

  BuildingRowsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? floorHeight,
    Value<double>? baseHeight,
    Value<double>? minLat,
    Value<double>? maxLat,
    Value<double>? minLng,
    Value<double>? maxLng,
  }) {
    return BuildingRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      floorHeight: floorHeight ?? this.floorHeight,
      baseHeight: baseHeight ?? this.baseHeight,
      minLat: minLat ?? this.minLat,
      maxLat: maxLat ?? this.maxLat,
      minLng: minLng ?? this.minLng,
      maxLng: maxLng ?? this.maxLng,
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
    if (floorHeight.present) {
      map['floor_height'] = Variable<double>(floorHeight.value);
    }
    if (baseHeight.present) {
      map['base_height'] = Variable<double>(baseHeight.value);
    }
    if (minLat.present) {
      map['min_lat'] = Variable<double>(minLat.value);
    }
    if (maxLat.present) {
      map['max_lat'] = Variable<double>(maxLat.value);
    }
    if (minLng.present) {
      map['min_lng'] = Variable<double>(minLng.value);
    }
    if (maxLng.present) {
      map['max_lng'] = Variable<double>(maxLng.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BuildingRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('floorHeight: $floorHeight, ')
          ..write('baseHeight: $baseHeight, ')
          ..write('minLat: $minLat, ')
          ..write('maxLat: $maxLat, ')
          ..write('minLng: $minLng, ')
          ..write('maxLng: $maxLng')
          ..write(')'))
        .toString();
  }
}

class $FloorOverlayRowsTable extends FloorOverlayRows
    with TableInfo<$FloorOverlayRowsTable, FloorOverlayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FloorOverlayRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _buildingIdMeta = const VerificationMeta(
    'buildingId',
  );
  @override
  late final GeneratedColumn<int> buildingId = GeneratedColumn<int>(
    'building_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES building_rows (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _assetPathMeta = const VerificationMeta(
    'assetPath',
  );
  @override
  late final GeneratedColumn<String> assetPath = GeneratedColumn<String>(
    'asset_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topLeftLatMeta = const VerificationMeta(
    'topLeftLat',
  );
  @override
  late final GeneratedColumn<double> topLeftLat = GeneratedColumn<double>(
    'top_left_lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topLeftLngMeta = const VerificationMeta(
    'topLeftLng',
  );
  @override
  late final GeneratedColumn<double> topLeftLng = GeneratedColumn<double>(
    'top_left_lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bottomLeftLatMeta = const VerificationMeta(
    'bottomLeftLat',
  );
  @override
  late final GeneratedColumn<double> bottomLeftLat = GeneratedColumn<double>(
    'bottom_left_lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bottomLeftLngMeta = const VerificationMeta(
    'bottomLeftLng',
  );
  @override
  late final GeneratedColumn<double> bottomLeftLng = GeneratedColumn<double>(
    'bottom_left_lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bottomRightLatMeta = const VerificationMeta(
    'bottomRightLat',
  );
  @override
  late final GeneratedColumn<double> bottomRightLat = GeneratedColumn<double>(
    'bottom_right_lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bottomRightLngMeta = const VerificationMeta(
    'bottomRightLng',
  );
  @override
  late final GeneratedColumn<double> bottomRightLng = GeneratedColumn<double>(
    'bottom_right_lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _floorNumberMeta = const VerificationMeta(
    'floorNumber',
  );
  @override
  late final GeneratedColumn<int> floorNumber = GeneratedColumn<int>(
    'floor_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    buildingId,
    assetPath,
    topLeftLat,
    topLeftLng,
    bottomLeftLat,
    bottomLeftLng,
    bottomRightLat,
    bottomRightLng,
    floorNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'floor_overlay_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<FloorOverlayRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('building_id')) {
      context.handle(
        _buildingIdMeta,
        buildingId.isAcceptableOrUnknown(data['building_id']!, _buildingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_buildingIdMeta);
    }
    if (data.containsKey('asset_path')) {
      context.handle(
        _assetPathMeta,
        assetPath.isAcceptableOrUnknown(data['asset_path']!, _assetPathMeta),
      );
    } else if (isInserting) {
      context.missing(_assetPathMeta);
    }
    if (data.containsKey('top_left_lat')) {
      context.handle(
        _topLeftLatMeta,
        topLeftLat.isAcceptableOrUnknown(
          data['top_left_lat']!,
          _topLeftLatMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_topLeftLatMeta);
    }
    if (data.containsKey('top_left_lng')) {
      context.handle(
        _topLeftLngMeta,
        topLeftLng.isAcceptableOrUnknown(
          data['top_left_lng']!,
          _topLeftLngMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_topLeftLngMeta);
    }
    if (data.containsKey('bottom_left_lat')) {
      context.handle(
        _bottomLeftLatMeta,
        bottomLeftLat.isAcceptableOrUnknown(
          data['bottom_left_lat']!,
          _bottomLeftLatMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bottomLeftLatMeta);
    }
    if (data.containsKey('bottom_left_lng')) {
      context.handle(
        _bottomLeftLngMeta,
        bottomLeftLng.isAcceptableOrUnknown(
          data['bottom_left_lng']!,
          _bottomLeftLngMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bottomLeftLngMeta);
    }
    if (data.containsKey('bottom_right_lat')) {
      context.handle(
        _bottomRightLatMeta,
        bottomRightLat.isAcceptableOrUnknown(
          data['bottom_right_lat']!,
          _bottomRightLatMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bottomRightLatMeta);
    }
    if (data.containsKey('bottom_right_lng')) {
      context.handle(
        _bottomRightLngMeta,
        bottomRightLng.isAcceptableOrUnknown(
          data['bottom_right_lng']!,
          _bottomRightLngMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bottomRightLngMeta);
    }
    if (data.containsKey('floor_number')) {
      context.handle(
        _floorNumberMeta,
        floorNumber.isAcceptableOrUnknown(
          data['floor_number']!,
          _floorNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_floorNumberMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FloorOverlayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FloorOverlayRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      buildingId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}building_id'],
      )!,
      assetPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_path'],
      )!,
      topLeftLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}top_left_lat'],
      )!,
      topLeftLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}top_left_lng'],
      )!,
      bottomLeftLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bottom_left_lat'],
      )!,
      bottomLeftLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bottom_left_lng'],
      )!,
      bottomRightLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bottom_right_lat'],
      )!,
      bottomRightLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bottom_right_lng'],
      )!,
      floorNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}floor_number'],
      )!,
    );
  }

  @override
  $FloorOverlayRowsTable createAlias(String alias) {
    return $FloorOverlayRowsTable(attachedDatabase, alias);
  }
}

class FloorOverlayRow extends DataClass implements Insertable<FloorOverlayRow> {
  final int id;
  final int buildingId;
  final String assetPath;
  final double topLeftLat;
  final double topLeftLng;
  final double bottomLeftLat;
  final double bottomLeftLng;
  final double bottomRightLat;
  final double bottomRightLng;
  final int floorNumber;
  const FloorOverlayRow({
    required this.id,
    required this.buildingId,
    required this.assetPath,
    required this.topLeftLat,
    required this.topLeftLng,
    required this.bottomLeftLat,
    required this.bottomLeftLng,
    required this.bottomRightLat,
    required this.bottomRightLng,
    required this.floorNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['building_id'] = Variable<int>(buildingId);
    map['asset_path'] = Variable<String>(assetPath);
    map['top_left_lat'] = Variable<double>(topLeftLat);
    map['top_left_lng'] = Variable<double>(topLeftLng);
    map['bottom_left_lat'] = Variable<double>(bottomLeftLat);
    map['bottom_left_lng'] = Variable<double>(bottomLeftLng);
    map['bottom_right_lat'] = Variable<double>(bottomRightLat);
    map['bottom_right_lng'] = Variable<double>(bottomRightLng);
    map['floor_number'] = Variable<int>(floorNumber);
    return map;
  }

  FloorOverlayRowsCompanion toCompanion(bool nullToAbsent) {
    return FloorOverlayRowsCompanion(
      id: Value(id),
      buildingId: Value(buildingId),
      assetPath: Value(assetPath),
      topLeftLat: Value(topLeftLat),
      topLeftLng: Value(topLeftLng),
      bottomLeftLat: Value(bottomLeftLat),
      bottomLeftLng: Value(bottomLeftLng),
      bottomRightLat: Value(bottomRightLat),
      bottomRightLng: Value(bottomRightLng),
      floorNumber: Value(floorNumber),
    );
  }

  factory FloorOverlayRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FloorOverlayRow(
      id: serializer.fromJson<int>(json['id']),
      buildingId: serializer.fromJson<int>(json['buildingId']),
      assetPath: serializer.fromJson<String>(json['assetPath']),
      topLeftLat: serializer.fromJson<double>(json['topLeftLat']),
      topLeftLng: serializer.fromJson<double>(json['topLeftLng']),
      bottomLeftLat: serializer.fromJson<double>(json['bottomLeftLat']),
      bottomLeftLng: serializer.fromJson<double>(json['bottomLeftLng']),
      bottomRightLat: serializer.fromJson<double>(json['bottomRightLat']),
      bottomRightLng: serializer.fromJson<double>(json['bottomRightLng']),
      floorNumber: serializer.fromJson<int>(json['floorNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'buildingId': serializer.toJson<int>(buildingId),
      'assetPath': serializer.toJson<String>(assetPath),
      'topLeftLat': serializer.toJson<double>(topLeftLat),
      'topLeftLng': serializer.toJson<double>(topLeftLng),
      'bottomLeftLat': serializer.toJson<double>(bottomLeftLat),
      'bottomLeftLng': serializer.toJson<double>(bottomLeftLng),
      'bottomRightLat': serializer.toJson<double>(bottomRightLat),
      'bottomRightLng': serializer.toJson<double>(bottomRightLng),
      'floorNumber': serializer.toJson<int>(floorNumber),
    };
  }

  FloorOverlayRow copyWith({
    int? id,
    int? buildingId,
    String? assetPath,
    double? topLeftLat,
    double? topLeftLng,
    double? bottomLeftLat,
    double? bottomLeftLng,
    double? bottomRightLat,
    double? bottomRightLng,
    int? floorNumber,
  }) => FloorOverlayRow(
    id: id ?? this.id,
    buildingId: buildingId ?? this.buildingId,
    assetPath: assetPath ?? this.assetPath,
    topLeftLat: topLeftLat ?? this.topLeftLat,
    topLeftLng: topLeftLng ?? this.topLeftLng,
    bottomLeftLat: bottomLeftLat ?? this.bottomLeftLat,
    bottomLeftLng: bottomLeftLng ?? this.bottomLeftLng,
    bottomRightLat: bottomRightLat ?? this.bottomRightLat,
    bottomRightLng: bottomRightLng ?? this.bottomRightLng,
    floorNumber: floorNumber ?? this.floorNumber,
  );
  FloorOverlayRow copyWithCompanion(FloorOverlayRowsCompanion data) {
    return FloorOverlayRow(
      id: data.id.present ? data.id.value : this.id,
      buildingId: data.buildingId.present
          ? data.buildingId.value
          : this.buildingId,
      assetPath: data.assetPath.present ? data.assetPath.value : this.assetPath,
      topLeftLat: data.topLeftLat.present
          ? data.topLeftLat.value
          : this.topLeftLat,
      topLeftLng: data.topLeftLng.present
          ? data.topLeftLng.value
          : this.topLeftLng,
      bottomLeftLat: data.bottomLeftLat.present
          ? data.bottomLeftLat.value
          : this.bottomLeftLat,
      bottomLeftLng: data.bottomLeftLng.present
          ? data.bottomLeftLng.value
          : this.bottomLeftLng,
      bottomRightLat: data.bottomRightLat.present
          ? data.bottomRightLat.value
          : this.bottomRightLat,
      bottomRightLng: data.bottomRightLng.present
          ? data.bottomRightLng.value
          : this.bottomRightLng,
      floorNumber: data.floorNumber.present
          ? data.floorNumber.value
          : this.floorNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FloorOverlayRow(')
          ..write('id: $id, ')
          ..write('buildingId: $buildingId, ')
          ..write('assetPath: $assetPath, ')
          ..write('topLeftLat: $topLeftLat, ')
          ..write('topLeftLng: $topLeftLng, ')
          ..write('bottomLeftLat: $bottomLeftLat, ')
          ..write('bottomLeftLng: $bottomLeftLng, ')
          ..write('bottomRightLat: $bottomRightLat, ')
          ..write('bottomRightLng: $bottomRightLng, ')
          ..write('floorNumber: $floorNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    buildingId,
    assetPath,
    topLeftLat,
    topLeftLng,
    bottomLeftLat,
    bottomLeftLng,
    bottomRightLat,
    bottomRightLng,
    floorNumber,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FloorOverlayRow &&
          other.id == this.id &&
          other.buildingId == this.buildingId &&
          other.assetPath == this.assetPath &&
          other.topLeftLat == this.topLeftLat &&
          other.topLeftLng == this.topLeftLng &&
          other.bottomLeftLat == this.bottomLeftLat &&
          other.bottomLeftLng == this.bottomLeftLng &&
          other.bottomRightLat == this.bottomRightLat &&
          other.bottomRightLng == this.bottomRightLng &&
          other.floorNumber == this.floorNumber);
}

class FloorOverlayRowsCompanion extends UpdateCompanion<FloorOverlayRow> {
  final Value<int> id;
  final Value<int> buildingId;
  final Value<String> assetPath;
  final Value<double> topLeftLat;
  final Value<double> topLeftLng;
  final Value<double> bottomLeftLat;
  final Value<double> bottomLeftLng;
  final Value<double> bottomRightLat;
  final Value<double> bottomRightLng;
  final Value<int> floorNumber;
  const FloorOverlayRowsCompanion({
    this.id = const Value.absent(),
    this.buildingId = const Value.absent(),
    this.assetPath = const Value.absent(),
    this.topLeftLat = const Value.absent(),
    this.topLeftLng = const Value.absent(),
    this.bottomLeftLat = const Value.absent(),
    this.bottomLeftLng = const Value.absent(),
    this.bottomRightLat = const Value.absent(),
    this.bottomRightLng = const Value.absent(),
    this.floorNumber = const Value.absent(),
  });
  FloorOverlayRowsCompanion.insert({
    this.id = const Value.absent(),
    required int buildingId,
    required String assetPath,
    required double topLeftLat,
    required double topLeftLng,
    required double bottomLeftLat,
    required double bottomLeftLng,
    required double bottomRightLat,
    required double bottomRightLng,
    required int floorNumber,
  }) : buildingId = Value(buildingId),
       assetPath = Value(assetPath),
       topLeftLat = Value(topLeftLat),
       topLeftLng = Value(topLeftLng),
       bottomLeftLat = Value(bottomLeftLat),
       bottomLeftLng = Value(bottomLeftLng),
       bottomRightLat = Value(bottomRightLat),
       bottomRightLng = Value(bottomRightLng),
       floorNumber = Value(floorNumber);
  static Insertable<FloorOverlayRow> custom({
    Expression<int>? id,
    Expression<int>? buildingId,
    Expression<String>? assetPath,
    Expression<double>? topLeftLat,
    Expression<double>? topLeftLng,
    Expression<double>? bottomLeftLat,
    Expression<double>? bottomLeftLng,
    Expression<double>? bottomRightLat,
    Expression<double>? bottomRightLng,
    Expression<int>? floorNumber,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (buildingId != null) 'building_id': buildingId,
      if (assetPath != null) 'asset_path': assetPath,
      if (topLeftLat != null) 'top_left_lat': topLeftLat,
      if (topLeftLng != null) 'top_left_lng': topLeftLng,
      if (bottomLeftLat != null) 'bottom_left_lat': bottomLeftLat,
      if (bottomLeftLng != null) 'bottom_left_lng': bottomLeftLng,
      if (bottomRightLat != null) 'bottom_right_lat': bottomRightLat,
      if (bottomRightLng != null) 'bottom_right_lng': bottomRightLng,
      if (floorNumber != null) 'floor_number': floorNumber,
    });
  }

  FloorOverlayRowsCompanion copyWith({
    Value<int>? id,
    Value<int>? buildingId,
    Value<String>? assetPath,
    Value<double>? topLeftLat,
    Value<double>? topLeftLng,
    Value<double>? bottomLeftLat,
    Value<double>? bottomLeftLng,
    Value<double>? bottomRightLat,
    Value<double>? bottomRightLng,
    Value<int>? floorNumber,
  }) {
    return FloorOverlayRowsCompanion(
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      assetPath: assetPath ?? this.assetPath,
      topLeftLat: topLeftLat ?? this.topLeftLat,
      topLeftLng: topLeftLng ?? this.topLeftLng,
      bottomLeftLat: bottomLeftLat ?? this.bottomLeftLat,
      bottomLeftLng: bottomLeftLng ?? this.bottomLeftLng,
      bottomRightLat: bottomRightLat ?? this.bottomRightLat,
      bottomRightLng: bottomRightLng ?? this.bottomRightLng,
      floorNumber: floorNumber ?? this.floorNumber,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (buildingId.present) {
      map['building_id'] = Variable<int>(buildingId.value);
    }
    if (assetPath.present) {
      map['asset_path'] = Variable<String>(assetPath.value);
    }
    if (topLeftLat.present) {
      map['top_left_lat'] = Variable<double>(topLeftLat.value);
    }
    if (topLeftLng.present) {
      map['top_left_lng'] = Variable<double>(topLeftLng.value);
    }
    if (bottomLeftLat.present) {
      map['bottom_left_lat'] = Variable<double>(bottomLeftLat.value);
    }
    if (bottomLeftLng.present) {
      map['bottom_left_lng'] = Variable<double>(bottomLeftLng.value);
    }
    if (bottomRightLat.present) {
      map['bottom_right_lat'] = Variable<double>(bottomRightLat.value);
    }
    if (bottomRightLng.present) {
      map['bottom_right_lng'] = Variable<double>(bottomRightLng.value);
    }
    if (floorNumber.present) {
      map['floor_number'] = Variable<int>(floorNumber.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FloorOverlayRowsCompanion(')
          ..write('id: $id, ')
          ..write('buildingId: $buildingId, ')
          ..write('assetPath: $assetPath, ')
          ..write('topLeftLat: $topLeftLat, ')
          ..write('topLeftLng: $topLeftLng, ')
          ..write('bottomLeftLat: $bottomLeftLat, ')
          ..write('bottomLeftLng: $bottomLeftLng, ')
          ..write('bottomRightLat: $bottomRightLat, ')
          ..write('bottomRightLng: $bottomRightLng, ')
          ..write('floorNumber: $floorNumber')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BuildingRowsTable buildingRows = $BuildingRowsTable(this);
  late final $FloorOverlayRowsTable floorOverlayRows = $FloorOverlayRowsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    buildingRows,
    floorOverlayRows,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'building_rows',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('floor_overlay_rows', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$BuildingRowsTableCreateCompanionBuilder =
    BuildingRowsCompanion Function({
      Value<int> id,
      required String name,
      required double floorHeight,
      required double baseHeight,
      required double minLat,
      required double maxLat,
      required double minLng,
      required double maxLng,
    });
typedef $$BuildingRowsTableUpdateCompanionBuilder =
    BuildingRowsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> floorHeight,
      Value<double> baseHeight,
      Value<double> minLat,
      Value<double> maxLat,
      Value<double> minLng,
      Value<double> maxLng,
    });

final class $$BuildingRowsTableReferences
    extends BaseReferences<_$AppDatabase, $BuildingRowsTable, BuildingRow> {
  $$BuildingRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FloorOverlayRowsTable, List<FloorOverlayRow>>
  _floorOverlayRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.floorOverlayRows,
    aliasName: $_aliasNameGenerator(
      db.buildingRows.id,
      db.floorOverlayRows.buildingId,
    ),
  );

  $$FloorOverlayRowsTableProcessedTableManager get floorOverlayRowsRefs {
    final manager = $$FloorOverlayRowsTableTableManager(
      $_db,
      $_db.floorOverlayRows,
    ).filter((f) => f.buildingId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _floorOverlayRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BuildingRowsTableFilterComposer
    extends Composer<_$AppDatabase, $BuildingRowsTable> {
  $$BuildingRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get floorHeight => $composableBuilder(
    column: $table.floorHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get baseHeight => $composableBuilder(
    column: $table.baseHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minLat => $composableBuilder(
    column: $table.minLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxLat => $composableBuilder(
    column: $table.maxLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minLng => $composableBuilder(
    column: $table.minLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxLng => $composableBuilder(
    column: $table.maxLng,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> floorOverlayRowsRefs(
    Expression<bool> Function($$FloorOverlayRowsTableFilterComposer f) f,
  ) {
    final $$FloorOverlayRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.floorOverlayRows,
      getReferencedColumn: (t) => t.buildingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FloorOverlayRowsTableFilterComposer(
            $db: $db,
            $table: $db.floorOverlayRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BuildingRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $BuildingRowsTable> {
  $$BuildingRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get floorHeight => $composableBuilder(
    column: $table.floorHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get baseHeight => $composableBuilder(
    column: $table.baseHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minLat => $composableBuilder(
    column: $table.minLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxLat => $composableBuilder(
    column: $table.maxLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minLng => $composableBuilder(
    column: $table.minLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxLng => $composableBuilder(
    column: $table.maxLng,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BuildingRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BuildingRowsTable> {
  $$BuildingRowsTableAnnotationComposer({
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

  GeneratedColumn<double> get floorHeight => $composableBuilder(
    column: $table.floorHeight,
    builder: (column) => column,
  );

  GeneratedColumn<double> get baseHeight => $composableBuilder(
    column: $table.baseHeight,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minLat =>
      $composableBuilder(column: $table.minLat, builder: (column) => column);

  GeneratedColumn<double> get maxLat =>
      $composableBuilder(column: $table.maxLat, builder: (column) => column);

  GeneratedColumn<double> get minLng =>
      $composableBuilder(column: $table.minLng, builder: (column) => column);

  GeneratedColumn<double> get maxLng =>
      $composableBuilder(column: $table.maxLng, builder: (column) => column);

  Expression<T> floorOverlayRowsRefs<T extends Object>(
    Expression<T> Function($$FloorOverlayRowsTableAnnotationComposer a) f,
  ) {
    final $$FloorOverlayRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.floorOverlayRows,
      getReferencedColumn: (t) => t.buildingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FloorOverlayRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.floorOverlayRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BuildingRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BuildingRowsTable,
          BuildingRow,
          $$BuildingRowsTableFilterComposer,
          $$BuildingRowsTableOrderingComposer,
          $$BuildingRowsTableAnnotationComposer,
          $$BuildingRowsTableCreateCompanionBuilder,
          $$BuildingRowsTableUpdateCompanionBuilder,
          (BuildingRow, $$BuildingRowsTableReferences),
          BuildingRow,
          PrefetchHooks Function({bool floorOverlayRowsRefs})
        > {
  $$BuildingRowsTableTableManager(_$AppDatabase db, $BuildingRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BuildingRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BuildingRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BuildingRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> floorHeight = const Value.absent(),
                Value<double> baseHeight = const Value.absent(),
                Value<double> minLat = const Value.absent(),
                Value<double> maxLat = const Value.absent(),
                Value<double> minLng = const Value.absent(),
                Value<double> maxLng = const Value.absent(),
              }) => BuildingRowsCompanion(
                id: id,
                name: name,
                floorHeight: floorHeight,
                baseHeight: baseHeight,
                minLat: minLat,
                maxLat: maxLat,
                minLng: minLng,
                maxLng: maxLng,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double floorHeight,
                required double baseHeight,
                required double minLat,
                required double maxLat,
                required double minLng,
                required double maxLng,
              }) => BuildingRowsCompanion.insert(
                id: id,
                name: name,
                floorHeight: floorHeight,
                baseHeight: baseHeight,
                minLat: minLat,
                maxLat: maxLat,
                minLng: minLng,
                maxLng: maxLng,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BuildingRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({floorOverlayRowsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (floorOverlayRowsRefs) db.floorOverlayRows,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (floorOverlayRowsRefs)
                    await $_getPrefetchedData<
                      BuildingRow,
                      $BuildingRowsTable,
                      FloorOverlayRow
                    >(
                      currentTable: table,
                      referencedTable: $$BuildingRowsTableReferences
                          ._floorOverlayRowsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$BuildingRowsTableReferences(
                            db,
                            table,
                            p0,
                          ).floorOverlayRowsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.buildingId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BuildingRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BuildingRowsTable,
      BuildingRow,
      $$BuildingRowsTableFilterComposer,
      $$BuildingRowsTableOrderingComposer,
      $$BuildingRowsTableAnnotationComposer,
      $$BuildingRowsTableCreateCompanionBuilder,
      $$BuildingRowsTableUpdateCompanionBuilder,
      (BuildingRow, $$BuildingRowsTableReferences),
      BuildingRow,
      PrefetchHooks Function({bool floorOverlayRowsRefs})
    >;
typedef $$FloorOverlayRowsTableCreateCompanionBuilder =
    FloorOverlayRowsCompanion Function({
      Value<int> id,
      required int buildingId,
      required String assetPath,
      required double topLeftLat,
      required double topLeftLng,
      required double bottomLeftLat,
      required double bottomLeftLng,
      required double bottomRightLat,
      required double bottomRightLng,
      required int floorNumber,
    });
typedef $$FloorOverlayRowsTableUpdateCompanionBuilder =
    FloorOverlayRowsCompanion Function({
      Value<int> id,
      Value<int> buildingId,
      Value<String> assetPath,
      Value<double> topLeftLat,
      Value<double> topLeftLng,
      Value<double> bottomLeftLat,
      Value<double> bottomLeftLng,
      Value<double> bottomRightLat,
      Value<double> bottomRightLng,
      Value<int> floorNumber,
    });

final class $$FloorOverlayRowsTableReferences
    extends
        BaseReferences<_$AppDatabase, $FloorOverlayRowsTable, FloorOverlayRow> {
  $$FloorOverlayRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BuildingRowsTable _buildingIdTable(_$AppDatabase db) =>
      db.buildingRows.createAlias(
        $_aliasNameGenerator(
          db.floorOverlayRows.buildingId,
          db.buildingRows.id,
        ),
      );

  $$BuildingRowsTableProcessedTableManager get buildingId {
    final $_column = $_itemColumn<int>('building_id')!;

    final manager = $$BuildingRowsTableTableManager(
      $_db,
      $_db.buildingRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_buildingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FloorOverlayRowsTableFilterComposer
    extends Composer<_$AppDatabase, $FloorOverlayRowsTable> {
  $$FloorOverlayRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetPath => $composableBuilder(
    column: $table.assetPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get topLeftLat => $composableBuilder(
    column: $table.topLeftLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get topLeftLng => $composableBuilder(
    column: $table.topLeftLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bottomLeftLat => $composableBuilder(
    column: $table.bottomLeftLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bottomLeftLng => $composableBuilder(
    column: $table.bottomLeftLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bottomRightLat => $composableBuilder(
    column: $table.bottomRightLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bottomRightLng => $composableBuilder(
    column: $table.bottomRightLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get floorNumber => $composableBuilder(
    column: $table.floorNumber,
    builder: (column) => ColumnFilters(column),
  );

  $$BuildingRowsTableFilterComposer get buildingId {
    final $$BuildingRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buildingId,
      referencedTable: $db.buildingRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuildingRowsTableFilterComposer(
            $db: $db,
            $table: $db.buildingRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FloorOverlayRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $FloorOverlayRowsTable> {
  $$FloorOverlayRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetPath => $composableBuilder(
    column: $table.assetPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get topLeftLat => $composableBuilder(
    column: $table.topLeftLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get topLeftLng => $composableBuilder(
    column: $table.topLeftLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bottomLeftLat => $composableBuilder(
    column: $table.bottomLeftLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bottomLeftLng => $composableBuilder(
    column: $table.bottomLeftLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bottomRightLat => $composableBuilder(
    column: $table.bottomRightLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bottomRightLng => $composableBuilder(
    column: $table.bottomRightLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get floorNumber => $composableBuilder(
    column: $table.floorNumber,
    builder: (column) => ColumnOrderings(column),
  );

  $$BuildingRowsTableOrderingComposer get buildingId {
    final $$BuildingRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buildingId,
      referencedTable: $db.buildingRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuildingRowsTableOrderingComposer(
            $db: $db,
            $table: $db.buildingRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FloorOverlayRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FloorOverlayRowsTable> {
  $$FloorOverlayRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assetPath =>
      $composableBuilder(column: $table.assetPath, builder: (column) => column);

  GeneratedColumn<double> get topLeftLat => $composableBuilder(
    column: $table.topLeftLat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get topLeftLng => $composableBuilder(
    column: $table.topLeftLng,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bottomLeftLat => $composableBuilder(
    column: $table.bottomLeftLat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bottomLeftLng => $composableBuilder(
    column: $table.bottomLeftLng,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bottomRightLat => $composableBuilder(
    column: $table.bottomRightLat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bottomRightLng => $composableBuilder(
    column: $table.bottomRightLng,
    builder: (column) => column,
  );

  GeneratedColumn<int> get floorNumber => $composableBuilder(
    column: $table.floorNumber,
    builder: (column) => column,
  );

  $$BuildingRowsTableAnnotationComposer get buildingId {
    final $$BuildingRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buildingId,
      referencedTable: $db.buildingRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuildingRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.buildingRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FloorOverlayRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FloorOverlayRowsTable,
          FloorOverlayRow,
          $$FloorOverlayRowsTableFilterComposer,
          $$FloorOverlayRowsTableOrderingComposer,
          $$FloorOverlayRowsTableAnnotationComposer,
          $$FloorOverlayRowsTableCreateCompanionBuilder,
          $$FloorOverlayRowsTableUpdateCompanionBuilder,
          (FloorOverlayRow, $$FloorOverlayRowsTableReferences),
          FloorOverlayRow,
          PrefetchHooks Function({bool buildingId})
        > {
  $$FloorOverlayRowsTableTableManager(
    _$AppDatabase db,
    $FloorOverlayRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FloorOverlayRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FloorOverlayRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FloorOverlayRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> buildingId = const Value.absent(),
                Value<String> assetPath = const Value.absent(),
                Value<double> topLeftLat = const Value.absent(),
                Value<double> topLeftLng = const Value.absent(),
                Value<double> bottomLeftLat = const Value.absent(),
                Value<double> bottomLeftLng = const Value.absent(),
                Value<double> bottomRightLat = const Value.absent(),
                Value<double> bottomRightLng = const Value.absent(),
                Value<int> floorNumber = const Value.absent(),
              }) => FloorOverlayRowsCompanion(
                id: id,
                buildingId: buildingId,
                assetPath: assetPath,
                topLeftLat: topLeftLat,
                topLeftLng: topLeftLng,
                bottomLeftLat: bottomLeftLat,
                bottomLeftLng: bottomLeftLng,
                bottomRightLat: bottomRightLat,
                bottomRightLng: bottomRightLng,
                floorNumber: floorNumber,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int buildingId,
                required String assetPath,
                required double topLeftLat,
                required double topLeftLng,
                required double bottomLeftLat,
                required double bottomLeftLng,
                required double bottomRightLat,
                required double bottomRightLng,
                required int floorNumber,
              }) => FloorOverlayRowsCompanion.insert(
                id: id,
                buildingId: buildingId,
                assetPath: assetPath,
                topLeftLat: topLeftLat,
                topLeftLng: topLeftLng,
                bottomLeftLat: bottomLeftLat,
                bottomLeftLng: bottomLeftLng,
                bottomRightLat: bottomRightLat,
                bottomRightLng: bottomRightLng,
                floorNumber: floorNumber,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FloorOverlayRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({buildingId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (buildingId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.buildingId,
                                referencedTable:
                                    $$FloorOverlayRowsTableReferences
                                        ._buildingIdTable(db),
                                referencedColumn:
                                    $$FloorOverlayRowsTableReferences
                                        ._buildingIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FloorOverlayRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FloorOverlayRowsTable,
      FloorOverlayRow,
      $$FloorOverlayRowsTableFilterComposer,
      $$FloorOverlayRowsTableOrderingComposer,
      $$FloorOverlayRowsTableAnnotationComposer,
      $$FloorOverlayRowsTableCreateCompanionBuilder,
      $$FloorOverlayRowsTableUpdateCompanionBuilder,
      (FloorOverlayRow, $$FloorOverlayRowsTableReferences),
      FloorOverlayRow,
      PrefetchHooks Function({bool buildingId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BuildingRowsTableTableManager get buildingRows =>
      $$BuildingRowsTableTableManager(_db, _db.buildingRows);
  $$FloorOverlayRowsTableTableManager get floorOverlayRows =>
      $$FloorOverlayRowsTableTableManager(_db, _db.floorOverlayRows);
}
