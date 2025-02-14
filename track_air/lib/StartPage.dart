import 'package:flutter/material.dart';
import 'PresetFormPage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'DisplayPreset.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Startpage extends StatefulWidget {
  const Startpage({super.key});

  @override
  State<Startpage> createState() => _StartpageState();
}

class _StartpageState extends State<Startpage> {
  List<Map<String, dynamic>> presets = [];
  String? selectedPresetName;
  Map<String, dynamic>? selectedPreset;
  bool _isErgonomicMode = false;
  static const String _ergonomicModeKey = 'ergonomicMode';

  @override
  void initState() {
    super.initState();
    _loadPresets();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isErgonomicMode = prefs.getBool(_ergonomicModeKey) ?? false;
    });
  }

  Future<void> _loadPresets() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/presets.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        final jsonContent = json.decode(content);
        setState(() {
          presets = List<Map<String, dynamic>>.from(jsonContent['presets']);
        });
      }
    } catch (e) {
      debugPrint('Error loading presets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game configuration'),
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
                      _isErgonomicMode ? 'Ergonomic' : 'Detailed',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Preset:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (presets.isEmpty)
                      const Text(
                        'No presets available. Create one by clicking the button below.',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        value: selectedPresetName,
                        hint: const Text('Choose a preset'),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedPresetName = newValue;
                            selectedPreset = presets.firstWhere(
                              (preset) => preset['presetName'] == newValue,
                              orElse: () => {},
                            );
                          });
                        },
                        items: presets.map<DropdownMenuItem<String>>((preset) {
                          return DropdownMenuItem<String>(
                            value: preset['presetName'] as String,
                            child: Text(preset['presetName'] as String),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
            if (selectedPreset != null) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preset: ${selectedPreset!['presetName']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Then replace the Text widget with:
                      Text(
                        'Created: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(selectedPreset!['createdAt']).toLocal())}',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const Divider(),
                      const Text(
                        'Magazine Capacities:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(_buildMagazineList(selectedPreset!['parameters'] as Map<String, dynamic>)),
                    ],
                  ),
                ),
              ),
            ],
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PresetFormPage(),
                  ),
                );
                // Reload presets when returning from the form
                _loadPresets();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add New Preset'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: selectedPreset != null
                  ? () {
                      Preset presetselec = Preset(
                        name : selectedPreset?['presetName'],
                        magazines : selectedPreset?['parameters'],
                        date : selectedPreset?['createdAt'],
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MagazineDisplay(preset: presetselec),
                        ),
                      );
                    }
                  : null, // Disable button if no preset is selectedconst Icon(Icons.add),
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const Text(
                'Start Game',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
            const SizedBox(height: 12),        
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMagazineList(Map<String, dynamic> parameters) {
    return parameters.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(entry.key),
            Text(
              '${entry.value} rounds',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}