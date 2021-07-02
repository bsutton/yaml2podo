part of '../../dart_code_generator.dart';

const template_methods = r'''
T _checkType<T>(value) {
  if (value is T) {
    return value;
  }
  throw StateError(
      'Value of type ${value.runtimeType} is not a subtype of \'${T}\'');
}

String? _fromDateTime(data) {
  if (data == null) {
    return null;
  }
  if (data is DateTime) {
    return data.toIso8601String();
  }
  return _checkType<String>(data);
}

String? _fromEnum<T>(T? value) {
  if (value == null) {
    return null;
  }
  final str = '\$value';
  final offset = str.indexOf('.');
  if (offset == -1) {
    throw ArgumentError('The value is not an enum: \$value');
  }
  return str.substring(offset + 1);
}

List<O?>? _fromList<I, O>(List<I?>? data, O Function(I) toJson) {
  if (data == null) {
    return null;
  }
  final result = <O?>[];
  for (final element in data) {
    O? value;
    if (element != null) {
      value = toJson(element);
    }
    result.add(value);
  }
  return result;
}

Map<K?, O?>? _fromMap<K, I, O>(Map<K?, I?>? data, O Function(I) toJson) {
  if (data == null) {
    return null;
  }
  final result = <K?, O?>{};
  for (final key in data.keys) {
    O? value;
    final element = data[key];
    if (element != null) {
      value = toJson(element);
    }
    result[key] = value;
  }
  return result;
}

DateTime? _toDateTime(data) {
  if (data == null) {
    return null;
  }
  if (data is String) {
    return DateTime.parse(data);
  }
  return _checkType<DateTime>(data);
}

double? _toDouble(data) {
  if (data == null) {
    return null;
  }
  if (data is int) {
    return data.toDouble();
  }
  return _checkType<double>(data);
}

T? _toEnum<T>(String? name, Iterable<T> values) {
  if (name == null) {
    return null;
  }
  final offset = '\$T.'.length;
  for (final value in values) {
    final key = '\$value'.substring(offset);
    if (name == key) {
      return value;
    }
  }

  throw ArgumentError(
      'The getter \'\$name\' isn\'t defined for the class \'\$T\'');
}

List<T?>? _toList<T>(data, T? Function(dynamic) fromJson) {
  if (data == null) {
    return null;
  }
  final result = <T?>[];
  final sequence = _checkType<List>(data);
  for (final element in sequence) {
    T? value;
    if (element != null) {
      value = fromJson(element);
    }
    result.add(value);
  }
  return result;
}

Map<K?, V?>? _toMap<K, V>(data, V? Function(dynamic) fromJson) {
  if (data == null) {
    return null;
  }
  final result = <K?, V?>{};
  final map = _checkType<Map<K?, dynamic>>(data);
  for (final key in map.keys) {
    V? value;
    final element = map[key];
    if (element != null) {
      value = fromJson(element);
    }
    result[key] = value;
  }
  return result;
}

T? _toObject<T>(data, T Function(Map) fromJson) {
  if (data == null) {
    return null;
  }
  final json = _checkType<Map>(data);
  return fromJson(json);
}

List<T?>? _toObjectList<T>(data, T Function(Map) fromJson) {
  if (data == null) {
    return null;
  }
  final result = <T?>[];
  final sequence = _checkType<Iterable>(data);
  for (final element in sequence) {
    T? value;
    if (element != null) {
      final json = _checkType<Map>(element);
      value = fromJson(json);
    }
    result.add(value);
  }
  return result;
}

Map<K?, V?>? _toObjectMap<K, V>(data, V Function(Map) fromJson) {
  if (data == null) {
    return null;
  }
  final result = <K?, V?>{};
  final map = _checkType<Map<K?, dynamic>>(data);
  for (final key in map.keys) {
    V? value;
    final element = map[key];
    if (element != null) {
      final json = _checkType<Map>(element);
      value = fromJson(json);
    }
    result[key] = value;
  }
  return result;
}''';
