import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart'; 

class Magazine {
  final int capacity;
  bool isSelected;
  int currentCapacity; // Nouvelle propriété pour suivre la capacité actuelle

  Magazine({
    required this.capacity,
    this.isSelected = false,
  }) : currentCapacity = capacity; // Initialiser la capacité actuelle

  factory Magazine.fromJson(String capacity) {
    return Magazine(
      capacity: int.parse(capacity),
    );
  }

  // Méthode pour calculer le pourcentage restant
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

  @override
  void initState() {
    super.initState();
    magazinesList = widget.preset.getMagazinesList();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Rétablir l'orientation portrait à la fermeture
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  // Fonction pour décrémenter la capacité du chargeur sélectionné
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

  // Fonction pour obtenir la couleur en fonction de la capacité restante
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
    // Vérifier si l'appareil peut vibrer
    if (await Vibration.hasVibrator() ?? false) {
      // Pattern de vibration : vibrer 500ms, pause 100ms, vibrer 500ms
      Vibration.vibrate(pattern: [0, 2000, 100, 2000, 100, 2000], amplitude: 255, intensities: []);
      
      // Alternative pour une vibration simple :
      // Vibration.vibrate(duration: 1000);
    }
  }

  void _selectMagazine(int index) {
    setState(() {
      if (selectedIndex == index) {
        selectedIndex = null;
      } else {
        selectedIndex = index;
      }
      
      // Mettre à jour l'état de sélection de tous les chargeurs
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
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationZ(0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Partie supérieure (le chargeur)
              Container(
                height: MediaQuery.of(context).size.height * 0.20,
                width: MediaQuery.of(context).size.width * 0.090,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      capacityColor,
                      Colors.white,
                    ],
                    stops: [remainingPercentage / 100, remainingPercentage / 100],
                  ),
                  border: Border.all(
                    color: isSelected 
                      ? Colors.blue
                      : const Color.fromARGB(255, 74, 74, 74),
                    width: 2
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 4,
                    )
                  ] : null,
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${magazine.currentCapacity}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      '/${magazine.capacity}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // Base solide
              Container(
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.width * 0.10,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[900] : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.preset.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
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
                child: const Text('FIRE (-1)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Handle end game button press
              },
              child: const Text('BOUTON FIN DE PARTIE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[100],
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}