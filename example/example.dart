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
