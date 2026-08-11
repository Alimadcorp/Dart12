import 'package:flutter/material.dart';

class OutputDisplay extends StatelessWidget {
  final String output;
  final bool encryptMode;

  const OutputDisplay({
    super.key,
    required this.output,
    required this.encryptMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outlineColor = theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
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
          output.isEmpty
              ? (encryptMode ? "Encoded output" : "Decoded output")
              : output,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: output.isEmpty
                ? outlineColor.withAlpha(100)
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
