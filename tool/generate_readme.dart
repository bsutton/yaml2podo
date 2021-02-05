import 'dart:io';
import 'package:yaml/yaml.dart' as _yaml;

void main(List<String> args) {
  final pubspec = _yaml.loadYaml(File('pubspec.yaml').readAsStringSync());
  final version = pubspec['version'].toString();
  File('lib/version.dart')
      .writeAsStringSync('const String version = \'$version\';\n');

  final executables = [
    [
      'dart',
      ['bin/yaml2podo.dart', 'example/json_objects.yaml2podo.yaml']
    ],
    [
      'dartfmt',
      ['-w', 'bin', 'example', 'lib', 'test', 'tool']
    ]
  ];

  for (var element in executables) {
    final executable = element[0] as String;
    final arguments = element[1] as List<String>;
    final result = Process.runSync(executable, arguments, runInShell: true);
    if (result.exitCode != 0) {
      print(result.stdout);
      print(result.stderr);
      exit(-1);
    }
  }

  final files = [
    'example/example.dart',
    'example/json_objects.yaml2podo.yaml',
    'example/json_objects.yaml2podo.dart'
  ];

  var text = _template;
  for (var name in files) {
    final content = File(name).readAsStringSync();
    final key = '{{file:$name}}';
    if (!text.contains(key)) {
      print('The template does not contain a key: ${key}');
      exit(-1);
    }

    text = text.replaceAll('{{file:$name}}', content);
  }

  final description = pubspec['description'].toString();
  text = text.replaceAll('{{description}}', description);
  text = text.replaceAll('{{version}}', version);

  final result =
      Process.runSync('dart', ['example/example.dart'], runInShell: true);
  if (result.exitCode != 0) {
    print(result.stdout);
    print(result.stderr);
    exit(-1);
  }

  text = text.replaceAll(
      '{{result:example/example.dart}}', result.stdout as String);
  File('README.md').writeAsStringSync(text);
}

final _template = '''
# yaml2podo

{{description}}

Version {{version}}

### Example of use.

Declarations (simple enough and informative).

[example/json_objects.yaml2podo.yaml](https://github.com/mezoni/yaml2podo/blob/master/example/json_objects.yaml2podo.yaml)

```yaml
{{file:example/json_objects.yaml2podo.yaml}}
```

Run utility.

<pre>
pub global run yaml2podo example/json_objects.yaml2podo.yaml
</pre>

Generated code does not contain dependencies and does not import anything.
The same source code that you would write with your hands. Or at least very close to such a code.

[example/json_objects.yaml2podo.dart](https://github.com/mezoni/yaml2podo/blob/master/example/json_objects.yaml2podo.dart)

```dart
{{file:example/json_objects.yaml2podo.dart}}
```

And, of course, an example of using code.

[example/example.dart](https://github.com/mezoni/yaml2podo/blob/master/example/example.dart)

```dart
{{file:example/example.dart}}
```

Result:

<pre>
{{result:example/example.dart}}
</pre>

### How to install utility `yaml2podo`?

Run the following command in the terminal

<pre>
pub global activate yaml2podo
</pre>
''';
