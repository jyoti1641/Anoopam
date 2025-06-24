import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart'; // Import themeNotifier

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = themeNotifier.value == ThemeMode.dark;
  String selectedLanguage = 'English';

  bool dailyAudio = true;
  bool dailyQuote = true;
  bool amrutvachan = true;
  bool ekadashi = true;

  bool isDarshanExpanded = false;
  String selectedDarshan = 'Mogri, IN';

  final List<String> darshanLocations = [
    'Mogri, IN',
    'Denham, UK',
    'Allentown, PA, USA',
    'Kharghar, IN',
    'Surat, IN',
    'Vemar, IN',
    'Amdavad, IN',
    'Norwalk, CA, USA',
  ];

  final List<String> languages = ['English', 'Hindi', 'Gujarati'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        elevation: 1,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Light/Dark Mode'),
            value: isDarkMode,
            onChanged: (value) async {
              setState(() {
                isDarkMode = value;
              });
              final prefs = await SharedPreferences.getInstance();
              prefs.setBool('isDarkMode', isDarkMode);
              themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          ListTile(
            title: const Text('Language'),
            subtitle: Text(selectedLanguage),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final selected = await showDialog<String>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text('Select Language'),
                  children: languages
                      .map((lang) => SimpleDialogOption(
                            child: Text(lang),
                            onPressed: () => Navigator.pop(context, lang),
                          ))
                      .toList(),
                ),
              );
              if (selected != null && selected != selectedLanguage) {
                setState(() {
                  selectedLanguage = selected;
                });
              }
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Preferences',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // Thakorji Darshan Expandable
          ListTile(
            title: const Text('Thakorji Darshan'),
            trailing: Icon(isDarshanExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              setState(() {
                isDarshanExpanded = !isDarshanExpanded;
              });
            },
          ),
          if (isDarshanExpanded)
            Column(
              children: darshanLocations
                  .map((location) => RadioListTile<String>(
                        title: Text(location),
                        value: location,
                        groupValue: selectedDarshan,
                        onChanged: (value) {
                          setState(() {
                            selectedDarshan = value!;
                          });
                        },
                      ))
                  .toList(),
            ),

          // Toggle Preferences
          SwitchListTile(
            title: const Text('Daily Audio'),
            value: dailyAudio,
            onChanged: (value) {
              setState(() {
                dailyAudio = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Daily Quote'),
            value: dailyQuote,
            onChanged: (value) {
              setState(() {
                dailyQuote = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Amrutvachan'),
            value: amrutvachan,
            onChanged: (value) {
              setState(() {
                amrutvachan = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Ekadashi'),
            value: ekadashi,
            onChanged: (value) {
              setState(() {
                ekadashi = value;
              });
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

