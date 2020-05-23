import 'package:artemis/builder.dart';
import 'package:artemis/generator/data.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  group('On query generation', () {
    test('When not configured, nothing will be generated', () async {
      final anotherBuilder = graphQLQueryBuilder(BuilderOptions({}));

      await testBuilder(
        anotherBuilder,
        {
          'a|api.schema.graphql': '',
          'a|some_query.query.graphql': 'query some_query { s, i }',
        },
      );
    });

    test(
        'Should include typeName if enabled',
            () async => testGenerator(
            query: 'query some_query { s, i }',
            includeTypeNameField: true,
            schema: r'''
        schema {
          query: SomeObject
        }
  
        type SomeObject {
          s: String
          i: Int
        }
      ''',
            libraryDefinition:
            LibraryDefinition(basename: r'query.graphql', queries: [
              QueryDefinition(
                  queryName: r'some_query',
                  queryType: r'SomeQuery$SomeObject',
                  classes: [
                    ClassDefinition(
                        name: r'SomeQuery$SomeObject',
                        properties: [
                          ClassProperty(
                              type: r'String',
                              name: r's',
                              isNonNull: false,
                              isResolveType: false),
                          ClassProperty(
                              type: r'int',
                              name: r'i',
                              isNonNull: false,
                              isResolveType: false),
                          ClassProperty(
                              type: r'String',
                              name: r'typeName',
                              annotations: ['JsonKey(name: \'__typename\')'],
                              isNonNull: true,
                              isResolveType: true),
                        ],
                        factoryPossibilities: {},
                        typeNameField: r'__typename',
                        isInput: false)
                  ],
                  generateHelpers: false,
                  suffix: r'Query')
            ]),
            generatedFile: r'''// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:gql/ast.dart';
part 'query.graphql.g.dart';

@JsonSerializable(explicitToJson: true)
class SomeQuery$SomeObject with EquatableMixin {
  SomeQuery$SomeObject();

  factory SomeQuery$SomeObject.fromJson(Map<String, dynamic> json) =>
      _$SomeQuery$SomeObjectFromJson(json);

  String s;

  int i;

  @JsonKey(name: '__typename')
  String typeName;

  @override
  List<Object> get props => [s, i, typeName];
  Map<String, dynamic> toJson() => _$SomeQuery$SomeObjectToJson(this);
}
''',
            generateHelpers: false));

    test(
        'A simple query yields simple classes',
        () async => testGenerator(
            query: 'query some_query { s, i }',
            schema: r'''
        schema {
          query: SomeObject
        }
  
        type SomeObject {
          s: String
          i: Int
        }
      ''',
            libraryDefinition:
                LibraryDefinition(basename: r'query.graphql', queries: [
              QueryDefinition(
                  queryName: r'some_query',
                  queryType: r'SomeQuery$SomeObject',
                  classes: [
                    ClassDefinition(
                        name: r'SomeQuery$SomeObject',
                        properties: [
                          ClassProperty(
                              type: r'String',
                              name: r's',
                              isNonNull: false,
                              isResolveType: false),
                          ClassProperty(
                              type: r'int',
                              name: r'i',
                              isNonNull: false,
                              isResolveType: false)
                        ],
                        factoryPossibilities: {},
                        typeNameField: r'__typename',
                        isInput: false)
                  ],
                  generateHelpers: false,
                  suffix: r'Query')
            ]),
            generatedFile: r'''// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:gql/ast.dart';
part 'query.graphql.g.dart';

@JsonSerializable(explicitToJson: true)
class SomeQuery$SomeObject with EquatableMixin {
  SomeQuery$SomeObject();

  factory SomeQuery$SomeObject.fromJson(Map<String, dynamic> json) =>
      _$SomeQuery$SomeObjectFromJson(json);

  String s;

  int i;

  @override
  List<Object> get props => [s, i];
  Map<String, dynamic> toJson() => _$SomeQuery$SomeObjectToJson(this);
}
''',
            generateHelpers: false));

    test(
        'A simple query with list input',
        () async => testGenerator(
            query: r'''
        query some_query($intsNonNullable: [Int]!, $stringNullable: String) {
          someQuery(intsNonNullable: $intsNonNullable, stringNullable: $stringNullable) {
            s
            i
            list(intsNonNullable: $intsNonNullable)
          }
        }
      ''',
            schema: r'''
         schema {
              query: Query
            }

            type Query {
              someQuery(intsNonNullable: [Int]!, stringNullable: String): SomeObject
            }

            type SomeObject {
              s: String
              i: Int
              list(intsNonNullable: [Int]!): [Int]!
            }
      ''',
            libraryDefinition:
                LibraryDefinition(basename: r'query.graphql', queries: [
              QueryDefinition(
                  queryName: r'some_query',
                  queryType: r'SomeQuery$Query',
                  classes: [
                    ClassDefinition(
                        name: r'SomeQuery$Query$SomeObject',
                        properties: [
                          ClassProperty(
                              type: r'String',
                              name: r's',
                              isNonNull: false,
                              isResolveType: false),
                          ClassProperty(
                              type: r'int',
                              name: r'i',
                              isNonNull: false,
                              isResolveType: false),
                          ClassProperty(
                              type: r'List<int>',
                              name: r'list',
                              isNonNull: true,
                              isResolveType: false)
                        ],
                        factoryPossibilities: {},
                        typeNameField: r'__typename',
                        isInput: false),
                    ClassDefinition(
                        name: r'SomeQuery$Query',
                        properties: [
                          ClassProperty(
                              type: r'SomeQuery$Query$SomeObject',
                              name: r'someQuery',
                              isNonNull: false,
                              isResolveType: false)
                        ],
                        factoryPossibilities: {},
                        typeNameField: r'__typename',
                        isInput: false)
                  ],
                  inputs: [
                    QueryInput(
                        type: r'List<int>',
                        name: r'intsNonNullable',
                        isNonNull: true),
                    QueryInput(
                        type: r'String',
                        name: r'stringNullable',
                        isNonNull: false)
                  ],
                  generateHelpers: true,
                  suffix: r'Query')
            ]),
            generatedFile: r'''// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:meta/meta.dart';
import 'package:artemis/artemis.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:gql/ast.dart';
part 'query.graphql.g.dart';

@JsonSerializable(explicitToJson: true)
class SomeQuery$Query$SomeObject with EquatableMixin {
  SomeQuery$Query$SomeObject();

  factory SomeQuery$Query$SomeObject.fromJson(Map<String, dynamic> json) =>
      _$SomeQuery$Query$SomeObjectFromJson(json);

  String s;

  int i;

  List<int> list;

  @override
  List<Object> get props => [s, i, list];
  Map<String, dynamic> toJson() => _$SomeQuery$Query$SomeObjectToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SomeQuery$Query with EquatableMixin {
  SomeQuery$Query();

  factory SomeQuery$Query.fromJson(Map<String, dynamic> json) =>
      _$SomeQuery$QueryFromJson(json);

  SomeQuery$Query$SomeObject someQuery;

  @override
  List<Object> get props => [someQuery];
  Map<String, dynamic> toJson() => _$SomeQuery$QueryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SomeQueryArguments extends JsonSerializable with EquatableMixin {
  SomeQueryArguments({@required this.intsNonNullable, this.stringNullable});

  factory SomeQueryArguments.fromJson(Map<String, dynamic> json) =>
      _$SomeQueryArgumentsFromJson(json);

  final List<int> intsNonNullable;

  final String stringNullable;

  @override
  List<Object> get props => [intsNonNullable, stringNullable];
  Map<String, dynamic> toJson() => _$SomeQueryArgumentsToJson(this);
}

class SomeQueryQuery extends GraphQLQuery<SomeQuery$Query, SomeQueryArguments> {
  SomeQueryQuery({this.variables});

  @override
  final DocumentNode document = DocumentNode(definitions: [
    OperationDefinitionNode(
        type: OperationType.query,
        name: NameNode(value: 'some_query'),
        variableDefinitions: [
          VariableDefinitionNode(
              variable: VariableNode(name: NameNode(value: 'intsNonNullable')),
              type: ListTypeNode(
                  type: NamedTypeNode(
                      name: NameNode(value: 'Int'), isNonNull: false),
                  isNonNull: true),
              defaultValue: DefaultValueNode(value: null),
              directives: []),
          VariableDefinitionNode(
              variable: VariableNode(name: NameNode(value: 'stringNullable')),
              type: NamedTypeNode(
                  name: NameNode(value: 'String'), isNonNull: false),
              defaultValue: DefaultValueNode(value: null),
              directives: [])
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
              name: NameNode(value: 'someQuery'),
              alias: null,
              arguments: [
                ArgumentNode(
                    name: NameNode(value: 'intsNonNullable'),
                    value:
                        VariableNode(name: NameNode(value: 'intsNonNullable'))),
                ArgumentNode(
                    name: NameNode(value: 'stringNullable'),
                    value:
                        VariableNode(name: NameNode(value: 'stringNullable')))
              ],
              directives: [],
              selectionSet: SelectionSetNode(selections: [
                FieldNode(
                    name: NameNode(value: 's'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null),
                FieldNode(
                    name: NameNode(value: 'i'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null),
                FieldNode(
                    name: NameNode(value: 'list'),
                    alias: null,
                    arguments: [
                      ArgumentNode(
                          name: NameNode(value: 'intsNonNullable'),
                          value: VariableNode(
                              name: NameNode(value: 'intsNonNullable')))
                    ],
                    directives: [],
                    selectionSet: null)
              ]))
        ]))
  ]);

  @override
  final String operationName = 'some_query';

  @override
  final SomeQueryArguments variables;

  @override
  List<Object> get props => [document, operationName, variables];
  @override
  SomeQuery$Query parse(Map<String, dynamic> json) =>
      SomeQuery$Query.fromJson(json);
}
''',
            generateHelpers: true));

    test(
        'The selection from query can nest',
        () async => testGenerator(
            query: r'''
            query some_query {
          s
          o {
            st
            ob {
              str
            }
          }
        }
            ''',
            schema: r'''
            schema {
              query: Result
            }

            type Result {
              s: String
              o: SomeObject
            }

            type SomeObject {
              st: String
              ob: [AnotherObject]
            }

            type AnotherObject {
              str: String
            }
      ''',
            libraryDefinition:
                LibraryDefinition(basename: r'query.graphql', queries: [
              QueryDefinition(
                  queryName: r'some_query',
                  queryType: r'SomeQuery$Result',
                  classes: [
                    ClassDefinition(
                        name: r'SomeQuery$Result$SomeObject$AnotherObject',
                        properties: [
                          ClassProperty(
                              type: r'String',
                              name: r'str',
                              isNonNull: false,
                              isResolveType: false)
                        ],
                        factoryPossibilities: {},
                        typeNameField: r'__typename',
                        isInput: false),
                    ClassDefinition(
                        name: r'SomeQuery$Result$SomeObject',
                        properties: [
                          ClassProperty(
                              type: r'String',
                              name: r'st',
                              isNonNull: false,
                              isResolveType: false),
                          ClassProperty(
                              type:
                                  r'List<SomeQuery$Result$SomeObject$AnotherObject>',
                              name: r'ob',
                              isNonNull: false,
                              isResolveType: false)
                        ],
                        factoryPossibilities: {},
                        typeNameField: r'__typename',
                        isInput: false),
                    ClassDefinition(
                        name: r'SomeQuery$Result',
                        properties: [
                          ClassProperty(
                              type: r'String',
                              name: r's',
                              isNonNull: false,
                              isResolveType: false),
                          ClassProperty(
                              type: r'SomeQuery$Result$SomeObject',
                              name: r'o',
                              isNonNull: false,
                              isResolveType: false)
                        ],
                        factoryPossibilities: {},
                        typeNameField: r'__typename',
                        isInput: false)
                  ],
                  generateHelpers: false,
                  suffix: r'Query')
            ]),
            generatedFile: r'''// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:gql/ast.dart';
part 'query.graphql.g.dart';

@JsonSerializable(explicitToJson: true)
class SomeQuery$Result$SomeObject$AnotherObject with EquatableMixin {
  SomeQuery$Result$SomeObject$AnotherObject();

  factory SomeQuery$Result$SomeObject$AnotherObject.fromJson(
          Map<String, dynamic> json) =>
      _$SomeQuery$Result$SomeObject$AnotherObjectFromJson(json);

  String str;

  @override
  List<Object> get props => [str];
  Map<String, dynamic> toJson() =>
      _$SomeQuery$Result$SomeObject$AnotherObjectToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SomeQuery$Result$SomeObject with EquatableMixin {
  SomeQuery$Result$SomeObject();

  factory SomeQuery$Result$SomeObject.fromJson(Map<String, dynamic> json) =>
      _$SomeQuery$Result$SomeObjectFromJson(json);

  String st;

  List<SomeQuery$Result$SomeObject$AnotherObject> ob;

  @override
  List<Object> get props => [st, ob];
  Map<String, dynamic> toJson() => _$SomeQuery$Result$SomeObjectToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SomeQuery$Result with EquatableMixin {
  SomeQuery$Result();

  factory SomeQuery$Result.fromJson(Map<String, dynamic> json) =>
      _$SomeQuery$ResultFromJson(json);

  String s;

  SomeQuery$Result$SomeObject o;

  @override
  List<Object> get props => [s, o];
  Map<String, dynamic> toJson() => _$SomeQuery$ResultToJson(this);
}
''',
            generateHelpers: false));

    test(
        'Query selections can be aliased',
        () async => testGenerator(
            query: 'query some_query { firstName: s, lastName: st }',
            schema: r'''
            schema {
              query: Result
            }

            type Result {
              s: String
              st: String
            }
      ''',
            libraryDefinition:
                LibraryDefinition(basename: r'query.graphql', queries: [
              QueryDefinition(
                  queryName: r'some_query',
                  queryType: r'SomeQuery$Result',
                  classes: [
                    ClassDefinition(
                        name: r'SomeQuery$Result',
                        properties: [
                          ClassProperty(
                              type: r'String',
                              name: r'firstName',
                              isNonNull: false,
                              isResolveType: false),
                          ClassProperty(
                              type: r'String',
                              name: r'lastName',
                              isNonNull: false,
                              isResolveType: false)
                        ],
                        factoryPossibilities: {},
                        typeNameField: r'__typename',
                        isInput: false)
                  ],
                  generateHelpers: false,
                  suffix: r'Query')
            ]),
            generatedFile: r'''// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:gql/ast.dart';
part 'query.graphql.g.dart';

@JsonSerializable(explicitToJson: true)
class SomeQuery$Result with EquatableMixin {
  SomeQuery$Result();

  factory SomeQuery$Result.fromJson(Map<String, dynamic> json) =>
      _$SomeQuery$ResultFromJson(json);

  String firstName;

  String lastName;

  @override
  List<Object> get props => [firstName, lastName];
  Map<String, dynamic> toJson() => _$SomeQuery$ResultToJson(this);
}
''',
            generateHelpers: false));

    test(
        'Imports from the scalar mapping are included',
        () async => testGenerator(
            query: r'''query some_query { bigDecimal, dateTime }''',
            schema: r'''
            scalar BigDecimal
            scalar DateTime

            schema {
              query: SomeObject
            }

            type SomeObject {
              bigDecimal: BigDecimal
              dateTime: DateTime
            }
      ''',
            builderOptionsMap: {
              'scalar_mapping': [
                {
                  'graphql_type': 'BigDecimal',
                  'dart_type': {
                    'name': 'Decimal',
                    'imports': ['package:decimal/decimal.dart'],
                  },
                },
                {
                  'graphql_type': 'DateTime',
                  'dart_type': 'DateTime',
                },
              ],
            },
            libraryDefinition:
                LibraryDefinition(basename: r'query.graphql', queries: [
              QueryDefinition(
                  queryName: r'some_query',
                  queryType: r'SomeQuery$SomeObject',
                  classes: [
                    ClassDefinition(
                        name: r'SomeQuery$SomeObject',
                        properties: [
                          ClassProperty(
                              type: r'Decimal',
                              name: r'bigDecimal',
                              isNonNull: false,
                              isResolveType: false),
                          ClassProperty(
                              type: r'DateTime',
                              name: r'dateTime',
                              isNonNull: false,
                              isResolveType: false)
                        ],
                        factoryPossibilities: {},
                        typeNameField: r'__typename',
                        isInput: false)
                  ],
                  generateHelpers: false,
                  suffix: r'Query')
            ], customImports: [
              r'package:decimal/decimal.dart'
            ]),
            generatedFile: r'''// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:gql/ast.dart';
import 'package:decimal/decimal.dart';
part 'query.graphql.g.dart';

@JsonSerializable(explicitToJson: true)
class SomeQuery$SomeObject with EquatableMixin {
  SomeQuery$SomeObject();

  factory SomeQuery$SomeObject.fromJson(Map<String, dynamic> json) =>
      _$SomeQuery$SomeObjectFromJson(json);

  Decimal bigDecimal;

  DateTime dateTime;

  @override
  List<Object> get props => [bigDecimal, dateTime];
  Map<String, dynamic> toJson() => _$SomeQuery$SomeObjectToJson(this);
}
''',
            generateHelpers: false));

    test(
        'Query name (pascal casing)',
        () async => testGenerator(
            query: r'''query PascalCasingQuery { s }''',
            schema: r'''
            schema {
              query: PascalCasingQuery
            }

            type PascalCasingQuery {
              s: String
            }
      ''',
            libraryDefinition:
                LibraryDefinition(basename: r'query.graphql', queries: [
              QueryDefinition(
                  queryName: r'PascalCasingQuery',
                  queryType: r'PascalCasingQuery$PascalCasingQuery',
                  classes: [
                    ClassDefinition(
                        name: r'PascalCasingQuery$PascalCasingQuery',
                        properties: [
                          ClassProperty(
                              type: r'String',
                              name: r's',
                              isNonNull: false,
                              isResolveType: false)
                        ],
                        factoryPossibilities: {},
                        typeNameField: r'__typename',
                        isInput: false)
                  ],
                  generateHelpers: false,
                  suffix: r'Query')
            ]),
            generatedFile: r'''// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:gql/ast.dart';
part 'query.graphql.g.dart';

@JsonSerializable(explicitToJson: true)
class PascalCasingQuery$PascalCasingQuery with EquatableMixin {
  PascalCasingQuery$PascalCasingQuery();

  factory PascalCasingQuery$PascalCasingQuery.fromJson(
          Map<String, dynamic> json) =>
      _$PascalCasingQuery$PascalCasingQueryFromJson(json);

  String s;

  @override
  List<Object> get props => [s];
  Map<String, dynamic> toJson() =>
      _$PascalCasingQuery$PascalCasingQueryToJson(this);
}
''',
            generateHelpers: false));
  });
}
