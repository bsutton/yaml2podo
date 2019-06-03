part of '../yaml2podo.dart';

class Yaml2PodoGenerator {
  static const String _factoryFromJson = '''
  factory {{NAME}}.fromJson(Map map) {
    return {{NAME}}(
{{ARGUMENTS}});
  }''';

  static const String _methodFromDateTime = '''
String _fromDateTime(dynamic data) {
  if (data == null) {
    return null;
  }
  if (data is DateTime) {
    return data.toIso8601String();
  }
  return data as String;
}''';

  static const String _methodFromList = '''
List _fromList(dynamic data, dynamic Function(dynamic) toJson) {
  if (data == null) {
    return null;
  }
  var result = [];
  for (var element in data) {
    var value;
    if (element != null) {
      value = toJson(element);
    }
    result.add(value);
  }
  return result;
}''';

  static const String _methodFromMap = '''
Map<String, dynamic> _fromMap(dynamic data, dynamic Function(dynamic) toJson) {
  if (data == null) {
    return null;
  }
  var result = <String, dynamic>{};
  for (var key in data.keys) {
    var value;
    var element = data[key];
    if (element != null) {
      value = toJson(element);
    }
    result[key.toString()] = value;
  }
  return result;
}''';

  static const String _methodToDateTime = '''
DateTime _toDateTime(dynamic data) {
  if (data == null) {
    return null;
  }
  if (data is String) {
    return DateTime.parse(data);
  }
  return data as DateTime;
}''';

  static const String _methodToDouble = '''
double _toDouble(dynamic data) {
  if (data == null) {
    return null;
  }
  if (data is int) {
    return data.toDouble();
  }
  return data as double;
}''';

  static const String _methodToList = '''
List<T> _toList<T>(dynamic data, T Function(dynamic) fromJson) {
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
}''';

  static const String _methodToMap = '''
Map<K, V> _toMap<K extends String, V>(
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
}''';

  static const String _methodToObject = '''
T _toObject<T>(dynamic data, T Function(dynamic) fromJson) {
  if (data == null) {
    return null;
  }
  return fromJson(data);
}''';

  Set<String> _usedMethods;

  final String version = '0.1.11';

  bool _camelize;

  Map<String, _TypeInfo> _classes;

  _TypeInfo _dynamicType;

  bool _immutable;

  Set<String> _primitiveTypeNames;

  Set<String> _reservedWords;

  Map<String, _TypeInfo> _primitiveTypes;

  Map<String, _TypeInfo> _types;

  Yaml2PodoGenerator({bool camelize = true, bool immutable = true}) {
    if (camelize == null) {
      throw ArgumentError.notNull('camelize');
    }

    if (immutable == null) {
      throw ArgumentError.notNull('immutable');
    }

    _camelize = camelize;
    _immutable = immutable;
    _dynamicType = _createDynmaicType();
    _classes = {};
    _types = {};
    _usedMethods = Set<String>();
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

  List<String> _generateContructor(_TypeInfo type) {
    var result = <String>[];
    var paramters = <String>[];
    for (var prop in type.props.values) {
      paramters.add('this.${prop.name}');
    }

    result.add('  ${type.fullName}({${paramters.join(', ')}});');
    return result;
  }

  List<String> _generateFactoryFromJson(_TypeInfo type) {
    var template = _factoryFromJson;
    template = template.replaceAll('{{NAME}}', type.fullName);
    var arguments = <String>[];
    var props = type.props;
    for (var prop in props.values) {
      var propName = prop.name;
      var propType = prop.type;
      var alias = prop.alias;
      if (alias != null) {
        var escaped = _escapeIdentifier(alias);
        alias = escaped.replaceAll('\'', '\\\'');
      } else {
        alias = propName;
      }

      var reader = _getReader('map[\'$alias\']', propType, true);
      arguments.add('      $propName: $reader');
    }

    template = template.replaceAll('{{ARGUMENTS}}', arguments.join(',\n'));
    return LineSplitter().convert(template).toList();
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

    var classes = _classes.values.toList();
    classes.sort((e1, e2) => e1.fullName.compareTo(e2.fullName));
    var lines = <String>[];
    lines.add('');
    for (var class_ in classes) {
      var className = class_.fullName;
      lines.add('class ${className} {');
      for (var prop in class_.props.values) {
        var propName = prop.name;
        var propType = prop.type.fullName;
        if (_immutable) {
          lines.add('  final ${propType} ${propName};');
        } else {
          lines.add('  ${propType} ${propName};');
        }
      }

      lines.add('');
      lines.addAll(_generateContructor(class_));
      lines.add('');
      //
      lines.addAll(_generateFactoryFromJson(class_));
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

        var writer = _getWriter('$propName', propType, true);
        lines.add('    result[\'$alias\'] = $writer;');
      }

      lines.add('    return result;');
      lines.add('  }');
      lines.add('');
      //
      lines.add('}');
      lines.add('');
    }

    lines.addAll(_generateMethods());
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

  List<String> _generateMethods() {
    var result = <String>[];
    var names = _usedMethods.toList()..sort();
    String template;
    for (var name in names) {
      switch (name) {
        case 'fromDateTime':
          template = _methodFromDateTime;
          break;
        case 'fromList':
          template = _methodFromList;
          break;
        case 'fromMap':
          template = _methodFromMap;
          break;
        case 'toDateTime':
          template = _methodToDateTime;
          break;
        case 'toDouble':
          template = _methodToDouble;
          break;
        case 'toList':
          template = _methodToList;
          break;
        case 'toMap':
          template = _methodToMap;
          break;
        case 'toObject':
          template = _methodToObject;
          break;
        default:
          throw StateError('Unknown methos name: $name');
      }

      result.addAll(LineSplitter().convert(template).toList());
    }

    return result;
  }

  String _getReader(String source, _TypeInfo type, bool canBeNull) {
    var typeName = type.fullName;
    switch (type.kind) {
      case _TypeKind.bottom:
        return '$source';
      case _TypeKind.custom:
        var reader = '$typeName.fromJson(e as Map)';
        if (canBeNull) {
          return _methodCall('toObject', [source, reader]);
        }

        return reader;
      case _TypeKind.iterable:
      case _TypeKind.list:
        var typeArgs = type.typeArgs;
        var reader = _getReader('e', typeArgs[0], false);
        return _methodCall('toList', [source, reader]);
      case _TypeKind.map:
        var typeArgs = type.typeArgs;
        var reader = _getReader('e', typeArgs[1], false);
        return _methodCall('toMap', [source, reader]);
      case _TypeKind.object:
        return '$source';
      case _TypeKind.primitive:
        switch (typeName) {
          case 'double':
            return _methodCall('toDouble', [source]);
          case 'DateTime':
            return _methodCall('toDateTime', [source]);
        }

        return '$source as $typeName';
      default:
        throw StateError('Unsupported type: $typeName');
    }
  }

  String _getWriter(String source, _TypeInfo type, bool canBeNull) {
    var typeName = type.fullName;
    switch (type.kind) {
      case _TypeKind.bottom:
        return '$source';
      case _TypeKind.custom:
        if (canBeNull) {
          return '$source?.toJson()';
        }

        return '$source.toJson()';
      case _TypeKind.iterable:
      case _TypeKind.list:
        var typeArgs = type.typeArgs;
        var writer = _getWriter('e', typeArgs[0], false);
        return _methodCall('fromList', [source, writer]);
      case _TypeKind.map:
        var typeArgs = type.typeArgs;
        var writer = _getWriter('e', typeArgs[1], false);
        return _methodCall('fromMap', [source, writer]);
      case _TypeKind.object:
        return '$source';
      case _TypeKind.primitive:
        switch (typeName) {
          case 'DateTime':
            return _methodCall('fromDateTime', [source]);
        }

        return '$source';
      default:
        throw StateError('Unsupported type: $typeName');
    }
  }

  String _methodCall(String name, List<String> args) {
    void checkArgs(int n) {
      if (args.length != n) {
        throw StateError('Wrong number of argumnets for method call: $name');
      }
    }

    String result;
    switch (name) {
      case 'fromDateTime':
      case 'toDateTime':
      case 'toDouble':
        checkArgs(1);
        result = '(${args[0]})';
        break;
      case 'fromList':
      case 'fromMap':
      case 'toList':
      case 'toMap':
      case 'toObject':
        checkArgs(2);
        result = '(${args[0]}, (e) => ${args[1]})';
        break;
      default:
        throw StateError('Unknown method call: $name');
    }

    _usedMethods.add(name);
    result = '_' + name + result;
    return result;
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

        if (const ['dynamic', 'Object'].contains(name)) {
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
