import 'package:dart12/components/boxiconbutton.dart';
import 'package:flutter/material.dart';
import 'lib/encode.dart';
import 'lib/decode.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _inputController = TextEditingController();
  String _output = "";
  bool _encryptMode = false;
  bool _v1 = false;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _output = encode(_inputController.text);
    });
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
                  decoration: const InputDecoration(
                    labelText: "Input",
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.zero),
                    ),
                    hintText: "Input",
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
                    child: Text(
                      _output,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
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
                          onTap: () => debugPrint('Encrypt/Decrypt toggled'),
                        ),
                      ),
                      BoxIconButton(
                        icon: Icons.swap_vert,
                        onTap: () => debugPrint('Swap pressed'),
                      ),
                      BoxIconButton(
                        icon: Icons.copy,
                        onTap: () => debugPrint('Copy pressed'),
                      ),
                      BoxIconButton(
                        icon: Icons.paste,
                        onTap: () => debugPrint('Paste pressed'),
                      ),
                      BoxIconButton(
                        icon: Icons.delete,
                        onTap: () => debugPrint('Clear pressed'),
                      ),
                      BoxIconButton(
                        icon: Icons.looks_one,
                        isToggleable: true,
                        onTap: () => debugPrint('Old/New toggled'),
                      ),
                      BoxIconButton(
                        icon: Icons.settings,
                        onTap: () => debugPrint('Settings pressed'),
                      ),
                    ],
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
