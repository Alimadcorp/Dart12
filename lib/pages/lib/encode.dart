import 'map.dart';
import 'util.dart';

String encode(
  String input,
  int version,
  bool caseSensitive,
  int unmatched, // 0: as-is, 1: ?, 2: unicode
) {
  // Use named arguments or print all parameters explicitly:
  // ignore: avoid_print
  print('mode: encode, input: $input, v: $version, case: $caseSensitive, unmatched: $unmatched');
  
  final out = StringBuffer();
  void writeOut(String ch) {
    out.write(switch (unmatched) { 1 => '?', 2 => "791${encode(a2u(ch), version, false, 1)}791", _ => ch });
  }
  bool _b = false;

  for (int i = 0; i < input.length; i++) {
    final ch = input[i];

    if (ch == '\n') { out.write('00'); continue; }
    else if (ch == '(' && !_b) { out.write('373'); _b = true; continue; }
    else if (ch == ')' && _b) { out.write('373'); _b = false; continue; } 
    else if (ch == '(' || ch == ')') { writeOut(ch); continue; }

    final String CH = ch.toUpperCase();
    final int? token = inverseCipher(CH, version);
    final bool _l = isLetter(ch); // is a letter
    final bool _C = (ch == CH && _l); // is a capital letter

    if(token == null) { writeOut(ch); }
    else { out.write(token.toString()); }
  }

  return compress(out.toString());
}