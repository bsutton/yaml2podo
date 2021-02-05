part of '../../yaml2podo_generator.dart';

class Yaml2PodoGenerator {
  bool camelize;

  late final TypeDeclaration _dynamicType;

  bool immutable;

  final Map<String, TypeDeclaration> _builtinTypes = {};

  final Set<String> _objectTypeNames = {};

  final Set<String> _reservedWords = {};

  final List<String> _stages = [];

  final Map<String, TypeDeclaration> _types = {};

  Yaml2PodoGenerator({this.camelize = true, this.immutable = true}) {
    final builtinTypeNames = <String>[
      'bool',
      'DateTime',
      'double',
      'dynamic',
      'int',
      'num',
      'Object',
      'String',
    ];

    _reservedWords.addAll(const [
      'assert',
      'break',
      'case',
      'catch',
      'class',
      'const',
      'continue',
      'default',
      'do',
      'else',
      'enum',
      'extends',
      'false',
      'final',
      'finally',
      'for',
      'if',
      'in',
      'is',
      'late',
      'new',
      'null',
      'rethrow',
      'return',
      'super',
      'switch',
      'this',
      'throw',
      'true',
      'try',
      'var',
      'void',
      'while',
      'with'
    ]);

    for (var name in builtinTypeNames) {
      final type = _createBuiltinType(name);
      _builtinTypes[name] = type;
      _types[name] = type;
    }

    _dynamicType = _builtinTypes['dynamic']!;
  }

  List<String> generate(Map source, {bool camelize = true}) {
    _stages.clear();
    for (var key in source.keys) {
      final name = key.toString();
      _addStage('Parsing data object type declaration \'$name\'');
      var type = _parseTypeName(name);
      if (type.arguments.isNotEmpty) {
        _error('Generic types are not supported');
      }

      if (_isCollectionTypeName(type.name)) {
        _error('Identifier \'$name\' cannot be used as the type name');
      }

      if (!_objectTypeNames.add(type.toString())) {
        _error('Duplicate type name');
      }

      type = _registerType(type);
      if (!type.isCustomType) {
        _error('Unable to register type \'$type\'');
      }

      if (!type.isUnknownType) {
        _error('Internal error');
      }

      type.isUnknownType = false;
      final properties = source[key];
      if (properties is Map) {
        _parseProperties(type, properties);
      } else if (properties is List) {
        _parseEnumValues(type, properties);
      } else if (properties == null) {
        //
      } else {
        _error(
            'Invalid yaml declaration format: \'${properties.runtimeType}\'');
      }

      _removeStage();
    }

    _analyzeTypes();
    final result = _generateCode();
    return result;
  }

  void _addStage(String stage) {
    _stages.add(stage);
  }

  TypeDeclaration _analyzeType(
      TypeDeclaration type, Set<TypeDeclaration> processed) {
    type = _registerType(type);
    if (!processed.add(type)) {
      return type;
    }

    final arguments = type.arguments;
    for (var i = 0; i < arguments.length; i++) {
      final argument = arguments[i];
      arguments[i] = _analyzeType(argument, processed);
    }

    void checkNumberOfTypeArguments(List<TypeDeclaration> args) {
      if (arguments.isEmpty) {
        arguments.addAll(args);
        return;
      }

      if (arguments.length != args.length) {
        _error('Wrong number of type arguments \'$type\'');
      }
    }

    switch (type.name) {
      case 'dynamic':
      case 'bool':
      case 'DateTime':
      case 'double':
      case 'int':
      case 'num':
      case 'Object':
      case 'String':
        checkNumberOfTypeArguments([]);
        break;
      case 'Iterable':
      case 'List':
        checkNumberOfTypeArguments([_dynamicType]);
        break;
      case 'Map':
        checkNumberOfTypeArguments([_types['String']!, _dynamicType]);
        break;
    }

    return type;
  }

  void _analyzeTypes() {
    void _walkTypes(TypeDeclaration type, Set<TypeDeclaration> processed) {
      if (!processed.add(type)) {
        return;
      }

      if (type.isUnknownType) {
        if (!_isCollectionTypeName(type.name)) {
          _error('Unknown type \'$type\'');
        }
      }

      for (var argument in type.arguments) {
        _walkTypes(argument, processed);
      }
    }

    _addStage('Analyzing types');
    final processed = <TypeDeclaration>{};
    for (var name in _objectTypeNames) {
      final type = _types[name]!;
      _addStage('Analyzing type \'$type\'');
      for (var property in type.properties.values) {
        _addStage('Analyzing prorerty \'$property\'');
        _walkTypes(property.type, processed);
        _removeStage();
      }

      _removeStage();
    }

    _removeStage();
  }

  TypeDeclaration _createBuiltinType(String name) {
    final result = TypeDeclaration(name: name);
    result.isCustomType = false;
    result.isUnknownType = false;
    return result;
  }

  void _error(String message) {
    final sb = StringBuffer();
    for (var stage in _stages) {
      sb.writeln(stage);
    }

    sb.write(message);
    throw FormatException(sb.toString());
  }

  TypeDeclaration? _findType(TypeDeclaration type) {
    return _types[type.toString()];
  }

  List<String> _generateCode() {
    final classes = _objectTypeNames.toList();
    classes.sort();
    final dartCodeGenerator = DartCodeGenerator();
    final types = <TypeDeclaration>[];
    for (var name in classes) {
      final type = _types[name]!;
      types.add(type);
    }

    final result = dartCodeGenerator.generate(types);
    return result;
  }

  bool _isCollectionTypeName(String name) {
    return const {'Iterable', 'List', 'Map'}.contains(name);
  }

  void _parseEnumValues(TypeDeclaration type, List values) {
    void errorInvalidValueName(String name) {
      _error('Inavlid value name');
    }

    type.isEnumType = true;
    final names = <String>{};
    for (var value in values) {
      _addStage('Parsing enum value \'$value\'');
      if (value is String) {
        if (value.isEmpty) {
          _error('Value name must not be empty');
        }

        if (!_utils.alpha(value.codeUnitAt(0))) {
          errorInvalidValueName(value);
        }

        for (var c in value.codeUnits) {
          if (!(_utils.alpha(c) || c == 95)) {
            errorInvalidValueName(value);
          }
        }

        final parts = value.toString().split('.');
        String? alias = parts[0].trim();
        final name = alias;
        if (parts.length == 2) {
          alias = parts[1].trim();
        } else if (parts.length > 2) {
          errorInvalidValueName(value);
        }

        if (!names.add(name)) {
          _error('Duplicate value');
        }

        if (alias == name) {
          alias = null;
        }

        final property = PropertyDeclaration(name: name, type: type);
        property.alias = alias;
        type.properties[name] = property;
      } else {
        errorInvalidValueName(value.toString());
      }
    }
  }

  void _parseProperties(TypeDeclaration type, Map data) {
    final names = <String>{};
    final properties = <String, PropertyDeclaration>{};
    for (var key in data.keys) {
      _addStage('Parsing property \'$key\'');
      final parts = key.toString().split('.');
      String? alias = parts[0].trim();
      var name = alias;
      if (parts.length == 2) {
        alias = parts[1].trim();
      } else if (parts.length > 2) {
        _error('Invalid property identifier declaration');
      }

      name = _utils.convertToIdentifier(name, '\$');
      if (camelize) {
        name = _utils.camelizeIdentifier(name);
      }

      if (name.isNotEmpty && name[0] == name[0].toUpperCase()) {
        name = name[0].toLowerCase() + name.substring(1);
      }

      bool isReservedName(String ident) {
        if (_reservedWords.contains(name)) {
          return true;
        }

        if (_builtinTypes.containsKey(name)) {
          return true;
        }

        if (_isCollectionTypeName(name)) {
          return true;
        }

        return false;
      }

      name = _utils.makePublicIdentifier(name, 'anon');
      if (names.contains(name) || isReservedName(name)) {
        while (true) {
          name += '_';
          if (!names.contains(name) && !isReservedName(name)) {
            break;
          }
        }
      }

      names.add(name);
      if (alias == name) {
        alias = null;
      }

      final type = _parseTypeName(data[key].toString());
      final property = PropertyDeclaration(name: name, type: type);
      property.alias = alias;
      property.isFinal = immutable;
      properties[name] = property;
      _removeStage();
    }

    Map<K, V> sortMap<K, V>(Map<K, V> map) {
      final result = <K, V>{};
      final keys = map.keys.toList();
      keys.sort();
      for (var key in keys) {
        result[key] = map[key]!;
      }

      return result;
    }

    type.properties.addAll(sortMap(properties));
  }

  TypeDeclaration _parseTypeName(String name) {
    if (_reservedWords.contains(name)) {
      _error('Identifier \'name\' cannot be used as a type name');
    }

    final parser = TypeParser();
    var type = parser.parse(name);
    type = _analyzeType(type, {});
    return type;
  }

  TypeDeclaration _registerType(TypeDeclaration type) {
    final foundType = _findType(type);
    if (foundType != null) {
      return foundType;
    }

    _types[type.toString()] = type;
    return type;
  }

  void _removeStage() {
    _stages.removeLast();
  }
}
