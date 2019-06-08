part of '../../_type_parser.dart';

class TypeTokenizer {
  static const _eof = 0;

  int _ch;

  int _pos;

  String _source;

  List<Token> tokenize(String source) {
    _source = source;
    var tokens = <Token>[];
    _reset();
    while (true) {
      _white();
      String text;
      _TokenKind kind;
      if (_ch == _eof) {
        kind = _TokenKind.eof;
        text = '';
        break;
      }

      var start = _pos;
      switch (_ch) {
        case 44:
          text = ',';
          kind = _TokenKind.comma;
          _nextCh();
          break;
        case 60:
          text = '<';
          kind = _TokenKind.open;
          _nextCh();
          break;
        case 62:
          text = '>';
          kind = _TokenKind.close;
          _nextCh();
          break;
        default:
          if (_utils.alpha(_ch) || _ch == 36 || _ch == 95) {
            var length = 1;
            _nextCh();
            while (_utils.alphanum(_ch) || _ch == 36 || _ch == 95) {
              length++;
              _nextCh();
            }

            text = source.substring(start, start + length);
            kind = _TokenKind.ident;
          } else {
            throw FormatException('Invalid type', source, start);
          }
      }

      var token = Token();
      token.kind = kind;
      token.start = start;
      token.text = text;
      tokens.add(token);
    }

    return tokens;
  }

  int _nextCh() {
    if (_pos + 1 < _source.length) {
      _ch = _source.codeUnitAt(++_pos);
    } else {
      _ch = _eof;
    }

    return _ch;
  }

  void _reset() {
    _pos = 0;
    _ch = _eof;
    if (_source.isNotEmpty) {
      _ch = _source.codeUnitAt(0);
    }
  }

  void _white() {
    while (true) {
      if (_ch == 32) {
        _nextCh();
      } else {
        break;
      }
    }
  }
}
