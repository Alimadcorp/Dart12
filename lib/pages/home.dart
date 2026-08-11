import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings.dart';
import 'button.dart';
import 'lib/encode.dart';
import 'lib/decode.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class DesktopScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return Scrollbar(controller: details.controller, child: child);
  }
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _inputController = TextEditingController();

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
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _encryptMode = prefs.getBool(_keyEncryptMode) ?? false;
      _v1 = prefs.getBool(_keyV1) ?? false;
      _inputController.text = prefs.getString(_keyInput) ?? "";
      _isLoading = false;
      _caseSensitivity = prefs.getBool(_keyCaseSensitivity) ?? false;
      _unmatchedChar = prefs.getString(_keyUnmatchedChar) ?? 'as_is';
    });
    _processText();
  }

  Future<void> _processText() async {
    final text = _inputController.text;
    if (text.isEmpty) {
      if (mounted) setState(() => _output = "");
      return;
    }

    try {
      final result = _encryptMode
          ? await encode(
              text,
              _v1 ? 1 : 2,
              _caseSensitivity,
              _unmatchedChar == "as_is"
                  ? 0
                  : (_unmatchedChar == "question_mark" ? 1 : 2),
            )
          : await decode(text, _v1 ? 1 : 2, _caseSensitivity);

      if (mounted && text == _inputController.text) {
        setState(() {
          _output = result;
        });
      }
    } catch (e) {
      if (mounted && text == _inputController.text) {
        setState(() {
          _output =
              "Error: Invalid input for ${_encryptMode ? 'encoding' : 'decoding'}";
        });
      }
    }
  }

  void _onTextChanged() {
    _processText();
    _saveString(_keyInput, _inputController.text);
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
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
    final temp = _output;
    _inputController.text = temp;
  }

  Future<void> _copy() async {
    if (_output.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _output));
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      _inputController.text = data.text!;
    }
  }

  void _clear() {
    _inputController.clear();
  }

  void _settings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SettingsPage()));
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outlineColor = theme.colorScheme.onSurfaceVariant;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                      borderRadius: BorderRadius.all(Radius.zero),
                      borderSide: BorderSide(color: outlineColor, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.zero),
                      borderSide: BorderSide(color: outlineColor, width: 2.0),
                    ),
                    hintText: "Input",
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
                    ),
                  ),
                ),
              ),

              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 16.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.zero,
                    border: Border(
                      left: BorderSide(color: outlineColor, width: 2.0),
                      right: BorderSide(color: outlineColor, width: 2.0),
                      top: BorderSide.none,
                      bottom: BorderSide(color: outlineColor, width: 2.0),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _output.isEmpty
                          ? (_encryptMode ? "Encoded output" : "Decoded output")
                          : _output,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: _output.isEmpty
                            ? theme.colorScheme.onSurfaceVariant.withAlpha(100)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: ScrollConfiguration(
                  behavior: DesktopScrollBehavior(),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: outlineColor, width: 2.0),
                            ),
                          ),
                          child: BoxIconButton(
                            icon: Icons.code_off,
                            isToggleable: true,
                            initialToggleState: _encryptMode,
                            onTap: (isToggled) => _changeMode(isToggled),
                          ),
                        ),

                        BoxIconButton(
                          icon: Icons.swap_vert,
                          onTap: (_) => _swap(),
                        ),

                        BoxIconButton(icon: Icons.copy, onTap: (_) => _copy()),
                        BoxIconButton(
                          icon: Icons.paste,
                          onTap: (_) => _paste(),
                        ),
                        BoxIconButton(
                          icon: Icons.delete,
                          onTap: (_) => _clear(),
                        ),
                        BoxIconButton(
                          icon: Icons.text_fields,
                          isToggleable: true,
                          initialToggleState: _caseSensitivity,
                          onTap: (isToggled) => _toggleSens(isToggled),
                        ),
                        BoxIconButton(
                          icon: Icons.looks_one,
                          isToggleable: true,
                          initialToggleState: _v1,
                          onTap: (isToggled) => _swapVersion(isToggled),
                        ),

                        BoxIconButton(
                          icon: Icons.settings,
                          onTap: (_) => _settings(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
