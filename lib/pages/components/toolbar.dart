import 'package:flutter/material.dart';
import 'button.dart';
import 'scroll.dart';

class BottomToolbar extends StatelessWidget {
  final bool encryptMode;
  final bool caseSensitivity;
  final bool v1;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<bool> onCaseSensChanged;
  final ValueChanged<bool> onVersionChanged;
  final VoidCallback onSwap;
  final VoidCallback onCopy;
  final VoidCallback onPaste;
  final VoidCallback onClear;
  final VoidCallback onSettings;
  final VoidCallback onHelp;

  const BottomToolbar({
    super.key,
    required this.encryptMode,
    required this.caseSensitivity,
    required this.v1,
    required this.onModeChanged,
    required this.onCaseSensChanged,
    required this.onVersionChanged,
    required this.onSwap,
    required this.onCopy,
    required this.onPaste,
    required this.onClear,
    required this.onSettings,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context) {
    final outlineColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Center(
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
                  key: ValueKey(encryptMode), // update on change
                  icon: Icons.code_off,
                  isToggleable: true,
                  toggled: encryptMode,
                  onTap: onModeChanged,
                ),
              ),
              BoxIconButton(icon: Icons.copy, onTap: (_) => onCopy()),
              BoxIconButton(icon: Icons.paste, onTap: (_) => onPaste()),
              BoxIconButton(icon: Icons.delete, onTap: (_) => onClear()),
              BoxIconButton(icon: Icons.text_fields, isToggleable: true, toggled: caseSensitivity, onTap: onCaseSensChanged),
              BoxIconButton(icon: Icons.looks_one, isToggleable: true, toggled: v1, onTap: onVersionChanged),
              BoxIconButton(icon: Icons.swap_vert, onTap: (_) => onSwap()),
              BoxIconButton(icon: Icons.help_outline, onTap: (_) => onHelp()),
              BoxIconButton(icon: Icons.settings, onTap: (_) => onSettings()),
            ],
          ),
        ),
      ),
    );
  }
}
