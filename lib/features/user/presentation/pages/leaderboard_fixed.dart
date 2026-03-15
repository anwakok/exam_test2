import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:game/features/user/domain/entities/user.dart';

class LeaderboardScreen extends StatelessWidget {
  final List<User> users;

  const LeaderboardScreen({super.key, required this.users});

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Sort users by best time, then by total games
    final sortedUsers = List<User>.from(users);
    sortedUsers.sort((a, b) {
      if (a.bestTime != b.bestTime) {
        return a.bestTime.compareTo(b.bestTime);
      }
      return b.totalGames.compareTo(a.totalGames);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF1a237e),
      appBar: AppBar(
        title: Text(
          'LEADERBOARD',
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
        child: sortedUsers.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 80,
                      color: Colors.amber.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No players yet',
                      style: GoogleFonts.sarabun(
                        fontSize: 20,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Be the first to play!',
                      style: GoogleFonts.sarabun(
                        fontSize: 16,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedUsers.length,
                itemBuilder: (context, index) {
                  final user = sortedUsers[index];
                  final medalColor = index == 0
                      ? Colors.amber
                      : index == 1
                      ? Colors.grey[400]
                      : index == 2
                      ? Colors.brown[300]
                      : Colors.grey[300];
                  final medalIcon = index == 0
                      ? Icons.emoji_events
                      : index == 1
                      ? Icons.emoji_events
                      : index == 2
                      ? Icons.emoji_events
                      : Icons.emoji_events;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color:
                            medalColor?.withValues(alpha: 0.8) ??
                            Colors.grey.withValues(alpha: 0.5),
                        width: index < 3 ? 3 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Medal
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: medalColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              medalIcon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // User info
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '#${index + 1}',
                                    style: GoogleFonts.bebasNeue(
                                      fontSize: 20,
                                      color: medalColor ?? Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    user.username,
                                    style: GoogleFonts.sarabun(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _formatTime(user.bestTime),
                                    style: GoogleFonts.bebasNeue(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${user.totalGames} games',
                                    style: GoogleFonts.sarabun(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
