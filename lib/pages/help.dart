import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  void initState() {
    super.initState();
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
                    child:
                      Column(
                        children: [
                          Text(
                            'Welcome! Here is a quick overview of what this is:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 8.0),
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
                          SizedBox(height: 8.0),
                          RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              children: [
                                TextSpan(
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
                                TextSpan(
                                  text: '\'s ',
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
                                TextSpan(
                                  text: ' came up with. A link to their research is given at the end.',
                                ),
                              ]
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Divider(),
                          SizedBox(height: 8.0),
                          Text(
                            'Toolbar buttons:',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ]
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

                  // External Links Section
                  Text(
                    'Links',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                    leading: const Icon(Icons.ondemand_video_rounded),
                    title: const Text("312's Channel"),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () => _openUrl('https://youtube.com/@3121534312'),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('RGN Analysis Slides'),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () => _openUrl('https://docs.google.com/presentation/d/110bIi0N-z-D4FKMVwkCpnr1YUTwLF7zX79gop2ZVmQo/present'),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
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
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Icon(icon, size: 24, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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