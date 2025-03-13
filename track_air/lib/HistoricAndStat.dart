import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoricAndStat extends StatefulWidget {
  const HistoricAndStat({Key? key}) : super(key: key);

  @override
  _HistoricAndStatState createState() => _HistoricAndStatState();
}

class _HistoricAndStatState extends State<HistoricAndStat> {
  int _totalBulletsFired = 0;
  String _selectedLanguage = 'English';
  static const String _languageKey = 'language';

  // Define a list of camouflage colors
  final List<Color> camoColors = [
    Color(0xFF8B8C7A), // Dark Olive Green
    Color(0xFFC2B280), // Khaki
    Color(0xFF8F9779), // Olive Drab
    Color(0xFFA67B5B), // Chocolate
  ];

  // Text translations
  final Map<String, Map<String, String>> _translations = {
    'English': {
      'name': "Historic & statistic",
      'totalBulletsFired': 'Total Bb(s) Fired',
      'otherStat': 'Other Stat',
    },
    'French': {
      'name': "Historique & statistique",
      'totalBulletsFired': 'Total de Bille(s) Tirées',
      'otherStat': 'Autre Stat',
    },
    'Spanish': {
      'name': "Historial y Estadísticas",
      'totalBulletsFired': 'Total de Balas Disparadas',
      'otherStat': 'Otra Estadística',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadSettings();
  }

  Future<void> _loadStats() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/game_stats.txt');

      if (await file.exists()) {
        final content = await file.readAsString();
        final lines = content.split('\n');

        int totalFired = 0;
        for (var line in lines) {
          if (line.startsWith('Total bullets fired: ')) {
            final parts = line.split(': ');
            if (parts.length == 2) {
              totalFired += int.tryParse(parts[1]) ?? 0;
            }
          }
        }

        setState(() {
          _totalBulletsFired = totalFired;
        });
      }
    } catch (e) {
      // Handle error (e.g., show a message to the user)
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString(_languageKey) ?? 'English' ?? 'Spanish';
    });
  }

  String getText(String key) {
    return _translations[_selectedLanguage]?[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey, // AppBar background color
            border: Border.all(color: Colors.black, width: 2.0), // Border color and width
          ),
          child: AppBar(
            title: Text(getText('name')),
            backgroundColor: Colors.transparent, // Make AppBar background transparent
            elevation: 0, // Remove shadow
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Use a Container with a camouflage color for the stat line
          Container(
            color: camoColors[0], // Use the first camouflage color
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8), // Add some space between the icon and text
                  Text(
                    '${getText('totalBulletsFired')}: $_totalBulletsFired',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Add more stat lines with varying camouflage colors
          Container(
            color: camoColors[1], // Use the second camouflage color
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                '...',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            color: camoColors[2], // Use the third camouflage color
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                '...',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            color: camoColors[3], // Use the fourth camouflage color
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                '...',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            color: camoColors[0], // Use the first camouflage color
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                '...',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            color: camoColors[1], // Use the second camouflage color
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                '...',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            color: camoColors[2], // Use the third camouflage color
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                '...',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            color: camoColors[3], // Use the fourth camouflage color
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                '...',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            color: camoColors[0], // Use the first camouflage color
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                '...',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            color: camoColors[1], // Use the second camouflage color
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                '...',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            color: camoColors[2], // Use the third camouflage color
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                '...',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            color: camoColors[3], // Use the fourth camouflage color
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                '...',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            color: camoColors[0], // Use the first camouflage color
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                '...',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            color: camoColors[1], // Use the second camouflage color
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                '...',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            color: camoColors[2], // Use the third camouflage color
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                '...',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            color: camoColors[3], // Use the fourth camouflage color
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.70, horizontal: 16.0),
              child: Text(
                '...',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          // Continue adding more stats as needed
        ],
      ),
    );
  }
}
