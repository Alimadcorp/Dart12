import 'map.dart';
import 'util.dart';

String decode(String masterInput, int version, bool caseSensitive) {
  
  final StringBuffer out = StringBuffer();
  masterInput = decompress(masterInput); // only place where decompression takes place
  
  // if not case sensitive and version is 1, remove those characters...
  if(!caseSensitive && version == 1) masterInput = masterInput.replaceAll(RegExp(r'7[123]7'), ""); 

  // split into sentences
  final List<String> inputs = masterInput.split(RegExp(r'\r?\n|00')).toList(); // split by double 0 or line break

  String acc = ""; // accumulator
  int accL = 0; // accumulator length
  bool _cL = false, _cW = false; // capitalize by letter, word
  for (int sentence = 0; sentence < inputs.length; sentence++) {
    final String input;
    final bool _cS; // capital sentence
    if (caseSensitive && inputs[sentence].startsWith("73")) {
      if (version == 2) {
        _cS = true; input = inputs[sentence].substring(2, inputs[sentence].length);
      } else if (version == 1 && inputs[sentence].startsWith("737")) {
        _cS = true; input = inputs[sentence].substring(3, inputs[sentence].length);
      } else { _cS = false; input = inputs[sentence]; }
    } else {
      _cS = false; input = inputs[sentence];
    }

    for (int i = 0; i < input.length; i++) {
      acc += input[i]; accL++; // add the character to accumulator

      if (!RegExp(r'\d').hasMatch(input[i])) { // if its not a digit,
        out.write(acc); // add it as-is to output
        acc = ""; // clear the accumulator
        accL = 0;
        continue; // skip rest of loop
      }

      if (input[i] == "0") { // if there is a space
        out.write("$acc ".replaceAll("0", "")); // write accumulator followed by a space to output
        _cW = false; // no longer capital by word as word has ended
        acc = ""; // reset accumulator
        accL = 0;
        continue; // skip rest of loop
      }
      
      if(accL == 4) { // if accumulator has a length of 4
        out.write(acc[0]); // write the first character to output
        acc = acc.substring(1, 4); // and then drop it
        accL = 3; // update length, accumulator has a max length of 3
      }

      if (acc == "") { continue; } // in some cases this might occur

      final int nAcc = int.parse(acc);
      final String? token;


      if (caseSensitive) {
        if (version == 1) {
          switch (nAcc) {
            case 717:
              _cL = true; // capitalize next letter
              // setting token to null skips adding to out and doesnt reset _cL
              token = null; acc = ""; accL = 0; break;
            case 727:
              _cW = true; // still capital, but by word
              token = null; acc = ""; accL = 0; break;
            case 737:
              token = null; // this is a repeated 737, we ignore it... quite a rare case
              acc = ""; accL = 0; break;
            default: token = cipher(nAcc, version);
          }
        } else if (version == 2) {
          switch (nAcc) {
            case 73: token = null; acc = ""; accL = 0;
            case 72: token = null; acc = ""; accL = 0; _cW = true; break;
            case 71: token = null; acc = ""; accL = 0; _cL = true; break;
            default: token = cipher(nAcc, version);
          }
        } else {
          token = cipher(nAcc, version);
        }
      } else {
        token = cipher(nAcc, version); // these will be all upper...
      }

      if (token != null) {
        out.write(caseSensitive ? _cS ? token.toUpperCase() : (_cW ? token.toUpperCase() : (_cL ? token.toUpperCase() : token.toLowerCase())) : token);
        acc = "";
        accL = 0;
        _cL = false;
      }
    }

    out.write("\n"); // after each sentence write a line break
  }

  return out.toString();
}
