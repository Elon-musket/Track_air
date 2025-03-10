import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class Magazine {
  final int capacity;
  bool isSelected;
  int currentCapacity;

  Magazine({
    required this.capacity,
    this.isSelected = false,
  }) : currentCapacity = capacity;

  factory Magazine.fromJson(String capacity) {
    return Magazine(
      capacity: int.parse(capacity),
    );
  }

  double get remainingPercentage => (currentCapacity / capacity) * 100;
}

class Preset {
  final String name;
  final Map<String, dynamic> magazines;
  String date;

  Preset({
    required this.name,
    required this.magazines,
    required this.date,
  });

  factory Preset.fromJson(Map<String, dynamic> json) {
    return Preset(
      name: json['presets'][0]['presetName'] as String,
      magazines: json['presets'][0]['parameters'] as Map<String, dynamic>,
      date: json['presets'][0]['createdAt'],
    );
  }

  List<Magazine> getMagazinesList() {
    List<Magazine> magazinesList = [];
    magazines.forEach((key, value) {
      if (key.startsWith('Magazine')) {
        magazinesList.add(Magazine.fromJson(value));
      }
    });
    return magazinesList;
  }
}

class MagazineDisplay extends StatefulWidget {
  final Preset preset;

  const MagazineDisplay({
    Key? key,
    required this.preset,
  }) : super(key: key);

  @override
  _MagazineDisplayState createState() => _MagazineDisplayState();
}

class _MagazineDisplayState extends State<MagazineDisplay> {
  late List<Magazine> magazinesList;
  int? selectedIndex;
  int _currentMagazineIndex = 0;
  bool _isErgonomicMode = false;
  String _selectedLanguage = 'English';
  static const String _ergonomicModeKey = 'ergonomicMode';
  static const String _languageKey = 'language';

  // Text translations
  final Map<String, Map<String, String>> _translations = {
    'English': {
      'ergonomic': 'Ergonomic',
      'detailed': 'Detailed',
      'reload': 'Reload',
      'fire': 'FIRE (-1)',
    },
    'French': {
      'ergonomic': 'Ergonomique',
      'detailed': 'Détaillé',
      'reload': 'Recharger',
      'fire': 'TIRER (-1)',
    },
  };

  String getText(String key) {
    return _translations[_selectedLanguage]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    magazinesList = widget.preset.getMagazinesList();
    _loadSettings(); // Load settings
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void rldMagazine() {
    setState(() {
      _currentMagazineIndex = (_currentMagazineIndex + 1) % magazinesList.length;
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isErgonomicMode = prefs.getBool(_ergonomicModeKey) ?? false;
      _selectedLanguage = prefs.getString(_languageKey) ?? 'English';
    });
  }

  @override
  void dispose() {
    // Restore portrait orientation on close
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  // Function to decrement the capacity of the selected magazine
  void _decrementCapacity() {
    if (selectedIndex != null && magazinesList[selectedIndex!].currentCapacity > 0) {
      setState(() {
        magazinesList[selectedIndex!].currentCapacity--;
        if (magazinesList[selectedIndex!].currentCapacity == 0) {
          _vibrateOnEmpty();
        }
      });
    }
  }

  // Function to get the color based on remaining capacity
  Color _getCapacityColor(double remainingPercentage) {
    if (remainingPercentage > 66) {
      return Colors.green;
    } else if (remainingPercentage > 33) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _vibrateOnEmpty() async {
    // Check if the device can vibrate
    if (await Vibration.hasVibrator() ?? false) {
      // Vibration pattern: vibrate 500ms, pause 100ms, vibrate 500ms
      Vibration.vibrate(pattern: [0, 2000, 100, 2000, 100, 2000], amplitude: 255, intensities: []);
    }
  }

  void _selectMagazine(int index) {
    setState(() {
      if (selectedIndex == index) {
        selectedIndex = null;
      } else {
        selectedIndex = index;
      }

      // Update the selection state of all magazines
      for (int i = 0; i < magazinesList.length; i++) {
        magazinesList[i].isSelected = (i == selectedIndex);
      }
    });
  }

  Widget _buildMagazine(Magazine magazine, int index) {
    final isSelected = index == selectedIndex;
    final remainingPercentage = magazine.remainingPercentage;
    final capacityColor = _getCapacityColor(remainingPercentage);

    return GestureDetector(
      onTap: () => _selectMagazine(index),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Image in the background
          Image.asset(
            'assets/magazine.png', // Replace with your image path
            width: 100,
            height: 150,
            fit: BoxFit.cover,
          ),
          // Transparent container with gradient
          ClipPath(
            clipper: GradientClipper(),
            child: Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [capacityColor, Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          // Text overlay
          Text(
            '${magazine.currentCapacity}',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        title: Text(widget.preset.name),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isErgonomicMode ? Colors.green.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isErgonomicMode ? Icons.accessibility_new : Icons.details,
                      size: 16,
                      color: _isErgonomicMode ? Colors.green : Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isErgonomicMode ? getText('ergonomic') : getText('detailed'),
                      style: TextStyle(
                        color: _isErgonomicMode ? Colors.green : Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: _isErgonomicMode
                  ? Center(
                      child: Row(
                        children: [
                          // Larger magazine on the left
                          Expanded(
                            child: Center(
                              child: Transform.scale(
                                scale: 2.75, // Enlarge the magazine
                                child: _buildMagazine(magazinesList[_currentMagazineIndex], _currentMagazineIndex),
                              ),
                            ),
                          ),
                          // Larger button on the right
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0, bottom: 15.0), // Adjust positioning
                            child: Transform.translate(
                              offset: const Offset(-28, -10), // Adjust positioning
                              child: GestureDetector(
                                onTap: rldMagazine,
                                child: Container(
                                  width: 300, // Larger
                                  height: 300, // Taller
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        spreadRadius: 4,
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    getText('reload'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 24, // Larger text
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 16.0,
                        crossAxisSpacing: 16.0,
                      ),
                      itemCount: magazinesList.length,
                      itemBuilder: (context, index) {
                        return _buildMagazine(magazinesList[index], index);
                      },
                    ),
            ),
          ),
          if (selectedIndex != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: _decrementCapacity,
                child: Text(getText('fire')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Custom clipper to clip the gradient shape
class GradientClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
