import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PresetFormPage extends StatefulWidget {
  const PresetFormPage({super.key});

  @override
  State<PresetFormPage> createState() => _PresetFormPageState();
}

class _PresetFormPageState extends State<PresetFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _presetNameController = TextEditingController();
  final List<TextEditingController> _magazineControllers = [];
  static const int maxMagazines = 10;
  String _selectedLanguage = 'English';

  // Text translations
  late Map<String, Map<String, String>> _translations = {
    'English': {
      'appBarTitle': 'Add New Preset',
      'presetNameLabel': 'Preset Name',
      'magazinesTitle': 'Magazines',
      'magazineLabel': 'Magazine',
      'Capacity': 'Capacity',
      'rounds': 'rounds',
      'addMagazine': 'Add Magazine',
      'savePreset': 'Save Preset',
      'enterPresetName': 'Please enter a preset name',
      'enterCapacity': 'Please enter capacity',
      'validNumber': 'Please enter a valid number',
      'presetSaved': 'Preset saved successfully!',
      'errorSaving': 'Error saving preset:',
    },
    'French': {
      'appBarTitle': 'Ajouter un nouveau préréglage',
      'presetNameLabel': 'Nom du préréglage',
      'magazinesTitle': 'Chargeurs',
      'magazineLabel': 'Chargeur',
      'rounds': 'bille(s)',
      'Capacity': 'Capicité',
      'addMagazine': 'Ajouter un magazine',
      'savePreset': 'Enregistrer le préréglage',
      'enterPresetName': 'Veuillez entrer un nom de préréglage',
      'enterCapacity': 'Veuillez entrer la capacité',
      'validNumber': 'Veuillez entrer un nombre valide',
      'presetSaved': 'Préréglage enregistré avec succès !',
      'errorSaving': 'Erreur lors de l\'enregistrement du préréglage :',
    },
    'Spanish': {
      'appBarTitle': 'Agregar una nueva configuración',
      'presetNameLabel': 'Nombre de la configuración',
      'magazinesTitle': 'Cargadores',
      'magazineLabel': 'Cargador',
      'rounds': 'bala(s)',
      'Capacity': 'Capacidad',
      'addMagazine': 'Agregar un cargador',
      'savePreset': 'Guardar configuración',
      'enterPresetName': 'Por favor, introduzca un nombre para la configuración',
      'enterCapacity': 'Por favor, introduzca la capacidad',
      'validNumber': 'Por favor, introduzca un número válido',
      'presetSaved': '¡Configuración guardada con éxito!',
      'errorSaving': 'Error al guardar la configuración:',
    }
  };

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _addMagazineField();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'English' ?? 'Spanish';
    });
  }

  String getText(String key) {
    return _translations[_selectedLanguage]?[key] ?? key;
  }

  void _addMagazineField() {
    if (_magazineControllers.length < maxMagazines) {
      setState(() {
        _magazineControllers.add(TextEditingController());
      });
    }
  }

  void _removeMagazineField(int index) {
    setState(() {
      _magazineControllers[index].dispose();
      _magazineControllers.removeAt(index);
    });
  }

  Future<void> _savePreset() async {
    if (_formKey.currentState!.validate()) {
      final parameters = <String, String>{};
      for (var i = 0; i < _magazineControllers.length; i++) {
        parameters['Magazine${i + 1}'] = _magazineControllers[i].text;
      }

      final preset = {
        "presetName": _presetNameController.text,
        "createdAt": DateTime.now().toUtc().toIso8601String(),
        "parameters": parameters
      };

      try {
        // Get the application documents directory
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/presets.json');

        Map<String, dynamic> jsonContent;
        if (await file.exists()) {
          final content = await file.readAsString();
          jsonContent = json.decode(content);
          jsonContent['presets'].add(preset);
        } else {
          jsonContent = {
            "presets": [preset]
          };
        }

        await file.writeAsString(json.encode(jsonContent));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(getText('presetSaved'))),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${getText('errorSaving')} $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getText('appBarTitle')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _presetNameController,
                decoration: InputDecoration(
                  labelText: getText('presetNameLabel'),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return getText('enterPresetName');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                '${getText('magazinesTitle')} (${_magazineControllers.length}/$maxMagazines)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ..._buildMagazineFields(),
              const SizedBox(height: 16),
              if (_magazineControllers.length < maxMagazines)
                ElevatedButton.icon(
                  onPressed: _addMagazineField,
                  icon: const Icon(Icons.add),
                  label: Text(getText('addMagazine')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _magazineControllers.isNotEmpty ? _savePreset : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(getText('savePreset')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMagazineFields() {
    return List.generate(_magazineControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _magazineControllers[index],
                decoration: InputDecoration(
                  labelText: '${getText('magazineLabel')} ${index + 1} ${getText('Capacity')}',
                  border: const OutlineInputBorder(),
                  suffixText: getText('rounds'),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return getText('enterCapacity');
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0 || number > 999) {
                    return getText('validNumber');
                  }
                  return null;
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () => _removeMagazineField(index),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _presetNameController.dispose();
    for (var controller in _magazineControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
