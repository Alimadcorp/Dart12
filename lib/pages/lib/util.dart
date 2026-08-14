// util functions
bool isLetter(String ch) {
  if (ch.isEmpty) return false;
  return ch.toUpperCase() != ch.toLowerCase();
}

String a2u(String ch) {
  if (ch.isEmpty) return "?"; // uhh
  final codePoint = ch.runes.first;
  return codePoint.toRadixString(16).toUpperCase();
}

String u2a(String hex) {
  final cleanHex = hex.replaceFirst(RegExp(r'^U\+', caseSensitive: false), '');
  final codePoint = int.parse(cleanHex, radix: 16);
  return String.fromCharCode(codePoint);
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
