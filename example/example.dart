import 'json_objects.yaml2podo.dart';

void main() {
  var products = _getProducts();
  var items = _creataOrderItems(products);
  var order = Order(
      amount: _calculateAmount(items),
      date: DateTime(2019, 05, 31),
      items: items);
  var object = order.toJson();
  print(object);
  order = Order.fromJson(object);
  object = order.toJson();
  print(object);
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
