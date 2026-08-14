import 'util.dart';

String decode(String input, int version, bool caseSensitive) {
  final out = StringBuffer();
  input = decompress(input); // only place where decompression takes place

  // ignore: avoid_print
  print('mode: encode, input: $input, v: $version, case: $caseSensitive');


  return input;
}
