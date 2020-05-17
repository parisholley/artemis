import 'package:artemis/generator/data.dart';
import 'package:test/test.dart';

import '../../helpers.dart';

void main() {
  group('On types not used by interfaces', () {
    test(
      'Those other types are not considered nor generated',
      () async => testGenerator(
        query: query,
        schema: graphQLSchema,
        libraryDefinition: libraryDefinition,
        generatedFile: generatedFile,
      ),
    );
  });
}

const query = r'''
  query custom($id: ID!) {
    nodeById(id: $id) {
      id
      __typename
      ... on User {
        username
      }
      ... on ChatMessage {
        message
      }
    }
  }
''';

// https://graphql-code-generator.com/#live-demo
const graphQLSchema = '''
  scalar String
  scalar ID
  
  schema {
    query: Query
  }
  
  type Query {
    nodeById(id: ID!): Node
  }
  
  interface Node {
    id: ID!
  }
  
  type User implements Node {
    id: ID!
    username: String!
  }
  
  type OtherEntity implements Node {
    id: ID!
    test: String!
  }
  
  type ChatMessage implements Node {
    id: ID!
    message: String!
    user: User!
  }
''';

final LibraryDefinition libraryDefinition =
    LibraryDefinition(basename: r'query.graphql', queries: [
  QueryDefinition(
      queryName: r'custom',
      queryType: r'Custom$Query',
      classes: [
        ClassDefinition(
            name: r'Custom$Query$Node$User',
            properties: [
              ClassProperty(
                  type: r'String',
                  name: r'username',
                  isNonNull: true,
                  isResolveType: false)
            ],
            extension: r'Custom$Query$Node',
            factoryPossibilities: {},
            typeNameField: r'__typename',
            isInput: false),
        ClassDefinition(
            name: r'Custom$Query$Node$ChatMessage',
            properties: [
              ClassProperty(
                  type: r'String',
                  name: r'message',
                  isNonNull: true,
                  isResolveType: false)
            ],
            extension: r'Custom$Query$Node',
            factoryPossibilities: {},
            typeNameField: r'__typename',
            isInput: false),
        ClassDefinition(
            name: r'Custom$Query$Node',
            properties: [
              ClassProperty(
                  type: r'String',
                  name: r'id',
                  isNonNull: true,
                  isResolveType: false),
              ClassProperty(
                  type: r'String',
                  name: r'$$typename',
                  annotations: [
                    r'override',
                    r'''JsonKey(name: '__typename')'''
                  ],
                  isNonNull: false,
                  isResolveType: true)
            ],
            factoryPossibilities: {
              r'User': r'Custom$Query$Node$User',
              r'ChatMessage': r'Custom$Query$Node$ChatMessage'
            },
            typeNameField: r'__typename',
            isInput: false),
        ClassDefinition(
            name: r'Custom$Query',
            properties: [
              ClassProperty(
                  type: r'Custom$Query$Node',
                  name: r'nodeById',
                  isNonNull: false,
                  isResolveType: false)
            ],
            factoryPossibilities: {},
            typeNameField: r'__typename',
            isInput: false)
      ],
      inputs: [QueryInput(type: r'String', name: r'id', isNonNull: true)],
      generateHelpers: false,
      suffix: r'Query')
]);

const generatedFile = r'''// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:gql/ast.dart';
part 'query.graphql.g.dart';

@JsonSerializable(explicitToJson: true)
class Custom$Query$Node$User extends Custom$Query$Node with EquatableMixin {
  Custom$Query$Node$User();

  factory Custom$Query$Node$User.fromJson(Map<String, dynamic> json) =>
      _$Custom$Query$Node$UserFromJson(json);

  String username;

  @override
  List<Object> get props => [username];
  Map<String, dynamic> toJson() => _$Custom$Query$Node$UserToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Custom$Query$Node$ChatMessage extends Custom$Query$Node
    with EquatableMixin {
  Custom$Query$Node$ChatMessage();

  factory Custom$Query$Node$ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$Custom$Query$Node$ChatMessageFromJson(json);

  String message;

  @override
  List<Object> get props => [message];
  Map<String, dynamic> toJson() => _$Custom$Query$Node$ChatMessageToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Custom$Query$Node with EquatableMixin {
  Custom$Query$Node();

  factory Custom$Query$Node.fromJson(Map<String, dynamic> json) {
    switch (json['__typename'].toString()) {
      case r'User':
        return Custom$Query$Node$User.fromJson(json);
      case r'ChatMessage':
        return Custom$Query$Node$ChatMessage.fromJson(json);
      default:
    }
    return _$Custom$Query$NodeFromJson(json);
  }

  String id;

  @override
  @JsonKey(name: '__typename')
  String $$typename;

  @override
  List<Object> get props => [id, $$typename];
  Map<String, dynamic> toJson() {
    switch ($$typename) {
      case r'User':
        return (this as Custom$Query$Node$User).toJson();
      case r'ChatMessage':
        return (this as Custom$Query$Node$ChatMessage).toJson();
      default:
    }
    return _$Custom$Query$NodeToJson(this);
  }
}

@JsonSerializable(explicitToJson: true)
class Custom$Query with EquatableMixin {
  Custom$Query();

  factory Custom$Query.fromJson(Map<String, dynamic> json) =>
      _$Custom$QueryFromJson(json);

  Custom$Query$Node nodeById;

  @override
  List<Object> get props => [nodeById];
  Map<String, dynamic> toJson() => _$Custom$QueryToJson(this);
}
''';
