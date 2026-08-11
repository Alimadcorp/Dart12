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
  bool _b = false;

  for (int i = 0; i < input.length; i++) {
    final ch = input[i];

    if (ch == '\n') { out.write('00'); continue; }
    else if (ch == '(' && !_b) { out.write('373'); _b = true; continue; }
    else if (ch == ')' && _b) { out.write('373'); _b = false; continue; } 
    else if (ch == '(' || ch == ')') { writeOut(out, ch, version, unmatched); continue; }

    final String CH = ch.toUpperCase();
    final int? token = inverseCipher(CH, version);
    final bool _l = isLetter(ch); // is a letter
    final bool _C = (ch == CH && _l); // is a capital letter

    if(token == null) { writeOut(out, ch, version, unmatched); }
    else { out.write(token.toString()); }
  }

  return compress(out.toString());
}