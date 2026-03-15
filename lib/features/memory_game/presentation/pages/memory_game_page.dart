import 'dart:async';
import 'dart:math';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:game/features/user/data/sqlite_user_repository.dart';
import 'package:game/features/user/domain/entities/user.dart';
import 'package:game/injection.dart';
import 'package:game/router.dart';

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
    try {
      final repo = getIt<SQLiteUserRepository>();
      final currentUser = await repo.getCurrentUser();
      if (currentUser != null) {
        setState(() {
          _currentUser = currentUser;
        });
      }
    } catch (e) {
      debugPrint('Error loading current user: $e');
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
      _cards.shuffle(Random());

      _flipped = List<bool>.filled(12, false);
      _matched = List<bool>.filled(12, false);

      setState(() {
        _isLoading = false;
      });

      _startPreview();
    } catch (e) {
      setState(() {
        _error = 'Failed to load cards: $e';
        _isLoading = false;
      });
    }
  }

  void _startPreview() {
    _isPreview = true;
    _previewTimeLeft = 5;

    setState(() {
      _flipped = List<bool>.filled(12, true);
    });

    _previewTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _previewTimeLeft--;
      });

      if (_previewTimeLeft <= 0) {
        timer.cancel();
        _endPreview();
      }
    });
  }

  void _endPreview() {
    setState(() {
      _isPreview = false;
      _flipped = List<bool>.filled(12, false);
    });
    _startGameTimer();
  }

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _onCardTap(int index) {
    if (_isPreview || _isProcessing || _flipped[index] || _matched[index]) {
      return;
    }

    setState(() {
      _flipped[index] = true;
    });

    if (_firstIndex == -1) {
      _firstIndex = index;
    } else if (_secondIndex == -1 && _firstIndex != index) {
      _secondIndex = index;
      _moves++;
      _checkMatch();
    }
  }

  void _checkMatch() {
    _isProcessing = true;

    final firstOriginalId = _cards[_firstIndex].originalId;
    final secondOriginalId = _cards[_secondIndex].originalId;

    if (firstOriginalId == secondOriginalId) {
      debugPrint(
        'Match found: $_firstIndex and $_secondIndex (originalId: $firstOriginalId)',
      );
      setState(() {
        _matched[_firstIndex] = true;
        _matched[_secondIndex] = true;
        _matches++;
        _firstIndex = -1;
        _secondIndex = -1;
        _isProcessing = false;
      });

      if (_matches == 6) {
        _gameTimer?.cancel();
        _saveScore();
        _saveUserScore();
        Future.delayed(const Duration(milliseconds: 500), _showWinDialog);
      }
    } else {
      debugPrint('No match: $_firstIndex and $_secondIndex');
      Future.delayed(const Duration(milliseconds: 800), () {
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
    // Save general scores for scoreboard (could be saved to file later)
    // For now, this method is kept for compatibility but can be removed
    // if we only want to track user-specific scores
    debugPrint('General score saved: $_moves moves, $_elapsedSeconds seconds');
  }

  Future<void> _saveUserScore() async {
    if (_currentUser == null) return;

    try {
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

      // Save updated user using SQLiteUserRepository
      final repo = getIt<SQLiteUserRepository>();
      await repo.updateUser(updatedUser);
      await repo.setCurrentUser(updatedUser.id);

      setState(() {
        _currentUser = updatedUser;
      });

      debugPrint(
        'User score saved: ${updatedUser.username} - $_moves moves, $_elapsedSeconds seconds',
      );
    } catch (e) {
      debugPrint('Error saving user score: $e');
    }
  }

  void _showWinDialog() {
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0d47a1),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.amber),
              const SizedBox(height: 20),
              Text(
                'Loading Yu-Gi-Oh Cards...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0d47a1),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 60),
              const SizedBox(height: 20),
              Text(
                _error!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _resetGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: const Color(0xFF1a237e),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0d47a1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a237e),
        title: const Text(
          'MEMORY DUEL',
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () => _showExitConfirmation(context),
        ),
        actions: [
          if (_isPreview)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_previewTimeLeft',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  _formatTime(_elapsedSeconds),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1a237e),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat('Moves', '$_moves', Icons.touch_app),
                _buildStat('Matches', '$_matches/6', Icons.check_circle),
                _buildStat('Pairs Left', '${6 - _matches}', Icons.style),
              ],
            ),
          ),
          if (_isPreview)
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'MEMORIZE THE CARDS!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1a237e),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
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

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a237e),
        title: const Text(
          'ออกจากเกม?',
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'คุณต้องการออกจากเกมหรือไม่? ความคืบหน้าจะไม่ถูกบันทึก',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('เล่นต่อ', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.router.replace(const MainMenuRoute());
            },
            child: const Text('ออก', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(int index) {
    final isFlipped = _flipped[index];
    final isMatched = _matched[index];
    final card = _cards[index];

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: isFlipped || isMatched ? 1 : 0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          // Calculate rotation for flip effect
          final angle = value * 3.14159; // pi
          final isFront = value < 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(angle),
            child: isFront
                ? _buildCardBack(isMatched)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.14159),
                    child: _buildCardFront(card, isMatched),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCardBack(bool isMatched) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMatched ? Colors.greenAccent : const Color(0xFF8B4513),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Dark base
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0xFF2D1810), // lighter brown center
                    Color(0xFF1A0F0A), // dark brown
                    Color(0xFF0D0805), // almost black
                  ],
                  stops: [0.0, 0.5, 1.0],
                  center: Alignment.center,
                ),
              ),
            ),
            // Swirling vortex effect
            CustomPaint(painter: YuGiOhCardBackPainter()),
            // Outer frame
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF8B4513).withValues(alpha: 0.8),
                  width: 2,
                ),
              ),
            ),
            // Center emblem - Millennium Eye style
            Center(
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFFFFD700), // bright gold
                      Color(0xFFB8860B), // dark goldenrod
                      Color(0xFF8B4513), // saddle brown
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                  border: Border.all(color: const Color(0xFFFFD700), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.visibility,
                    color: Color(0xFF1A0F0A),
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFront(GameCard card, bool isMatched) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isMatched ? Colors.green : Colors.white,
        border: Border.all(
          color: isMatched ? Colors.greenAccent : Colors.amber,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: CachedNetworkImage(
          imageUrl: card.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[800],
            child: const Icon(Icons.error, color: Colors.red),
          ),
        ),
      ),
    );
  }
}

// Custom painter for Yu-Gi-Oh! card back vortex effect
class YuGiOhCardBackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) / 2;

    // Draw swirling energy lines (like the official card back)
    for (int i = 0; i < 20; i++) {
      final path = Path();
      final startAngle = (i * 18) * 3.14159 / 180;

      // Create swirling line from center to edge
      for (double r = 8; r < maxRadius - 5; r += 2) {
        final spiralFactor = r / maxRadius;
        final angle =
            startAngle + spiralFactor * 4 * 3.14159; // 2 full rotations
        final x = center.dx + cos(angle) * r;
        final y = center.dy + sin(angle) * r;

        if (r == 8) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      // Gold/orange gradient stroke
      final paint = Paint()
        ..color = Color.lerp(
          const Color(0xFFFFD700), // gold
          const Color(0xFFFF8C00), // dark orange
          i / 20,
        )!.withValues(alpha: 0.4 + (i % 3) * 0.1)
        ..strokeWidth = 2 + (i % 3)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, paint);
    }

    // Draw outer ring of energy
    for (int i = 0; i < 36; i++) {
      final angle = (i * 10) * 3.14159 / 180;
      final innerR = maxRadius * 0.6;
      final outerR = maxRadius * 0.9;

      final startX = center.dx + cos(angle) * innerR;
      final startY = center.dy + sin(angle) * innerR;
      final endX = center.dx + cos(angle) * outerR;
      final endY = center.dy + sin(angle) * outerR;

      final paint = Paint()
        ..color = const Color(0xFFD2691E).withValues(alpha: 0.3)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }

    // Draw concentric circles (subtle)
    for (int i = 1; i <= 4; i++) {
      final radius = maxRadius * (i / 5);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0xFF8B4513).withValues(alpha: 0.15)
          ..strokeWidth = 0.5
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
