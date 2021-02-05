part of '../../type_system.dart';

class TypeDeclaration {
  List<TypeDeclaration> arguments = [];

  bool isCustomType = true;

  bool isEnumType = false;

  bool isUnknownType = true;

  final String name;

  TypeDeclaration({required this.name});

  Map<String, PropertyDeclaration> properties = {};

  @override
  String toString() {
    final sb = StringBuffer();
    sb.write(name);
    if (arguments.isNotEmpty) {
      sb.write('<');
      final args = <String>[];
      for (var argument in arguments) {
        args.add(argument.toString());
      }

      sb.write(args.join(', '));
      sb.write('>');
    }

    return sb.toString();
  }
}
