## 0.1.17

- Added option to `Yaml2PodoGenerator` to format generated code (default: on)
- Rewritten generator source code `Yaml2PodoGenerator`

## 0.1.16

Fixed bug in `bin/resp2yaml.dart` (incorrect generation of a comments in the file header)

## 0.1.15

- Fixed bug in `Yaml2PodoGenerator` (incorrect constructor code was generated for a class with no properties) 

## 0.1.14

- Added generator `Resp2YamlGenerator`
- Added utilty `bin/resp2yaml.dart`

## 0.1.12

- Added option to `Yaml2PodoGenerator` to store model prototypes as comments within the generated code (default: on)
- Fixed minor bug in `Yaml2PodoGenerator` (first character of property identifiers has not been converted to lowercase) 

## 0.1.11

- Restored code formatting of generated code in `bin/yaml2podo.dart`

## 0.1.10

- Added option to `Yaml2PodoGenerator` to generate immutable fields (default: on)

## 0.1.9

- Minor changes in `Yaml2PodoGenerator` (converter methods have been converted to static methods)
- Minor improvements in `Yaml2PodoGenerator` (unused converter methods are not generated)

## 0.1.8

- Minor improvements in `Yaml2PodoGenerator` (removed unnecessary checks and wrappers in generated code for save calls)

## 0.1.7

- Fixed bug in `Yaml2PodoGenerator`

## 0.1.6

- Minor changes in `convertToIdentifier()`

## 0.1.5

- Fixed bugs in `Yaml2PodoGenerator`
- Fixed bugs in `camelizeIdentifier()`
- Fixed bugs in `convertToIdentifier()`

## 0.1.4

- Minor improvements in source code

## 0.1.3

- Updated description for a more accurate understanding of the purpose of this software

## 0.1.2

- Minor improvements in `_JsonConverter`

## 0.1.1

- Fixed bugs in `Yaml2PodoGenerator`

## 0.1.0

- Initial release
