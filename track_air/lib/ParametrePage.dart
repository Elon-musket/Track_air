import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParametrePage extends StatefulWidget {
  const ParametrePage({super.key});

  @override
  State<ParametrePage> createState() => _ParametrePageState();
}

class _ParametrePageState extends State<ParametrePage> {
  bool _isErgonomicMode = false;
  String _selectedLanguage = 'English';
  static const String _ergonomicModeKey = 'ergonomicMode';
  static const String _languageKey = 'language';

  // Text translations
  late Map<String, Map<String, String>> _translations = {
    'English': {
      'appBarTitle': 'Settings',
      'ergonomicModeTitle': 'Ergonomic Mode',
      'ergonomicModeSubtitle': 'Switch between ergonomic and detailed display',
      'languageTitle': 'Language',
      'currentLanguage': 'Current language',
    },
    'French': {
      'appBarTitle': 'Paramètres',
      'ergonomicModeTitle': 'Mode Ergonomique',
      'ergonomicModeSubtitle': 'Basculer entre affichage ergonomique et détaillé',
      'languageTitle': 'Langue',
      'currentLanguage': 'Langue actuelle',
    },
    'Spanish': {
      'appBarTitle': 'Parámetros',
      'ergonomicModeTitle': 'Mode Ergonómico',
      'ergonomicModeSubtitle': 'Alternar entre vista ergonómica y detallada',
      'languageTitle': 'Idioma',
      'currentLanguage': 'Idioma actual',
    },
  };

  String get _getTranslatedText => _selectedLanguage;

  String getText(String key) {
    return _translations[_selectedLanguage]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isErgonomicMode = prefs.getBool(_ergonomicModeKey) ?? false;
      _selectedLanguage = prefs.getString(_languageKey) ?? 'English' ?? 'Spanish';
    });
  }

  Future<void> _saveErgonomicMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ergonomicModeKey, value);
    setState(() {
      _isErgonomicMode = value;
    });
  }

  Future<void> _saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
    setState(() {
      _selectedLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getText('appBarTitle')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text(getText('ergonomicModeTitle')),
              subtitle: Text(getText('ergonomicModeSubtitle')),
              trailing: Switch(
                value: _isErgonomicMode,
                onChanged: _saveErgonomicMode,
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(getText('languageTitle')),
              subtitle: Text('${getText('currentLanguage')}: $_selectedLanguage'),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                items: const [
                  DropdownMenuItem(
                    value: 'English',
                    child: Text('English'),
                  ),
                  DropdownMenuItem(
                    value: 'French',
                    child: Text('Français'),
                  ),
                  DropdownMenuItem(
                    value: 'Spanish',
                    child: Text('Español'),
                  ),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _saveLanguage(newValue);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}