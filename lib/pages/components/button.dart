import 'package:flutter/material.dart';

class BoxIconButton extends StatefulWidget {
  final IconData icon;
  final void Function(bool isToggled) onTap;
  final VoidCallback? onLongTap;
  final bool isToggleable;
  final bool toggled;
  final double size;

  const BoxIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.onLongTap,
    this.isToggleable = false,
    this.toggled = false,
    this.size = 48.0,
  });

  @override
  State<BoxIconButton> createState() => _BoxIconButtonState();
}

class _BoxIconButtonState extends State<BoxIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outlineColor = theme.colorScheme.onSurfaceVariant;
    final primaryColor = theme.colorScheme.primary;
    final backgroundColor = theme.colorScheme.surface;

    final bool isActive = widget.isToggleable ? widget.toggled : _isPressed;

    final currentColor = isActive ? primaryColor : backgroundColor;
    final currentIconColor = isActive ? backgroundColor : primaryColor;

    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isToggleable) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (!widget.isToggleable) setState(() => _isPressed = false);
      },
      onTapCancel: () {
        if (!widget.isToggleable) setState(() => _isPressed = false);
      },
      onTap: () {
        widget.onTap(!widget.toggled);
      },
      onLongPress: widget.onLongTap,
      onSecondaryTapDown: (_) => widget.onLongTap?.call(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: currentColor,
          borderRadius: BorderRadius.zero,
          border: Border(
            left: BorderSide.none,
            right: BorderSide(color: outlineColor, width: 2.0),
            top: BorderSide.none,
            bottom: BorderSide(color: outlineColor, width: 2.0),
          ),
        ),
        child: Icon(
          widget.icon == Icons.looks_one
              ? (widget.toggled ? Icons.looks_one : Icons.looks_two)
              : (widget.icon == Icons.code_off
                  ? (widget.toggled ? Icons.code : Icons.code_off)
                  : widget.icon),
          color: currentIconColor,
          size: widget.size * 0.5,
        ),
      ),
    );
  }
}