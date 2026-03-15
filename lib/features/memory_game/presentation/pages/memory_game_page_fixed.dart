import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game/router.dart';
import 'package:game/features/user/domain/entities/user.dart';

class GameCard {
  final int id;
  final int originalId;
  final String name;
  final String imageUrl;

  GameCard({
    required this.id,
    required this.originalId,
    required this.name,
    required this.imageUrl,
  });
}

@RoutePage()
class MemoryGamePage extends StatefulWidget {
  const MemoryGamePage({super.key});

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  late List<GameCard> _cards;
  late List<bool> _flipped;
  late List<bool> _matched;
  int _firstIndex = -1;
  int _secondIndex = -1;
  int _moves = 0;
  int _matches = 0;
  bool _isProcessing = false;
  bool _isPreview = true;
  int _previewTimeLeft = 5;
  Timer? _previewTimer;
  Timer? _gameTimer;
  int _elapsedSeconds = 0;
  bool _isLoading = true;
  String? _error;
  User? _currentUser;

  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadCards();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserJson = prefs.getString('current_user');
    if (currentUserJson != null) {
      setState(() {
        _currentUser = User.fromJson(jsonDecode(currentUserJson));
      });
    }
  }

  Future<void> _loadCards() async {
    try {
      final response = await _dio.get(
        'https://db.ygoprodeck.com/api/v7/cardinfo.php',
        queryParameters: {'num': 6, 'offset': Random().nextInt(500)},
      );

      final data = response.data['data'] as List;
      final yugiCards = data
          .map(
            (c) => GameCard(
              id: c['id'],
              originalId: c['id'],
              name: c['name'],
              imageUrl:
                  c['card_images']?[0]?['image_url_small'] ??
                  c['card_images']?[0]?['image_url'] ??
                  '',
            ),
          )
          .toList();

      // Create pairs with same originalId but different display id
      _cards = [];
      int pairId = 0;
      for (final card in yugiCards) {
        // First card of pair
        _cards.add(
          GameCard(
            id: pairId * 2,
            originalId: card.originalId,
            name: card.name,
            imageUrl: card.imageUrl,
          ),
        );
        // Second card of pair (same originalId)
        _cards.add(
          GameCard(
            id: pairId * 2 + 1,
            originalId: card.originalId,
            name: card.name,
            imageUrl: card.imageUrl,
          ),
        );
        pairId++;
      }

      // Shuffle cards
      _cards.shuffle(Random());

      // Initialize game state
      _flipped = List.filled(12, true); // Start with all cards visible for preview
      _matched = List.filled(12, false);

      setState(() {
        _isLoading = false;
      });

      // Start preview countdown
      _startPreview();
    } catch (e) {
      setState(() {
        _error = 'Failed to load cards: $e';
        _isLoading = false;
      });
    }
  }

  void _startPreview() {
    _previewTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _previewTimeLeft--;
        if (_previewTimeLeft <= 0) {
          _previewTimer?.cancel();
          _isPreview = false;
          _flipped = List.filled(12, false); // Hide all cards
          _startGameTimer();
        }
      });
    });
  }

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _onCardTap(int index) {
    if (_isProcessing || _flipped[index] || _matched[index] || _isPreview) {
      return;
    }

    setState(() {
      _flipped[index] = true;
    });

    if (_firstIndex == -1) {
      _firstIndex = index;
    } else {
      _secondIndex = index;
      _moves++;
      _isProcessing = true;
      _checkMatch();
    }
  }

  void _checkMatch() {
    final firstOriginalId = _cards[_firstIndex].originalId;
    final secondOriginalId = _cards[_secondIndex].originalId;

    if (firstOriginalId == secondOriginalId) {
      // Match found
      setState(() {
        _matched[_firstIndex] = true;
        _matched[_secondIndex] = true;
        _matches++;
        _firstIndex = -1;
        _secondIndex = -1;
        _isProcessing = false;
      });

      // Check for win
      if (_matches == 6) {
        _gameTimer?.cancel();
        _showWinDialog();
      }
    } else {
      // No match - flip cards back after delay
      Timer(const Duration(seconds: 1), () {
        setState(() {
          _flipped[_firstIndex] = false;
          _flipped[_secondIndex] = false;
          _firstIndex = -1;
          _secondIndex = -1;
          _isProcessing = false;
        });
      });
    }
  }

  Future<void> _saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    final scores = prefs.getStringList('memory_game_scores') ?? [];

    final newScore = {
      'moves': _moves,
      'timeSeconds': _elapsedSeconds,
      'date': DateTime.now().toIso8601String(),
    };

    scores.add(jsonEncode(newScore));

    if (scores.length > 20) {
      scores.removeAt(0);
    }

    await prefs.setStringList('memory_game_scores', scores);
  }

  Future<void> _saveUserScore() async {
    if (_currentUser == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Update user stats
      final updatedUser = _currentUser!.copyWith(
        totalGames: _currentUser!.totalGames + 1,
        bestTime: _elapsedSeconds < _currentUser!.bestTime 
            ? _elapsedSeconds 
            : _currentUser!.bestTime,
        bestMoves: _moves < _currentUser!.bestMoves 
            ? _moves 
            : _currentUser!.bestMoves,
      );

      // Save updated user
      await prefs.setString('current_user', jsonEncode(updatedUser.toJson()));
      
      // Update in users list
      final usersJson = prefs.getStringList('users') ?? [];
      final users = usersJson
          .map((json) => User.fromJson(jsonDecode(json)))
          .toList();
      
      final userIndex = users.indexWhere((u) => u.id == updatedUser.id);
      if (userIndex != -1) {
        users[userIndex] = updatedUser;
        final updatedUsersJson = users.map((u) => jsonEncode(u.toJson())).toList();
        await prefs.setStringList('users', updatedUsersJson);
      }

      setState(() {
        _currentUser = updatedUser;
      });
    } catch (e) {
      debugPrint('Error saving score: $e');
    }
  }

  void _showWinDialog() {
    if (_currentUser != null) {
      _saveUserScore();
    }
    _saveScore(); // Save general score for leaderboard
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a237e),
        title: const Text(
          '🎉 YOU WON!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.amber,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Time: ${_formatTime(_elapsedSeconds)}',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'Moves: $_moves',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            if (_currentUser != null) ...[
              const SizedBox(height: 8),
              Text(
                'Player: ${_currentUser!.username}',
                style: const TextStyle(color: Colors.amber, fontSize: 16),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.router.replace(const MemoryGameRoute());
            },
            child: const Text(
              'Play Again',
              style: TextStyle(color: Colors.amber),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.router.replace(const MainMenuRoute());
            },
            child: const Text('Menu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _resetGame() {
    _previewTimer?.cancel();
    _gameTimer?.cancel();
    setState(() {
      _isLoading = true;
      _error = null;
      _moves = 0;
      _matches = 0;
      _elapsedSeconds = 0;
      _isPreview = true;
      _previewTimeLeft = 5;
      _firstIndex = -1;
      _secondIndex = -1;
      _isProcessing = false;
    });
    _loadCards();
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a237e),
      appBar: AppBar(
        title: const Text('MEMORY DUEL'),
        backgroundColor: const Color(0xFF1a237e),
        foregroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _resetGame,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Game stats
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStat('Time', _formatTime(_elapsedSeconds), Icons.timer),
                          _buildStat('Moves', '$_moves', Icons.touch_app),
                          _buildStat('Matches', '$_matches/6', Icons.check_circle),
                        ],
                      ),
                    ),
                    // Preview countdown
                    if (_isPreview)
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Memorize the cards! $_previewTimeLeft',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    // Game board
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: 12,
                          itemBuilder: (context, index) {
                            return _buildCard(index);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(int index) {
    final card = _cards[index];
    final isFlipped = _flipped[index];
    final isMatched = _matched[index];

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isFlipped || isMatched ? Colors.white : Colors.amber,
          border: Border.all(
            color: isMatched ? Colors.green : Colors.amber,
            width: 2,
          ),
        ),
        child: isFlipped || isMatched
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: card.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: card.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(color: Colors.amber),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
              )
            : const Center(
                child: Icon(
                  Icons.help_outline,
                  color: Color(0xFF1a237e),
                  size: 40,
                ),
              ),
      ),
    );
  }
}
