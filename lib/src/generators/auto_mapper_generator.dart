import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

class AutoMapperGenerator extends Builder {
  final formatter = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
    pageWidth: 200,
  );

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
      // Ignora arquivos que não são bibliotecas Dart válidas (ex.: arquivos part gerados pelo MobX, etc.)
      final isLibrary = await buildStep.resolver.isLibrary(assetId);
      if (!isLibrary) return;

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
        final targetType = annotation.getField('target')?.toTypeValue()?.getDisplayString();
        final targetClassElement = annotation.getField('target')?.toTypeValue()?.element as ClassElement?;
        final targetImport = annotation.getField('target')?.toTypeValue()?.element?.library?.uri.toString();

        final classImport = element.library.uri.toString();

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
            ${_buildConstructorArgs(element, targetClassElement, imports)}
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

  // Monta os argumentos com base no construtor (suporta nomeados e posicionais). Fallback: usa fields se não houver construtor.
  String _buildConstructorArgs(ClassElement sourceClass, ClassElement targetClass, List<String> imports) {
    final constructor = targetClass.unnamedConstructor;

    // Busca um field na hierarquia da classe (classe atual + supertipos),
    // dando preferência ao field declarado na própria classe concreta.
    FieldElement? _findFieldInHierarchy(InterfaceElement element, String name) {
      // Primeiro tenta na própria classe
      final ownField = element.fields.where((f) => f.name == name).firstOrNull;
      if (ownField != null) {
        return ownField;
      }

      // Depois procura nos supertipos, na ordem em que aparecem
      for (final superType in element.allSupertypes) {
        final superField = superType.element.fields.where((f) => f.name == name).firstOrNull;
        if (superField != null) {
          return superField;
        }
      }

      return null;
    }

    String buildValue(String paramOrFieldName, DartType targetParamType) {
      final sourceField = _findFieldInHierarchy(sourceClass, paramOrFieldName);

      if (sourceField != null) {
        // List<T>
        if (sourceField.type.isDartCoreList) {
          if (sourceField.type is ParameterizedType) {
            final type = sourceField.type as ParameterizedType;
            if (type.typeArguments.isNotEmpty) {
              final typeArgument = type.typeArguments.first;
              if (typeArgument.element is ClassElement) {
                final classElement = typeArgument.element as ClassElement;
                final annotation = _getAutoMapAnnotation(classElement);
                if (annotation != null) {
                  final targetChildType = annotation.getField('target')?.toTypeValue()?.getDisplayString();
                  return 'source.${sourceField.name}.map((item) => AutoMapper.convert<${classElement.name}, $targetChildType>(item)).toList()';
                }
              }
            }
          }
          // Caso padrão: passa o campo diretamente (ex.: List<String>, List<int>, enums ou List sem anotação)
          return 'source.${sourceField.name}';
        }

        // Tipo complexo com @AutoMap
        final ann = sourceField.type.element is ClassElement ? _getAutoMapAnnotation(sourceField.type.element as ClassElement) : null;
        if (ann != null) {
          final sourceChildType = sourceField.type.getDisplayString();
          final targetChildType = targetParamType.getDisplayString();

          if (sourceChildType.endsWith('?')) {
            final nullableSourceChildType = _ensureNullableTypeName(sourceChildType);
            final nullableTargetChildType = _ensureNullableTypeName(targetChildType);
            return 'source.${sourceField.name} == null ? null : AutoMapper.convert<$nullableSourceChildType, $nullableTargetChildType>(source.${sourceField.name})';
          }

          return 'AutoMapper.convert<$sourceChildType, $targetChildType>(source.${sourceField.name})';
        }

        // Tipos simples/pass-through
        return 'source.${sourceField.name}';
      }

      // Se não encontrou o field na origem, tenta default pelo field do alvo (para suportar @AutoMapFieldValue)
      final targetField = _findFieldInHierarchy(targetClass, paramOrFieldName);
      if (targetField != null) {
        return _defaultValueForField(targetField, imports);
      }
      return 'null';
    }

    if (constructor != null) {
      // Usa os parâmetros do construtor (posicionais e nomeados)
      final args = constructor.formalParameters.map((param) {
        final value = buildValue(param.name ?? '', param.type);
        if (param.isNamed) {
          return '${param.name}: $value,';
        } else {
          return '$value,';
        }
      }).join('\n');
      return args;
    }

    // Fallback: usa os fields do alvo como nomeados
    return targetClass.fields.map((field) {
      final value = buildValue(field.name ?? '', field.type);
      return '${field.name}: $value,';
    }).join('\n');
  }

  String _defaultValueForField(FieldElement field, List<String> imports) {
    final annotation = field.metadata.annotations.where(
          (meta) => meta.computeConstantValue()?.type?.getDisplayString() == 'AutoMapFieldValue'
    ).firstOrNull;

    if (annotation != null) {
      final defaultValue = annotation.computeConstantValue()?.getField('defaultValue');


      return defaultValue != null ? "${_getValueFromType(defaultValue, imports)}" : 'null';
    }
    return 'null';
  }

  dynamic _getValueFromType(DartObject value, List<String> imports) {
    if (value.isNull) {
      return null;
    }

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

      final list = value.toListValue() ?? [];

      final values = list.map((item) {
        return _getValueFromType(item, imports);
      }).join(', ');

      return '[$values]';
    }

    if (value.toMapValue() != null) {
      return value.toMapValue();
    }

    // Se for um objeto, retorna o valor do objeto
    if (value.type is InterfaceType) {
      final interfaceType = value.type as InterfaceType;
      final element = interfaceType.element;
      final className = element.name;

      // Pega o import do arquivo
      final import = value.type?.element?.library?.uri.toString();

      if (import != null) {
        final importStatement = "import '$import';";

        if (!imports.contains(importStatement)) {
          imports.add(importStatement);
        }
      }

      // Tratamento especial para enums: recupera o nome da constante a partir do campo 'index'
      final indexObj = value.getField('index');
      if (indexObj != null && indexObj.toIntValue() != null) {
        final idx = indexObj.toIntValue()!;
        final enumConstants = element.fields.where((f) => f.isEnumConstant).toList();
        if (idx >= 0 && idx < enumConstants.length) {
          final constName = enumConstants[idx].name;
          return '$className.$constName';
        }
      }

      // Caso não seja enum, monta a instância do objeto com seus campos
      final fields = element.fields;

      final fieldValues = fields.map((field) {
        final fieldValue = value.getField(field.name ?? '');

        if (fieldValue != null) {
          final fieldValueString = _getValueFromType(fieldValue, imports);

          return '${field.name}: $fieldValueString';
        }
        return '${field.name}: null';
      }).join(', ');

      return '$className($fieldValues)';
    }

    return value.toSymbolValue();
  }

  DartObject? _getAutoMapAnnotation(ClassElement element) {
    return element.metadata.annotations.map((meta) {
      return meta.computeConstantValue();
    }).firstWhere((value) {
      return value?.type?.getDisplayString() == 'AutoMap';
    }, orElse: () => null);
  }

  String _ensureNullableTypeName(String typeName) {
    return typeName.endsWith('?') ? typeName : '$typeName?';
  }

  AssetId _allFileOutput(BuildStep buildStep) {
    return AssetId(
      buildStep.inputId.package,
      p.join('lib', 'auto_mapper.dart'),
    );
  }
}

Builder autoMapperBuilder(BuilderOptions options) => AutoMapperGenerator();
