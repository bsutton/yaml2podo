part of '../../_type_parser.dart';

class Token {
  final _TokenKind kind;

  final int start;

  final String text;

  Token({required this.kind, required this.start, required this.text});

  @override
  String toString() => text;
}

enum _TokenKind { close, comma, eof, ident, open }
