import 'json_objects.dart';

void main() {
  // Order
  var products = _getProducts();
  var items = _creataOrderItems(products);
  var order = Order(
      amount: _calculateAmount(items), date: DateTime.now(), items: items);
  var jsonOrder = order.toJson();
  print(jsonOrder);
  order = Order.fromJson(jsonOrder);
  // Messages
  var messages = Messages(messages: []);
  messages.messages.add(['Hello', 'Goodbye']);
  messages.messages.add(['Yes', 'No']);
  var jsonMessages = messages.toJson();
  print(jsonMessages);
  // ObjectWithMap
  var objectWithMap = ObjectWithMap(products: {});
  for (var product in products) {
    objectWithMap.products[product.name] = product;
  }

  var jsonObjectWithMap = objectWithMap.toJson();
  print(jsonObjectWithMap);
  objectWithMap = ObjectWithMap.fromJson(jsonObjectWithMap);
}

List<OrderItem> _creataOrderItems(List<Product> products) {
  var result = <OrderItem>[];
  for (var i = 0; i < products.length; i++) {
    var product = products[i];
    var orderItem =
        OrderItem(price: 10.0 + i, product: product, quantity: i + 1);
    result.add(orderItem);
  }

  return result;
}

double _calculateAmount(List<OrderItem> items) {
  var result = 0.0;
  for (var item in items) {
    result += item.quantity * item.price;
  }

  return result;
}

List<Product> _getProducts() {
  var result = <Product>[];
  for (var i = 0; i < 2; i++) {
    var product = Product(id: i, name: 'Product $i');
    result.add(product);
  }

  return result;
}
