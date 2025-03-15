import 'dart:async';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;

class AutoMapperGenerator extends Builder {
  final formatter = DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);

  @override
  final Map<String, List<String>> buildExtensions = const {
    r'$package$': ['lib/auto_mapper.dart']
  };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final List<String> imports = [];

    imports.add("import 'package:auto_mapper/auto_mapper.dart';\n");

    final body = await buildStep //
        .findAssets(Glob('lib/**/*.dart'))
        .asyncExpand((assetId) async* {
      final library = await buildStep.resolver.libraryFor(assetId);
      final reader = LibraryReader(library);

      final generated = await generate(reader, buildStep, imports);

      // yield significa que o valor será retornado, mas a função continuará executando
      yield generated;
    }).toList();

    final aggregatedBuffer = StringBuffer();

    aggregatedBuffer.writeln("// GENERATED CODE - DO NOT MODIFY BY HAND");

    aggregatedBuffer.writeln(imports.join('\n'));

    aggregatedBuffer.writeln("class GeneratedMappings {");
    aggregatedBuffer.writeln("  static void register() {");
    aggregatedBuffer.writeln(body.join('\n'));

    aggregatedBuffer.writeln("  }");
    aggregatedBuffer.writeln("}");

    final formattedCode = formatter.format(aggregatedBuffer.toString());

    final outputId = _allFileOutput(buildStep);
    await buildStep.writeAsString(outputId, formattedCode);
  }

  FutureOr<String> generate(LibraryReader library, BuildStep buildStep, List<String> imports) {
    final buffer = StringBuffer();
    final mappings = <String>[];

    for (var element in library.classes) {
      final annotation = _getAutoMapAnnotation(element);

      if (annotation != null) {
        final targetType = annotation.getField('target')?.toTypeValue()?.getDisplayString(withNullability: false);
        final targetClassElement = annotation.getField('target')?.toTypeValue()?.element as ClassElement?;
        final targetImport = annotation.getField('target')?.toTypeValue()?.element?.librarySource?.uri.toString();

        final classImport = element.source.uri.toString();

        if (targetType != null && targetClassElement != null) {
          String import = "import '$targetImport';";

          if (!imports.contains(import)) {
            imports.add(import);
          }

          import = "import '$classImport';";

          if (!imports.contains(import)) {
            imports.add(import);
          }

          mappings.add('''
        add<${element.name}, $targetType>(
          (${element.name} source) => $targetType(
            ${targetClassElement.fields.map((field) {
            final sourceField = element.fields.where((f) => f.name == field.name).firstOrNull;

            if (sourceField != null) {
              if (sourceField.type.isDartCoreList) {
                final type = sourceField.type as ParameterizedType;
                final typeArgument = type.typeArguments.first;

                if (typeArgument.element is ClassElement) {
                  final classElement = typeArgument.element as ClassElement;
                  final annotation = _getAutoMapAnnotation(classElement);

                  if (annotation != null) {
                    final targetChildType = annotation.getField('target')?.toTypeValue()?.getDisplayString(withNullability: false);

                    return '${field.name}: source.${sourceField.name}.map((item) => AutoMapper.convert<${classElement.name}, $targetChildType>(item)).toList(),';
                  }
                }
              } else {
                final annotation = sourceField.type.element is ClassElement ? _getAutoMapAnnotation(sourceField.type.element as ClassElement) : null;

                if (annotation != null) {
                  final targetChildType = annotation.getField('target')?.toTypeValue()?.getDisplayString(withNullability: false);
                  return '${field.name}: AutoMapper.convert<${sourceField.type.element?.name ?? ''}, $targetChildType>(source.${sourceField.name}),';
                } else {
                  return '${field.name}: source.${sourceField.name},';
                }
              }
            } else {
              return '${field.name}: ${_defaultValueForField(field)},';
            }
          }).join('\n')}
          )
        );
      ''');
        }
      }
    }

    if (mappings.isEmpty) {
      return '';
    }

    for (var mapping in mappings) {
      buffer.writeln("    AutoMapper.$mapping");
    }

    return buffer.toString();
  }

  String _defaultValueForField(FieldElement field) {
    final annotation = field.metadata.where(
          (meta) => meta.computeConstantValue()?.type?.getDisplayString(withNullability: false) == 'AutoMapFieldValue'
    ).firstOrNull;

    if (annotation != null) {
      final defaultValue = annotation.computeConstantValue()?.getField('defaultValue');


      return defaultValue != null ? "${_getValueFromType(defaultValue)}" : 'null';
    }
    return 'null';
  }

  dynamic _getValueFromType(DartObject value) {
    if (value.isNull) {
      return null;
    }

    print('********TYPE*********');
    print(value.toRecordValue());
    print('*****************');

    if (value.toBoolValue() != null) {
      return value.toBoolValue();
    }

    if (value.toIntValue() != null) {
      return value.toIntValue();
    }

    if (value.toDoubleValue() != null) {
      return value.toDoubleValue();
    }

    if (value.toStringValue() != null) {
      return '"${value.toStringValue()}"';
    }

    if (value.toSymbolValue() != null) {
      return value.toSymbolValue();
    }

    if (value.toListValue() != null) {
      print('********LIST*********');

      final list = value.toListValue() ?? [];

      final values = list.map((item) {
        return _getValueFromType(item);
      }).join(', ');

      return '[$values]';
    }

    if (value.toMapValue() != null) {
      return value.toMapValue();
    }

    // Se for um objeto, retorna o valor do objeto
    if (value.type is InterfaceType) {
      final interfaceType = value.type as InterfaceType;
      final className = interfaceType.element.name;
      final fields = interfaceType.element.fields;

      final fieldValues = fields.map((field) {
        final fieldValue = value.getField(field.name);

        if (fieldValue != null) {
          final fieldValueString = _getValueFromType(fieldValue);

          return '${field.name}: $fieldValueString';
        }
        return '${field.name}: null';
      }).join(', ');

      return '$className($fieldValues)';
    }

    return value.toSymbolValue();
  }

  DartObject? _getAutoMapAnnotation(ClassElement element) {
    return element.metadata.map((meta) {
      return meta.computeConstantValue();
    }).firstWhere((value) {
      return value?.type?.getDisplayString(withNullability: false) == 'AutoMap';
    }, orElse: () => null);
  }

  AssetId _allFileOutput(BuildStep buildStep) {
    return AssetId(
      buildStep.inputId.package,
      p.join('lib', 'auto_mapper.dart'),
    );
  }
}

Builder autoMapperBuilder(BuilderOptions options) => AutoMapperGenerator();
