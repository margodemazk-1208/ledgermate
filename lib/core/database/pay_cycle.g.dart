// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pay_cycle.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetPayCycleCollection on Isar {
  IsarCollection<PayCycle> get payCycles => this.collection();
}

const PayCycleSchema = CollectionSchema(
  name: r'PayCycle',
  id: -2876134144525020125,
  properties: {
    r'fixedSalary': PropertySchema(
      id: 0,
      name: r'fixedSalary',
      type: IsarType.long,
    ),
    r'mandatoryExpenses': PropertySchema(
      id: 1,
      name: r'mandatoryExpenses',
      type: IsarType.objectList,

      target: r'MandatoryExpenseItem',
    ),
    r'paydayDate': PropertySchema(
      id: 2,
      name: r'paydayDate',
      type: IsarType.dateTime,
    ),
    r'startDate': PropertySchema(
      id: 3,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
    r'variableIncomeTotal': PropertySchema(
      id: 4,
      name: r'variableIncomeTotal',
      type: IsarType.long,
    ),
  },

  estimateSize: _payCycleEstimateSize,
  serialize: _payCycleSerialize,
  deserialize: _payCycleDeserialize,
  deserializeProp: _payCycleDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'MandatoryExpenseItem': MandatoryExpenseItemSchema},

  getId: _payCycleGetId,
  getLinks: _payCycleGetLinks,
  attach: _payCycleAttach,
  version: '3.4.1',
);

int _payCycleEstimateSize(
  PayCycle object,
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

void _payCycleSerialize(
  PayCycle object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.fixedSalary);
  writer.writeObjectList<MandatoryExpenseItem>(
    offsets[1],
    allOffsets,
    MandatoryExpenseItemSchema.serialize,
    object.mandatoryExpenses,
  );
  writer.writeDateTime(offsets[2], object.paydayDate);
  writer.writeDateTime(offsets[3], object.startDate);
  writer.writeLong(offsets[4], object.variableIncomeTotal);
}

PayCycle _payCycleDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PayCycle();
  object.fixedSalary = reader.readLong(offsets[0]);
  object.id = id;
  object.mandatoryExpenses =
      reader.readObjectList<MandatoryExpenseItem>(
        offsets[1],
        MandatoryExpenseItemSchema.deserialize,
        allOffsets,
        MandatoryExpenseItem(),
      ) ??
      [];
  object.paydayDate = reader.readDateTime(offsets[2]);
  object.startDate = reader.readDateTime(offsets[3]);
  object.variableIncomeTotal = reader.readLong(offsets[4]);
  return object;
}

P _payCycleDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readObjectList<MandatoryExpenseItem>(
                offset,
                MandatoryExpenseItemSchema.deserialize,
                allOffsets,
                MandatoryExpenseItem(),
              ) ??
              [])
          as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _payCycleGetId(PayCycle object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _payCycleGetLinks(PayCycle object) {
  return [];
}

void _payCycleAttach(IsarCollection<dynamic> col, Id id, PayCycle object) {
  object.id = id;
}

extension PayCycleQueryWhereSort on QueryBuilder<PayCycle, PayCycle, QWhere> {
  QueryBuilder<PayCycle, PayCycle, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PayCycleQueryWhere on QueryBuilder<PayCycle, PayCycle, QWhereClause> {
  QueryBuilder<PayCycle, PayCycle, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PayCycle, PayCycle, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterWhereClause> idBetween(
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

extension PayCycleQueryFilter
    on QueryBuilder<PayCycle, PayCycle, QFilterCondition> {
  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition> fixedSalaryEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fixedSalary', value: value),
      );
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition>
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

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition> fixedSalaryLessThan(
    int value, {
    bool include = false,
  }) {
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

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition> fixedSalaryBetween(
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

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition>
  mandatoryExpensesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'mandatoryExpenses', length, true, length, true);
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition>
  mandatoryExpensesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'mandatoryExpenses', 0, true, 0, true);
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition>
  mandatoryExpensesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'mandatoryExpenses', 0, false, 999999, true);
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition>
  mandatoryExpensesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'mandatoryExpenses', 0, true, length, include);
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition>
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

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition>
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

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition> paydayDateEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'paydayDate', value: value),
      );
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition> paydayDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'paydayDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition> paydayDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'paydayDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition> paydayDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'paydayDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition> startDateEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startDate', value: value),
      );
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition> startDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition> startDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition> startDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition>
  variableIncomeTotalEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'variableIncomeTotal', value: value),
      );
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition>
  variableIncomeTotalGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'variableIncomeTotal',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition>
  variableIncomeTotalLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'variableIncomeTotal',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition>
  variableIncomeTotalBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'variableIncomeTotal',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PayCycleQueryObject
    on QueryBuilder<PayCycle, PayCycle, QFilterCondition> {
  QueryBuilder<PayCycle, PayCycle, QAfterFilterCondition>
  mandatoryExpensesElement(FilterQuery<MandatoryExpenseItem> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'mandatoryExpenses');
    });
  }
}

extension PayCycleQueryLinks
    on QueryBuilder<PayCycle, PayCycle, QFilterCondition> {}

extension PayCycleQuerySortBy on QueryBuilder<PayCycle, PayCycle, QSortBy> {
  QueryBuilder<PayCycle, PayCycle, QAfterSortBy> sortByFixedSalary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedSalary', Sort.asc);
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterSortBy> sortByFixedSalaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedSalary', Sort.desc);
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterSortBy> sortByPaydayDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paydayDate', Sort.asc);
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterSortBy> sortByPaydayDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paydayDate', Sort.desc);
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterSortBy> sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterSortBy> sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterSortBy> sortByVariableIncomeTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variableIncomeTotal', Sort.asc);
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterSortBy>
  sortByVariableIncomeTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variableIncomeTotal', Sort.desc);
    });
  }
}

extension PayCycleQuerySortThenBy
    on QueryBuilder<PayCycle, PayCycle, QSortThenBy> {
  QueryBuilder<PayCycle, PayCycle, QAfterSortBy> thenByFixedSalary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedSalary', Sort.asc);
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterSortBy> thenByFixedSalaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fixedSalary', Sort.desc);
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterSortBy> thenByPaydayDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paydayDate', Sort.asc);
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterSortBy> thenByPaydayDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paydayDate', Sort.desc);
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterSortBy> thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterSortBy> thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterSortBy> thenByVariableIncomeTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variableIncomeTotal', Sort.asc);
    });
  }

  QueryBuilder<PayCycle, PayCycle, QAfterSortBy>
  thenByVariableIncomeTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variableIncomeTotal', Sort.desc);
    });
  }
}

extension PayCycleQueryWhereDistinct
    on QueryBuilder<PayCycle, PayCycle, QDistinct> {
  QueryBuilder<PayCycle, PayCycle, QDistinct> distinctByFixedSalary() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fixedSalary');
    });
  }

  QueryBuilder<PayCycle, PayCycle, QDistinct> distinctByPaydayDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paydayDate');
    });
  }

  QueryBuilder<PayCycle, PayCycle, QDistinct> distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }

  QueryBuilder<PayCycle, PayCycle, QDistinct> distinctByVariableIncomeTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'variableIncomeTotal');
    });
  }
}

extension PayCycleQueryProperty
    on QueryBuilder<PayCycle, PayCycle, QQueryProperty> {
  QueryBuilder<PayCycle, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PayCycle, int, QQueryOperations> fixedSalaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fixedSalary');
    });
  }

  QueryBuilder<PayCycle, List<MandatoryExpenseItem>, QQueryOperations>
  mandatoryExpensesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mandatoryExpenses');
    });
  }

  QueryBuilder<PayCycle, DateTime, QQueryOperations> paydayDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paydayDate');
    });
  }

  QueryBuilder<PayCycle, DateTime, QQueryOperations> startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<PayCycle, int, QQueryOperations> variableIncomeTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'variableIncomeTotal');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

const MandatoryExpenseItemSchema = Schema(
  name: r'MandatoryExpenseItem',
  id: -2400845936588924220,
  properties: {
    r'amount': PropertySchema(id: 0, name: r'amount', type: IsarType.long),
    r'name': PropertySchema(id: 1, name: r'name', type: IsarType.string),
  },

  estimateSize: _mandatoryExpenseItemEstimateSize,
  serialize: _mandatoryExpenseItemSerialize,
  deserialize: _mandatoryExpenseItemDeserialize,
  deserializeProp: _mandatoryExpenseItemDeserializeProp,
);

int _mandatoryExpenseItemEstimateSize(
  MandatoryExpenseItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _mandatoryExpenseItemSerialize(
  MandatoryExpenseItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.amount);
  writer.writeString(offsets[1], object.name);
}

MandatoryExpenseItem _mandatoryExpenseItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MandatoryExpenseItem();
  object.amount = reader.readLong(offsets[0]);
  object.name = reader.readString(offsets[1]);
  return object;
}

P _mandatoryExpenseItemDeserializeProp<P>(
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
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension MandatoryExpenseItemQueryFilter
    on
        QueryBuilder<
          MandatoryExpenseItem,
          MandatoryExpenseItem,
          QFilterCondition
        > {
  QueryBuilder<
    MandatoryExpenseItem,
    MandatoryExpenseItem,
    QAfterFilterCondition
  >
  amountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'amount', value: value),
      );
    });
  }

  QueryBuilder<
    MandatoryExpenseItem,
    MandatoryExpenseItem,
    QAfterFilterCondition
  >
  amountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'amount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    MandatoryExpenseItem,
    MandatoryExpenseItem,
    QAfterFilterCondition
  >
  amountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'amount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    MandatoryExpenseItem,
    MandatoryExpenseItem,
    QAfterFilterCondition
  >
  amountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'amount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    MandatoryExpenseItem,
    MandatoryExpenseItem,
    QAfterFilterCondition
  >
  nameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MandatoryExpenseItem,
    MandatoryExpenseItem,
    QAfterFilterCondition
  >
  nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MandatoryExpenseItem,
    MandatoryExpenseItem,
    QAfterFilterCondition
  >
  nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MandatoryExpenseItem,
    MandatoryExpenseItem,
    QAfterFilterCondition
  >
  nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MandatoryExpenseItem,
    MandatoryExpenseItem,
    QAfterFilterCondition
  >
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MandatoryExpenseItem,
    MandatoryExpenseItem,
    QAfterFilterCondition
  >
  nameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MandatoryExpenseItem,
    MandatoryExpenseItem,
    QAfterFilterCondition
  >
  nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MandatoryExpenseItem,
    MandatoryExpenseItem,
    QAfterFilterCondition
  >
  nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    MandatoryExpenseItem,
    MandatoryExpenseItem,
    QAfterFilterCondition
  >
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<
    MandatoryExpenseItem,
    MandatoryExpenseItem,
    QAfterFilterCondition
  >
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }
}

extension MandatoryExpenseItemQueryObject
    on
        QueryBuilder<
          MandatoryExpenseItem,
          MandatoryExpenseItem,
          QFilterCondition
        > {}
