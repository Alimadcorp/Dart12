import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatefulWidget {
  final String? targetTitle; // <-- Added parameter

  const HelpPage({super.key, this.targetTitle});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final Map<String, GlobalKey> _cardKeys = {}; // <-- Key registry
  String? _highlightedTitle; // <-- Animation state

  @override
  void initState() {
    super.initState();
    if (widget.targetTitle != null) {
      _highlightedTitle = widget.targetTitle;

      // Scroll and schedule highlight removal after render
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToTarget(widget.targetTitle!);
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() => _highlightedTitle = null);
          }
        });
      });
    }
  }

  void _scrollToTarget(String title) {
    final key = _cardKeys[title];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.2,
      );
    }
  }

  Future<void> _openUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quickstart'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12.0),
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 0.0, bottom: 16.0, left: 8.0, right: 8.0),
              child: Column(
                children: [
                  Text(
                    'Welcome! Here is a quick overview of what this is:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      children: [
                        const TextSpan(
                          text: '312 is a substitution cipher invented by ',
                        ),
                        TextSpan(
                          text: '3121534312',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _openUrl("https://www.youtube.com/@3121534312");
                            },
                        ),
                        const TextSpan(
                          text: ', an anonymous person on YouTube. This tool allows you to encode and decode the 312 cipher! Just enter your input into the text box above, and get the encoded/decoded output in the box below it. ',
                        ),
                        const TextSpan(
                          text: "Scroll down and click 'Got it' to get started.",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      children: [
                        const TextSpan(
                          text: 'The interpretation of the cipher used in this app is according to what ',
                        ),
                        TextSpan(
                          text: 'RetroGamingNow',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _openUrl("https://www.youtube.com/@retrogamingnow");
                            },
                        ),
                        const TextSpan(
                          text: "'s ",
                        ),
                        TextSpan(
                          text: 'community',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _openUrl("https://discord.gg/RetroGamingNow");
                            },
                        ),
                        const TextSpan(
                          text: ' came up with. A link to their research is given at the end.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Divider(),
                  const SizedBox(height: 8.0),
                  Text(
                    'Toolbar buttons:',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            _buildHelpCard(
              theme,
              icon: Icons.code,
              title: 'Encode/Decode',
              subtitle: 'Press to toggle between encode and decode mode',
            ),
            const SizedBox(height: 8.0),
            _buildHelpCard(
              theme,
              icon: Icons.text_fields,
              title: 'Case sensitinivity',
              subtitle: 'If this is on, capitalization will be preserved in output.\nIn decode mode, toggling this on will prioritize parsing capitalization before substitution, which may be useful if you are not getting the intended output, sometimes...',
            ),
            const SizedBox(height: 8.0),
            _buildHelpCard(
              theme,
              icon: Icons.looks_two,
              title: 'Version',
              subtitle: 'Toggle between version 1 and 2 of the cipher. Version 1 is since before the 2014 trinary update',
            ),
            const SizedBox(height: 8.0),
            _buildHelpCard(
              theme,
              icon: Icons.swap_vert,
              title: 'Swap',
              subtitle: 'Toggles encode mode and swaps the output with input',
            ),
            const SizedBox(height: 8.0),
            _buildHelpCard(
              theme,
              icon: Icons.copy,
              title: 'Copy',
              subtitle: 'Copy the output to clipboard',
            ),
            const SizedBox(height: 8.0),
            _buildHelpCard(
              theme,
              icon: Icons.paste,
              title: 'Paste',
              subtitle: 'Paste input from clipboard',
            ),
            const SizedBox(height: 8.0),
            _buildHelpCard(
              theme,
              icon: Icons.delete,
              title: 'Clear',
              subtitle: 'Clear the input and output',
            ),
            const SizedBox(height: 8.0),
            _buildHelpCard(
              theme,
              icon: Icons.help_outline,
              title: 'Help',
              subtitle: 'Open this screen',
            ),
            const SizedBox(height: 8.0),
            _buildHelpCard(
              theme,
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'View more options, links and credits',
            ),
            const SizedBox(height: 8.0),
            const Divider(),
            const SizedBox(height: 8.0),
            Text(
              'Links',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              leading: const Icon(Icons.ondemand_video_rounded),
              title: const Text("312's Channel"),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => _openUrl('https://youtube.com/@3121534312'),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              leading: const Icon(Icons.description_outlined),
              title: const Text('RGN Analysis Slides'),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => _openUrl('https://docs.google.com/presentation/d/110bIi0N-z-D4FKMVwkCpnr1YUTwLF7zX79gop2ZVmQo/present'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool("viewed_help", true);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    // Generate or fetch key for scrolling
    final key = _cardKeys.putIfAbsent(title, () => GlobalKey());
    final isHighlighted = _highlightedTitle == title;

    return AnimatedContainer(
      key: key,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isHighlighted
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted ? theme.colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: isHighlighted
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isHighlighted
                        ? theme.colorScheme.onPrimaryContainer
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isHighlighted
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}