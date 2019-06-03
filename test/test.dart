import 'package:test/test.dart';

import 'package:yaml2podo/_utils.dart' as _utils;
import 'json_objects.dart';

void main() {
  _testBinUtils();
  _testJsonSerializer();
}

final List<Product> _products = [
  Product(id: 0, name: 'Product 0'),
  Product(id: 1, name: 'Product 1')
];

void _testBinUtils() {
  test('_utils: capitalizeIdentifier()', () {
    var result = _utils.capitalizeIdentifier('abc');
    expect(result, 'Abc');
    result = _utils.capitalizeIdentifier('_abc');
    expect(result, '_Abc');
    result = _utils.capitalizeIdentifier('\$abc');
    expect(result, '\$Abc');
    result = _utils.capitalizeIdentifier('_\$abc');
    expect(result, '_\$Abc');
    result = _utils.capitalizeIdentifier('\$_abc');
    expect(result, '\$_Abc');
    result = _utils.capitalizeIdentifier('_');
    expect(result, '_');
    result = _utils.capitalizeIdentifier('');
    expect(result, '');
  });

  test('_utils: camelizeIdentifier()', () {
    var result = _utils.camelizeIdentifier('');
    expect(result, '');
    result = _utils.camelizeIdentifier('abc');
    expect(result, 'abc');
    result = _utils.camelizeIdentifier('abc_');
    expect(result, 'abc_');
    result = _utils.camelizeIdentifier('abc_def_');
    expect(result, 'abcDef_');
    result = _utils.camelizeIdentifier('abc_def');
    expect(result, 'abcDef');
    result = _utils.camelizeIdentifier('_abc_def');
    expect(result, '_abcDef');
    result = _utils.camelizeIdentifier('__abc_def');
    expect(result, '__abcDef');
    result = _utils.camelizeIdentifier('abc__def');
    expect(result, 'abc_Def');
    result = _utils.camelizeIdentifier('_abc__def');
    expect(result, '_abc_Def');
    result = _utils.camelizeIdentifier('__abc__def');
    expect(result, '__abc_Def');
    result = _utils.camelizeIdentifier('_1abc');
    expect(result, '_1abc');
    result = _utils.camelizeIdentifier('\$1abc');
    expect(result, '\$1abc');
    result = _utils.camelizeIdentifier('abc_1def');
    expect(result, 'abc1Def');
    result = _utils.camelizeIdentifier('_abc_\$def');
    expect(result, '_abc\$Def');
  });

  test('_utils: convertToIdentifier()', () {
    var replacement = '\$';
    var result = _utils.convertToIdentifier('1abc', replacement);
    expect(result, '\$1abc');
    result = _utils.convertToIdentifier('a:bc', replacement);
    expect(result, 'a\$bc');
    result = _utils.convertToIdentifier('abc?', replacement);
    expect(result, 'abc\$');
    result = _utils.convertToIdentifier('3', replacement);
    expect(result, '\$3');
    result = _utils.convertToIdentifier('person-list', replacement);
    expect(result, 'person_list');
    result = _utils.convertToIdentifier('-', replacement);
    expect(result, '\$');
    result = _utils.convertToIdentifier('-1', replacement);
    expect(result, '\$1');
    result = _utils.convertToIdentifier('-a-', replacement);
    expect(result, '\$a_');
  });

  test('_utils: makePublicIdentifier()', () {
    var result = _utils.makePublicIdentifier('', 'temp');
    expect(result, 'temp');
    result = _utils.makePublicIdentifier('_', 'temp');
    expect(result, 'temp_');
    result = _utils.makePublicIdentifier('__', 'temp');
    expect(result, 'temp__');
    result = _utils.makePublicIdentifier('abc', 'temp');
    expect(result, 'abc');
    result = _utils.makePublicIdentifier('_abc', 'temp');
    expect(result, 'abc_');
    result = _utils.makePublicIdentifier('__abc', 'temp');
    expect(result, 'abc__');
  });
}

void _testJsonSerializer() {
  test('Serialize "Order" instance', () {
    var order =
        Order(amount: 0, date: DateTime.now(), items: [], isShipped: true);
    for (var i = 0; i < _products.length; i++) {
      var product = _products[i];
      var item = OrderItem(price: i, product: product, quantity: i);
      order.items.add(item);
    }

    order.items.add(null);
    order.items.add(OrderItem());
    var jsonOrder = order.toJson();
    var expected = <String, dynamic>{
      'amount': 0,
      'date': order.date.toIso8601String(),
      'items': [
        {
          'product': {'id': 0, 'name': 'Product 0'},
          'price': 0,
          'quantity': 0
        },
        {
          'product': {'id': 1, 'name': 'Product 1'},
          'price': 1,
          'quantity': 1
        },
        null,
        {'product': null, 'price': null, 'quantity': null},
      ],
      'is_shipped': true,
    };

    expect(jsonOrder, expected);
    _transform(order);
  });

  test('Serialize "Foo" instance', () {
    var foo = Foo(bars: {});
    foo.bars['0'] = Bar(i: 0);
    foo.bars['1'] = Bar(i: 1);
    foo.bars['2'] = null;
    var jsonOrder = foo.toJson();
    var expected = {
      'bars': {
        '0': {'i': 0},
        '1': {'i': 1},
        '2': null
      }
    };
    expect(jsonOrder, expected);
    _transform(foo);
  });

  test('Serialize "Alias" instance', () {
    var value = Alias(clazz: 'foo');
    var jsonValue = value.toJson();
    var expected = {
      'class': 'foo',
    };
    expect(jsonValue, expected);
    _transform(value);
  });

  test('Serialize "Super" instance', () {
    var value = Super(
        boolean: true,
        date: DateTime.now(),
        float: 1.0,
        foo2: Foo(),
        integer: 2,
        list: [],
        map: {},
        string: 'hello');

    value.list.add({});

    value.map['0'] = [];
    value.map['0'].add(Bar(i: 123));
    value.map['1'] = null;
    value.list[0]["bar"] = Bar(i: 99);
    var jsonValue = value.toJson();
    var expected = {
      'foo': null,
      'foo2': {'bars': null},
      'date': value.date.toIso8601String(),
      'string': 'hello',
      'boolean': true,
      'map2': null,
      "map": {
        '0': [
          {'i': 123}
        ],
        '1': null
      },
      'float': 1.0,
      'integer': 2,
      'list': [
        {
          'bar': {'i': 99}
        }
      ]
    };
    expect(jsonValue, expected);
    _transform(value);
  });
}

void _transform(dynamic object) {
  var type = object.runtimeType as Type;
  var jsonOject = object.toJson();
  var object2 = _unmarshal(jsonOject, type: type);
  var jsonOject2 = object2.toJson();
  expect(jsonOject, jsonOject2);
}

T _unmarshal<T>(dynamic value, {Type type}) {
  if (type == null) {
    type = T;
    if (type == dynamic) {
      type = value.runtimeType as Type;
    }
  }

  switch (type) {
    case Alias:
      return Alias.fromJson(value as Map) as T;
    case Bar:
      return Bar.fromJson(value as Map) as T;
    case Foo:
      return Foo.fromJson(value as Map) as T;
    case ObjectWithObjects:
      return ObjectWithObjects.fromJson(value as Map) as T;
    case Order:
      return Order.fromJson(value as Map) as T;
    case OrderItem:
      return OrderItem.fromJson(value as Map) as T;
    case Product:
      return Product.fromJson(value as Map) as T;
    case Super:
      return Super.fromJson(value as Map) as T;
    default:
      throw StateError('Unable to marshal value of type \'$type\'');
  }
}
