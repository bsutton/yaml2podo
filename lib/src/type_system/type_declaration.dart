part of '../../type_system.dart';

class TypeDeclaration {
  List<TypeDeclaration> arguments = [];

  bool isCustomType = true;

  bool isEnumType = false;

  bool isUnknownType = true;

  String name;

  Map<String, PropertyDeclaration> properties = {};

  @override
  String toString() {
    var sb = StringBuffer();
    sb.write(name);
    if (arguments.isNotEmpty) {
      sb.write('<');
      var args = <String>[];
      for (var argument in arguments) {
        args.add(argument.toString());
      }

      sb.write(args.join(', '));
      sb.write('>');
    }

    return sb.toString();
  }
}
