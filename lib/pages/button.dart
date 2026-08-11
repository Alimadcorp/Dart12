import 'package:flutter/material.dart';

class BoxIconButton extends StatefulWidget {
  final IconData icon;
  final void Function(bool isToggled) onTap;
  final bool isToggleable;
  final bool initialToggleState;
  final double size;

  const BoxIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isToggleable = false,
    this.initialToggleState = false,
    this.size = 48.0,
  });

  @override
  State<BoxIconButton> createState() => _BoxIconButtonState();
}

class _BoxIconButtonState extends State<BoxIconButton> {
  late bool _isToggled;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _isToggled = widget.initialToggleState;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outlineColor = theme.colorScheme.onSurfaceVariant;
    final primaryColor = theme.colorScheme.primary;
    final backgroundColor = theme.colorScheme.surface;

    final bool isActive = widget.isToggleable ? _isToggled : _isPressed;

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
        bool newToggleState = _isToggled;
        if (widget.isToggleable) {
          newToggleState = !_isToggled;
          setState(() => _isToggled = newToggleState);
        }
        widget.onTap(newToggleState);
      },
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
              ? (_isToggled ? Icons.looks_one : Icons.looks_two)
              : (widget.icon == Icons.code_off
                    ? (_isToggled ? Icons.code : Icons.code_off)
                    : widget.icon),
          color: currentIconColor,
          size: widget.size * 0.5,
        ),
      ),
    );
  }
}
