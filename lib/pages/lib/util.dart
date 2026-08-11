import 'encode.dart';

// util functions
bool isLetter(String ch) {
  if (ch.isEmpty) return false;
  final up = ch.toUpperCase();
  final low = ch.toLowerCase();
  return up != low;
}

bool isTerminator(String ch) {
  const terminators = {'.', ',', '!', '?', '\n', '\r'};
  return terminators.contains(ch);
}

String toUnicode(String ch) {
  if (ch.isEmpty) return "?"; // uhh
  final codePoint = ch.runes.first;
  return codePoint.toRadixString(16).toUpperCase();
}

String fromUnicode(String hex) {
  final cleanHex = hex.replaceFirst(RegExp(r'^U\+', caseSensitive: false), '');
  final codePoint = int.parse(cleanHex, radix: 16);
  return String.fromCharCode(codePoint);
}

void writeOut(StringBuffer out, String ch, int version, int unmatched) {
  out.write(switch (unmatched) {
    1 => '?',
    2 => encode(toUnicode(ch), version, false, 1),
    _ => ch,
  });
}

String compress(String input) {
  final _p = RegExp(r'11|22|33');
  return input.replaceAllMapped(_p, (m) => switch (m[0]) {
    '11' => '4', '22' => '5', '33' => '6', _ => m[0]!
  });
}

String decompress(String input) {
  final _p = RegExp(r'[456]');
  return input.replaceAllMapped(_p, (m) => switch (m[0]) {
    '4' => '11', '5' => '22', '6' => '33', _ => m[0]!
  });
}
