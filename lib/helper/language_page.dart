import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';


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
