import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:game/features/user/domain/entities/user.dart';

class ScoreboardScreen extends StatelessWidget {
  final User currentUser;

  const ScoreboardScreen({super.key, required this.currentUser});

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a237e),
      appBar: AppBar(
        title: Text(
          'SCOREBOARD',
          style: GoogleFonts.bebasNeue(fontSize: 28, color: Colors.amber),
        ),
        backgroundColor: const Color(0xFF1a237e),
        foregroundColor: Colors.amber,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a237e), Color(0xFF0d47a1), Color(0xFF01579b)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Current User Score Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.amber[700],
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            currentUser.username,
                            style: GoogleFonts.bebasNeue(
                              fontSize: 32,
                              color: const Color(0xFF1a237e),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Best Score Display
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'BEST SCORE',
                              style: GoogleFonts.sarabun(
                                fontSize: 18,
                                color: Colors.amber[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Icon(
                                      Icons.timer,
                                      color: Colors.amber[600],
                                      size: 28,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatTime(currentUser.bestTime),
                                      style: GoogleFonts.bebasNeue(
                                        fontSize: 24,
                                        color: const Color(0xFF1a237e),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Best Time',
                                      style: GoogleFonts.sarabun(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 1,
                                  height: 60,
                                  color: Colors.amber.withValues(alpha: 0.3),
                                ),
                                Column(
                                  children: [
                                    Icon(
                                      Icons.trending_up,
                                      color: Colors.amber[600],
                                      size: 28,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      currentUser.totalGames.toString(),
                                      style: GoogleFonts.bebasNeue(
                                        fontSize: 24,
                                        color: const Color(0xFF1a237e),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Games Played',
                                      style: GoogleFonts.sarabun(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Back Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: const Color(0xFF1a237e),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'BACK TO MENU',
                      style: GoogleFonts.sarabun(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
