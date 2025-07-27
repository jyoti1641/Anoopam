import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anoopam_mission/providers/theme_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedLanguage = 'English';

  bool dailyAudio = false;
  bool dailyQuote = false;
  bool amrutvachan = false;
  bool ekadashi = false;

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

  final List<String> languages = [
    'language.english',
    'language.hindi',
    'language.gujarati'
  ];

  @override
  void initState() {
    super.initState();
    loadPreferences();
    // Remove context-dependent code from here
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dailyAudio = prefs.getBool('dailyAudio') ?? false; // Use false as default
      dailyQuote = prefs.getBool('dailyQuote') ?? false; // Use false as default
      amrutvachan =
          prefs.getBool('amrutvachan') ?? false; // Use false as default
      ekadashi = prefs.getBool('ekadashi') ?? false;
      selectedDarshan = prefs.getString('selectedDarshan') ?? 'Mogri, IN';
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final langCode = context.locale.languageCode;
    setState(() {
      selectedLanguage = langCode == 'en'
          ? 'language.english'
          : langCode == 'hi'
              ? 'language.hindi'
              : 'language.gujarati';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDarkMode = themeProvider.currentTheme == ThemeMode.dark;

        return Scaffold(
          appBar: AppBar(
            title: Text('settings.title'.tr()),
            elevation: 1,
          ),
          body: ListView(
            children: [
              SwitchListTile(
                title: Text('settings.lightDarkMode'.tr()),
                value: isDarkMode,
                onChanged: (value) async {
                  await themeProvider.toggleTheme();
                },
              ),
              ListTile(
                title: Text('settings.language'.tr()),
                subtitle: Text(selectedLanguage.tr()),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final selected = await showDialog<String>(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: Text('settings.selectLanguage'.tr()),
                      children: languages
                          .map((langKey) => SimpleDialogOption(
                                child: Text(langKey.tr()),
                                onPressed: () =>
                                    Navigator.pop(context, langKey),
                              ))
                          .toList(),
                    ),
                  );
                  if (selected != null && selected != selectedLanguage) {
                    setState(() {
                      selectedLanguage = selected;
                    });
                    if (selected == 'language.english') {
                      context.setLocale(const Locale('en'));
                    } else if (selected == 'language.hindi') {
                      context.setLocale(const Locale('hi'));
                    } else if (selected == 'language.gujarati') {
                      context.setLocale(const Locale('gu'));
                    }
                  }
                },
              ),
              const Divider(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'settings.preferences'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              // Thakorji Darshan Expandable
              ListTile(
                title: Text('settings.thakorjiDarshan'.tr()),
                trailing: Icon(
                    isDarshanExpanded ? Icons.expand_less : Icons.expand_more),
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
                            title: Text(location.tr()),
                            value: location,
                            groupValue: selectedDarshan,
                            onChanged: (value) async {
                              setState(() {
                                selectedDarshan = value!;
                              });
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString('selectedDarshan', value!);
                            },
                          ))
                      .toList(),
                ),

              // Toggle Preferences
              SwitchListTile(
                title: Text('settings.dailyAudio'.tr()),
                value: dailyAudio,
                onChanged: (value) async {
                  setState(() {
                    dailyAudio = value;
                  });
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('dailyAudio', value);
                  print('Saved dailyAudio: $value'); // Debug print
                },
              ),
              SwitchListTile(
                title: Text('settings.dailyQuote'.tr()),
                value: dailyQuote,
                onChanged: (value) async {
                  setState(() {
                    dailyQuote = value;
                  });
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('dailyQuote', value);
                  print('Saved dailyQuote: $value'); // Debug print
                },
              ),
              SwitchListTile(
                title: Text('settings.amrutvachan'.tr()),
                value: amrutvachan,
                onChanged: (value) async {
                  setState(() {
                    amrutvachan = value;
                  });
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('amrutvachan', value);
                  print('Saved amrutvachan: $value'); // Debug print
                },
              ),
              SwitchListTile(
                title: Text('settings.ekadashi'.tr()),
                value: ekadashi,
                onChanged: (value) async {
                  setState(() {
                    ekadashi = value;
                  });
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('ekadashi', value);
                  print('Saved ekadashi: $value'); // Debug print
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
