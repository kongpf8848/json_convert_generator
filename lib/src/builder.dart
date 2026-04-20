import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'template.dart';

Builder jsonConvertBuilder(BuilderOptions options) {
  return JsonConvertBuilder(options);
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
  final BuilderOptions options;

  JsonConvertBuilder(this.options);

  @override
  Map<String, List<String>> get buildExtensions => {
    r'$lib$': ['utils/json_convert.generator.dart'],
  };

  /// Get scan directories from builder options
  /// Default to ['lib'] if not specified
  List<String> get _scanDirectories {
    final dirs = options.config['scan_directories'];
    if (dirs == null) {
      return ['lib'];
    }
    if (dirs is List) {
      return dirs.whereType<String>().toList();
    }
    if (dirs is String) {
      return [dirs];
    }
    return ['lib'];
  }

  /// Get exclude patterns from builder options
  List<String> get _excludePatterns {
    final excludes = options.config['exclude_patterns'];
    if (excludes == null) {
      return ['*.g.dart', '*.freezed.dart'];
    }
    if (excludes is List) {
      return excludes.whereType<String>().toList();
    }
    return ['*.g.dart', '*.freezed.dart'];
  }

  /// Check if a file path should be excluded based on patterns
  bool _shouldExclude(String path) {
    final patterns = _excludePatterns;
    for (final pattern in patterns) {
      if (pattern.contains('/')) {
        // Path pattern (e.g., "lib/utils/")
        if (path.startsWith(pattern)) {
          return true;
        }
      } else {
        // File name pattern (e.g., "*.g.dart")
        final regex = RegExp(
          pattern.replaceAll('.', r'\.').replaceAll('*', '.*') + r'$',
        );
        if (regex.hasMatch(path)) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    final annotatedClasses = <String, ClassInfo>{};
    final packageName = buildStep.inputId.package;

    final scanDirs = _scanDirectories;

    // If no scan directories specified, skip scanning
    if (scanDirs.isEmpty) {
      await buildStep.writeAsString(
        AssetId(packageName, 'lib/utils/json_convert.generator.dart'),
        _generateEmptyContent(),
      );
      return;
    }

    // Scan all specified directories
    final allFiles = <AssetId>[];
    for (final dir in scanDirs) {
      final globPattern = dir.startsWith('lib/') || dir == 'lib'
          ? '$dir/**/*.dart'
          : 'lib/$dir/**/*.dart';
      await for (final assetId in buildStep.findAssets(Glob(globPattern))) {
        allFiles.add(assetId);
      }
    }

    for (final assetId in allFiles) {
      // Skip generated files based on exclude patterns
      if (_shouldExclude(assetId.path)) {
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
        print('+++++++++++++++Error resolving $assetId: $e');
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

    // Support both non-generic (1 param) and generic (2 params) fromJson
    if (parameters.isEmpty || parameters.length > 2) {
      return false;
    }

    // First parameter must be Map<String, dynamic> or Map<String, Object?>
    final firstParamType = (parameters.first as dynamic).type;
    final firstTypeString = _getTypeDisplayString(firstParamType);
    final isValidFirstParam = firstTypeString == 'Map<String, dynamic>' ||
        firstTypeString == 'Map<String, Object?>';

    if (!isValidFirstParam) {
      return false;
    }

    // If has 2nd parameter, it should be a function type (generic deserializer)
    if (parameters.length == 2) {
      final secondParamType = (parameters[1] as dynamic).type;
      final secondTypeString = _getTypeDisplayString(secondParamType);
      // Check if it's a function type like "T Function(Object?)" or "T Function(dynamic)"
      if (!secondTypeString.contains('Function')) {
        return false;
      }
    }

    return true;
  }

  /// Get type display string with analyzer API compatibility
  String _getTypeDisplayString(dynamic type) {
    // analyzer API compatibility:
    // - old: getDisplayString()
    // - new: getDisplayString(withNullability: bool)
    try {
      return type.getDisplayString(withNullability: true);
    } catch (_) {}

    try {
      return type.getDisplayString();
    } catch (_) {}

    return '';
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
