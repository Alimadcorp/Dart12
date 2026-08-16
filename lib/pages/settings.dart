import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const String keyUnmatchedChar = 'unmatched_character';

  String _unmatchedChar = 'as_is';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _unmatchedChar = prefs.getString(keyUnmatchedChar) ?? 'as_is';
    });
  }

  Future<void> _updatePreference(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
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
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Preferences',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            initialValue: _unmatchedChar,
            decoration: const InputDecoration(
              labelText: 'What to do with unmatched chars',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'as_is', child: Text('Do nothing')),
              DropdownMenuItem(
                value: 'question_mark',
                child: Text('Replace with ?'),
              ),
              DropdownMenuItem(value: 'unicode', child: Text('Replace with unicode')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _unmatchedChar = val);
                _updatePreference(keyUnmatchedChar, val);
              }
            },
          ),

          const SizedBox(height: 12),

          Text("What to do with characters that don't exist in the cipher?\nLeave them as they are, replace with a ? symbol, or replace with a codepoint using the unicode encoding standard that was introduced in the 2014 cipher update", 
          textScaler: TextScaler.linear(0.8), 
          style: TextStyle(
            color: Color.from(alpha: 1.0, red: 0.5, green: 0.5, blue: 0.5)
          )),
          
          const Divider(height: 40),

          Text(
            'About & Credits',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Github Repository'),
            subtitle: const Text('Alimadcorp/dart12'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _openUrl('https://github.com/Alimadcorp/dart12'),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('All Versions'),
            subtitle: const Text('alimad.itch.io/312'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _openUrl('https://alimad.itch.io/312'),
          ),
          ListTile(
            leading: const Icon(Icons.ondemand_video_rounded),
            title: const Text('312\'s Youtube Channel'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _openUrl('https://youtube.com/@3121534312'),
          ),
          ListTile(
            leading: const Icon(Icons.android),
            title: const Text('Google Play Store'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _openUrl(
              'https://play.google.com/store/apps/details?id=com.alimad.dart12',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('RGN Analysis Slides'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _openUrl(
              'https://docs.google.com/presentation/d/110bIi0N-z-D4FKMVwkCpnr1YUTwLF7zX79gop2ZVmQo/present',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.grid_on_sharp),
            title: const Text('Decrypt Matrix Codes'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _openUrl('https://312.alimad.co/544315616323'),
          ),

          const Divider(height: 24),

          Center(
            child: TextButton(
              onPressed: () => _openUrl('https://alimad.co'),
              child: Text(
                'Made by Muhammad Ali',
                style: theme.textTheme.bodyMedium?.copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
