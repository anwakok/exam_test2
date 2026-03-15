import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:game/features/user/domain/entities/user.dart';

class LeaderboardScreen extends StatelessWidget {
  final List<User> users;

  const LeaderboardScreen({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    // Sort by best time first, then by best moves
    final sortedUsers = List<User>.from(users)
      ..sort((a, b) {
        if (a.bestTime != b.bestTime) {
          return a.bestTime.compareTo(b.bestTime);
        }
        return a.bestMoves.compareTo(b.bestMoves);
      });

    return Scaffold(
      backgroundColor: const Color(0xFF1a237e),
      appBar: AppBar(
        title: Text(
          'LEADERBOARD',
          style: GoogleFonts.bebasNeue(
            fontSize: 28,
            color: Colors.amber,
          ),
        ),
        backgroundColor: const Color(0xFF1a237e),
        foregroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: sortedUsers.isEmpty
          ? Center(
              child: Text(
                'ยังไม่มีข้อมูลผู้เล่น',
                style: GoogleFonts.sarabun(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedUsers.length,
              itemBuilder: (context, index) {
                final user = sortedUsers[index];
                final rank = index + 1;

                Color medalColor = Colors.grey;
                IconData medalIcon = Icons.emoji_events;

                if (rank == 1) {
                  medalColor = Colors.amber;
                } else if (rank == 2) {
                  medalColor = Colors.grey[300]!;
                } else if (rank == 3) {
                  medalColor = Colors.brown[300]!;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
                                  '#$rank',
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 20,
                                    color: Colors.amber,
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
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}