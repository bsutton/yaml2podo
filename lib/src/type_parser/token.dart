part of '../../_type_parser.dart';

class Token {
  _TokenKind kind;
  int start;
  String text;

  @override
  String toString() => text;
}

enum _TokenKind { close, comma, eof, ident, open }
