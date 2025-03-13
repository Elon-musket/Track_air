import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
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
  Timer? _holdTimer;
  static const int _holdDuration = 3; // Duration in seconds
  double _holdProgress = 0.0;
  bool _isBottomSheetOpen = false;

  // Text translations
  final Map<String, Map<String, String>> _translations = {
    'English': {
      'ergonomic': 'Ergonomic',
      'detailed': 'Detailed',
      'reload': 'Reload',
      'fire': 'FIRE (-1)',
      'endGame': 'End Game',
    },
    'French': {
      'ergonomic': 'Ergonomique',
      'detailed': 'Détaillé',
      'reload': 'Recharger',
      'fire': 'TIRER (-1)',
      'endGame': 'Fin de Partie',
    },
    'Spanish': {
      'ergonomic': 'Ergonómico',
      'detailed': 'Detallado',
      'reload': 'Recargar',
      'fire': 'DISPARAR (-1)',
      'endGame': 'Fin del juego',
    },
  };

  // Map capacity ranges to image assets
  final Map<String, String> _capacityImages = {
    'empty': 'assets/MagazineEmpty.png',
    'MagazineAlmostVeryEmpty': 'assets/MagazineAlmostVeryEmpty.png',
    'MagazineAlmostEmpty': 'assets/MagazineAlmostEmpty.png',
    'Belowmid': 'assets/magazineBelowMid.png',
    'mid': 'assets/MagazineMid.png',
    'Almostmid': 'assets/MagazineAlmostMid.png',
    'SlcyHigh': 'assets/magazineSlicyFull.png',
    'high': 'assets/magazineFull.png',
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
      _selectedLanguage = prefs.getString(_languageKey) ?? 'English' ?? 'Spanish';
    });
  }

  @override
  void dispose() {
    // Restore portrait orientation on close
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _holdTimer?.cancel();
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

  // Function to get the image based on remaining capacity
  String _getImageForCapacity(double remainingPercentage) {
    if (remainingPercentage == 0) {
      return _capacityImages['empty']!;
    } else if (remainingPercentage < 10) {
      return _capacityImages['MagazineAlmostVeryEmpty']!;
    }
    else if (remainingPercentage < 20) {
      return _capacityImages['MagazineAlmostEmpty']!;
    }
    else if (remainingPercentage < 40) {
      return _capacityImages['Belowmid']!;
    }
    else if (remainingPercentage < 50) {
      return _capacityImages['mid']!;
    }
    else if (remainingPercentage < 65) {
      return _capacityImages['Almostmid']!;
    }
    else if (remainingPercentage < 85){
      return _capacityImages['SlcyHigh']!;
    }
    else {
      return _capacityImages['high']!;
    }
  }

  Widget _buildMagazine(Magazine magazine, int index) {
    final isSelected = index == selectedIndex;
    final remainingPercentage = magazine.remainingPercentage;
    final imagePath = _getImageForCapacity(remainingPercentage);

    return GestureDetector(
      onTap: () => _selectMagazine(index),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Image based on capacity
          Image.asset(
            imagePath,
            width: 100,
            height: 150,
            fit: BoxFit.cover,
          ),
          // Text overlay
          Text(
            '${magazine.currentCapacity}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _startHoldTimer() {
    _holdTimer?.cancel();
    _holdProgress = 0.0;
    setState(() {});
    _holdTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _holdProgress += 0.1;
        if (_holdProgress >= 1.0) {
          _endGame();
          timer.cancel();
        }
      });
    });
  }

  void _cancelHoldTimer() {
    _holdTimer?.cancel();
    _holdProgress = 0.0;
    setState(() {});
  }

  Future<void> _endGame() async {
    int totalFired = magazinesList.fold(0, (sum, magazine) => sum + (magazine.capacity - magazine.currentCapacity));

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/game_stats.txt');
      final stats = 'Total bullets fired: $totalFired\nDate: ${DateTime.now().toIso8601String()}\n';

      if (await file.exists()) {
        final content = await file.readAsString();
        await file.writeAsString('$content\n$stats');
      } else {
        await file.writeAsString(stats);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Game stats saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving game stats: $e')),
        );
      }
    }
  }

  void _toggleBottomSheet() {
    setState(() {
      _isBottomSheetOpen = !_isBottomSheetOpen;
    });
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
      body: Stack(
        children: [
          Column(
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
                                    scale: 2.25, // Enlarge the magazine
                                    child: _buildMagazine(magazinesList[_currentMagazineIndex], _currentMagazineIndex),
                                  ),
                                ),
                              ),
                              // Larger button on the right
                              Padding(
                                padding: const EdgeInsets.only(right: 25.0, bottom: 10.0), // Adjust positioning
                                child: Transform.translate(
                                  offset: const Offset(-68, 10), // Adjust positioning
                                  child: GestureDetector(
                                    onTap: rldMagazine,
                                    child: Container(
                                      width: 250, // Larger
                                      height: 250, // Taller
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
            ],
          ),
          if (_isBottomSheetOpen)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 4,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.exit_to_app),
                      title: Text(getText('endGame')),
                      onTap: () {
                        _startHoldTimer();
                      },
                    ),
                    if (selectedIndex != null)
                      ListTile(
                        leading: Icon(Icons.local_fire_department),
                        title: Text(getText('fire')),
                        onTap: () {
                          _decrementCapacity();
                        },
                      ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: _toggleBottomSheet,
              child: Icon(_isBottomSheetOpen ? Icons.close : Icons.menu),
            ),
          ),
        ],
      ),
    );
  }
}
