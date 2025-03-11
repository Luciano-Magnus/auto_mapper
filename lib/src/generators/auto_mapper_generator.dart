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
        final targetImport = annotation.getField('target')?.toTypeValue()?.element?.librarySource?.uri.toString();

        final classImport = element.source.uri.toString();

        if (targetType != null) {
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
                ${element.fields.map((field) {
            //Verifica se o campo é uma lista de objetos
            if (field.type.isDartCoreList) {
              final type = field.type as ParameterizedType;

              final typeArguments = type.typeArguments;
              final typeArgument = typeArguments.first;

              if (typeArgument.element is ClassElement) {
                final classElement = typeArgument.element as ClassElement;
                final annotation = _getAutoMapAnnotation(classElement);

                if (annotation != null) {
                  final targetChildType = annotation.getField('target')?.toTypeValue()?.getDisplayString(withNullability: false);

                  return '${field.name}: source.${field.name}.map((item) => AutoMapper.convert<${classElement.name}, $targetChildType>(item)).toList()';
                }
              }
            } else {
              //Verifica se o campo é um objeto com a anotação AutoMap
              final annotation = field.type.element is ClassElement ? _getAutoMapAnnotation(field.type.element as ClassElement) : null;

              if (annotation != null) {
                final targetChildType = annotation.getField('target')?.toTypeValue()?.getDisplayString(withNullability: false);

                return '${field.name}: AutoMapper.convert<${field.type.element?.name ?? ''}, $targetChildType>(source.${field.name})';
              } else {
                return '${field.name}: source.${field.name}';
              }
            }
          }).join(',\n')}
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
