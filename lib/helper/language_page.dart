import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization
      .ensureInitialized(); // Ensure translations are initialized

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('ar')], // Supported languages
      path: 'assets/lang', // Path to translation files
      fallbackLocale: Locale('en'), // Default language
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Locales',
      localizationsDelegates:
          context.localizationDelegates, // Localization delegates
      supportedLocales: context.supportedLocales, // Supported locales
      locale: context.locale, // Current locale
      home: SettingsPage(), // Main page is the SettingsPage
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Callback for language change
  void _onLanguageChange(Locale newLocale) {
    context.setLocale(newLocale); // Change locale when language is selected
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings').tr(), // Translated title
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Text('Profile Settings').tr(), // Translated text
            onTap: () {},
          ),
          ListTile(
            title: Text('Support and Feedback').tr(), // Translated text
            onTap: () {},
          ),
          ListTile(
            title: Text('Legal Information').tr(), // Translated text
            onTap: () {},
          ),
          ListTile(
            title: Text('Language').tr(), // Translated text
            onTap: () {
              // Navigate to the LanguagePage and pass the onLanguageChange callback
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LanguagePage(
                    onLanguageChange: _onLanguageChange,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class LanguagePage extends StatelessWidget {
  final void Function(Locale newLocale) onLanguageChange;

  LanguagePage({required this.onLanguageChange});

  // Method to change language and go back to the previous page
  void _changeLanguage(BuildContext context, Locale locale) {
    onLanguageChange(
        locale); // Notify the previous page about the language change
    context.setLocale(locale); // Change language
    Navigator.pop(context); // Go back to the previous page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Language').tr(), // Translated title
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Text('English'),
            onTap: () {
              _changeLanguage(
                  context, Locale('en')); // Change language to English
            },
          ),
          ListTile(
            title: Text('العربية'),
            onTap: () {
              _changeLanguage(
                  context, Locale('ar')); // Change language to Arabic
            },
          ),
        ],
      ),
    );
  }
}
