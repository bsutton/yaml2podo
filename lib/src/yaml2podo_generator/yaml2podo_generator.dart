part of '../../yaml2podo_generator.dart';

class Yaml2PodoGenerator {
  bool _camelize;

  TypeDeclaration _dynamicType;

  bool _immutable;

  Map<String, TypeDeclaration> _builtinTypes;

  Set<String> _objectTypeNames;

  Set<String> _reservedWords;

  List<String> _stages;

  Map<String, TypeDeclaration> _types;

  Yaml2PodoGenerator({bool camelize = true, bool immutable = true}) {
    if (camelize == null) {
      throw ArgumentError.notNull('camelize');
    }

    if (immutable == null) {
      throw ArgumentError.notNull('immutable');
    }

    _camelize = camelize;
    _immutable = immutable;
    _objectTypeNames = {};
    _stages = [];
    _types = {};
    _builtinTypes = {};
    var builtinTypeNames = <String>[
      'bool',
      'DateTime',
      'double',
      'dynamic',
      'int',
      'num',
      'Object',
      'String',
    ];

    _reservedWords = Set<String>.from([
      "assert",
      "break",
      "case",
      "catch",
      "class",
      "const",
      "continue",
      "default",
      "do",
      "else",
      "enum",
      "extends",
      "false",
      "final",
      "finally",
      "for",
      "if",
      "in",
      "is",
      "late",
      "new",
      "null",
      "rethrow",
      "return",
      "super",
      "switch",
      "this",
      "throw",
      "true",
      "try",
      "var",
      "void",
      "while",
      "with",
    ]);

    for (var name in builtinTypeNames) {
      var type = _createBuiltinType(name);
      _builtinTypes[name] = type;
      _types[name] = type;
    }

    _dynamicType = _builtinTypes['dynamic'];
  }

  List<String> generate(Map source, {bool camelize = true}) {
    _stages.clear();
    for (var key in source.keys) {
      var name = key.toString();
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
      var properties = source[key];
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
    var result = _generateCode();
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

    var arguments = type.arguments;
    for (var i = 0; i < arguments.length; i++) {
      var argument = arguments[i];
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
        checkNumberOfTypeArguments([_types['String'], _dynamicType]);
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
    var processed = <TypeDeclaration>{};
    for (var name in _objectTypeNames) {
      var type = _types[name];
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
    var result = TypeDeclaration();
    result.name = name;
    result.isCustomType = false;
    result.isUnknownType = false;
    return result;
  }

  void _error(String message) {
    var sb = StringBuffer();
    for (var stage in _stages) {
      sb.writeln(stage);
    }

    sb.write(message);
    throw FormatException(sb.toString());
  }

  TypeDeclaration _findType(TypeDeclaration type) {
    return _types[type.toString()];
  }

  List<String> _generateCode() {
    var classes = _objectTypeNames.toList();
    classes.sort();
    var dartCodeGenerator = DartCodeGenerator();
    var types = <TypeDeclaration>[];
    for (var name in classes) {
      var type = _types[name];
      types.add(type);
    }

    var result = dartCodeGenerator.generate(types);
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
    var names = Set<String>();
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

        var parts = value.toString().split('.');
        var alias = parts[0].trim();
        var name = alias;
        if (parts.length == 2) {
          alias = parts[1].trim();
        } else if (parts.length > 2) {
          errorInvalidValueName(value);
        }

        if (!names.add(name)) {
          _error("Duplicate value");
        }

        if (alias == name) {
          alias = null;
        }

        var property = PropertyDeclaration();
        property.alias = alias;
        property.name = name;
        property.type = type;
        type.properties[name] = property;
      } else {
        errorInvalidValueName(value.toString());
      }
    }
  }

  void _parseProperties(TypeDeclaration type, Map data) {
    var names = Set<String>();
    var properties = <String, PropertyDeclaration>{};
    for (var key in data.keys) {
      _addStage('Parsing property \'$key\'');
      var parts = key.toString().split('.');
      var alias = parts[0].trim();
      var name = alias;
      if (parts.length == 2) {
        alias = parts[1].trim();
      } else if (parts.length > 2) {
        _error("Invalid property identifier declaration");
      }

      name = _utils.convertToIdentifier(name, '\$');
      if (_camelize) {
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

      var type = _parseTypeName(data[key].toString());
      var property = PropertyDeclaration();
      property.alias = alias;
      property.name = name;
      property.type = type;
      property.isFinal = _immutable;
      properties[name] = property;
      _removeStage();
    }

    Map<K, V> sortMap<K, V>(Map<K, V> map) {
      var result = <K, V>{};
      var keys = map.keys.toList();
      keys.sort();
      for (var key in keys) {
        result[key] = map[key];
      }

      return result;
    }

    type.properties.addAll(sortMap(properties));
  }

  TypeDeclaration _parseTypeName(String name) {
    if (_reservedWords.contains(name)) {
      _error('Identifier \'name\' cannot be used as a type name');
    }

    var parser = TypeParser();
    var type = parser.parse(name);
    type = _analyzeType(type, {});
    return type;
  }

  TypeDeclaration _registerType(TypeDeclaration type) {
    var foundType = _findType(type);
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
