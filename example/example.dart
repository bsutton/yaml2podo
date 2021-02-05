import 'json_objects.yaml2podo.dart';

void main() {
  final products = _getProducts();
  final items = _creataOrderItems(products);
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

double _calculateAmount(List<OrderItem> items) {
  var result = 0.0;
  for (var item in items) {
    result += item.quantity! * item.price!;
  }

  return result;
}

List<OrderItem> _creataOrderItems(List<Product> products) {
  final result = <OrderItem>[];
  for (var i = 0; i < products.length; i++) {
    final product = products[i];
    final orderItem =
        OrderItem(price: 10.0 + i, product: product, quantity: i + 1);
    result.add(orderItem);
  }

  return result;
}

List<Product> _getProducts() {
  final result = <Product>[];
  for (var i = 0; i < 2; i++) {
    final product = Product(id: i, name: 'Product $i');
    result.add(product);
  }

  return result;
}
