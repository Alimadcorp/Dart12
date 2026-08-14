import 'map.dart';
import 'util.dart';

String encode(
  String input,
  int version, // 1, 2
  bool caseSensitive,
  int unmatched, // 0: as-is, 1: ?, 2: unicode
) {
  final out = StringBuffer();

  void writeUnmatched(String ch) {
    out.write(switch (unmatched) {
      1 => '?',
      2 => "791${encode(a2u(ch), version, false, 1)}791",
      _ => ch
    });
  }

  bool _b = false; // bracket open
  int _c = 0; // 0: isn't, 2: is by word, 3: is by sentence
  final String _s = version == 1 ? "7" : ""; // suffix for capitalization

  // pointers for capitalization
  int lS = 0, wS = 0; // line start, word start
  int lE = -1, wE = -1; // line end, word end
  int lU = 0, wU = 0; // is current line/word uppercase? -1: no, 0: idk, 1: yea
  // we do this so that we dont end up recalculating stuff

  for (int i = 0; i < input.length; i++) {
    final String ch = input[i];
    if (ch == '\n' || ch == '\r') { // marks end of a line
      out.write('00');
      _c = lU = wU = 0; // reset these to zero
      lS = i + 1; // mark start of next line
      continue;
    } else if (ch == ' ') { // marks end of a word
      out.write('0');
      wU = 0; // mark as unresolved
      wS = i + 1; // update word start
      if (_c == 2) _c = 0; // reset to zero only if it was capital by word
      continue; 
    } 
    else if (ch == '(' && !_b) { out.write('373'); _b = true; continue; } 
    else if (ch == ')' && _b) { out.write('373'); _b = false; continue; } 
    else if (ch == '(' || ch == ')') { writeUnmatched(ch); continue; }

    final String CH = ch.toUpperCase();
    final int? token = inverseCipher(CH, version);

    if (caseSensitive) {
      // only go ahead if its a capital letter and hasnt already been handled
      if (ch == CH && isLetter(ch) && _c == 0) {
        if (i + 1 < input.length) {
          
          // check if the rest of the current line is uppercase
          if (i > lE && lU == 0) {
            int nLine = input.indexOf('\n', i);
            int rLine = input.indexOf('\r', i);
            if (nLine == -1) nLine = input.length;
            if (rLine == -1) rLine = input.length;
            
            lE = nLine < rLine ? nLine : rLine;
            final String line = input.substring(lS, lE);
            lU = (line == line.toUpperCase()) ? 1 : -1;
          }

          // check if the rest of the current word is uppercase
          if (i > wE && wU == 0) {
            wE = i;
            while (wE < lE && input[wE] != " ") {
              wE++;
            }
            final String word = input.substring(wS, wE);
            wU = (word == word.toUpperCase()) ? 1 : -1;
          }

          if (lU == 1) {
            _c = 3;
            out.write("73$_s");
          } else if (wU == 1) {
            _c = 2;
            out.write("72$_s");
          } else {
            out.write("71$_s");
          }
        } else {
          // if it is the last letter of the input, and is capital, then capitalize by letter 
          out.write("71$_s");
        }
      }
    }

    if (token == null) { writeUnmatched(ch); } 
    else { out.write(token.toString()); }
  }

  // The only point where compression takes place
  return compress(out.toString());
}