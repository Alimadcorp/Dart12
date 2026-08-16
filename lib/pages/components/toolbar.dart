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
  final ValueChanged<String>? onHelpHighlight;

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
    this.onHelpHighlight,
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
                  key: ValueKey(encryptMode),
                  icon: Icons.code_off,
                  isToggleable: true,
                  toggled: encryptMode,
                  onTap: onModeChanged,
                  onLongTap: () => onHelpHighlight?.call('Encode/Decode'),
                ),
              ),
              BoxIconButton(
                icon: Icons.copy,
                onTap: (_) => onCopy(),
                onLongTap: () => onHelpHighlight?.call('Copy'),
              ),
              BoxIconButton(
                icon: Icons.paste,
                onTap: (_) => onPaste(),
                onLongTap: () => onHelpHighlight?.call('Paste'),
              ),
              BoxIconButton(
                icon: Icons.delete,
                onTap: (_) => onClear(),
                onLongTap: () => onHelpHighlight?.call('Clear'),
              ),
              BoxIconButton(
                icon: Icons.text_fields,
                isToggleable: true,
                toggled: caseSensitivity,
                onTap: onCaseSensChanged,
                onLongTap: () => onHelpHighlight?.call('Case sensitinivity'),
              ),
              BoxIconButton(
                icon: Icons.looks_one,
                isToggleable: true,
                toggled: v1,
                onTap: onVersionChanged,
                onLongTap: () => onHelpHighlight?.call('Version'),
              ),
              BoxIconButton(
                icon: Icons.swap_vert,
                onTap: (_) => onSwap(),
                onLongTap: () => onHelpHighlight?.call('Swap'),
              ),
              BoxIconButton(
                icon: Icons.help_outline,
                onTap: (_) => onHelp(),
                onLongTap: () => onHelpHighlight?.call('Help'),
              ),
              BoxIconButton(
                icon: Icons.settings,
                onTap: (_) => onSettings(),
                onLongTap: () => onHelpHighlight?.call('Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
