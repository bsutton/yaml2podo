// Generated by 'yaml2podo'
// Version: 0.1.2
// https://pub.dev/packages/yaml2podo

final _jc = _JsonConverter();

class Alias {
  String clazz;

  Alias();

  factory Alias.fromJson(Map map) {
    var result = Alias();
    result.clazz = map['class'] as String;
    return result;
  }

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};
    result['class'] = clazz;
    return result;
  }
}

class Bar {
  int i;

  Bar();

  factory Bar.fromJson(Map map) {
    var result = Bar();
    result.i = map['i'] as int;
    return result;
  }

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};
    result['i'] = i;
    return result;
  }
}

class Foo {
  Map<String, Bar> bars;

  Foo();

  factory Foo.fromJson(Map map) {
    var result = Foo();
    result.bars = _jc.toMap(map['bars'], (e) => Bar.fromJson(e as Map));
    return result;
  }

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};
    result['bars'] = _jc.fromMap(bars, (e) => e.toJson());
    return result;
  }
}

class ObjectWithObjects {
  Map<String, Object> map;
  List<Object> list;

  ObjectWithObjects();

  factory ObjectWithObjects.fromJson(Map map) {
    var result = ObjectWithObjects();
    result.map = _jc.toMap(map['map'], (e) => e);
    result.list = _jc.toList(map['list'], (e) => e);
    return result;
  }

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};
    result['map'] = _jc.fromMap(map, (e) => e);
    result['list'] = _jc.fromList(list, (e) => e);
    return result;
  }
}

class Order {
  double amount;
  bool isShipped;
  DateTime date;
  List<OrderItem> items;

  Order();

  factory Order.fromJson(Map map) {
    var result = Order();
    result.amount = _jc.toDouble(map['amount']);
    result.isShipped = map['is_shipped'] as bool;
    result.date = _jc.toDateTime(map['date']);
    result.items =
        _jc.toList(map['items'], (e) => OrderItem.fromJson(e as Map));
    return result;
  }

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};
    result['amount'] = amount;
    result['is_shipped'] = isShipped;
    result['date'] = _jc.fromDateTime(date);
    result['items'] = _jc.fromList(items, (e) => e.toJson());
    return result;
  }
}

class OrderItem {
  int quantity;
  num price;
  Product product;

  OrderItem();

  factory OrderItem.fromJson(Map map) {
    var result = OrderItem();
    result.quantity = map['quantity'] as int;
    result.price = map['price'] as num;
    result.product = Product.fromJson(map['product'] as Map);
    return result;
  }

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};
    result['quantity'] = quantity;
    result['price'] = price;
    result['product'] = product.toJson();
    return result;
  }
}

class Product {
  String name;
  int id;

  Product();

  factory Product.fromJson(Map map) {
    var result = Product();
    result.name = map['name'] as String;
    result.id = map['id'] as int;
    return result;
  }

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};
    result['name'] = name;
    result['id'] = id;
    return result;
  }
}

class Super {
  Map<String, List<int>> map2;
  DateTime date;
  String string;
  bool boolean;
  Map<String, List<Bar>> map;
  double float;
  int integer;
  List<Map<String, Bar>> list;

  Super();

  factory Super.fromJson(Map map) {
    var result = Super();
    result.map2 = _jc.toMap(map['map2'], (e) => _jc.toList(e, (e) => e as int));
    result.date = _jc.toDateTime(map['date']);
    result.string = map['string'] as String;
    result.boolean = map['boolean'] as bool;
    result.map = _jc.toMap(
        map['map'], (e) => _jc.toList(e, (e) => Bar.fromJson(e as Map)));
    result.float = _jc.toDouble(map['float']);
    result.integer = map['integer'] as int;
    result.list = _jc.toList(
        map['list'], (e) => _jc.toMap(e, (e) => Bar.fromJson(e as Map)));
    return result;
  }

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};
    result['map2'] = _jc.fromMap(map2, (e) => _jc.fromList(e, (e) => e));
    result['date'] = _jc.fromDateTime(date);
    result['string'] = string;
    result['boolean'] = boolean;
    result['map'] = _jc.fromMap(map, (e) => _jc.fromList(e, (e) => e.toJson()));
    result['float'] = float;
    result['integer'] = integer;
    result['list'] =
        _jc.fromList(list, (e) => _jc.fromMap(e, (e) => e.toJson()));
    return result;
  }
}

class _JsonConverter {
  String fromDateTime(dynamic data) {
    if (data == null) {
      return null;
    }

    if (data is DateTime) {
      return data.toIso8601String();
    }

    return data as String;
  }

  List fromList(dynamic data, dynamic Function(dynamic) toJson) {
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
  }

  Map<String, dynamic> fromMap(dynamic data, dynamic Function(dynamic) toJson) {
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
