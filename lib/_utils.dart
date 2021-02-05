bool alpha(int c) {
  if (c >= 65 && c <= 90 || c >= 97 && c <= 122) {
    return true;
  }

  return false;
}

bool alphanum(int c) {
  if (alpha(c) || digit(c)) {
    return true;
  }

  return false;
}

String camelizeIdentifier(String ident) {
  if (ident.isEmpty) {
    return ident;
  }

  var pos = 0;
  final sb = StringBuffer();
  while (pos < ident.length) {
    final c = ident.codeUnitAt(pos);
    if (c == 95) {
      sb.write('_');
      pos++;
    } else {
      break;
    }
  }

  var needCapitalize = false;
  for (; pos < ident.length; pos++) {
    final c = ident.codeUnitAt(pos);
    final s = ident[pos];
    if (c == 95) {
      if (pos + 1 < ident.length) {
        if (ident.codeUnitAt(pos + 1) == 95) {
          sb.write(s);
        } else {
          needCapitalize = true;
        }
      } else {
        needCapitalize = true;
        if (pos + 1 == ident.length) {
          sb.write(s);
        }
      }
    } else {
      var s2 = s;
      if (needCapitalize) {
        s2 = s.toUpperCase();
        if (s2 != s) {
          needCapitalize = false;
        }
      }

      sb.write(s2);
    }
  }

  return sb.toString();
}

String capitalizeIdentifier(String ident) {
  if (ident.isEmpty) {
    return ident;
  }

  final prefix = <String>[];
  var rest = ident;
  var pos = 0;
  while (pos < ident.length) {
    final c = ident.codeUnitAt(pos);
    if (c == 36 || c == 95) {
      prefix.add(ident[pos++]);
    } else {
      break;
    }
  }

  rest = ident.substring(pos);
  var result = prefix.join();
  if (rest.isNotEmpty) {
    result = result + rest[0].toUpperCase() + rest.substring(1);
  }

  return result;
}

String convertToIdentifier(String str, String replacement) {
  if (str.isEmpty) {
    throw ArgumentError.value(str, 'str', 'Must not be empty');
  }

  str = str[0] + str.substring(1).replaceAll('-', '_');
  var pos = 0;
  final sb = StringBuffer();
  if (digit(str.codeUnitAt(pos))) {
    final s = str[pos];
    sb.write(replacement);
    sb.write(s);
    pos++;
  }

  while (pos < str.length) {
    final c = str.codeUnitAt(pos);
    if (!(alphanum(c) || c == 95)) {
      sb.write(replacement);
      pos++;
    } else {
      break;
    }
  }

  for (; pos < str.length; pos++) {
    final c = str.codeUnitAt(pos);
    final s = str[pos];
    if (alphanum(c) || c == 95) {
      sb.write(s);
    } else {
      sb.write(replacement);
    }
  }

  final result = sb.toString();
  return result;
}

bool digit(int c) {
  if (c >= 48 && c <= 57) {
    return true;
  }

  return false;
}

String makePublicIdentifier(String ident, String option) {
  if (ident.isEmpty) {
    return option;
  }

  final suffix = <String>[];
  var pos = 0;
  while (pos < ident.length) {
    final c = ident.codeUnitAt(pos);
    if (c == 95) {
      suffix.add('_');
      pos++;
    } else {
      break;
    }
  }

  var rest = ident.substring(pos);
  if (rest.isEmpty) {
    rest = option;
  }

  final result = rest + suffix.join('');
  return result;
}
