// Generated by 'yaml2podo'
// Version: 0.1.2
// https://pub.dev/packages/yaml2podo

final _jc = _JsonConverter();

class Messages {
  List<Iterable<String>> messages;

  Messages();

  factory Messages.fromJson(Map map) {
    var result = Messages();
    result.messages =
        _jc.toList(map['messages'], (e) => _jc.toList(e, (e) => e as String));
    return result;
  }

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};
    result['messages'] =
        _jc.fromList(messages, (e) => _jc.fromList(e, (e) => e));
    return result;
  }
}

class ObjectWithMap {
  Map<String, Product> products;

  ObjectWithMap();

  factory ObjectWithMap.fromJson(Map map) {
    var result = ObjectWithMap();
    result.products =
        _jc.toMap(map['products'], (e) => Product.fromJson(e as Map));
    return result;
  }

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};
    result['products'] = _jc.fromMap(products, (e) => e.toJson());
    return result;
  }
}

class Order {
  double amount;
  DateTime date;
  List<OrderItem> items;

  Order();

  factory Order.fromJson(Map map) {
    var result = Order();
    result.amount = _jc.toDouble(map['amount']);
    result.date = _jc.toDateTime(map['date']);
    result.items =
        _jc.toList(map['items'], (e) => OrderItem.fromJson(e as Map));
    return result;
  }

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};
    result['amount'] = amount;
    result['date'] = _jc.fromDateTime(date);
    result['items'] = _jc.fromList(items, (e) => e.toJson());
    return result;
  }
}

class OrderItem {
  int quantity;
  double price;
  Product product;

  OrderItem();

  factory OrderItem.fromJson(Map map) {
    var result = OrderItem();
    result.quantity = map['qty'] as int;
    result.price = _jc.toDouble(map['price']);
    result.product = Product.fromJson(map['product'] as Map);
    return result;
  }

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};
    result['qty'] = quantity;
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
