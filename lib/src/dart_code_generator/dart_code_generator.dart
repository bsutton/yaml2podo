part of '../../dart_code_generator.dart';

class DartCodeGenerator {
  Map<String, List<String> Function()> _methodGenarators = {};

  List<String> generate(Iterable<TypeDeclaration> types) {
    var result = <String>[];
    var lines = _generateFile(types);
    result.addAll(lines);
    return result;
  }

  void _addMethodGenerator(String name) {
    String template;
    switch (name) {
      case 'fromDateTime':
        template = _methodFromDateTime;
        break;
      case 'fromEnum':
        template = _methodFromEnum;
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
      case 'toEnum':
        template = _methodToEnum;
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
      case 'toObjectList':
        template = _methodToObjectList;
        break;
      case 'toObjectMap':
        template = _methodToObjectMap;
        break;
      default:
        throw StateError('Unknown method name: $name');
    }

    if (!_methodGenarators.containsKey(name)) {
      generator() => LineSplitter().convert(template).toList();
      _methodGenarators[name] = generator;
    }
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
    var sb = StringBuffer();
    sb.write('  ');
    sb.write(type.name);
    sb.write('(');
    var arguments = <String>[];
    for (var property in type.properties.values) {
      var sb = StringBuffer();
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
    var result = <String>[];
    var sb = StringBuffer();
    sb.write(' enum ');
    sb.write(type.name);
    sb.write(' { ');
    var values = <String>[];
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
  factory {{NAME}}.fromJson(Map<String, dynamic> json) {
    return {{NAME}}(
{{ARGUMENTS}});
  }''';

    var result = template;
    result = result.replaceAll('{{NAME}}', type.name);
    var properties = type.properties;
    var names = properties.values.map((e) => e.name);
    var arguments = <String>[];
    for (var name in names) {
      var property = properties[name];
      var alias = property.alias;
      if (alias != null) {
        alias = alias.replaceAll('\$', '\\\$');
        alias = alias.replaceAll('\'', '\\\'');
      } else {
        alias = name;
      }

      var reader = _getReader('json[\'$alias\']', property.type, true);
      var sb = StringBuffer();
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
    var result = <String>[];
    for (var type in types) {
      if (type.isCustomType) {
        if (type.isEnumType) {
          var lines = _generateEnum(type);
          result.addAll(lines);
        } else {
          var lines = _generateClass(type);
          result.addAll(lines);
        }
      }

      result.add('');
    }

    var lines = _generateMethods();
    result.addAll(lines);
    return result;
  }

  List<String> _generateMethods() {
    var result = <String>[];
    var names = _methodGenarators.keys.toList();
    names.sort();
    for (var name in names) {
      var genarator = _methodGenarators[name];
      var lines = genarator();
      result.addAll(lines);
      result.add('');
    }

    return result;
  }

  List<String> _generateMethodToJson(TypeDeclaration type) {
    const template = '''
  Map<String, dynamic> toJson() {
{{STATEMENT}}
  }''';

    var result = template;
    var properties = type.properties;
    var names = properties.values.map((e) => e.name);
    var statement = <String>[];
    if (names.isEmpty) {
      statement.add('    return {};');
    } else {
      statement.add('    return {');
      for (var name in names) {
        var property = properties[name];
        var alias = property.alias;
        if (alias != null) {
          alias = alias.replaceAll('\$', '\\\$');
          alias = alias.replaceAll('\'', '\\\'');
        } else {
          alias = name;
        }

        var writer = _getWriter(name, property.type, true);
        var sb = StringBuffer();
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
    var result = <String>[];
    var names = type.properties.values.map((e) => e.name);
    var properties = type.properties;
    for (var name in names) {
      var property = properties[name];
      var sb = StringBuffer();
      sb.write('  ');
      if (property.isFinal) {
        sb.write('final ');
      }

      sb.write(property.type.toString());
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
            var arguments = type.arguments;
            var elementType = arguments[0];
            var reader = _getReader('e', elementType, false);
            if (_isCustomObjectType(elementType)) {
              return _methodCall('toObjectList', [name, reader]);
            }

            return _methodCall('toList', [name, reader]);
          case 'Map':
            var arguments = type.arguments;
            var valueType = arguments[1];
            var reader = _getReader('e', valueType, false);
            if (_isCustomObjectType(valueType)) {
              return _methodCall('toObjectMap', [name, reader]);
            }

            return _methodCall('toMap', [name, reader]);
          default:
            if (type.arguments.isNotEmpty) {
              throw ArgumentError('Generic type is not supported: $type');
            }

            var sb = StringBuffer();
            sb.write(type.name);
            sb.write('.fromJson(e)');
            var reader = sb.toString();
            if (canBeNull) {
              return _methodCall('toObject', [name, reader]);
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
          var sb = StringBuffer();
          sb.write(name);
          sb.write(' as ');
          sb.write(type.toString());
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
            var arguments = type.arguments;
            var writer = _getWriter('e', arguments[0], false);
            return _methodCall('fromList', [name, writer]);
          case 'Map':
            var arguments = type.arguments;
            var writer = _getWriter('e', arguments[1], false);
            return _methodCall('fromMap', [name, writer]);
          default:
            if (type.arguments.isNotEmpty) {
              throw ArgumentError('Generic type is not supported: $type');
            }

            var sb = StringBuffer();
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

  String _methodCall(String name, List<String> args) {
    void checkArgs(int n) {
      if (args.length != n) {
        throw StateError('Wrong number of argumnets for method call: $name');
      }
    }

    String result;
    switch (name) {
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
        checkArgs(2);
        result = '(${args[0]}, (e) => ${args[1]})';
        break;
      default:
        throw StateError('Unknown method call: $name');
    }

    _addMethodGenerator(name);
    result = '_' + name + result;
    return result;
  }
}
