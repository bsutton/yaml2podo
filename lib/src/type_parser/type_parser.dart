part of '../../_type_parser.dart';

class TypeParser {
  String? _source;

  late Token _token;

  late List<Token> _tokens;

  int _pos = 0;

  TypeDeclaration parse(String source) {
    _source = source;
    final tokenizer = TypeTokenizer();
    _tokens = tokenizer.tokenize(source);
    _reset();

    return _parseType();
  }

  void _match(_TokenKind kind) {
    if (_token.kind == kind) {
      _nextToken();
      return;
    }

    throw FormatException('Invalid type', _source, _token.start);
  }

  Token _nextToken() {
    if (_pos + 1 < _tokens.length) {
      _token = _tokens[++_pos];
    }

    return _token;
  }

  List<TypeDeclaration> _parseArgs() {
    final result = <TypeDeclaration>[];
    final type = _parseType();
    result.add(type);
    while (true) {
      if (_token.kind != _TokenKind.comma) {
        break;
      }

      _nextToken();
      final type = _parseType();
      result.add(type);
    }

    return result;
  }

  TypeDeclaration _parseType() {
    final name = _token.text;
    _match(_TokenKind.ident);
    var arguments = <TypeDeclaration>[];
    if (_token.kind == _TokenKind.open) {
      _nextToken();
      arguments = _parseArgs();
      _match(_TokenKind.close);
    }

    final result = TypeDeclaration(name: name);
    result.arguments.addAll(arguments);
    return result;
  }

  void _reset() {
    _pos = 0;
    _token = _tokens[0];
  }
}
