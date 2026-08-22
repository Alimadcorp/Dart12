import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dart12/pages/help.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings.dart';
import 'lib/encode.dart';
import 'lib/decode.dart';
import 'components/toolbar.dart';
import 'components/output.dart';

Stream<Progress> startAsyncEncode({
  required String input,
  required int version,
  required bool caseSensitive,
  required int unmatched,
}) async* {
  final ReceivePort receivePort = ReceivePort();

  final Uint8List inputBytes = utf8.encode(input);
  final TransferableTypedData transferable = TransferableTypedData.fromList([inputBytes]);

  final config = EncodeConfig(
    transferableInput: transferable,
    version: version,
    caseSensitive: caseSensitive,
    unmatched: unmatched,
    replyTo: receivePort.sendPort,
  );

  final Isolate isolate = await Isolate.spawn(encode, config);
  await for (final dynamic message in receivePort) {
    if (message is Progress) {
      yield message;
      if (message.progress >= 1.0) {
        receivePort.close();
        isolate.kill(priority: Isolate.immediate);
        break;
      }
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _inputController = TextEditingController();
  Timer? _debounceTimer;
  String _lastProcessedText = "";
  SharedPreferences? _prefs;
  String _output = "";
  bool _encryptMode = true;
  bool _isLoading = true;
  bool _v1 = false;
  bool _viewedHelp = false;
  bool _caseSensitivity = true;
  String _unmatchedChar = 'as_is';
  StreamSubscription<Progress>? _encodingSubscription;
  // our subsription when a stream is alive
  double _progressValue = 0.0;

  static const String _keyViewedHelp = 'viewed_help';
  static const String _keyInput = 'saved_input';
  static const String _keyEncryptMode = 'encrypt_mode';
  static const String _keyV1 = 'v1_mode';
  static const String _keyCaseSensitivity = 'case_sens';
  static const String _keyUnmatchedChar = 'unmatched_character';

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    _inputController.addListener(_onTextChanged);
  }

  Future<void> _loadSavedData() async {
    _prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _encryptMode = _prefs?.getBool(_keyEncryptMode) ?? true;
      _v1 = _prefs?.getBool(_keyV1) ?? false;
      _viewedHelp = _prefs?.getBool(_keyViewedHelp) ?? false;
      final dynamic _r = _prefs?.get(_keyCaseSensitivity);
      _caseSensitivity = (_r is bool) ? _r : true;
      _unmatchedChar = _prefs?.getString(_keyUnmatchedChar) ?? 'as_is';
      final savedText = _prefs?.getString(_keyInput) ?? "";
      _inputController.text = savedText;
      _lastProcessedText = savedText;
      _isLoading = false;
    });

    if (_inputController.text.isNotEmpty) { _processText(); }
    if (!_viewedHelp) { _help(); }
  }

  void _onTextChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    // add a 200 ms delay if length is greater than 100 to improve performance while typin
    final int duration = _inputController.text.length > 5000 ? 450 : (_inputController.text.length > 100 ? 200 : 0);
    _debounceTimer = Timer(Duration(milliseconds: duration), () {
      final currentText = _inputController.text;
      if (currentText != _lastProcessedText) {
        _lastProcessedText = currentText;
        _processText();
        _saveString(_keyInput, currentText);
      }
    });
  }

  Future<void> _processText() async {
    final text = _inputController.text;
    await _encodingSubscription?.cancel(); // pause previously running stuff
    if (text.isEmpty) {
      if (mounted) setState(() { _output = ""; _progressValue = 1.0; });
      return;
    }

    setState(() => _progressValue = 0.01);

    if (_encryptMode) {
      final int unmatchedInt = _unmatchedChar == "as_is" 
          ? 0 
          : (_unmatchedChar == "question_mark" ? 1 : 2);

      final progressStream = startAsyncEncode(
        input: text,
        version: _v1 ? 1 : 2,
        caseSensitive: _caseSensitivity,
        unmatched: unmatchedInt,
      );

      _encodingSubscription = progressStream.listen(
        (Progress data) {
          if (!mounted || text != _inputController.text) return;
          
          setState(() {
            _progressValue = data.progress.clamp(0.0, 1.0);
            if (data.result != null) {
              _output = data.result!;
            }
          });
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _output = "Error: $error";
            _progressValue = 1.0;
          });
        },
      );
    } 
    else {
      try {
        final result = decode(text, _v1 ? 1 : 2, _caseSensitivity); 
        if (mounted && text == _inputController.text) {
          setState(() {
            _output = result;
            _progressValue = 1.0;
          });
        }
      } catch (e) {
        if (mounted && text == _inputController.text) {
          setState(() {
            _output = e.toString();
            _progressValue = 1.0;
          });
        }
      }
    }
  }

  void _saveString(String key, String value) {
    _prefs?.setString(key, value);
  }

  void _saveBool(String key, bool value) {
    _prefs?.setBool(key, value);
  }

  void _changeMode(bool isToggled) {
    setState(() => _encryptMode = isToggled);
    _saveBool(_keyEncryptMode, isToggled);
    _processText();
  }

  void _swapVersion(bool isToggled) {
    setState(() => _v1 = isToggled);
    _saveBool(_keyV1, isToggled);
    _processText();
  }

  void _toggleSens(bool isToggled) {
    setState(() => _caseSensitivity = isToggled);
    _saveBool(_keyCaseSensitivity, isToggled);
    _processText();
  }

  void _swap() {
    if (_output.isEmpty) return;
    _debounceTimer?.cancel();
    final newText = _output.replaceFirst(RegExp(r'[0\n]*$'), ''); // replace all trailing 0s and breaks
    _encryptMode = !_encryptMode;
    _saveBool(_keyEncryptMode, _encryptMode);
    _lastProcessedText = newText;
    _inputController.text = newText;
    _processText();
  }

  Future<void> _copy() async {
    if (_output.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _output));
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) _inputController.text = data!.text!;
  }

  void _clear() => _inputController.clear();

  Future<void> _settings() async {
    final oldUnmatched = _unmatchedChar;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
    await _prefs?.reload();
    final newUnmatched = _prefs?.getString(_keyUnmatchedChar) ?? 'as_is';
    if (oldUnmatched != newUnmatched) {
      setState(() {
        _unmatchedChar = newUnmatched;
      });
      _processText();
    }
  }

  void _help() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const HelpPage()),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _encodingSubscription?.cancel();
    _inputController.removeListener(_onTextChanged);
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final outlineColor = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: outlineColor, width: 2.0),
                      left: BorderSide(color: outlineColor, width: 2.0),
                      right: BorderSide(color: outlineColor, width: 2.0),
                    ),
                  ),
                  child: TextField(
                    controller: _inputController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none, 
                      hintText: "Input",
                      hintStyle: TextStyle(color: outlineColor.withAlpha(100)),
                      contentPadding: const EdgeInsets.all(12.0), 
                    ),
                  ),
                )

              ),
              Container(
                height: 2,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.symmetric(vertical: BorderSide(color: outlineColor, width: 2.0))
                ),
                alignment: Alignment.centerLeft,
                child: AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 20),
                  widthFactor: _progressValue,
                  heightFactor: 1.0,
                  child: ColoredBox(color: theme.colorScheme.primary),
                ),
              ),
              Expanded(
                flex: 1,
                child: OutputDisplay(
                  output: _output, // output
                  encryptMode: _encryptMode,
                ),
              ),
              BottomToolbar(
                encryptMode: _encryptMode,
                caseSensitivity: _caseSensitivity,
                v1: _v1,
                onModeChanged: _changeMode,
                onCaseSensChanged: _toggleSens,
                onVersionChanged: _swapVersion,
                onSwap: _swap,
                onCopy: _copy,
                onPaste: _paste,
                onClear: _clear,
                onSettings: _settings,
                onHelp: _help,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
