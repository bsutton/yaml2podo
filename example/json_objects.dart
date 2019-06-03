// Generated by 'yaml2podo'
// Version: 0.1.11
// https://pub.dev/packages/yaml2podo

class Messages {
  final List<Iterable<String>> messages;

  Messages({this.messages});

  factory Messages.fromJson(Map map) {
    return Messages(
        messages:
            _toList(map['messages'], (e) => _toList(e, (e) => e as String)));
  }

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};
    result['messages'] = _fromList(messages, (e) => _fromList(e, (e) => e));
    return result;
  }
}

class ObjectWithMap {
  final Map<String, Product> products;

  ObjectWithMap({this.products});

  factory ObjectWithMap.fromJson(Map map) {
    return ObjectWithMap(
        products: _toMap(map['products'], (e) => Product.fromJson(e as Map)));
  }

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};
    result['products'] = _fromMap(products, (e) => e.toJson());
    return result;
  }
}

class Order {
  final double amount;
  final DateTime date;
  final List<OrderItem> items;

  Order({this.amount, this.date, this.items});

  factory Order.fromJson(Map map) {
    return Order(
        amount: _toDouble(map['amount']),
        date: _toDateTime(map['date']),
        items: _toList(map['items'], (e) => OrderItem.fromJson(e as Map)));
  }

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};
    result['amount'] = amount;
    result['date'] = _fromDateTime(date);
    result['items'] = _fromList(items, (e) => e.toJson());
    return result;
  }
}

class OrderItem {
  final int quantity;
  final double price;
  final Product product;

  OrderItem({this.quantity, this.price, this.product});

  factory OrderItem.fromJson(Map map) {
    return OrderItem(
        quantity: map['qty'] as int,
        price: _toDouble(map['price']),
        product: _toObject(map['product'], (e) => Product.fromJson(e as Map)));
  }

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};
    result['qty'] = quantity;
    result['price'] = price;
    result['product'] = product?.toJson();
    return result;
  }
}

class Product {
  final String name;
  final int id;

  Product({this.name, this.id});

  factory Product.fromJson(Map map) {
    return Product(name: map['name'] as String, id: map['id'] as int);
  }

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};
    result['name'] = name;
    result['id'] = id;
    return result;
  }
}

String _fromDateTime(dynamic data) {
  if (data == null) {
    return null;
  }
  if (data is DateTime) {
    return data.toIso8601String();
  }
  return data as String;
}

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
}

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
}

DateTime _toDateTime(dynamic data) {
  if (data == null) {
    return null;
  }
  if (data is String) {
    return DateTime.parse(data);
  }
  return data as DateTime;
}

double _toDouble(dynamic data) {
  if (data == null) {
    return null;
  }
  if (data is int) {
    return data.toDouble();
  }
  return data as double;
}

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
}

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
}

T _toObject<T>(dynamic data, T Function(dynamic) fromJson) {
  if (data == null) {
    return null;
  }
  return fromJson(data);
}

/*
Messages:
  messages : List<Iterable<String>>
ObjectWithMap:
  products: Map<String, Product>
Order:  
  date: DateTime
  items: List<OrderItem>
  amount: double
OrderItem:
  product: Product
  quantity.qty: int
  price: double  
Product:
  name: String
  id: int
*/
