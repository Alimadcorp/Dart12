import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings.dart';
import 'components/toolbar.dart';
import 'components/output.dart';
import 'lib/encode.dart';
import 'lib/decode.dart';

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
  bool _encryptMode = false;
  bool _isLoading = true;
  bool _v1 = false;
  bool _caseSensitivity = true;
  String _unmatchedChar = 'as_is';

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
      _encryptMode = _prefs?.getBool(_keyEncryptMode) ?? false;
      _v1 = _prefs?.getBool(_keyV1) ?? false;
      final dynamic _r = _prefs?.get(_keyCaseSensitivity);
      _caseSensitivity = (_r is bool) ? _r : true;

      _unmatchedChar = _prefs?.getString(_keyUnmatchedChar) ?? 'as_is';

      final savedText = _prefs?.getString(_keyInput) ?? "";
      _inputController.text = savedText;
      _lastProcessedText = savedText;

      _isLoading = false;
    });

    if (_inputController.text.isNotEmpty) {
      _processText();
    }
  }

  void _onTextChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    // add a 200 ms delay if length is greater than 100 to improve performance while typin
    final int duration =  _inputController.text.length > 100 ? 200 : 0; 
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
    if (text.isEmpty) {
      if (mounted) setState(() => _output = "");
      return;
    }

    try {
      final result = _encryptMode
          ? encode(
              text,
              _v1 ? 1 : 2,
              _caseSensitivity,
              _unmatchedChar == "as_is"
                  ? 0
                  : (_unmatchedChar == "question_mark" ? 1 : 2),
            )
          : decode(text, _v1 ? 1 : 2, _caseSensitivity);

      if (mounted && text == _inputController.text) {
        setState(() => _output = result);
      }
    } catch (e) {
      if (mounted && text == _inputController.text) {
        setState(() {
          _output = e.toString();
        });
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
    _changeMode(!_encryptMode);
    _inputController.text = _output;
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

  @override
  void dispose() {
    _debounceTimer?.cancel();
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
                child: TextField(
                  controller: _inputController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    labelText: "Input",
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: outlineColor, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: outlineColor, width: 2.0),
                    ),
                    hintText: "Input",
                    hintStyle: TextStyle(color: outlineColor.withAlpha(100)),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: OutputDisplay(
                  output: _output,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
