import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anoopam_mission/providers/theme_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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

  final List<String> languages = [
    'language.english',
    'language.hindi',
    'language.gujarati'
  ];

  @override
  void initState() {
    super.initState();
    // Remove context-dependent code from here
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
                title: Text('settings.dailyAudio'.tr()),
                value: dailyAudio,
                onChanged: (value) {
                  setState(() {
                    dailyAudio = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('settings.dailyQuote'.tr()),
                value: dailyQuote,
                onChanged: (value) {
                  setState(() {
                    dailyQuote = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('settings.amrutvachan'.tr()),
                value: amrutvachan,
                onChanged: (value) {
                  setState(() {
                    amrutvachan = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('settings.ekadashi'.tr()),
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
      },
    );
  }
}
