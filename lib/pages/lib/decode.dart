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

Future<String> decodeIsolate(DecodeConfig config) async {
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
  final String result = await decode(input, config.version, config.caseSensitive, config.replyTo);
  config.replyTo?.send(Progress(
    progress: 1.0, 
    finalResult: result,
  ));

  return result;
}

Future<String> decode(String masterInput, int version, bool caseSensitive, [SendPort? progressPort]) async {
  final StringBuffer out = StringBuffer();
  masterInput = masterInput.replaceAll('4', '11').replaceAll('5', '22').replaceAll('6', '33'); 
  await Future.delayed(const Duration(milliseconds: 1));
  final RegExp regex = RegExp(r'791(.*?)791');
  final matches = regex.allMatches(masterInput).toList();

  if (matches.isNotEmpty) {
    final StringBuffer processedInput = StringBuffer();
    int lastEnd = 0;

    // resolve all nested async decode calls in parallel
    final decodedTokens = await Future.wait(
      matches.map((m) => decode(m.group(1) ?? "", version, false)),
    );

    for (int i = 0; i < matches.length; i++) {
      final match = matches[i];
      processedInput.write(masterInput.substring(lastEnd, match.start));
      processedInput.write(u2a(decodedTokens[i]));
      lastEnd = match.end;
    }
    processedInput.write(masterInput.substring(lastEnd));
    masterInput = processedInput.toString();
  }
  
  if (!caseSensitive && version == 1) {
    masterInput = masterInput.replaceAll('717', '').replaceAll('727', '').replaceAll('737', ''); 
  }

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
        await Future.delayed(const Duration(milliseconds: 1));
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

      if (codeUnit < 48 || codeUnit > 57) { // if its not a digit
        out.write(acc.toString()); // add it as-is to output
        acc.clear();
        accL = 0;
        continue;
      }

      if (char == "0") { // space marker
        final String accStr = acc.toString();
        out.write(accStr.substring(0, accStr.length - 1));
        out.write(' ');
        _cW = false;
        acc.clear();
        accL = 0;
        continue;
      }
      
      if (accL == 4) {
        final String accStr = acc.toString();
        out.write(accStr[0]);
        acc.clear();
        acc.write(accStr.substring(1, 4));
        accL = 3;
      }

      if (accL == 0) { continue; }

      final String accStr = acc.toString();
      final int? nAcc = int.tryParse(accStr);
      final String? token;

      if (caseSensitive) {
        if (version == 1) {
          switch (nAcc) {
            case 717:
              _cL = true;
              token = null; acc.clear(); accL = 0; break;
            case 727:
              _cW = true;
              token = null; acc.clear(); accL = 0; break;
            case 737:
              token = null;
              acc.clear(); accL = 0; break;
            case 373:
              _b = !_b; token = _b ? '(' : ')'; break;
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
        }
      } else {
        if (nAcc == 373) {
          _b = !_b; token = _b ? '(' : ')';
        } else {
          token = nAcc != null ? cipher(nAcc, version) : null;
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

    out.write("\n");
  }

  return out.toString();
}