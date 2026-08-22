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
  final codePoint = int.tryParse(cleanHex, radix: 16);
  if (codePoint == null || codePoint < 0 || codePoint > 0x10FFFF) {
    return "";
  }
  return String.fromCharCode(codePoint);
}