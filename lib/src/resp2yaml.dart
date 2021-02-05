part of '../resp2yaml.dart';

class Resp2YamlGenerator {
  static const String _unknownTypeName = 'Object';

  final Map<String, Map<String, Set<String>>> _classes = {};

  List<String> generate(dynamic jsonObject, List<String> path) {
    _analyze(jsonObject, path);
    final lines = <String>[];
    for (var className in _classes.keys) {
      lines.add('${className}:');
      final class_ = _classes[className]!;
      for (var key in class_.keys) {
        final typeUnion = class_[key]!;
        final typeName = _reduceTypeUnion(typeUnion);
        final escaped = key.replaceAll('"', '\\\"');
        lines.add('  "${escaped}": ${typeName}');
      }

      lines.add('');
    }

    return lines;
  }

  String _analyze(dynamic value, List<String> path) {
    if (value is Map) {
      return _analyzeMap(value, path);
    } else if (value is List) {
      return _analyzeList(value, path);
    } else if (value is bool) {
      return 'bool';
    } else if (value is DateTime) {
      return 'DateTime';
    } else if (value is double) {
      return 'double';
    } else if (value is int) {
      return 'int';
    } else if (value is String) {
      DateTime? date;
      try {
        date = DateTime.parse(value);
        if (value != date.toIso8601String()) {
          date = null;
        }
      } catch (e) {
        //
      }

      if (date != null) {
        return 'DateTime';
      }

      return 'String';
    } else if (value == null) {
      return _unknownTypeName;
    } else {
      throw StateError(
          'Unsupported data type: ${value.runtimeType}: ${_pathToString(path)}');
    }
  }

  String _analyzeList(List list, List<String> path) {
    if (list.isEmpty) {
      return 'List<${_unknownTypeName}>';
    }

    final typeUnion = <String>{};
    for (var element in list) {
      final typeName = _analyze(element, path);
      typeUnion.add(typeName);
      // TODO: Temporary solution. Need implement a deeper analysis
      if (element is Map) {
        break;
      }
    }

    final typeName = _reduceTypeUnion(typeUnion);
    return 'List<${typeName}>';
  }

  String _analyzeMap(Map map, List<String> path) {
    final className = _registerClass(path);
    final class_ = _classes[className]!;
    for (var key in map.keys) {
      final newkey = key.toString();
      final value = map[key];
      final newPath = path.toList()..add(newkey);
      final typeName = _analyze(value, newPath);
      var typeUnion = class_[newkey];
      if (typeUnion == null) {
        typeUnion = <String>{};
        class_[newkey] = typeUnion;
      }

      typeUnion.add(typeName);
    }

    return className;
  }

  String _pathToString(List<String> path) {
    return path.join('.');
  }

  String _reduceTypeUnion(Set<String> typeUnion) {
    if (typeUnion.isEmpty) {
      throw StateError('Internal error');
    }

    if (typeUnion.length == 1) {
      return typeUnion.first;
    }

    if (typeUnion.length == 2) {
      if (typeUnion.contains(_unknownTypeName)) {
        return typeUnion.where((e) => e != _unknownTypeName).first;
      }
    }

    return _unknownTypeName;
  }

  String _registerClass(List<String> path) {
    final parts = <String>[];
    for (var part in path) {
      part = _utils.convertToIdentifier(part, '\$');
      part = _utils.makePublicIdentifier(part, 'Anon');
      part = _utils.camelizeIdentifier(part);
      part = _utils.capitalizeIdentifier(part);
      parts.add(part);
    }

    var result = parts.join();
    result = _utils.convertToIdentifier(result, '\$');
    result = _utils.makePublicIdentifier(result, 'Anon');
    result = _utils.camelizeIdentifier(result);
    result = _utils.capitalizeIdentifier(result);
    if (_classes.containsKey(result)) {
      while (true) {
        result += '_';
        if (!_classes.containsKey(result)) {
          break;
        }
      }
    }

    _classes[result] = {};
    return result;
  }
}
