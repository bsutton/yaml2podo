part of '../../dart_code_generator.dart';

const String _methodFromDateTime = '''
String _fromDateTime(data) {
  if (data == null) {
    return null;
  }
  if (data is DateTime) {
    return data.toIso8601String();
  }
  return data as String;
}''';

const String _methodFromEnum = '''
String _fromEnum<T>(T value) {
  if (value == null) {
    return null;
  }

  var str = '\$value';
  var offset = str.indexOf('.');
  if (offset == -1) {
    throw ArgumentError('The value is not an enum: \$value');
  }

  return str.substring(offset + 1);
}''';

const String _methodFromList = '''
List _fromList(data, Function(dynamic) toJson) {
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

const String _methodFromMap = '''
Map<K, V> _fromMap<K, V>(data, V Function(dynamic) toJson) {
  if (data == null) {
    return null;
  }
  var result = <K, V>{};
  for (var key in data.keys) {
    V value;
    var element = data[key];
    if (element != null) {
      value = toJson(element);
    }
    result[key as K] = value;
  }
  return result;
}''';

const String _methodToDateTime = '''
DateTime _toDateTime(data) {
  if (data == null) {
    return null;
  }
  if (data is String) {
    return DateTime.parse(data);
  }
  return data as DateTime;
}''';

const String _methodToDouble = '''
double _toDouble(data) {
  if (data == null) {
    return null;
  }
  if (data is int) {
    return data.toDouble();
  }
  return data as double;
}''';

const String _methodToEnum = '''
T _toEnum<T>(String name, Iterable<T> values) {
  if (name == null) {
    return null;
  }

  var offset = '\$T.'.length;
  for (var value in values) {
    var key = '\$value'.substring(offset);
    if (name == key) {
      return value;
    }
  }

  throw ArgumentError(
      'The getter \'\$name\' isn\'t defined for the class \'\$T\'');
}''';

const String _methodToList = '''
List<T> _toList<T>(data, T Function(dynamic) fromJson) {
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

const String _methodToMap = '''
Map<K, V> _toMap<K, V>(data, V Function(dynamic) fromJson) {
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
    result[key as K] = value;
  }
  return result;
}''';

const String _methodToObject = '''
T _toObject<T>(data, T Function(Map<String, dynamic>) fromJson) {
  if (data == null) {
    return null;
  }
  return fromJson(data as Map<String, dynamic>);
}''';

const String _methodToObjectList = '''
List<T> _toObjectList<T>(data, T Function(Map<String, dynamic>) fromJson) {
  if (data == null) {
    return null;
  }
  var result = <T>[];
  for (var element in data) {
    T value;
    if (element != null) {
      value = fromJson(element as Map<String, dynamic>);
    }
    result.add(value);
  }
  return result;
}''';

const String _methodToObjectMap = '''
Map<K, V> _toObjectMap<K, V>(data, V Function(Map<String, dynamic>) fromJson) {
  if (data == null) {
    return null;
  }
  var result = <K, V>{};
  for (var key in data.keys) {
    V value;
    var element = data[key];
    if (element != null) {
      value = fromJson(element as Map<String, dynamic>);
    }
    result[key as K] = value;
  }
  return result;
}''';
