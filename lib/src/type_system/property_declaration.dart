part of '../../type_system.dart';

class PropertyDeclaration {
  String alias;

  bool isFinal = false;

  String name;

  TypeDeclaration type;

  @override
  String toString() {
    var sb = StringBuffer();
    sb.write(name);
    sb.write(': ');
    sb.write(type);
    return sb.toString();
  }
}
