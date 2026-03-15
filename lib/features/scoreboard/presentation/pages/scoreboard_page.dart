import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game/router.dart';

class Score {
  final int moves;
  final int timeSeconds;
  final DateTime date;

  Score({required this.moves, required this.timeSeconds, required this.date});

  Map<String, dynamic> toJson() => {
    'moves': moves,
    'timeSeconds': timeSeconds,
    'date': date.toIso8601String(),
  };

  factory Score.fromJson(Map<String, dynamic> json) => Score(
    moves: json['moves'],
    timeSeconds: json['timeSeconds'],
    date: DateTime.parse(json['date']),
  );
}

@RoutePage()
class ScoreboardPage extends StatefulWidget {
  const ScoreboardPage({super.key});

  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  List<Score> _scores = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    final scoresJson = prefs.getStringList('memory_game_scores') ?? [];

    setState(() {
      _scores = scoresJson
          .map(
            (s) => Score.fromJson(
              Map<String, dynamic>.from(
                Map<String, dynamic>.from(s as dynamic),
              ),
            ),
          )
          .toList();
      _scores.sort((a, b) => a.timeSeconds.compareTo(b.timeSeconds));
      _isLoading = false;
    });
  }

  Future<void> _clearScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('memory_game_scores');
    setState(() {
      _scores = [];
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d47a1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a237e),
        title: const Text(
          'SCOREBOARD',
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () => context.router.replace(const MainMenuRoute()),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showClearDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : _scores.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
                  const SizedBox(height: 20),
                  Text(
                    'No Scores Yet!',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Play Memory Duel to record your scores',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _scores.length,
              itemBuilder: (context, index) {
                final score = _scores[index];
                final isTop3 = index < 3;

                return Card(
                  color: isTop3
                      ? index == 0
                            ? const Color(0xFFFFD700) // Gold
                            : index == 1
                            ? const Color(0xFFC0C0C0) // Silver
                            : const Color(0xFFCD7F32) // Bronze
                      : const Color(0xFF1a237e),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isTop3 ? Colors.white : Colors.amber,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isTop3
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isTop3 ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 18,
                          color: isTop3 ? Colors.black87 : Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(score.timeSeconds),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isTop3 ? Colors.black : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Icon(
                          Icons.touch_app,
                          size: 18,
                          color: isTop3 ? Colors.black87 : Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${score.moves} moves',
                          style: TextStyle(
                            fontSize: 16,
                            color: isTop3 ? Colors.black87 : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '${score.date.day}/${score.date.month}/${score.date.year}',
                      style: TextStyle(
                        color: isTop3 ? Colors.black54 : Colors.white54,
                      ),
                    ),
                    trailing: isTop3
                        ? Icon(
                            index == 0
                                ? Icons.emoji_events
                                : index == 1
                                ? Icons.emoji_events
                                : Icons.emoji_events,
                            color: index == 0
                                ? Colors.orange.shade800
                                : index == 1
                                ? Colors.grey.shade700
                                : Colors.brown.shade600,
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a237e),
        title: const Text(
          'Clear All Scores?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will delete all recorded scores. This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.amber)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearScores();
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
