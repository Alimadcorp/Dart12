import 'dart:isolate';
import 'dart:convert';
import 'dart:typed_data';

import 'map.dart';
import 'util.dart';
import 'encode.dart';

class DecodeConfig {
  final TransferableTypedData? transferableInput;
  final String? input;
  final int version;
  final bool caseSensitive;
  final SendPort? replyTo;

  DecodeConfig({
    this.transferableInput, this.input, required this.version, required this.caseSensitive, this.replyTo,
  });
}

String decodeIsolate(DecodeConfig config) {
  final String input;
  if (config.transferableInput != null) {
    final ByteBuffer buffer = config.transferableInput!.materialize();
    final Uint8List raw = buffer.asUint8List();
    input = utf8.decode(raw);
  } else if (config.input != null) {
    input = config.input!;
  } else {
    input = "";
  }

  // Runs the decode method and passes the port down for progress
  final String result = decode(input, config.version, config.caseSensitive, config.replyTo);
  
  config.replyTo?.send(Progress(
    progress: 1.0, 
    finalResult: result,
  ));

  return result;
}

// Modified to accept an optional SendPort so it doesn't break when making recursive unicode calls
String decode(String masterInput, int version, bool caseSensitive, [SendPort? progressPort]) {
  
  final StringBuffer out = StringBuffer();
  // only place where decompression takes place
  masterInput = masterInput.replaceAll('4', '11').replaceAll('5', '22').replaceAll('6', '33'); 

  masterInput = masterInput.replaceAllMapped(RegExp(r'791(.*?)791'), (Match match) {
    final String token = match.group(1) ?? "";
    return u2a(decode(token, version, false)); // Recursive call gracefully skips progress reporting
  }); 
  
  // if not case sensitive and version is 1, remove those characters...
  if(!caseSensitive && version == 1) masterInput = masterInput.replaceAll('717', '').replaceAll('727', '').replaceAll('737', ''); 

  // split into sentences
  final List<String> inputs = masterInput.split(RegExp(r'\r?\n|00')); 

  final StringBuffer acc = StringBuffer(); 
  int accL = 0; 
  bool _cL = false, _cW = false; 
  bool _b = false; 

  int lastProgress = -1;
  final int total = inputs.length;

  for (int sentence = 0; sentence < inputs.length; sentence++) {
    if (progressPort != null) {
      int currentProgress = (sentence * 90) ~/ (total > 0 ? total : 1);
      if (currentProgress != lastProgress || sentence == total - 1) {
        progressPort.send(Progress(progress: currentProgress / 100.0));
        lastProgress = currentProgress;
      }
    }

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
            case 73: token = null; acc.clear(); accL = 0; break;
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