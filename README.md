# yaml2podo

The `yaml2podo` is a generator and utility (all in one) that generates PODO classes to convert between JSON and Dart objects

Version 0.1.24

### Example of use.

Declarations (simple enough and informative).

[example/json_objects.yaml](https://github.com/mezoni/yaml2podo/blob/master/example/json_objects.yaml)

```yaml
{{file:example/json_objects.yaml}}
```

Run utility.

<pre>
pub global run yaml2podo example/json_objects.yaml
</pre>

Generated code does not contain dependencies and does not import anything.
The same source code that you would write with your hands. Or at least very close to such a code.

[example/json_objects.dart](https://github.com/mezoni/yaml2podo/blob/master/example/json_objects.dart)

```dart
{{file:example/json_objects.dart}}
```

And, of course, an example of using code.

[example/example.dart](https://github.com/mezoni/yaml2podo/blob/master/example/example.dart)

```dart
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

```

Result:

<pre>
{amount: 32.0, date: 2019-05-31T00:00:00.000, items: [{price: 10.0, product: {id: 0, name: Product 0}, qty: 1}, {price: 11.0, product: {id: 1, name: Product 1}, qty: 2}]}
{amount: 32.0, date: 2019-05-31T00:00:00.000, items: [{price: 10.0, product: {id: 0, name: Product 0}, qty: 1}, {price: 11.0, product: {id: 1, name: Product 1}, qty: 2}]}

</pre>

### How to install utility `yaml2podo`?

Run the following command in the terminal

<pre>
pub global activate yaml2podo
</pre>
