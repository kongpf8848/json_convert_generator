import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'template.dart';

Builder jsonConvertBuilder(BuilderOptions options) {
  return JsonConvertBuilder();
}

/// Class information for code generation
class ClassInfo {
  final String name;
  final int typeParamsCount;
  final String libraryPath;

  ClassInfo({
    required this.name,
    required this.typeParamsCount,
    required this.libraryPath,
  });
}

class JsonConvertBuilder extends Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
    r'$lib$': ['utils/json_convert.generator.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final annotatedClasses = <String, ClassInfo>{};
    final packageName = buildStep.inputId.package;

    // Scan all lib dart files
    final allLibFiles = buildStep.findAssets(Glob('lib/**/*.dart'));

    await for (final assetId in allLibFiles) {
      // Skip generated files and utils
      if (assetId.path.endsWith('.g.dart') ||
          assetId.path.endsWith('.freezed.dart') ||
          assetId.path.startsWith('lib/utils/')) {
        continue;
      }

      try {
        final library = await buildStep.resolver.libraryFor(assetId);
        for (final clazz in _collectClassesFromLibrary(library)) {
          if (_hasTargetAnnotation(clazz)) {
            final info = _extractClassInfo(clazz, assetId);
            if (info != null) {
              annotatedClasses[clazz.name ?? ''] = info;
            }
          }
        }
      } catch (e) {
        // Skip files that can't be resolved
      }
    }

    var content = "";
    if (annotatedClasses.isEmpty) {
      content = _generateEmptyContent();
    } else {
      content = _generateContent(annotatedClasses, packageName);
    }
    await buildStep.writeAsString(
      AssetId(packageName, 'lib/utils/json_convert.generator.dart'),
      content,
    );
  }

  /// Check if class has @JsonSerializable annotation
  bool _hasTargetAnnotation(ClassElement clazz) {
    // Check if it has a fromJson factory/static method with
    // a single Map<String, dynamic> parameter.
    for (final constructor in clazz.constructors) {
      if (constructor.name == 'fromJson' &&
          _isValidFromJsonSignature(constructor)) {
        return true;
      }
    }

    for (final method in clazz.methods) {
      if (method.name == 'fromJson' && _isValidFromJsonSignature(method)) {
        return true;
      }
    }

    return false;
  }

  bool _isValidFromJsonSignature(ExecutableElement executable) {
    final parameters = _getExecutableParameters(executable);

    if (parameters.length != 1) {
      return false;
    }

    final parameterType = (parameters.first as dynamic).type;
    return parameterType.getDisplayString() == 'Map<String, dynamic>';
  }

  List<dynamic> _getExecutableParameters(ExecutableElement executable) {
    final dynamic target = executable;

    // analyzer API compatibility:
    // - old: ExecutableElement.parameters
    // - some variants: formalParameters
    try {
      final value = target.parameters;
      if (value is List) {
        return List<dynamic>.from(value);
      }
    } catch (_) {}

    try {
      final value = target.formalParameters;
      if (value is List) {
        return List<dynamic>.from(value);
      }
    } catch (_) {}

    return <dynamic>[];
  }

  Iterable<ClassElement> _collectClassesFromLibrary(dynamic library) {
    final classes = <ClassElement>[];

    // analyzer old/new API compatibility:
    // 1) library.classes
    // 2) library.topLevelElements (filter ClassElement)
    // 3) library.units -> unit.classes
    void addIfClassElements(dynamic value) {
      if (value is Iterable) {
        for (final element in value) {
          if (element is ClassElement) {
            classes.add(element);
          }
        }
      }
    }

    try {
      addIfClassElements(library.classes);
    } catch (_) {}

    if (classes.isNotEmpty) {
      return classes;
    }

    try {
      addIfClassElements(library.topLevelElements);
    } catch (_) {}

    if (classes.isNotEmpty) {
      return classes;
    }

    try {
      final units = library.units;
      if (units is Iterable) {
        for (final unit in units) {
          addIfClassElements((unit as dynamic).classes);
        }
      }
    } catch (_) {}

    return classes;
  }

  /// Extract class information for conversion
  ClassInfo? _extractClassInfo(ClassElement clazz, AssetId assetId) {
    // Get type parameters count
    final typeParamsCount = clazz.typeParameters.length;
    return ClassInfo(
      name: clazz.name ?? 'Unknown',
      typeParamsCount: typeParamsCount,
      libraryPath: assetId.path,
    );
  }

  String _generateEmptyContent() {
    return JsonConvertTemplates.emptyContent;
  }

  String _generateContent(Map<String, ClassInfo> classes, String packageName) {
    // Build imports from unique library paths.
    final uniqueLibs = <String>{};
    for (final clazz in classes.values) {
      final lib = clazz.libraryPath.replaceFirst('lib/', '');
      uniqueLibs.add(lib);
    }
    final imports = (uniqueLibs.toList()..sort())
        .map((lib) => "import 'package:$packageName/$lib';")
        .join('\n');

    final sortedEntries = classes.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final listEntries = sortedEntries
        .map((entry) => _buildListEntry(entry.key, entry.value.typeParamsCount))
        .join('\n');

    final convertEntries = sortedEntries
        .map(
          (entry) => _buildConvertEntry(entry.key, entry.value.typeParamsCount),
        )
        .join('\n');

    return _renderTemplate(JsonConvertTemplates.content, {
      'imports': imports,
      'listEntries': listEntries,
      'convertEntries': convertEntries,
    });
  }

  String _buildListEntry(String className, int typeParamsCount) {
    final template = typeParamsCount > 0
        ? JsonConvertTemplates.genericListEntry
        : JsonConvertTemplates.nonGenericListEntry;
    return _renderTemplate(template, {'className': className});
  }

  String _buildConvertEntry(String className, int typeParamsCount) {
    final template = typeParamsCount > 0
        ? JsonConvertTemplates.genericConvertEntry
        : JsonConvertTemplates.nonGenericConvertEntry;
    return _renderTemplate(template, {'className': className});
  }

  String _renderTemplate(String template, Map<String, String> variables) {
    var rendered = template;
    variables.forEach((key, value) {
      rendered = rendered.replaceAll('{{$key}}', value);
    });
    return rendered;
  }
}
