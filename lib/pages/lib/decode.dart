import 'map.dart';
import 'util.dart';

String decode(String masterInput, int version, bool caseSensitive) {
  
  final StringBuffer out = StringBuffer();
  masterInput = decompress(masterInput); // only place where decompression takes place

  masterInput = masterInput.replaceAllMapped(RegExp(r'791(.*?)791'), (Match match) {
    final String token = match.group(1) ?? "";
    return u2a(decode(token, version, false));
  }); // replace all unicode chars
  
  // if not case sensitive and version is 1, remove those characters...
  if(!caseSensitive && version == 1) masterInput = masterInput.replaceAll('717', '').replaceAll('727', '').replaceAll('737', ''); 

  // split into sentences
  final List<String> inputs = masterInput.split(RegExp(r'\r?\n|00')); // split by double 0 or line break

  final StringBuffer acc = StringBuffer(); // accumulator
  int accL = 0; // accumulator length
  bool _cL = false, _cW = false; // capitalize by letter, word
  bool _b = false; // bracket open
  for (int sentence = 0; sentence < inputs.length; sentence++) {
    final String input;
    final bool _cS; // capital sentence
    if (caseSensitive && inputs[sentence].startsWith("73")) {
      if (version == 2) {
        _cS = true; input = inputs[sentence].substring(2);
      } else if (version == 1 && inputs[sentence].startsWith("737")) {
        _cS = true; input = inputs[sentence].substring(3);
      } else { _cS = false; input = inputs[sentence]; }
    } else {
      _cS = false; input = inputs[sentence];
    }

    for (int i = 0; i < input.length; i++) {
      final String char = input[i];
      final int codeUnit = char.codeUnitAt(0);

      acc.write(char); accL++; // add the character to accumulator

      if (codeUnit < 48 || codeUnit > 57) { // if its not a digit,
        out.write(acc.toString()); // add it as-is to output
        acc.clear(); // clear the accumulator
        accL = 0;
        continue; // skip rest of loop
      }

      if (char == "0") { // if there is a space
        final String accStr = acc.toString();
        out.write(accStr.substring(0, accStr.length - 1));
        out.write(' '); // write accumulator followed by a space to output
        _cW = false; // no longer capital by word as word has ended
        acc.clear(); // reset accumulator
        accL = 0;
        continue; // skip rest of loop
      }
      
      if(accL == 4) { // if accumulator has a length of 4
        final String accStr = acc.toString();
        out.write(accStr[0]); // write the first character to output
        acc.clear();
        acc.write(accStr.substring(1, 4)); // and then drop it
        accL = 3; // update length, accumulator has a max length of 3
      }

      if (accL == 0) { continue; } // in some cases this might occur

      final String accStr = acc.toString();
      final int? nAcc = int.tryParse(accStr);
      final String? token;


      if (caseSensitive) {
        if (version == 1) {
          switch (nAcc) {
            case 717:
              _cL = true; // capitalize next letter
              // setting token to null skips adding to out and doesnt reset _cL
              token = null; acc.clear(); accL = 0; break;
            case 727:
              _cW = true; // still capital, but by word
              token = null; acc.clear(); accL = 0; break;
            case 737:
              token = null; // this is a repeated 737, we ignore it... quite a rare case
              acc.clear(); accL = 0; break;
            case 373:
              // added bracket support
              _b = !_b; token = _b ? '(' : ')'; break; 
              // do not clear accumulator as token is not null, hence the clear loop wont be skipped
            default: token = nAcc != null ? cipher(nAcc, version) : null;
          }
        } else if (version == 2) {
          switch (nAcc) {
            case 73: token = null; acc.clear(); accL = 0;
            case 72: token = null; acc.clear(); accL = 0; _cW = true; break;
            case 71: token = null; acc.clear(); accL = 0; _cL = true; break;
            case 373: _b = !_b; token = _b ? '(' : ')'; break;
            default: token = nAcc != null ? cipher(nAcc, version) : null;
          }
        } else {
          token = nAcc != null ? cipher(nAcc, version) : null;
          // unreachable unless you do something stupid
          // please dont do stupid things
        }
      } else {
        if(nAcc == 373) {
          _b = !_b; token = _b ? '(' : ')';
        } else {
          token = nAcc != null ? cipher(nAcc, version) : null; // these will be all upper...
        }
      }

      if (token != null) {
        final bool isUpper = caseSensitive ? (_cS || _cW || _cL) : false;
        out.write(caseSensitive ? (isUpper ? token.toUpperCase() : token.toLowerCase()) : token);
        acc.clear();
        accL = 0;
        _cL = false;
      }
    }

    out.write("\n"); // after each sentence write a line break
  }

  return out.toString();
}
