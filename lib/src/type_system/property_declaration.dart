part of '../../type_system.dart';

class PropertyDeclaration {
  String? alias;

  bool isFinal = false;

  final String name;

  final TypeDeclaration type;

  PropertyDeclaration({required this.name, required this.type});

  @override
  String toString() {
    final sb = StringBuffer();
    sb.write(name);
    sb.write(': ');
    sb.write(type);
    return sb.toString();
  }
}
