// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_profile.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetLocalProfileCollection on Isar {
  IsarCollection<LocalProfile> get localProfiles => this.collection();
}

const LocalProfileSchema = CollectionSchema(
  name: r'LocalProfile',
  id: -3481655517967548928,
  properties: {
    r'carryOverBalance': PropertySchema(
      id: 0,
      name: r'carryOverBalance',
      type: IsarType.long,
    ),
    r'fixedSalary': PropertySchema(
      id: 1,
      name: r'fixedSalary',
      type: IsarType.long,
    ),
    r'incomeFrequency': PropertySchema(
      id: 2,
      name: r'incomeFrequency',
      type: IsarType.byte,
      enumMap: _LocalProfileincomeFrequencyEnumValueMap,
    ),
    r'incomeIntervalType': PropertySchema(
      id: 3,
      name: r'incomeIntervalType',
      type: IsarType.int,
      enumMap: _LocalProfileincomeIntervalTypeEnumValueMap,
    ),
    r'language': PropertySchema(
      id: 4,
      name: r'language',
      type: IsarType.byte,
      enumMap: _LocalProfilelanguageEnumValueMap,
    ),
    r'lastAccrualDate': PropertySchema(
      id: 5,
      name: r'lastAccrualDate',
      type: IsarType.dateTime,
    ),
    r'lastRolloverDate': PropertySchema(
      id: 6,
      name: r'lastRolloverDate',
      type: IsarType.dateTime,
    ),
    r'mandatoryExpenses': PropertySchema(
      id: 7,
      name: r'mandatoryExpenses',
      type: IsarType.objectList,

      target: r'MandatoryExpenseItem',
    ),
    r'nextPaydayDate': PropertySchema(
      id: 8,
      name: r'nextPaydayDate',
      type: IsarType.dateTime,
    ),
    r'notifDailyReminderEnabled': PropertySchema(
      id: 9,
      name: r'notifDailyReminderEnabled',
      type: IsarType.bool,
    ),
    r'notifDailyReminderTime': PropertySchema(
      id: 10,
      name: r'notifDailyReminderTime',
      type: IsarType.long,
    ),
    r'notifGoalMilestoneEnabled': PropertySchema(
      id: 11,
      name: r'notifGoalMilestoneEnabled',
      type: IsarType.bool,
    ),
    r'notifLimitAlertEnabled': PropertySchema(
      id: 12,
      name: r'notifLimitAlertEnabled',
      type: IsarType.bool,
    ),
    r'notifPayCycleEnabled': PropertySchema(
      id: 13,
      name: r'notifPayCycleEnabled',
      type: IsarType.bool,
    ),
    r'onboardingComplete': PropertySchema(
      id: 14,
      name: r'onboardingComplete',
      type: IsarType.bool,
    ),
    r'theme': PropertySchema(
      id: 15,
      name: r'theme',
      type: IsarType.byte,
      enumMap: _LocalProfilethemeEnumValueMap,
    ),
  },

  estimateSize: _localProfileEstimateSize,
  serialize: _localProfileSerialize,
  deserialize: _localProfileDeserialize,
  deserializeProp: _localProfileDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'MandatoryExpenseItem': MandatoryExpenseItemSchema},

  getId: _localProfileGetId,
  getLinks: _localProfileGetLinks,
  attach: _localProfileAttach,
  version: '3.4.1',
);

int _localProfileEstimateSize(
  LocalProfile object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.mandatoryExpenses.length * 3;
  {
    final offsets = allOffsets[MandatoryExpenseItem]!;
    for (var i = 0; i < object.mandatoryExpenses.length; i++) {
      final value = object.mandatoryExpenses[i];
      bytesCount += MandatoryExpenseItemSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  return bytesCount;
}

void _localProfileSerialize(
  LocalProfile object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.carryOverBalance);
  writer.writeLong(offsets[1], object.fixedSalary);
  writer.writeByte(offsets[2], object.incomeFrequency.index);
  writer.writeInt(offsets[3], object.incomeIntervalType?.index);
  writer.writeByte(offsets[4], object.language.index);
  writer.writeDateTime(offsets[5], object.lastAccrualDate);
  writer.writeDateTime(offsets[6], object.lastRolloverDate);
  writer.writeObjectList<MandatoryExpenseItem>(
    offsets[7],
    allOffsets,
    MandatoryExpenseItemSchema.serialize,
    object.mandatoryExpenses,
  );
  writer.writeDateTime(offsets[8], object.nextPaydayDate);
  writer.writeBool(offsets[9], object.notifDailyReminderEnabled);
  writer.writeLong(offsets[10], object.notifDailyReminderTime);
  writer.writeBool(offsets[11], object.notifGoalMilestoneEnabled);
  writer.writeBool(offsets[12], object.notifLimitAlertEnabled);
  writer.writeBool(offsets[13], object.notifPayCycleEnabled);
  writer.writeBool(offsets[14], object.onboardingComplete);
  writer.writeByte(offsets[15], object.theme.index);
}

LocalProfile _localProfileDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocalProfile();
  object.carryOverBalance = reader.readLong(offsets[0]);
  object.fixedSalary = reader.readLong(offsets[1]);
  object.id = id;
  object.incomeFrequency =
      _LocalProfileincomeFrequencyValueEnumMap[reader.readByteOrNull(
        offsets[2],
      )] ??
      IncomeFrequency.periodic;
  object.incomeIntervalType =
      _LocalProfileincomeIntervalTypeValueEnumMap[reader.readIntOrNull(
        offsets[3],
      )];
  object.language =
      _LocalProfilelanguageValueEnumMap[reader.readByteOrNull(offsets[4])] ??
      AppLanguage.id;
  object.lastAccrualDate = reader.readDateTimeOrNull(offsets[5]);
  object.lastRolloverDate = reader.readDateTimeOrNull(offsets[6]);
  object.mandatoryExpenses =
      reader.readObjectList<MandatoryExpenseItem>(
        offsets[7],
        MandatoryExpenseItemSchema.deserialize,
        allOffsets,
        MandatoryExpenseItem(),
      ) ??
      [];
  object.nextPaydayDate = reader.readDateTimeOrNull(offsets[8]);
  object.notifDailyReminderEnabled = reader.readBool(offsets[9]);
  object.notifDailyReminderTime = reader.readLong(offsets[10]);
  object.notifGoalMilestoneEnabled = reader.readBool(offsets[11]);
  object.notifLimitAlertEnabled = reader.readBool(offsets[12]);
  object.notifPayCycleEnabled = reader.readBool(offsets[13]);
  object.onboardingComplete = reader.readBool(offsets[14]);
  object.theme =
      _LocalProfilethemeValueEnumMap[reader.readByteOrNull(offsets[15])] ??
      AppThemeSetting.dark;
  return object;
}

P _localProfileDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (_LocalProfileincomeFrequencyValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              IncomeFrequency.periodic)
          as P;
    case 3:
      return (_LocalProfileincomeIntervalTypeValueEnumMap[reader.readIntOrNull(
            offset,
          )])
          as P;
    case 4:
      return (_LocalProfilelanguageValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              AppLanguage.id)
          as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readObjectList<MandatoryExpenseItem>(
                offset,
                MandatoryExpenseItemSchema.deserialize,
                allOffsets,
                MandatoryExpenseItem(),
              ) ??
              [])
          as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (_LocalProfilethemeValueEnumMap[reader.readByteOrNull(offset)] ??
              AppThemeSetting.dark)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _LocalProfileincomeFrequencyEnumValueMap = {'periodic': 0, 'daily': 1};
const _LocalProfileincomeFrequencyValueEnumMap = {
  0: IncomeFrequency.periodic,
  1: IncomeFrequency.daily,
};
const _LocalProfileincomeIntervalTypeEnumValueMap = {
  'weekly': 0,
  'biweekly': 1,
  'monthly': 2,
  'custom': 3,
};
const _LocalProfileincomeIntervalTypeValueEnumMap = {
  0: IncomeIntervalType.weekly,
  1: IncomeIntervalType.biweekly,
  2: IncomeIntervalType.monthly,
  3: IncomeIntervalType.custom,
};
const _LocalProfilelanguageEnumValueMap = {'id': 0, 'en': 1};
const _LocalProfilelanguageValueEnumMap = {
  0: AppLanguage.id,
  1: AppLanguage.en,
};
const _LocalProfilethemeEnumValueMap = {'dark': 0, 'light': 1};
const _LocalProfilethemeValueEnumMap = {
  0: AppThemeSetting.dark,
  1: AppThemeSetting.light,
};

Id _localProfileGetId(LocalProfile object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _localProfileGetLinks(LocalProfile object) {
  return [];
}

void _localProfileAttach(
  IsarCollection<dynamic> col,
  Id id,
  LocalProfile object,
) {
  object.id = id;
}

extension LocalProfileQueryWhereSort
    on QueryBuilder<LocalProfile, LocalProfile, QWhere> {
  QueryBuilder<LocalProfile, LocalProfile, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LocalProfileQueryWhere
    on QueryBuilder<LocalProfile, LocalProfile, QWhereClause> {
  QueryBuilder<LocalProfile, LocalProfile, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension LocalProfileQueryFilter
    on QueryBuilder<LocalProfile, LocalProfile, QFilterCondition> {
  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  carryOverBalanceEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'carryOverBalance', value: value),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  carryOverBalanceGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'carryOverBalance',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  carryOverBalanceLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'carryOverBalance',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  carryOverBalanceBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'carryOverBalance',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  fixedSalaryEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fixedSalary', value: value),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  fixedSalaryGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fixedSalary',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  fixedSalaryLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fixedSalary',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  fixedSalaryBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fixedSalary',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  incomeFrequencyEqualTo(IncomeFrequency value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'incomeFrequency', value: value),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  incomeFrequencyGreaterThan(IncomeFrequency value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'incomeFrequency',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  incomeFrequencyLessThan(IncomeFrequency value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'incomeFrequency',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  incomeFrequencyBetween(
    IncomeFrequency lower,
    IncomeFrequency upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'incomeFrequency',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  incomeIntervalTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'incomeIntervalType'),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  incomeIntervalTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'incomeIntervalType'),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  incomeIntervalTypeEqualTo(IncomeIntervalType? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'incomeIntervalType', value: value),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  incomeIntervalTypeGreaterThan(
    IncomeIntervalType? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'incomeIntervalType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  incomeIntervalTypeLessThan(
    IncomeIntervalType? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'incomeIntervalType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  incomeIntervalTypeBetween(
    IncomeIntervalType? lower,
    IncomeIntervalType? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'incomeIntervalType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  languageEqualTo(AppLanguage value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'language', value: value),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  languageGreaterThan(AppLanguage value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'language',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  languageLessThan(AppLanguage value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'language',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  languageBetween(
    AppLanguage lower,
    AppLanguage upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'language',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  lastAccrualDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastAccrualDate'),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  lastAccrualDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastAccrualDate'),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  lastAccrualDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastAccrualDate', value: value),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  lastAccrualDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastAccrualDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  lastAccrualDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastAccrualDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  lastAccrualDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastAccrualDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  lastRolloverDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastRolloverDate'),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  lastRolloverDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastRolloverDate'),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  lastRolloverDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastRolloverDate', value: value),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  lastRolloverDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastRolloverDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  lastRolloverDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastRolloverDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  lastRolloverDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastRolloverDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  mandatoryExpensesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'mandatoryExpenses', length, true, length, true);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  mandatoryExpensesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'mandatoryExpenses', 0, true, 0, true);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  mandatoryExpensesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'mandatoryExpenses', 0, false, 999999, true);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  mandatoryExpensesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'mandatoryExpenses', 0, true, length, include);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  mandatoryExpensesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mandatoryExpenses',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  mandatoryExpensesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mandatoryExpenses',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  nextPaydayDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'nextPaydayDate'),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  nextPaydayDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'nextPaydayDate'),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  nextPaydayDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nextPaydayDate', value: value),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  nextPaydayDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nextPaydayDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  nextPaydayDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nextPaydayDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  nextPaydayDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nextPaydayDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  notifDailyReminderEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notifDailyReminderEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  notifDailyReminderTimeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notifDailyReminderTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  notifDailyReminderTimeGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'notifDailyReminderTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  notifDailyReminderTimeLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'notifDailyReminderTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  notifDailyReminderTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'notifDailyReminderTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  notifGoalMilestoneEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notifGoalMilestoneEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  notifLimitAlertEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notifLimitAlertEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  notifPayCycleEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notifPayCycleEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  onboardingCompleteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'onboardingComplete', value: value),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition> themeEqualTo(
    AppThemeSetting value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'theme', value: value),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  themeGreaterThan(AppThemeSetting value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'theme',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition> themeLessThan(
    AppThemeSetting value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'theme',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition> themeBetween(
    AppThemeSetting lower,
    AppThemeSetting upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'theme',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension LocalProfileQueryObject
    on QueryBuilder<LocalProfile, LocalProfile, QFilterCondition> {
  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  mandatoryExpensesElement(FilterQuery<MandatoryExpenseItem> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'mandatoryExpenses');
    });
  }
}

extension LocalProfileQueryLinks
    on QueryBuilder<LocalProfile, LocalProfile, QFilterCondition> {}

extension LocalProfileQuerySortBy
    on QueryBuilder<LocalProfile, LocalProfile, QSortBy> {
  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByCarryOverBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carryOverBalance', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByCarryOverBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carryOverBalance', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> sortByFixedSalary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedSalary', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByFixedSalaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedSalary', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByIncomeFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incomeFrequency', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByIncomeFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incomeFrequency', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByIncomeIntervalType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incomeIntervalType', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByIncomeIntervalTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incomeIntervalType', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> sortByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> sortByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByLastAccrualDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccrualDate', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByLastAccrualDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccrualDate', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByLastRolloverDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRolloverDate', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByLastRolloverDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRolloverDate', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByNextPaydayDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextPaydayDate', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByNextPaydayDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextPaydayDate', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByNotifDailyReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifDailyReminderEnabled', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByNotifDailyReminderEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifDailyReminderEnabled', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByNotifDailyReminderTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifDailyReminderTime', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByNotifDailyReminderTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifDailyReminderTime', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByNotifGoalMilestoneEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifGoalMilestoneEnabled', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByNotifGoalMilestoneEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifGoalMilestoneEnabled', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByNotifLimitAlertEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifLimitAlertEnabled', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByNotifLimitAlertEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifLimitAlertEnabled', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByNotifPayCycleEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifPayCycleEnabled', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByNotifPayCycleEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifPayCycleEnabled', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByOnboardingComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingComplete', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByOnboardingCompleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingComplete', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> sortByTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> sortByThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.desc);
    });
  }
}

extension LocalProfileQuerySortThenBy
    on QueryBuilder<LocalProfile, LocalProfile, QSortThenBy> {
  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByCarryOverBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carryOverBalance', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByCarryOverBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carryOverBalance', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenByFixedSalary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedSalary', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByFixedSalaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedSalary', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByIncomeFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incomeFrequency', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByIncomeFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incomeFrequency', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByIncomeIntervalType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incomeIntervalType', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByIncomeIntervalTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incomeIntervalType', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByLastAccrualDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccrualDate', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByLastAccrualDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAccrualDate', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByLastRolloverDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRolloverDate', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByLastRolloverDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRolloverDate', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByNextPaydayDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextPaydayDate', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByNextPaydayDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextPaydayDate', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByNotifDailyReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifDailyReminderEnabled', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByNotifDailyReminderEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifDailyReminderEnabled', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByNotifDailyReminderTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifDailyReminderTime', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByNotifDailyReminderTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifDailyReminderTime', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByNotifGoalMilestoneEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifGoalMilestoneEnabled', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByNotifGoalMilestoneEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifGoalMilestoneEnabled', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByNotifLimitAlertEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifLimitAlertEnabled', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByNotifLimitAlertEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifLimitAlertEnabled', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByNotifPayCycleEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifPayCycleEnabled', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByNotifPayCycleEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notifPayCycleEnabled', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByOnboardingComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingComplete', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByOnboardingCompleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingComplete', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenByTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenByThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.desc);
    });
  }
}

extension LocalProfileQueryWhereDistinct
    on QueryBuilder<LocalProfile, LocalProfile, QDistinct> {
  QueryBuilder<LocalProfile, LocalProfile, QDistinct>
  distinctByCarryOverBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'carryOverBalance');
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct> distinctByFixedSalary() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fixedSalary');
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct>
  distinctByIncomeFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'incomeFrequency');
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct>
  distinctByIncomeIntervalType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'incomeIntervalType');
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct> distinctByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language');
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct>
  distinctByLastAccrualDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastAccrualDate');
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct>
  distinctByLastRolloverDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastRolloverDate');
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct>
  distinctByNextPaydayDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextPaydayDate');
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct>
  distinctByNotifDailyReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notifDailyReminderEnabled');
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct>
  distinctByNotifDailyReminderTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notifDailyReminderTime');
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct>
  distinctByNotifGoalMilestoneEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notifGoalMilestoneEnabled');
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct>
  distinctByNotifLimitAlertEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notifLimitAlertEnabled');
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct>
  distinctByNotifPayCycleEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notifPayCycleEnabled');
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct>
  distinctByOnboardingComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'onboardingComplete');
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct> distinctByTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'theme');
    });
  }
}

extension LocalProfileQueryProperty
    on QueryBuilder<LocalProfile, LocalProfile, QQueryProperty> {
  QueryBuilder<LocalProfile, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocalProfile, int, QQueryOperations> carryOverBalanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'carryOverBalance');
    });
  }

  QueryBuilder<LocalProfile, int, QQueryOperations> fixedSalaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fixedSalary');
    });
  }

  QueryBuilder<LocalProfile, IncomeFrequency, QQueryOperations>
  incomeFrequencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'incomeFrequency');
    });
  }

  QueryBuilder<LocalProfile, IncomeIntervalType?, QQueryOperations>
  incomeIntervalTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'incomeIntervalType');
    });
  }

  QueryBuilder<LocalProfile, AppLanguage, QQueryOperations> languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
    });
  }

  QueryBuilder<LocalProfile, DateTime?, QQueryOperations>
  lastAccrualDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastAccrualDate');
    });
  }

  QueryBuilder<LocalProfile, DateTime?, QQueryOperations>
  lastRolloverDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastRolloverDate');
    });
  }

  QueryBuilder<LocalProfile, List<MandatoryExpenseItem>, QQueryOperations>
  mandatoryExpensesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mandatoryExpenses');
    });
  }

  QueryBuilder<LocalProfile, DateTime?, QQueryOperations>
  nextPaydayDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextPaydayDate');
    });
  }

  QueryBuilder<LocalProfile, bool, QQueryOperations>
  notifDailyReminderEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notifDailyReminderEnabled');
    });
  }

  QueryBuilder<LocalProfile, int, QQueryOperations>
  notifDailyReminderTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notifDailyReminderTime');
    });
  }

  QueryBuilder<LocalProfile, bool, QQueryOperations>
  notifGoalMilestoneEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notifGoalMilestoneEnabled');
    });
  }

  QueryBuilder<LocalProfile, bool, QQueryOperations>
  notifLimitAlertEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notifLimitAlertEnabled');
    });
  }

  QueryBuilder<LocalProfile, bool, QQueryOperations>
  notifPayCycleEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notifPayCycleEnabled');
    });
  }

  QueryBuilder<LocalProfile, bool, QQueryOperations>
  onboardingCompleteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'onboardingComplete');
    });
  }

  QueryBuilder<LocalProfile, AppThemeSetting, QQueryOperations>
  themeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'theme');
    });
  }
}
