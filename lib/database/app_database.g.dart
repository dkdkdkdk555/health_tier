// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HtDayBodyTable extends HtDayBody
    with TableInfo<$HtDayBodyTable, HtDayBodyData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HtDayBodyTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
      'day', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _muscleMeta = const VerificationMeta('muscle');
  @override
  late final GeneratedColumn<double> muscle = GeneratedColumn<double>(
      'muscle', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
      'fat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
      'memo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _wkoutYnMeta =
      const VerificationMeta('wkoutYn');
  @override
  late final GeneratedColumn<int> wkoutYn = GeneratedColumn<int>(
      'wkout_yn', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _drunkYnMeta =
      const VerificationMeta('drunkYn');
  @override
  late final GeneratedColumn<int> drunkYn = GeneratedColumn<int>(
      'drunk_yn', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _stampMeta = const VerificationMeta('stamp');
  @override
  late final GeneratedColumn<String> stamp = GeneratedColumn<String>(
      'stamp', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, day, weight, muscle, fat, memo, wkoutYn, drunkYn, stamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ht_day_body';
  @override
  VerificationContext validateIntegrity(Insertable<HtDayBodyData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day')) {
      context.handle(
          _dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    }
    if (data.containsKey('muscle')) {
      context.handle(_muscleMeta,
          muscle.isAcceptableOrUnknown(data['muscle']!, _muscleMeta));
    }
    if (data.containsKey('fat')) {
      context.handle(
          _fatMeta, fat.isAcceptableOrUnknown(data['fat']!, _fatMeta));
    }
    if (data.containsKey('memo')) {
      context.handle(
          _memoMeta, memo.isAcceptableOrUnknown(data['memo']!, _memoMeta));
    }
    if (data.containsKey('wkout_yn')) {
      context.handle(_wkoutYnMeta,
          wkoutYn.isAcceptableOrUnknown(data['wkout_yn']!, _wkoutYnMeta));
    }
    if (data.containsKey('drunk_yn')) {
      context.handle(_drunkYnMeta,
          drunkYn.isAcceptableOrUnknown(data['drunk_yn']!, _drunkYnMeta));
    }
    if (data.containsKey('stamp')) {
      context.handle(
          _stampMeta, stamp.isAcceptableOrUnknown(data['stamp']!, _stampMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {day},
      ];
  @override
  HtDayBodyData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HtDayBodyData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      day: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight']),
      muscle: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}muscle']),
      fat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fat']),
      memo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memo']),
      wkoutYn: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wkout_yn'])!,
      drunkYn: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}drunk_yn'])!,
      stamp: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stamp']),
    );
  }

  @override
  $HtDayBodyTable createAlias(String alias) {
    return $HtDayBodyTable(attachedDatabase, alias);
  }
}

class HtDayBodyData extends DataClass implements Insertable<HtDayBodyData> {
  final int id;
  final String day;
  final double? weight;
  final double? muscle;
  final double? fat;
  final String? memo;
  final int wkoutYn;
  final int drunkYn;
  final String? stamp;
  const HtDayBodyData(
      {required this.id,
      required this.day,
      this.weight,
      this.muscle,
      this.fat,
      this.memo,
      required this.wkoutYn,
      required this.drunkYn,
      this.stamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day'] = Variable<String>(day);
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<double>(weight);
    }
    if (!nullToAbsent || muscle != null) {
      map['muscle'] = Variable<double>(muscle);
    }
    if (!nullToAbsent || fat != null) {
      map['fat'] = Variable<double>(fat);
    }
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['wkout_yn'] = Variable<int>(wkoutYn);
    map['drunk_yn'] = Variable<int>(drunkYn);
    if (!nullToAbsent || stamp != null) {
      map['stamp'] = Variable<String>(stamp);
    }
    return map;
  }

  HtDayBodyCompanion toCompanion(bool nullToAbsent) {
    return HtDayBodyCompanion(
      id: Value(id),
      day: Value(day),
      weight:
          weight == null && nullToAbsent ? const Value.absent() : Value(weight),
      muscle:
          muscle == null && nullToAbsent ? const Value.absent() : Value(muscle),
      fat: fat == null && nullToAbsent ? const Value.absent() : Value(fat),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      wkoutYn: Value(wkoutYn),
      drunkYn: Value(drunkYn),
      stamp:
          stamp == null && nullToAbsent ? const Value.absent() : Value(stamp),
    );
  }

  factory HtDayBodyData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HtDayBodyData(
      id: serializer.fromJson<int>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      weight: serializer.fromJson<double?>(json['weight']),
      muscle: serializer.fromJson<double?>(json['muscle']),
      fat: serializer.fromJson<double?>(json['fat']),
      memo: serializer.fromJson<String?>(json['memo']),
      wkoutYn: serializer.fromJson<int>(json['wkoutYn']),
      drunkYn: serializer.fromJson<int>(json['drunkYn']),
      stamp: serializer.fromJson<String?>(json['stamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'day': serializer.toJson<String>(day),
      'weight': serializer.toJson<double?>(weight),
      'muscle': serializer.toJson<double?>(muscle),
      'fat': serializer.toJson<double?>(fat),
      'memo': serializer.toJson<String?>(memo),
      'wkoutYn': serializer.toJson<int>(wkoutYn),
      'drunkYn': serializer.toJson<int>(drunkYn),
      'stamp': serializer.toJson<String?>(stamp),
    };
  }

  HtDayBodyData copyWith(
          {int? id,
          String? day,
          Value<double?> weight = const Value.absent(),
          Value<double?> muscle = const Value.absent(),
          Value<double?> fat = const Value.absent(),
          Value<String?> memo = const Value.absent(),
          int? wkoutYn,
          int? drunkYn,
          Value<String?> stamp = const Value.absent()}) =>
      HtDayBodyData(
        id: id ?? this.id,
        day: day ?? this.day,
        weight: weight.present ? weight.value : this.weight,
        muscle: muscle.present ? muscle.value : this.muscle,
        fat: fat.present ? fat.value : this.fat,
        memo: memo.present ? memo.value : this.memo,
        wkoutYn: wkoutYn ?? this.wkoutYn,
        drunkYn: drunkYn ?? this.drunkYn,
        stamp: stamp.present ? stamp.value : this.stamp,
      );
  HtDayBodyData copyWithCompanion(HtDayBodyCompanion data) {
    return HtDayBodyData(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      weight: data.weight.present ? data.weight.value : this.weight,
      muscle: data.muscle.present ? data.muscle.value : this.muscle,
      fat: data.fat.present ? data.fat.value : this.fat,
      memo: data.memo.present ? data.memo.value : this.memo,
      wkoutYn: data.wkoutYn.present ? data.wkoutYn.value : this.wkoutYn,
      drunkYn: data.drunkYn.present ? data.drunkYn.value : this.drunkYn,
      stamp: data.stamp.present ? data.stamp.value : this.stamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HtDayBodyData(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('weight: $weight, ')
          ..write('muscle: $muscle, ')
          ..write('fat: $fat, ')
          ..write('memo: $memo, ')
          ..write('wkoutYn: $wkoutYn, ')
          ..write('drunkYn: $drunkYn, ')
          ..write('stamp: $stamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, day, weight, muscle, fat, memo, wkoutYn, drunkYn, stamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HtDayBodyData &&
          other.id == this.id &&
          other.day == this.day &&
          other.weight == this.weight &&
          other.muscle == this.muscle &&
          other.fat == this.fat &&
          other.memo == this.memo &&
          other.wkoutYn == this.wkoutYn &&
          other.drunkYn == this.drunkYn &&
          other.stamp == this.stamp);
}

class HtDayBodyCompanion extends UpdateCompanion<HtDayBodyData> {
  final Value<int> id;
  final Value<String> day;
  final Value<double?> weight;
  final Value<double?> muscle;
  final Value<double?> fat;
  final Value<String?> memo;
  final Value<int> wkoutYn;
  final Value<int> drunkYn;
  final Value<String?> stamp;
  const HtDayBodyCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.weight = const Value.absent(),
    this.muscle = const Value.absent(),
    this.fat = const Value.absent(),
    this.memo = const Value.absent(),
    this.wkoutYn = const Value.absent(),
    this.drunkYn = const Value.absent(),
    this.stamp = const Value.absent(),
  });
  HtDayBodyCompanion.insert({
    this.id = const Value.absent(),
    required String day,
    this.weight = const Value.absent(),
    this.muscle = const Value.absent(),
    this.fat = const Value.absent(),
    this.memo = const Value.absent(),
    this.wkoutYn = const Value.absent(),
    this.drunkYn = const Value.absent(),
    this.stamp = const Value.absent(),
  }) : day = Value(day);
  static Insertable<HtDayBodyData> custom({
    Expression<int>? id,
    Expression<String>? day,
    Expression<double>? weight,
    Expression<double>? muscle,
    Expression<double>? fat,
    Expression<String>? memo,
    Expression<int>? wkoutYn,
    Expression<int>? drunkYn,
    Expression<String>? stamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (weight != null) 'weight': weight,
      if (muscle != null) 'muscle': muscle,
      if (fat != null) 'fat': fat,
      if (memo != null) 'memo': memo,
      if (wkoutYn != null) 'wkout_yn': wkoutYn,
      if (drunkYn != null) 'drunk_yn': drunkYn,
      if (stamp != null) 'stamp': stamp,
    });
  }

  HtDayBodyCompanion copyWith(
      {Value<int>? id,
      Value<String>? day,
      Value<double?>? weight,
      Value<double?>? muscle,
      Value<double?>? fat,
      Value<String?>? memo,
      Value<int>? wkoutYn,
      Value<int>? drunkYn,
      Value<String?>? stamp}) {
    return HtDayBodyCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      weight: weight ?? this.weight,
      muscle: muscle ?? this.muscle,
      fat: fat ?? this.fat,
      memo: memo ?? this.memo,
      wkoutYn: wkoutYn ?? this.wkoutYn,
      drunkYn: drunkYn ?? this.drunkYn,
      stamp: stamp ?? this.stamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (muscle.present) {
      map['muscle'] = Variable<double>(muscle.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (wkoutYn.present) {
      map['wkout_yn'] = Variable<int>(wkoutYn.value);
    }
    if (drunkYn.present) {
      map['drunk_yn'] = Variable<int>(drunkYn.value);
    }
    if (stamp.present) {
      map['stamp'] = Variable<String>(stamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HtDayBodyCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('weight: $weight, ')
          ..write('muscle: $muscle, ')
          ..write('fat: $fat, ')
          ..write('memo: $memo, ')
          ..write('wkoutYn: $wkoutYn, ')
          ..write('drunkYn: $drunkYn, ')
          ..write('stamp: $stamp')
          ..write(')'))
        .toString();
  }
}

class $HtDayDietTable extends HtDayDiet
    with TableInfo<$HtDayDietTable, HtDayDietData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HtDayDietTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
      'day', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dietMeta = const VerificationMeta('diet');
  @override
  late final GeneratedColumn<String> diet = GeneratedColumn<String>(
      'diet', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _calorieMeta =
      const VerificationMeta('calorie');
  @override
  late final GeneratedColumn<double> calorie = GeneratedColumn<double>(
      'calorie', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _proteinMeta =
      const VerificationMeta('protein');
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
      'protein', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, day, title, diet, calorie, protein];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ht_day_diet';
  @override
  VerificationContext validateIntegrity(Insertable<HtDayDietData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day')) {
      context.handle(
          _dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('diet')) {
      context.handle(
          _dietMeta, diet.isAcceptableOrUnknown(data['diet']!, _dietMeta));
    }
    if (data.containsKey('calorie')) {
      context.handle(_calorieMeta,
          calorie.isAcceptableOrUnknown(data['calorie']!, _calorieMeta));
    }
    if (data.containsKey('protein')) {
      context.handle(_proteinMeta,
          protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HtDayDietData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HtDayDietData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      day: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      diet: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}diet']),
      calorie: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}calorie']),
      protein: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}protein']),
    );
  }

  @override
  $HtDayDietTable createAlias(String alias) {
    return $HtDayDietTable(attachedDatabase, alias);
  }
}

class HtDayDietData extends DataClass implements Insertable<HtDayDietData> {
  final int id;
  final String day;
  final String title;
  final String? diet;
  final double? calorie;
  final double? protein;
  const HtDayDietData(
      {required this.id,
      required this.day,
      required this.title,
      this.diet,
      this.calorie,
      this.protein});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day'] = Variable<String>(day);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || diet != null) {
      map['diet'] = Variable<String>(diet);
    }
    if (!nullToAbsent || calorie != null) {
      map['calorie'] = Variable<double>(calorie);
    }
    if (!nullToAbsent || protein != null) {
      map['protein'] = Variable<double>(protein);
    }
    return map;
  }

  HtDayDietCompanion toCompanion(bool nullToAbsent) {
    return HtDayDietCompanion(
      id: Value(id),
      day: Value(day),
      title: Value(title),
      diet: diet == null && nullToAbsent ? const Value.absent() : Value(diet),
      calorie: calorie == null && nullToAbsent
          ? const Value.absent()
          : Value(calorie),
      protein: protein == null && nullToAbsent
          ? const Value.absent()
          : Value(protein),
    );
  }

  factory HtDayDietData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HtDayDietData(
      id: serializer.fromJson<int>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      title: serializer.fromJson<String>(json['title']),
      diet: serializer.fromJson<String?>(json['diet']),
      calorie: serializer.fromJson<double?>(json['calorie']),
      protein: serializer.fromJson<double?>(json['protein']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'day': serializer.toJson<String>(day),
      'title': serializer.toJson<String>(title),
      'diet': serializer.toJson<String?>(diet),
      'calorie': serializer.toJson<double?>(calorie),
      'protein': serializer.toJson<double?>(protein),
    };
  }

  HtDayDietData copyWith(
          {int? id,
          String? day,
          String? title,
          Value<String?> diet = const Value.absent(),
          Value<double?> calorie = const Value.absent(),
          Value<double?> protein = const Value.absent()}) =>
      HtDayDietData(
        id: id ?? this.id,
        day: day ?? this.day,
        title: title ?? this.title,
        diet: diet.present ? diet.value : this.diet,
        calorie: calorie.present ? calorie.value : this.calorie,
        protein: protein.present ? protein.value : this.protein,
      );
  HtDayDietData copyWithCompanion(HtDayDietCompanion data) {
    return HtDayDietData(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      title: data.title.present ? data.title.value : this.title,
      diet: data.diet.present ? data.diet.value : this.diet,
      calorie: data.calorie.present ? data.calorie.value : this.calorie,
      protein: data.protein.present ? data.protein.value : this.protein,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HtDayDietData(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('title: $title, ')
          ..write('diet: $diet, ')
          ..write('calorie: $calorie, ')
          ..write('protein: $protein')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, day, title, diet, calorie, protein);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HtDayDietData &&
          other.id == this.id &&
          other.day == this.day &&
          other.title == this.title &&
          other.diet == this.diet &&
          other.calorie == this.calorie &&
          other.protein == this.protein);
}

class HtDayDietCompanion extends UpdateCompanion<HtDayDietData> {
  final Value<int> id;
  final Value<String> day;
  final Value<String> title;
  final Value<String?> diet;
  final Value<double?> calorie;
  final Value<double?> protein;
  const HtDayDietCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.title = const Value.absent(),
    this.diet = const Value.absent(),
    this.calorie = const Value.absent(),
    this.protein = const Value.absent(),
  });
  HtDayDietCompanion.insert({
    this.id = const Value.absent(),
    required String day,
    required String title,
    this.diet = const Value.absent(),
    this.calorie = const Value.absent(),
    this.protein = const Value.absent(),
  })  : day = Value(day),
        title = Value(title);
  static Insertable<HtDayDietData> custom({
    Expression<int>? id,
    Expression<String>? day,
    Expression<String>? title,
    Expression<String>? diet,
    Expression<double>? calorie,
    Expression<double>? protein,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (title != null) 'title': title,
      if (diet != null) 'diet': diet,
      if (calorie != null) 'calorie': calorie,
      if (protein != null) 'protein': protein,
    });
  }

  HtDayDietCompanion copyWith(
      {Value<int>? id,
      Value<String>? day,
      Value<String>? title,
      Value<String?>? diet,
      Value<double?>? calorie,
      Value<double?>? protein}) {
    return HtDayDietCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      title: title ?? this.title,
      diet: diet ?? this.diet,
      calorie: calorie ?? this.calorie,
      protein: protein ?? this.protein,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (diet.present) {
      map['diet'] = Variable<String>(diet.value);
    }
    if (calorie.present) {
      map['calorie'] = Variable<double>(calorie.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HtDayDietCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('title: $title, ')
          ..write('diet: $diet, ')
          ..write('calorie: $calorie, ')
          ..write('protein: $protein')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HtDayBodyTable htDayBody = $HtDayBodyTable(this);
  late final $HtDayDietTable htDayDiet = $HtDayDietTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [htDayBody, htDayDiet];
}

typedef $$HtDayBodyTableCreateCompanionBuilder = HtDayBodyCompanion Function({
  Value<int> id,
  required String day,
  Value<double?> weight,
  Value<double?> muscle,
  Value<double?> fat,
  Value<String?> memo,
  Value<int> wkoutYn,
  Value<int> drunkYn,
  Value<String?> stamp,
});
typedef $$HtDayBodyTableUpdateCompanionBuilder = HtDayBodyCompanion Function({
  Value<int> id,
  Value<String> day,
  Value<double?> weight,
  Value<double?> muscle,
  Value<double?> fat,
  Value<String?> memo,
  Value<int> wkoutYn,
  Value<int> drunkYn,
  Value<String?> stamp,
});

class $$HtDayBodyTableFilterComposer
    extends Composer<_$AppDatabase, $HtDayBodyTable> {
  $$HtDayBodyTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get muscle => $composableBuilder(
      column: $table.muscle, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fat => $composableBuilder(
      column: $table.fat, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wkoutYn => $composableBuilder(
      column: $table.wkoutYn, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get drunkYn => $composableBuilder(
      column: $table.drunkYn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stamp => $composableBuilder(
      column: $table.stamp, builder: (column) => ColumnFilters(column));
}

class $$HtDayBodyTableOrderingComposer
    extends Composer<_$AppDatabase, $HtDayBodyTable> {
  $$HtDayBodyTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get muscle => $composableBuilder(
      column: $table.muscle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fat => $composableBuilder(
      column: $table.fat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wkoutYn => $composableBuilder(
      column: $table.wkoutYn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get drunkYn => $composableBuilder(
      column: $table.drunkYn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stamp => $composableBuilder(
      column: $table.stamp, builder: (column) => ColumnOrderings(column));
}

class $$HtDayBodyTableAnnotationComposer
    extends Composer<_$AppDatabase, $HtDayBodyTable> {
  $$HtDayBodyTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<double> get muscle =>
      $composableBuilder(column: $table.muscle, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<int> get wkoutYn =>
      $composableBuilder(column: $table.wkoutYn, builder: (column) => column);

  GeneratedColumn<int> get drunkYn =>
      $composableBuilder(column: $table.drunkYn, builder: (column) => column);

  GeneratedColumn<String> get stamp =>
      $composableBuilder(column: $table.stamp, builder: (column) => column);
}

class $$HtDayBodyTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HtDayBodyTable,
    HtDayBodyData,
    $$HtDayBodyTableFilterComposer,
    $$HtDayBodyTableOrderingComposer,
    $$HtDayBodyTableAnnotationComposer,
    $$HtDayBodyTableCreateCompanionBuilder,
    $$HtDayBodyTableUpdateCompanionBuilder,
    (
      HtDayBodyData,
      BaseReferences<_$AppDatabase, $HtDayBodyTable, HtDayBodyData>
    ),
    HtDayBodyData,
    PrefetchHooks Function()> {
  $$HtDayBodyTableTableManager(_$AppDatabase db, $HtDayBodyTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HtDayBodyTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HtDayBodyTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HtDayBodyTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> day = const Value.absent(),
            Value<double?> weight = const Value.absent(),
            Value<double?> muscle = const Value.absent(),
            Value<double?> fat = const Value.absent(),
            Value<String?> memo = const Value.absent(),
            Value<int> wkoutYn = const Value.absent(),
            Value<int> drunkYn = const Value.absent(),
            Value<String?> stamp = const Value.absent(),
          }) =>
              HtDayBodyCompanion(
            id: id,
            day: day,
            weight: weight,
            muscle: muscle,
            fat: fat,
            memo: memo,
            wkoutYn: wkoutYn,
            drunkYn: drunkYn,
            stamp: stamp,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String day,
            Value<double?> weight = const Value.absent(),
            Value<double?> muscle = const Value.absent(),
            Value<double?> fat = const Value.absent(),
            Value<String?> memo = const Value.absent(),
            Value<int> wkoutYn = const Value.absent(),
            Value<int> drunkYn = const Value.absent(),
            Value<String?> stamp = const Value.absent(),
          }) =>
              HtDayBodyCompanion.insert(
            id: id,
            day: day,
            weight: weight,
            muscle: muscle,
            fat: fat,
            memo: memo,
            wkoutYn: wkoutYn,
            drunkYn: drunkYn,
            stamp: stamp,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HtDayBodyTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HtDayBodyTable,
    HtDayBodyData,
    $$HtDayBodyTableFilterComposer,
    $$HtDayBodyTableOrderingComposer,
    $$HtDayBodyTableAnnotationComposer,
    $$HtDayBodyTableCreateCompanionBuilder,
    $$HtDayBodyTableUpdateCompanionBuilder,
    (
      HtDayBodyData,
      BaseReferences<_$AppDatabase, $HtDayBodyTable, HtDayBodyData>
    ),
    HtDayBodyData,
    PrefetchHooks Function()>;
typedef $$HtDayDietTableCreateCompanionBuilder = HtDayDietCompanion Function({
  Value<int> id,
  required String day,
  required String title,
  Value<String?> diet,
  Value<double?> calorie,
  Value<double?> protein,
});
typedef $$HtDayDietTableUpdateCompanionBuilder = HtDayDietCompanion Function({
  Value<int> id,
  Value<String> day,
  Value<String> title,
  Value<String?> diet,
  Value<double?> calorie,
  Value<double?> protein,
});

class $$HtDayDietTableFilterComposer
    extends Composer<_$AppDatabase, $HtDayDietTable> {
  $$HtDayDietTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get diet => $composableBuilder(
      column: $table.diet, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get calorie => $composableBuilder(
      column: $table.calorie, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get protein => $composableBuilder(
      column: $table.protein, builder: (column) => ColumnFilters(column));
}

class $$HtDayDietTableOrderingComposer
    extends Composer<_$AppDatabase, $HtDayDietTable> {
  $$HtDayDietTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get diet => $composableBuilder(
      column: $table.diet, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get calorie => $composableBuilder(
      column: $table.calorie, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get protein => $composableBuilder(
      column: $table.protein, builder: (column) => ColumnOrderings(column));
}

class $$HtDayDietTableAnnotationComposer
    extends Composer<_$AppDatabase, $HtDayDietTable> {
  $$HtDayDietTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get diet =>
      $composableBuilder(column: $table.diet, builder: (column) => column);

  GeneratedColumn<double> get calorie =>
      $composableBuilder(column: $table.calorie, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);
}

class $$HtDayDietTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HtDayDietTable,
    HtDayDietData,
    $$HtDayDietTableFilterComposer,
    $$HtDayDietTableOrderingComposer,
    $$HtDayDietTableAnnotationComposer,
    $$HtDayDietTableCreateCompanionBuilder,
    $$HtDayDietTableUpdateCompanionBuilder,
    (
      HtDayDietData,
      BaseReferences<_$AppDatabase, $HtDayDietTable, HtDayDietData>
    ),
    HtDayDietData,
    PrefetchHooks Function()> {
  $$HtDayDietTableTableManager(_$AppDatabase db, $HtDayDietTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HtDayDietTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HtDayDietTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HtDayDietTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> day = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> diet = const Value.absent(),
            Value<double?> calorie = const Value.absent(),
            Value<double?> protein = const Value.absent(),
          }) =>
              HtDayDietCompanion(
            id: id,
            day: day,
            title: title,
            diet: diet,
            calorie: calorie,
            protein: protein,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String day,
            required String title,
            Value<String?> diet = const Value.absent(),
            Value<double?> calorie = const Value.absent(),
            Value<double?> protein = const Value.absent(),
          }) =>
              HtDayDietCompanion.insert(
            id: id,
            day: day,
            title: title,
            diet: diet,
            calorie: calorie,
            protein: protein,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HtDayDietTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HtDayDietTable,
    HtDayDietData,
    $$HtDayDietTableFilterComposer,
    $$HtDayDietTableOrderingComposer,
    $$HtDayDietTableAnnotationComposer,
    $$HtDayDietTableCreateCompanionBuilder,
    $$HtDayDietTableUpdateCompanionBuilder,
    (
      HtDayDietData,
      BaseReferences<_$AppDatabase, $HtDayDietTable, HtDayDietData>
    ),
    HtDayDietData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HtDayBodyTableTableManager get htDayBody =>
      $$HtDayBodyTableTableManager(_db, _db.htDayBody);
  $$HtDayDietTableTableManager get htDayDiet =>
      $$HtDayDietTableTableManager(_db, _db.htDayDiet);
}
