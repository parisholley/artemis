import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:gql_code_gen/gql_code_gen.dart' as dart;

import '../generator/data.dart';
import '../generator/helpers.dart';

/// Generates a [Spec] of a single enum definition.
Spec enumDefinitionToSpec(EnumDefinition definition) =>
    CodeExpression(Code('''enum ${definition.name.namePrintable} {
  ${definition.values.removeDuplicatedBy((i) => i).map((v) => '${normalizeName(v)}, ').join()}
}'''));

String _fromJsonBody(ClassDefinition definition) {
  final buffer = StringBuffer();
  buffer
      .writeln('''switch (json['${definition.typeNameField}'].toString()) {''');

  for (final p in definition.factoryPossibilities.entries) {
    buffer.writeln('''      case r'${p.key}':
        return ${p.value}.fromJson(json);''');
  }

  buffer.writeln('''      default:
    }
    return _\$${definition.name.namePrintable}FromJson(json);''');
  return buffer.toString();
}

String _toJsonBody(ClassDefinition definition) {
  final buffer = StringBuffer();
  final typeName = normalizeName(definition.typeNameField);
  buffer.writeln('''switch ($typeName) {''');

  for (final p in definition.factoryPossibilities.entries) {
    buffer.writeln('''      case r'${p.key}':
        return (this as ${p.value}).toJson();''');
  }

  buffer.writeln('''      default:
    }
    return _\$${definition.name.namePrintable}ToJson(this);''');
  return buffer.toString();
}

Method _propsMethod(String body) {
  return Method((m) => m
    ..type = MethodType.getter
    ..returns = refer('List<Object>')
    ..annotations.add(CodeExpression(Code('override')))
    ..name = 'props'
    ..lambda = true
    ..body = Code(body));
}

/// Generates a [Spec] of a single class definition.
Spec classDefinitionToSpec(
    ClassDefinition definition, Iterable<FragmentClassDefinition> fragments) {
  final fromJson = definition.factoryPossibilities.isNotEmpty
      ? Constructor(
          (b) => b
            ..factory = true
            ..name = 'fromJson'
            ..requiredParameters.add(Parameter(
              (p) => p
                ..type = refer('Map<String, dynamic>')
                ..name = 'json',
            ))
            ..body = Code(_fromJsonBody(definition)),
        )
      : Constructor(
          (b) => b
            ..factory = true
            ..name = 'fromJson'
            ..lambda = true
            ..requiredParameters.add(Parameter(
              (p) => p
                ..type = refer('Map<String, dynamic>')
                ..name = 'json',
            ))
            ..body = Code('_\$${definition.name.namePrintable}FromJson(json)'),
        );

  final toJson = definition.factoryPossibilities.isNotEmpty
      ? Method(
          (m) => m
            ..name = 'toJson'
            ..returns = refer('Map<String, dynamic>')
            ..body = Code(_toJsonBody(definition)),
        )
      : Method(
          (m) => m
            ..name = 'toJson'
            ..lambda = true
            ..returns = refer('Map<String, dynamic>')
            ..body = Code('_\$${definition.name.namePrintable}ToJson(this)'),
        );

  final props = definition.mixins
      .map((i) => fragments
          .firstWhere((f) => f.name == i)
          .properties
          .map((p) => p.name.namePrintable))
      .expand((i) => i)
      .followedBy(definition.properties.map((p) => p.name.namePrintable));

  return Class(
    (b) => b
      ..annotations
          .add(CodeExpression(Code('JsonSerializable(explicitToJson: true)')))
      ..name = definition.name.namePrintable
      ..mixins.add(refer('EquatableMixin'))
      ..mixins.addAll(definition.mixins.map((i) => refer(i)))
      ..methods.add(_propsMethod('[${props.join(',')}]'))
      ..extend =
          definition.extension != null ? refer(definition.extension) : null
      ..implements.addAll(definition.implementations.map((i) => refer(i)))
      ..constructors.add(Constructor((b) {
        if (definition.isInput) {
          b
            ..optionalParameters.addAll(definition.properties
                .where((property) =>
                    !property.isOverride && !property.isResolveType)
                .map(
                  (property) => Parameter(
                    (p) {
                      p
                        ..name = property.name.namePrintable
                        ..named = true
                        ..toThis = true;

                      if (property.isNonNull) {
                        p.annotations.add(refer('required'));
                      }
                    },
                  ),
                ));
        }
      }))
      ..constructors.add(fromJson)
      ..methods.add(toJson)
      ..fields.addAll(definition.properties.map((p) {
        final field = Field(
          (f) => f
            ..name = p.name.namePrintable
            ..type = refer(p.type)
            ..annotations.addAll(
              p.annotations.map((e) => CodeExpression(Code(e))),
            ),
        );
        return field;
      })),
  );
}

/// Generates a [Spec] of a single fragment class definition.
Spec fragmentClassDefinitionToSpec(FragmentClassDefinition definition) {
  final fields = (definition.properties ?? []).map((p) {
    final lines = <String>[];
    lines.addAll(p.annotations.map((e) => '@${e}'));
    lines.add('${p.type} ${p.name.namePrintable};');
    return lines.join('\n');
  });

  return CodeExpression(Code('''mixin ${definition.name.namePrintable} {
  ${fields.join('\n')}
}'''));
}

/// Generates a [Spec] of a mutation argument class.
Spec generateArgumentClassSpec(QueryDefinition definition) {
  return Class(
    (b) => b
      ..annotations
          .add(CodeExpression(Code('JsonSerializable(explicitToJson: true)')))
      ..name = '${definition.className}Arguments'
      ..extend = refer('JsonSerializable')
      ..mixins.add(refer('EquatableMixin'))
      ..methods.add(_propsMethod(
          '[${definition.inputs.map((input) => input.name.namePrintable).join(',')}]'))
      ..constructors.add(Constructor(
        (b) => b
          ..optionalParameters.addAll(definition.inputs.map(
            (input) => Parameter(
              (p) {
                p
                  ..name = input.name.namePrintable
                  ..named = true
                  ..toThis = true;

                if (input.isNonNull) {
                  p.annotations.add(refer('required'));
                }
              },
            ),
          )),
      ))
      ..constructors.add(Constructor(
        (b) => b
          ..factory = true
          ..name = 'fromJson'
          ..lambda = true
          ..requiredParameters.add(Parameter(
            (p) => p
              ..type = refer('Map<String, dynamic>')
              ..name = 'json',
          ))
          ..body = Code('_\$${definition.className}ArgumentsFromJson(json)'),
      ))
      ..methods.add(Method(
        (m) => m
          ..name = 'toJson'
          ..lambda = true
          ..returns = refer('Map<String, dynamic>')
          ..body = Code('_\$${definition.className}ArgumentsToJson(this)'),
      ))
      ..fields.addAll(definition.inputs.map(
        (p) => Field(
          (f) => f
            ..name = p.name.namePrintable
            ..type = refer(p.type)
            ..modifier = FieldModifier.final$
            ..annotations
                .addAll(p.annotations.map((e) => CodeExpression(Code(e)))),
        ),
      )),
  );
}

/// Generates a [Spec] of a query/mutation class.
Spec generateQueryClassSpec(QueryDefinition definition) {
  final typeDeclaration = definition.inputs.isEmpty
      ? '${definition.queryType}, JsonSerializable'
      : '${definition.queryType}, ${definition.className}Arguments';

  final constructor = definition.inputs.isEmpty
      ? Constructor()
      : Constructor((b) => b
        ..optionalParameters.add(Parameter(
          (p) => p
            ..name = 'variables'
            ..toThis = true
            ..named = true,
        )));

  final fields = [
    Field(
      (f) => f
        ..annotations.add(CodeExpression(Code('override')))
        ..modifier = FieldModifier.final$
        ..type = refer('DocumentNode', 'package:gql/ast.dart')
        ..name = 'document'
        ..assignment = dart.fromNode(definition.document).code,
    ),
    Field(
      (f) => f
        ..annotations.add(CodeExpression(Code('override')))
        ..modifier = FieldModifier.final$
        ..type = refer('String')
        ..name = 'operationName'
        ..assignment = Code('\'${definition.queryName}\''),
    ),
  ];

  if (definition.inputs.isNotEmpty) {
    fields.add(Field(
      (f) => f
        ..annotations.add(CodeExpression(Code('override')))
        ..modifier = FieldModifier.final$
        ..type = refer('${definition.className}Arguments')
        ..name = 'variables',
    ));
  }

  return Class(
    (b) => b
      ..name = '${definition.className}${definition.suffix}'
      ..extend = refer('GraphQLQuery<$typeDeclaration>')
      ..constructors.add(constructor)
      ..fields.addAll(fields)
      ..methods.add(_propsMethod(
          '[document, operationName${definition.inputs.isNotEmpty ? ', variables' : ''}]'))
      ..methods.add(Method(
        (m) => m
          ..annotations.add(CodeExpression(Code('override')))
          ..returns = refer(definition.queryType)
          ..name = 'parse'
          ..requiredParameters.add(Parameter(
            (p) => p
              ..type = refer('Map<String, dynamic>')
              ..name = 'json',
          ))
          ..lambda = true
          ..body = Code('${definition.queryType}.fromJson(json)'),
      )),
  );
}

/// Gathers and generates a [Spec] of a whole query/mutation and its
/// dependencies into a single library file.
Spec generateLibrarySpec(LibraryDefinition definition) {
  final importDirectives = [
    Directive.import('package:json_annotation/json_annotation.dart'),
    Directive.import('package:equatable/equatable.dart'),
    Directive.import('package:gql/ast.dart'),
  ];

  if (definition.queries.any((q) => q.generateHelpers)) {
    importDirectives.insertAll(
      0,
      [
        Directive.import('package:artemis/artemis.dart'),
      ],
    );
  }

  // inserts import of meta package only if there is at least one non nullable input
  // see this link for details https://github.com/dart-lang/sdk/issues/4188#issuecomment-240322222
  if (hasNonNullableInput(definition.queries)) {
    importDirectives.insertAll(
      0,
      [
        Directive.import('package:meta/meta.dart'),
      ],
    );
  }

  importDirectives.addAll(definition.customImports
      .map((customImport) => Directive.import(customImport)));

  final bodyDirectives = <Spec>[
    CodeExpression(Code('part \'${definition.basename}.g.dart\';')),
  ];

  final uniqueDefinitions = definition.queries
      .map((e) => e.classes.map((e) => e))
      .expand((e) => e)
      .fold<Map<String, Definition>>(<String, Definition>{}, (acc, element) {
    acc[element.name.name] = element;

    return acc;
  }).values;

  final fragments = uniqueDefinitions.whereType<FragmentClassDefinition>();
  final classes = uniqueDefinitions.whereType<ClassDefinition>();
  final enums = uniqueDefinitions.whereType<EnumDefinition>();

  bodyDirectives.addAll(fragments.map(fragmentClassDefinitionToSpec));
  bodyDirectives
      .addAll(classes.map((cDef) => classDefinitionToSpec(cDef, fragments)));
  bodyDirectives.addAll(enums.map(enumDefinitionToSpec));

  for (final queryDef in definition.queries) {
    if (queryDef.inputs.isNotEmpty && queryDef.generateHelpers) {
      bodyDirectives.add(generateArgumentClassSpec(queryDef));
    }
    if (queryDef.generateHelpers) {
      bodyDirectives.add(generateQueryClassSpec(queryDef));
    }
  }

  return Library(
    (b) => b..directives.addAll(importDirectives)..body.addAll(bodyDirectives),
  );
}

/// Emit a [Spec] into a String, considering Dart formatting.
String specToString(Spec spec) {
  final emitter = DartEmitter();
  return DartFormatter().format(spec.accept(emitter).toString());
}

/// Generate Dart code typings from a query or mutation and its response from
/// a [QueryDefinition] into a buffer.
void writeLibraryDefinitionToBuffer(
    StringBuffer buffer, LibraryDefinition definition) {
  buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND\n');
  buffer.write(specToString(generateLibrarySpec(definition)));
}

/// Generate an empty file just exporting the library. This is used to avoid
/// a breaking change on file generation.
String writeLibraryForwarder(LibraryDefinition definition) =>
    '''// GENERATED CODE - DO NOT MODIFY BY HAND
export '${definition.basename}.dart';
''';
