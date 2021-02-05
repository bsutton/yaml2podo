part of '../../dart_code_generator.dart';

class DartCodeGenerator {
  List<String> generate(Iterable<TypeDeclaration> types) {
    final result = <String>[];
    final lines = _generateFile(types);
    result.addAll(lines);
    return result;
  }

  List<String> _generateClass(TypeDeclaration type) {
    const template = '''
class {{NAME}} {
{{FIELDS}}

{{CTOR}}

{{FACTORY}}

{{TO_JSON}}
}''';

    var result = template;
    result = result.replaceAll('{{NAME}}', type.toString());
    var lines = _generateConstructor(type);
    result = result.replaceAll('{{CTOR}}', lines.join('\n'));
    lines = _generateProperties(type);
    result = result.replaceAll('{{FIELDS}}', lines.join('\n'));
    lines = _generateFactoryFromJson(type);
    result = result.replaceAll('{{FACTORY}}', lines.join('\n'));
    lines = _generateMethodToJson(type);
    result = result.replaceAll('{{TO_JSON}}', lines.join('\n'));
    return LineSplitter().convert(result).toList();
  }

  List<String> _generateConstructor(TypeDeclaration type) {
    final sb = StringBuffer();
    sb.write('  ');
    sb.write(type.name);
    sb.write('(');
    final arguments = <String>[];
    for (var property in type.properties.values) {
      final sb = StringBuffer();
      sb.write('this.');
      sb.write(property.name);
      arguments.add(sb.toString());
    }

    if (arguments.isNotEmpty) {
      sb.write('{');
      sb.write(arguments.join(', '));
      sb.write('}');
    }

    sb.write(');');
    return [sb.toString()];
  }

  List<String> _generateEnum(TypeDeclaration type) {
    final result = <String>[];
    final sb = StringBuffer();
    sb.write(' enum ');
    sb.write(type.name);
    sb.write(' { ');
    final values = <String>[];
    for (var property in type.properties.values) {
      values.add(property.name);
    }

    sb.write(values.join(', '));
    sb.write(' } ');
    result.add(sb.toString());
    return result;
  }

  List<String> _generateFactoryFromJson(TypeDeclaration type) {
    const template = '''
  factory {{NAME}}.fromJson(Map json) {
    return {{NAME}}(
{{ARGUMENTS}});
  }''';

    var result = template;
    result = result.replaceAll('{{NAME}}', type.name);
    final properties = type.properties;
    final names = properties.values.map((e) => e.name);
    final arguments = <String>[];
    for (var name in names) {
      final property = properties[name]!;
      var alias = property.alias;
      if (alias != null) {
        alias = alias.replaceAll('\$', '\\\$');
        alias = alias.replaceAll('\'', '\\\'');
      } else {
        alias = name;
      }

      final reader = _getReader('json[\'$alias\']', property.type, true);
      final sb = StringBuffer();
      sb.write('      ');
      sb.write(name);
      sb.write(': ');
      sb.write(reader);
      sb.write(',');
      arguments.add(sb.toString());
    }

    result = result.replaceAll('{{ARGUMENTS}}', arguments.join('\n'));
    return LineSplitter().convert(result).toList();
  }

  List<String> _generateFile(Iterable<TypeDeclaration> types) {
    final result = <String>[];
    for (var type in types) {
      if (type.isCustomType) {
        if (type.isEnumType) {
          final lines = _generateEnum(type);
          result.addAll(lines);
        } else {
          final lines = _generateClass(type);
          result.addAll(lines);
        }
      }

      result.add('');
    }

    final lines = _generateMethods();
    result.addAll(lines);
    return result;
  }

  List<String> _generateMethods() {
    final template = template_methods;
    return LineSplitter().convert(template).toList();
  }

  List<String> _generateMethodToJson(TypeDeclaration type) {
    const template = '''
  Map<String, dynamic> toJson() {
{{STATEMENT}}
  }''';

    var result = template;
    final properties = type.properties;
    final names = properties.values.map((e) => e.name);
    final statement = <String>[];
    if (names.isEmpty) {
      statement.add('    return {};');
    } else {
      statement.add('    return {');
      for (var name in names) {
        final property = properties[name]!;
        var alias = property.alias;
        if (alias != null) {
          alias = alias.replaceAll('\$', '\\\$');
          alias = alias.replaceAll('\'', '\\\'');
        } else {
          alias = name;
        }

        final writer = _getWriter(name, property.type, true);
        final sb = StringBuffer();
        sb.write('      ');
        sb.write('\'');
        sb.write(alias);
        sb.write('\': ');
        sb.write(writer);
        sb.write(',');
        statement.add(sb.toString());
      }

      statement.add('    };');
    }

    result = result.replaceAll('{{STATEMENT}}', statement.join('\n'));
    return LineSplitter().convert(result).toList();
  }

  List<String> _generateProperties(TypeDeclaration type) {
    final result = <String>[];
    final names = type.properties.values.map((e) => e.name);
    final properties = type.properties;
    for (var name in names) {
      final property = properties[name]!;
      final sb = StringBuffer();
      sb.write('  ');
      if (property.isFinal) {
        sb.write('final ');
      }

      //sb.write(property.type.toString());
      sb.write(_typeToString(property.type));
      sb.write(' ');
      sb.write(property.name);
      sb.write(';');
      result.add(sb.toString());
    }

    return result;
  }

  String _getReader(String name, TypeDeclaration type, bool canBeNull) {
    if (type.isCustomType) {
      if (type.isEnumType) {
        throw UnimplementedError();
      } else {
        switch (type.name) {
          case 'Iterable':
          case 'List':
            final arguments = type.arguments;
            final elementType = arguments[0];
            final reader = _getReader('e', elementType, false);
            if (_isCustomObjectType(elementType)) {
              return _methodCall('toObjectList', [name, 'e', reader]);
            }

            return _methodCall('toList', [name, 'e', reader]);
          case 'Map':
            final arguments = type.arguments;
            final valueType = arguments[1];
            final reader = _getReader('e', valueType, false);
            if (_isCustomObjectType(valueType)) {
              return _methodCall('toObjectMap', [name, 'e', reader]);
            }

            return _methodCall('toMap', [name, 'e', reader]);
          default:
            if (type.arguments.isNotEmpty) {
              throw ArgumentError('Generic type is not supported: $type');
            }

            final sb = StringBuffer();
            sb.write(type.name);
            sb.write('.fromJson(e)');
            final reader = sb.toString();
            if (canBeNull) {
              return _methodCall('toObject', [name, 'e', reader]);
            }

            return reader;
        }
      }
    } else {
      switch (type.name) {
        case 'bool':
        case 'int':
        case 'num':
        case 'String':
          final sb = StringBuffer();
          sb.write(name);
          sb.write(' as ');
          sb.write(_typeToString(type));
          return sb.toString();
        case 'DateTime':
          return _methodCall('toDateTime', [name]);
        case 'double':
          return _methodCall('toDouble', [name]);
        case 'dynamic':
        case 'Object':
          return name;
        default:
          throw ArgumentError('Unsupported built-in type: ${type}');
      }
    }
  }

  String _getWriter(String name, TypeDeclaration type, bool canBeNull) {
    if (type.isCustomType) {
      if (type.isEnumType) {
        throw UnimplementedError();
      } else {
        switch (type.name) {
          case 'Iterable':
          case 'List':
            final arguments = type.arguments;
            final elementType = _typeToString(arguments[0]);
            //var writer = _getWriter('e', arguments[0], false);
            final writer = _getWriter('e', arguments[0], canBeNull);
            return _methodCall('fromList', [name, '$elementType e', writer]);
          case 'Map':
            final arguments = type.arguments;
            final valueType = _typeToString(arguments[1]);
            //var writer = _getWriter('e', arguments[1], false);
            final writer = _getWriter('e', arguments[1], canBeNull);
            return _methodCall('fromMap', [name, '$valueType e', writer]);
          default:
            if (type.arguments.isNotEmpty) {
              throw ArgumentError('Generic type is not supported: $type');
            }

            final sb = StringBuffer();
            sb.write(name);
            if (canBeNull) {
              sb.write('?');
            }

            sb.write('.toJson()');
            return sb.toString();
        }
      }
    } else {
      switch (type.name) {
        case 'bool':
        case 'double':
        case 'int':
        case 'num':
        case 'String':
          return name;
        case 'DateTime':
          return _methodCall('fromDateTime', [name]);
        case 'dynamic':
        case 'Object':
          return name;
        default:
          throw ArgumentError('Unsupported built-in type: ${type}');
      }
    }
  }

  bool _isCollectionType(TypeDeclaration type) {
    if (type.isCustomType) {
      switch (type.name) {
        case 'Iterable':
        case 'List':
        case 'Map':
          return true;
      }
    }

    return false;
  }

  bool _isCustomObjectType(TypeDeclaration type) {
    if (type.isCustomType) {
      if (!_isCollectionType(type)) {
        return true;
      }
    }

    return false;
  }

  String _methodCall(String method, List<String> args) {
    void checkArgs(int n) {
      if (args.length != n) {
        throw StateError('Wrong number of argumnets for method call: $method');
      }
    }

    String result;
    switch (method) {
      case 'fromDateTime':
      case 'fromEnum':
      case 'toDateTime':
      case 'toDouble':
        checkArgs(1);
        result = '(${args[0]})';
        break;
      case 'fromList':
      case 'fromMap':
      case 'toEnum':
      case 'toList':
      case 'toMap':
      case 'toObject':
      case 'toObjectList':
      case 'toObjectMap':
        checkArgs(3);
        result = '(${args[0]}, (${args[1]}) => ${args[2]})';
        break;
      default:
        throw StateError('Unknown method call: $method');
    }

    result = '_' + method + result;
    return result;
  }

  String _typeToString(TypeDeclaration type) {
    final name = type.name;
    final arguments = type.arguments;
    final sb = StringBuffer();
    sb.write(name);
    if (arguments.isNotEmpty) {
      sb.write('<');
      final args = <String>[];
      for (var argument in arguments) {
        args.add(_typeToString(argument));
      }

      sb.write(args.join(', '));
      sb.write('>');
    }

    sb.write('?');
    return sb.toString();
  }
}
