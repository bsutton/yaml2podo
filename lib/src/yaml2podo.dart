part of '../yaml2podo.dart';

class Yaml2PodoGenerator {
  static const String _converterTemplate = '''
class _JsonConverter {
  List fromList(dynamic data, dynamic Function(dynamic) toJson) {
    if (data == null) {
      return null;
    }

    var result = [];
    for (var element in data) {
      var value = toJson(element);
      result.add(value);
    }

    return result;
  }

  Map<String, dynamic> fromMap(dynamic data, dynamic Function(dynamic) toJson) {
    if (data == null) {
      return null;
    }

    var result = <String, dynamic>{};
    for (var key in data.keys) {
      var value = toJson(data[key]);
      result[key.toString()] = value;
    }

    return result;
  }

  DateTime toDateTime(dynamic data) {
    if (data == null) {
      return null;
    }

    if (data is String) {
      return DateTime.parse(data);
    }

    return data as DateTime;
  }

  double toDouble(dynamic data) {
    if (data == null) {
      return null;
    }

    if (data is int) {
      return data.toDouble();
    }

    return data as double;
  }

  List<T> toList<T>(dynamic data, T Function(dynamic) fromJson) {
    if (data == null) {
      return null;
    }

    var result = <T>[];
    for (var element in data) {
      T value;
      if (element != null) {
        value = fromJson(element);
      }

      result.add(value);
    }

    return result;
  }

  Map<K, V> toMap<K extends String, V>(
      dynamic data, V Function(dynamic) fromJson) {
    if (data == null) {
      return null;
    }

    var result = <K, V>{};
    for (var key in data.keys) {
      V value;
      var element = data[key];
      if (element != null) {
        value = fromJson(element);
      }

      result[key.toString() as K] = value;
    }

    return result;
  }
}
''';

  bool _camelize;

  Map<String, _TypeInfo> _classes;

  String _converterVariable;

  _TypeInfo _dynamicType;

  Set<String> _primitiveTypeNames;

  Set<String> _reservedWords;

  Map<String, _TypeInfo> _primitiveTypes;

  Map<String, _TypeInfo> _types;

  Yaml2PodoGenerator({bool camelize = true}) {
    if (camelize == null) {
      throw ArgumentError.notNull('camelize');
    }

    _camelize = camelize;
    _dynamicType = _createDynmaicType();
    _classes = {};
    _types = {};
    _converterVariable = '_jc';
    _primitiveTypes = {};
    _primitiveTypeNames = Set<String>.from([
      'bool',
      'DateTime',
      'double',
      'int',
      'num',
      'String',
    ]);

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

    for (var name in _primitiveTypeNames) {
      _primitiveTypes[name] = _createPrimitiveType(name);
    }
  }

  List<String> generate(Map source, {bool camelize = true}) {
    for (var key in source.keys) {
      var name = key.toString();
      var class_ = _parseTypeName(name);
      if (class_.typeArgs.isNotEmpty) {
        throw StateError('Generic types are not supported: ${class_.typeArgs}');
      }

      if (_classes.containsKey(class_.fullName)) {
        throw StateError('Duplicate type name: ${class_.fullName}');
      }

      if (class_.kind != _TypeKind.custom) {
        throw StateError('Unable to generate class: ${class_.fullName}');
      }

      _classes[class_.fullName] = class_;
      var props = source[key] as Map;
      if (props != null) {
        _parseProps(class_, props);
      }
    }

    for (var class_ in _classes.values) {
      for (var prop in class_.props.values) {
        var propType = prop.type;
        void walkTypes(_TypeInfo type) {
          if (_types.containsKey(type.fullName)) {
            return;
          }

          for (var typeArg in type.typeArgs) {
            walkTypes(typeArg);
          }

          switch (type.kind) {
            case _TypeKind.iterable:
            case _TypeKind.list:
            case _TypeKind.map:
              _types[type.fullName] = type;
              break;
            case _TypeKind.custom:
              if (!_classes.containsKey(type.fullName)) {
                throw StateError('Unknown type: ${type}');
              }

              break;
            default:
              break;
          }
        }

        switch (propType.kind) {
          case _TypeKind.bottom:
          case _TypeKind.object:
            break;
          case _TypeKind.iterable:
          case _TypeKind.list:
          case _TypeKind.map:
            walkTypes(propType);
            break;
          case _TypeKind.custom:
            if (!_classes.containsKey(propType.fullName)) {
              throw StateError('Unknown property type: ${propType}');
            }

            break;
          case _TypeKind.primitive:
            break;
          default:
            throw StateError('Unsupported property type: ${propType}');
        }
      }
    }

    var accessors = Set<String>();
    var classes = _classes.values.toList();
    classes.sort((e1, e2) => e1.fullName.compareTo(e2.fullName));
    var lines = <String>[];
    lines.add('final $_converterVariable = _JsonConverter();');
    lines.add('');
    for (var class_ in classes) {
      var className = class_.fullName;
      lines.add('class ${className} {');
      for (var prop in class_.props.values) {
        var propName = prop.name;
        var propType = prop.type.fullName;
        lines.add('  ${propType} ${propName};');
      }

      lines.add('');
      lines.add('  ${className}();');
      lines.add('');
      //
      lines.add('  factory ${className}.fromJson(Map map) {');
      lines.add('    var result = ${className}();');
      for (var prop in class_.props.values) {
        var propName = prop.name;
        var propType = prop.type;
        var alias = prop.alias;
        if (alias != null) {
          var escaped = _escapeIdentifier(alias);
          alias = escaped.replaceAll('\'', '\\\'');
        } else {
          alias = propName;
        }

        var reader = _getReader('map[\'$alias\']', propType);
        lines.add('    result.$propName = $reader;');
      }

      lines.add('    return result;');
      lines.add('}');
      lines.add('');
      //
      lines.add('  Map<String, dynamic> toJson() {');
      lines.add('    var result = <String, dynamic>{};');
      for (var prop in class_.props.values) {
        var propName = prop.name;
        var propType = prop.type;
        var alias = prop.alias;
        if (alias != null) {
          var escaped = _escapeIdentifier(alias);
          alias = escaped.replaceAll('\'', '\\\'');
        } else {
          alias = propName;
        }

        var writer = _getWriter('$propName', propType);
        lines.add('    result[\'$alias\'] = $writer;');
      }

      lines.add('    return result;');
      lines.add('}');
      lines.add('');
      //
      lines.add('}');
      lines.add('');
    }

    lines.addAll(LineSplitter().convert(_converterTemplate).toList());
    return lines;

    //
    //
    //

    for (var class_ in classes) {
      var className = class_.fullName;
      lines.add('  ..addType(() => ${className}())');
      for (var prop in class_.props.values) {
        accessors.add(prop.name);
      }
    }

    for (var type in _types.values) {
      var typeName = type.fullName;
      var typeArgs = type.typeArgs;
      switch (type.kind) {
        case _TypeKind.iterable:
        case _TypeKind.list:
          var typeArg0 = typeArgs[0].fullName;
          lines.add(
              '  ..addIterableType<${typeName}, ${typeArg0}>(() => <${typeArg0}>[])');
          break;
        case _TypeKind.map:
          var typeArg0 = typeArgs[0].fullName;
          var typeArg1 = typeArgs[1].fullName;
          lines.add(
              '  ..addMapType<${typeName}, ${typeArg0}, ${typeArg1}>(() => <${typeArg0}, ${typeArg1}>{})');
          break;
        default:
          throw StateError('Internal error');
          break;
      }
    }

    for (var name in accessors.toList()..sort()) {
      var escaped = _escapeIdentifier(name);
      lines.add(
          '  ..addAccessor(\'${escaped}\', (o) => o.${name}, (o, v) => o.${name} = v)');
    }

    for (var class_ in classes) {
      var className = class_.fullName;
      for (var prop in class_.props.values) {
        var propName = prop.name;
        var propType = prop.type.fullName;
        var alias = '';
        if (prop.alias != null) {
          var escaped = _escapeIdentifier(prop.alias);
          escaped = escaped.replaceAll('\'', '\\\'');
          alias = ', alias: \'${escaped}\'';
        }

        var escaped = _escapeIdentifier(propName);
        lines.add(
            '  ..addProperty<${className}, ${propType}>(\'${escaped}\'${alias})');
      }
    }

    lines.last = lines.last + ';';
    lines.add('');
    for (var class_ in classes) {
      var className = class_.fullName;
      lines.add('class ${className} {');
      for (var prop in class_.props.values) {
        var propTypeName = prop.type.fullName;
        var propName = prop.name;
        lines.add('  ${propTypeName} ${propName};');
      }

      lines.add('');
      lines.add('  ${className}();');
      lines.add('');
      lines.add('  factory ${className}.fromJson(Map map) {');
      lines.add('    return json.unmarshal<${className}>(map);');
      lines.add('  }');
      lines.add('');
      lines.add('  Map<String, dynamic> toJson() {');
      lines.add('    return json.marshal(this) as Map<String, dynamic>;');
      lines.add('  }');
      lines.add('}');
      lines.add('');
    }

    return lines;
  }

  void _analyzeType(_TypeInfo type) {
    var typeArgs = type.typeArgs;
    for (var typeArg in typeArgs) {
      _analyzeType(typeArg);
    }

    void checkTypeArgsCount(List<_TypeInfo> args) {
      if (typeArgs.isEmpty) {
        typeArgs.addAll(args);
        return;
      }

      if (typeArgs.length != args.length) {
        throw StateError('Wrong number of type arguments: $type');
      }
    }

    _TypeKind kind;
    switch (type.simpleName) {
      case 'dynamic':
        checkTypeArgsCount([]);
        kind = _TypeKind.bottom;
        break;
      case 'bool':
      case 'DateTime':
      case 'double':
      case 'int':
      case 'num':
      case 'String':
        checkTypeArgsCount([]);
        kind = _TypeKind.primitive;
        break;
      case 'Iterable':
        checkTypeArgsCount([_dynamicType]);
        kind = _TypeKind.iterable;
        break;
      case 'List':
        checkTypeArgsCount([_dynamicType]);
        kind = _TypeKind.list;
        break;
      case 'Map':
        checkTypeArgsCount([_primitiveTypes['String'], _dynamicType]);
        kind = _TypeKind.map;
        break;
      case 'Object':
        checkTypeArgsCount([]);
        kind = _TypeKind.object;
        break;
      default:
        kind = _TypeKind.custom;
    }

    type.kind = kind;
  }

  _TypeInfo _createDynmaicType() {
    var result = _TypeInfo();
    result.fullName = "dynamic";
    result.kind = _TypeKind.bottom;
    result.simpleName = "dynamic";
    return result;
  }

  _TypeInfo _createPrimitiveType(String name) {
    var result = _TypeInfo();
    result.fullName = name;
    result.kind = _TypeKind.primitive;
    result.simpleName = name;
    return result;
  }

  String _escapeIdentifier(String ident) {
    return ident.replaceAll('\$', '\\\$');
  }

  String _getReader(String source, _TypeInfo type) {
    var typeName = type.fullName;
    switch (type.kind) {
      case _TypeKind.bottom:
        return '$source';
      case _TypeKind.custom:
        return '$typeName.fromJson($source as Map)';
      case _TypeKind.iterable:
      case _TypeKind.list:
        var typeArgs = type.typeArgs;
        var reader = _getReader('e', typeArgs[0]);
        return '$_converterVariable.toList($source, (e) => $reader)';
      case _TypeKind.map:
        var typeArgs = type.typeArgs;
        var reader = _getReader('e', typeArgs[1]);
        return '$_converterVariable.toMap($source, (e) => $reader)';
      case _TypeKind.object:
        return '$source';
      case _TypeKind.primitive:
        switch (typeName) {
          case 'double':
            return '$_converterVariable.toDouble($source)';
          case 'DateTime':
            return '$_converterVariable.toDateTime($source)';
        }

        return '$source as $typeName';
      default:
        throw StateError('Unsupported type: $typeName');
    }
  }

  String _getWriter(String source, _TypeInfo type) {
    var typeName = type.fullName;
    switch (type.kind) {
      case _TypeKind.bottom:
        return '$source';
      case _TypeKind.custom:
        return '$source?.toJson()';
      case _TypeKind.iterable:
      case _TypeKind.list:
        var typeArgs = type.typeArgs;
        var writer = _getWriter('e', typeArgs[0]);
        return '$_converterVariable.fromList($source, (e) => $writer)';
      case _TypeKind.map:
        var typeArgs = type.typeArgs;
        var writer = _getWriter('e', typeArgs[1]);
        return '$_converterVariable.fromMap($source, (e) => $writer)';
      case _TypeKind.object:
        return '$source';
      case _TypeKind.primitive:
        switch (typeName) {
          case 'DateTime':
            return '$source?.toIso8601String()';
        }

        return '$source';
      default:
        throw StateError('Unsupported type: $typeName');
    }
  }

  void _parseProps(_TypeInfo type, Map data) {
    var names = Set<String>();
    var props = <String, _PropInfo>{};
    for (var key in data.keys) {
      var parts = key.toString().split('.');
      var alias = parts[0].trim();
      var name = alias;
      if (parts.length == 2) {
        alias = parts[1].trim();
      } else if (parts.length > 2) {
        throw StateError("Invalid property declaration: ${key}");
      }

      name = _utils.convertToIdentifier(name, '\$');
      if (_camelize) {
        name = _utils.camelizeIdentifier(name);
      }

      bool isReservedName(String ident) {
        if (_reservedWords.contains(name)) {
          return true;
        }

        if (_primitiveTypeNames.contains(name)) {
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

      var typeName = data[key].toString();
      var type = _parseTypeName(typeName);
      var prop = _PropInfo();
      prop.alias = alias;
      prop.name = name;
      prop.type = type;
      props[name] = prop;
    }

    type.props.addAll(props);
  }

  _TypeInfo _parseTypeName(String name) {
    var parser = _TypeParser();
    var type = parser.parse(name);
    _analyzeType(type);
    return type;
  }
}

class _PropInfo {
  String alias;
  String name;
  _TypeInfo type;

  @override
  String toString() => '$type $name';
}

class _Token {
  _TokenKind kind;
  int start;
  String text;

  @override
  String toString() => text;
}

enum _TokenKind { close, comma, eof, ident, open }

class _TypeInfo {
  String fullName;
  _TypeKind kind;
  Map<String, _PropInfo> props = {};
  String simpleName;
  List<_TypeInfo> typeArgs = [];

  @override
  String toString() => '$fullName';
}

enum _TypeKind { bottom, custom, iterable, list, map, object, primitive }

class _TypeParser {
  String _source;

  _Token _token;

  List<_Token> _tokens;

  int _pos;

  _TypeInfo parse(String source) {
    _source = source;
    var tokenizer = _TypeTokenizer();
    _tokens = tokenizer.tokenize(source);
    _reset();

    return _parseType();
  }

  void _match(_TokenKind kind) {
    if (_token.kind == kind) {
      _nextToken();
      return;
    }

    throw FormatException('Invalid type', _source, _token.start);
  }

  _Token _nextToken() {
    if (_pos + 1 < _tokens.length) {
      _token = _tokens[++_pos];
    }

    return _token;
  }

  List<_TypeInfo> _parseArgs() {
    var result = <_TypeInfo>[];
    var type = _parseType();
    result.add(type);
    while (true) {
      if (_token.kind != _TokenKind.comma) {
        break;
      }

      _nextToken();
      var type = _parseType();
      result.add(type);
    }

    return result;
  }

  _TypeInfo _parseType() {
    var simpleName = _token.text;
    _match(_TokenKind.ident);
    var args = <_TypeInfo>[];
    if (_token.kind == _TokenKind.open) {
      _nextToken();
      args = _parseArgs();
      _match(_TokenKind.close);
    }

    var result = _TypeInfo();
    result.simpleName = simpleName;
    result.fullName = simpleName;
    if (args.isNotEmpty) {
      var sb = StringBuffer();
      sb.write(simpleName);
      sb.write('<');
      sb.write(args.join(', '));
      sb.write('>');
      result.fullName = sb.toString();
    }

    result.typeArgs.addAll(args);
    return result;
  }

  void _reset() {
    _pos = 0;
    _token = _tokens[0];
  }
}

class _TypeTokenizer {
  static const _eof = 0;

  int _ch;

  int _pos;

  String _source;

  List<_Token> tokenize(String source) {
    _source = source;
    var tokens = <_Token>[];
    _reset();
    while (true) {
      _white();
      String text;
      _TokenKind kind;
      if (_ch == _eof) {
        kind = _TokenKind.eof;
        text = '';
        break;
      }

      var start = _pos;
      switch (_ch) {
        case 44:
          text = ',';
          kind = _TokenKind.comma;
          _nextCh();
          break;
        case 60:
          text = '<';
          kind = _TokenKind.open;
          _nextCh();
          break;
        case 62:
          text = '>';
          kind = _TokenKind.close;
          _nextCh();
          break;
        default:
          if (_utils.alpha(_ch) || _ch == 36 || _ch == 95) {
            var length = 1;
            _nextCh();
            while (_utils.alphanum(_ch) || _ch == 36 || _ch == 95) {
              length++;
              _nextCh();
            }

            text = source.substring(start, start + length);
            kind = _TokenKind.ident;
          } else {
            throw FormatException('Invalid type', source, start);
          }
      }

      var token = _Token();
      token.kind = kind;
      token.start = start;
      token.text = text;
      tokens.add(token);
    }

    return tokens;
  }

  int _nextCh() {
    if (_pos + 1 < _source.length) {
      _ch = _source.codeUnitAt(++_pos);
    } else {
      _ch = _eof;
    }

    return _ch;
  }

  void _reset() {
    _pos = 0;
    _ch = _eof;
    if (_source.isNotEmpty) {
      _ch = _source.codeUnitAt(0);
    }
  }

  void _white() {
    while (true) {
      if (_ch == 32) {
        _nextCh();
      } else {
        break;
      }
    }
  }
}
