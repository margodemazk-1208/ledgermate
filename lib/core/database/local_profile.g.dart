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
    r'language': PropertySchema(
      id: 3,
      name: r'language',
      type: IsarType.byte,
      enumMap: _LocalProfilelanguageEnumValueMap,
    ),
    r'nextPaydayDate': PropertySchema(
      id: 4,
      name: r'nextPaydayDate',
      type: IsarType.dateTime,
    ),
    r'notifDailyReminderEnabled': PropertySchema(
      id: 5,
      name: r'notifDailyReminderEnabled',
      type: IsarType.bool,
    ),
    r'notifDailyReminderTime': PropertySchema(
      id: 6,
      name: r'notifDailyReminderTime',
      type: IsarType.long,
    ),
    r'notifGoalMilestoneEnabled': PropertySchema(
      id: 7,
      name: r'notifGoalMilestoneEnabled',
      type: IsarType.bool,
    ),
    r'notifLimitAlertEnabled': PropertySchema(
      id: 8,
      name: r'notifLimitAlertEnabled',
      type: IsarType.bool,
    ),
    r'notifPayCycleEnabled': PropertySchema(
      id: 9,
      name: r'notifPayCycleEnabled',
      type: IsarType.bool,
    ),
    r'theme': PropertySchema(
      id: 10,
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
  embeddedSchemas: {},

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
  writer.writeByte(offsets[3], object.language.index);
  writer.writeDateTime(offsets[4], object.nextPaydayDate);
  writer.writeBool(offsets[5], object.notifDailyReminderEnabled);
  writer.writeLong(offsets[6], object.notifDailyReminderTime);
  writer.writeBool(offsets[7], object.notifGoalMilestoneEnabled);
  writer.writeBool(offsets[8], object.notifLimitAlertEnabled);
  writer.writeBool(offsets[9], object.notifPayCycleEnabled);
  writer.writeByte(offsets[10], object.theme.index);
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
  object.language =
      _LocalProfilelanguageValueEnumMap[reader.readByteOrNull(offsets[3])] ??
      AppLanguage.id;
  object.nextPaydayDate = reader.readDateTimeOrNull(offsets[4]);
  object.notifDailyReminderEnabled = reader.readBool(offsets[5]);
  object.notifDailyReminderTime = reader.readLong(offsets[6]);
  object.notifGoalMilestoneEnabled = reader.readBool(offsets[7]);
  object.notifLimitAlertEnabled = reader.readBool(offsets[8]);
  object.notifPayCycleEnabled = reader.readBool(offsets[9]);
  object.theme =
      _LocalProfilethemeValueEnumMap[reader.readByteOrNull(offsets[10])] ??
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
      return (_LocalProfilelanguageValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              AppLanguage.id)
          as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
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
    on QueryBuilder<LocalProfile, LocalProfile, QFilterCondition> {}

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

  QueryBuilder<LocalProfile, LocalProfile, QDistinct> distinctByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language');
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

  QueryBuilder<LocalProfile, AppLanguage, QQueryOperations> languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
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

  QueryBuilder<LocalProfile, AppThemeSetting, QQueryOperations>
  themeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'theme');
    });
  }
}
