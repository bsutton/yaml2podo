# yaml2podo

The `yaml2podo` is a generator and utility (all in one) that generates PODO classes to convert between JSON and Dart objects

Version 0.1.9

### Example of use.

Declarations (simple enough and informative).

[example/json_objects.yaml](https://github.com/mezoni/yaml2podo/blob/master/example/json_objects.yaml)

```yaml
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
```

Run utility.

<pre>
pub global run yaml2podo example/json_objects.yaml
</pre>

Generated code does not contain dependencies and does not import anything.
The same source code that you would write with your hands. Or at least very close to such a code.

[example/json_objects.dart](https://github.com/mezoni/yaml2podo/blob/master/example/json_objects.dart)

```dart
// Generated by 'yaml2podo'
// Version: 0.1.9
// https://pub.dev/packages/yaml2podo

class Messages {
  List<Iterable<String>> messages;

  Messages();

  factory Messages.fromJson(Map map) {
    var result = Messages();
    result.messages =
        _toList(map['messages'], (e) => _toList(e, (e) => e as String));
    return result;
  }

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};
    result['messages'] = _fromList(messages, (e) => _fromList(e, (e) => e));
    return result;
  }
}

class ObjectWithMap {
  Map<String, Product> products;

  ObjectWithMap();

  factory ObjectWithMap.fromJson(Map map) {
    var result = ObjectWithMap();
    result.products =
        _toMap(map['products'], (e) => Product.fromJson(e as Map));
    return result;
  }

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};
    result['products'] = _fromMap(products, (e) => e.toJson());
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
    result.amount = _toDouble(map['amount']);
    result.date = _toDateTime(map['date']);
    result.items = _toList(map['items'], (e) => OrderItem.fromJson(e as Map));
    return result;
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
  int quantity;
  double price;
  Product product;

  OrderItem();

  factory OrderItem.fromJson(Map map) {
    var result = OrderItem();
    result.quantity = map['qty'] as int;
    result.price = _toDouble(map['price']);
    result.product =
        _toObject(map['product'], (e) => Product.fromJson(e as Map));
    return result;
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

```

And, of course, an example of using code.

[example/example.dart](https://github.com/mezoni/yaml2podo/blob/master/example/example.dart)

```dart
import 'json_objects.dart';

void main() {
  // Order
  var products = _getProducts();
  var order = _createOrder();
  _addItemsToOrder(order, products);
  var jsonOrder = order.toJson();
  print(jsonOrder);
  order = Order.fromJson(jsonOrder);
  // Messages
  var messages = Messages();
  messages.messages = [];
  messages.messages.add(['Hello', 'Goodbye']);
  messages.messages.add(['Yes', 'No']);
  var jsonMessages = messages.toJson();
  print(jsonMessages);
  // ObjectWithMap
  var objectWithMap = ObjectWithMap();
  objectWithMap.products = {};
  for (var product in products) {
    objectWithMap.products[product.name] = product;
  }

  var jsonObjectWithMap = objectWithMap.toJson();
  print(jsonObjectWithMap);
  objectWithMap = ObjectWithMap.fromJson(jsonObjectWithMap);
}

void _addItemsToOrder(Order order, List<Product> products) {
  for (var i = 0; i < products.length; i++) {
    var product = products[i];
    var orderItem = OrderItem();
    orderItem.product = product;
    orderItem.quantity = i + 1;
    orderItem.price = 10.0 + i;
    order.items.add(orderItem);
    order.amount += orderItem.quantity * orderItem.price;
  }
}

Order _createOrder() {
  var result = Order();
  result.amount = 0;
  result.date = DateTime.now();
  result.items = [];
  return result;
}

List<Product> _getProducts() {
  var result = <Product>[];
  for (var i = 0; i < 2; i++) {
    var product = Product();
    product.id = i;
    product.name = 'Product $i';
    result.add(product);
  }

  return result;
}

```

Result:

<pre>
{amount: 32.0, date: 2019-06-03T16:56:28.652480, items: [{qty: 1, price: 10.0, product: {name: Product 0, id: 0}}, {qty: 2, price: 11.0, product: {name: Product 1, id: 1}}]}
{messages: [[Hello, Goodbye], [Yes, No]]}
{products: {Product 0: {name: Product 0, id: 0}, Product 1: {name: Product 1, id: 1}}}

</pre>

### How to install utility `yaml2podo`?

Run the following command in the terminal

<pre>
pub global activate yaml2podo
</pre>
