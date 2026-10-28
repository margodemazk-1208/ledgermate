// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_goal.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetFinancialGoalCollection on Isar {
  IsarCollection<FinancialGoal> get financialGoals => this.collection();
}

const FinancialGoalSchema = CollectionSchema(
  name: r'FinancialGoal',
  id: -4634083842245294579,
  properties: {
    r'currentAmount': PropertySchema(
      id: 0,
      name: r'currentAmount',
      type: IsarType.long,
    ),
    r'goalName': PropertySchema(
      id: 1,
      name: r'goalName',
      type: IsarType.string,
    ),
    r'manualDailyAllocation': PropertySchema(
      id: 2,
      name: r'manualDailyAllocation',
      type: IsarType.long,
    ),
    r'targetAmount': PropertySchema(
      id: 3,
      name: r'targetAmount',
      type: IsarType.long,
    ),
    r'targetDate': PropertySchema(
      id: 4,
      name: r'targetDate',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _financialGoalEstimateSize,
  serialize: _financialGoalSerialize,
  deserialize: _financialGoalDeserialize,
  deserializeProp: _financialGoalDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _financialGoalGetId,
  getLinks: _financialGoalGetLinks,
  attach: _financialGoalAttach,
  version: '3.4.1',
);

int _financialGoalEstimateSize(
  FinancialGoal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.goalName.length * 3;
  return bytesCount;
}

void _financialGoalSerialize(
  FinancialGoal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.currentAmount);
  writer.writeString(offsets[1], object.goalName);
  writer.writeLong(offsets[2], object.manualDailyAllocation);
  writer.writeLong(offsets[3], object.targetAmount);
  writer.writeDateTime(offsets[4], object.targetDate);
}

FinancialGoal _financialGoalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FinancialGoal();
  object.currentAmount = reader.readLong(offsets[0]);
  object.goalName = reader.readString(offsets[1]);
  object.id = id;
  object.manualDailyAllocation = reader.readLongOrNull(offsets[2]);
  object.targetAmount = reader.readLong(offsets[3]);
  object.targetDate = reader.readDateTime(offsets[4]);
  return object;
}

P _financialGoalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _financialGoalGetId(FinancialGoal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _financialGoalGetLinks(FinancialGoal object) {
  return [];
}

void _financialGoalAttach(
  IsarCollection<dynamic> col,
  Id id,
  FinancialGoal object,
) {
  object.id = id;
}

extension FinancialGoalQueryWhereSort
    on QueryBuilder<FinancialGoal, FinancialGoal, QWhere> {
  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FinancialGoalQueryWhere
    on QueryBuilder<FinancialGoal, FinancialGoal, QWhereClause> {
  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterWhereClause> idBetween(
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

extension FinancialGoalQueryFilter
    on QueryBuilder<FinancialGoal, FinancialGoal, QFilterCondition> {
  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  currentAmountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currentAmount', value: value),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  currentAmountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentAmount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  currentAmountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentAmount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  currentAmountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentAmount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  goalNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'goalName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  goalNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'goalName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  goalNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'goalName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  goalNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'goalName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  goalNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'goalName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  goalNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'goalName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  goalNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'goalName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  goalNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'goalName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  goalNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'goalName', value: ''),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  goalNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'goalName', value: ''),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition> idBetween(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  manualDailyAllocationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'manualDailyAllocation'),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  manualDailyAllocationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'manualDailyAllocation'),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  manualDailyAllocationEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'manualDailyAllocation',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  manualDailyAllocationGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'manualDailyAllocation',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  manualDailyAllocationLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'manualDailyAllocation',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  manualDailyAllocationBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'manualDailyAllocation',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  targetAmountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'targetAmount', value: value),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  targetAmountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'targetAmount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  targetAmountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'targetAmount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  targetAmountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'targetAmount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  targetDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'targetDate', value: value),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  targetDateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'targetDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  targetDateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'targetDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
  targetDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'targetDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension FinancialGoalQueryObject
    on QueryBuilder<FinancialGoal, FinancialGoal, QFilterCondition> {}

extension FinancialGoalQueryLinks
    on QueryBuilder<FinancialGoal, FinancialGoal, QFilterCondition> {}

extension FinancialGoalQuerySortBy
    on QueryBuilder<FinancialGoal, FinancialGoal, QSortBy> {
  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
  sortByCurrentAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentAmount', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
  sortByCurrentAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentAmount', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByGoalName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalName', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
  sortByGoalNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalName', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
  sortByManualDailyAllocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manualDailyAllocation', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
  sortByManualDailyAllocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manualDailyAllocation', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
  sortByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
  sortByTargetAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
  sortByTargetDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.desc);
    });
  }
}

extension FinancialGoalQuerySortThenBy
    on QueryBuilder<FinancialGoal, FinancialGoal, QSortThenBy> {
  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
  thenByCurrentAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentAmount', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
  thenByCurrentAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentAmount', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByGoalName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalName', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
  thenByGoalNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalName', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
  thenByManualDailyAllocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manualDailyAllocation', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
  thenByManualDailyAllocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manualDailyAllocation', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
  thenByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
  thenByTargetAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetAmount', Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.asc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
  thenByTargetDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.desc);
    });
  }
}

extension FinancialGoalQueryWhereDistinct
    on QueryBuilder<FinancialGoal, FinancialGoal, QDistinct> {
  QueryBuilder<FinancialGoal, FinancialGoal, QDistinct>
  distinctByCurrentAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentAmount');
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QDistinct> distinctByGoalName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goalName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QDistinct>
  distinctByManualDailyAllocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'manualDailyAllocation');
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QDistinct>
  distinctByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetAmount');
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QDistinct> distinctByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetDate');
    });
  }
}

extension FinancialGoalQueryProperty
    on QueryBuilder<FinancialGoal, FinancialGoal, QQueryProperty> {
  QueryBuilder<FinancialGoal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FinancialGoal, int, QQueryOperations> currentAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentAmount');
    });
  }

  QueryBuilder<FinancialGoal, String, QQueryOperations> goalNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goalName');
    });
  }

  QueryBuilder<FinancialGoal, int?, QQueryOperations>
  manualDailyAllocationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'manualDailyAllocation');
    });
  }

  QueryBuilder<FinancialGoal, int, QQueryOperations> targetAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetAmount');
    });
  }

  QueryBuilder<FinancialGoal, DateTime, QQueryOperations> targetDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetDate');
    });
  }
}
