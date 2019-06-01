import 'dart:io';
import 'package:yaml/yaml.dart' as _yaml;

void main(List<String> args) {
  var files = [
    'example/example.dart',
    'example/json_objects.yaml',
    'example/json_objects.dart'
  ];

  var text = _template;
  for (var name in files) {
    var content = File(name).readAsStringSync();
    text = text.replaceAll('{{file:$name}}', content);
  }

  var pubspec = _yaml.loadYaml(File('pubspec.yaml').readAsStringSync());
  var description = pubspec['description'].toString();
  text = text.replaceAll('{{description}}', description);
  var version = pubspec['version'].toString();
  text = text.replaceAll('{{version}}', version);

  File('README.md').writeAsStringSync(text);
}

final _template = '''
# yaml2podo

{{description}}

Version {{version}}

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
{{file:example/example.dart}}
```
''';
