import 'package:flutter/material.dart';
import 'package:track_air/ParametrePage.dart';
import 'package:track_air/StartPage.dart';
import 'package:track_air/HistoricAndStat.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2C3E50), // Dark military blue
              const Color(0xFF374F66), // Medium military blue
              const Color(0xFF446275), // Light military blue
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Military-style logo container
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutBack,
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 50),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          border: Border.all(
                            color: const Color(0xFF8B9D7D), // Military green
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/logotrackair.png',
                          height: 200,
                          width: 200,
                          color: const Color(0xFFD5DDCD), // Light military green
                        ),
                      ),
                    ),
                    // Military-styled buttons
                    _buildButton(
                      context,
                      'Commencer la partie',
                      Icons.play_arrow_rounded,
                      const Color(0xFF7D8B69), // Light olive
                      () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const Startpage())),
                    ),
                    const SizedBox(height: 20),
                    _buildButton(
                      context,
                      'Historique & Statistiques',
                      Icons.bar_chart_rounded,
                      const Color(0xFF656D4A), // Military green
                      () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const HistoricAndStat())),
                    ),
                    const SizedBox(height: 20),
                    _buildButton(
                      context,
                      'Paramètres',
                      Icons.settings_rounded,
                      const Color(0xFF4B5842), // Dark olive
                      () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const ParametrePage())),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF8B9D7D).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 4),
            blurRadius: 8.0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: const Color(0xFFE5E5E5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                fontFamily: 'RobotoMono', // Military-style font
              ),
            ),
          ],
        ),
      ),
    );
  }
}