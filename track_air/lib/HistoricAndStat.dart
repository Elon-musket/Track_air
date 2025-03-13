import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HistoricAndStat extends StatefulWidget {
  const HistoricAndStat({Key? key}) : super(key: key);

  @override
  _HistoricAndStatState createState() => _HistoricAndStatState();
}

class _HistoricAndStatState extends State<HistoricAndStat> {
  int _totalBulletsFired = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique et Statistiques'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              'Total Bullets Fired: $_totalBulletsFired',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
