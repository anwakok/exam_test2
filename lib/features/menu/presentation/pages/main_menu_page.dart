import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:game/router.dart';
import 'package:game/features/user/presentation/pages/login_screen.dart';
import 'package:game/features/user/presentation/pages/leaderboard_screen.dart';
import 'package:game/features/user/presentation/pages/scoreboard_screen.dart';
import 'package:game/features/user/data/sqlite_user_repository.dart';
import 'package:game/injection.dart';
import 'package:game/features/user/domain/entities/user.dart';

@RoutePage()
class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
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

  Future<void> _logout() async {
    try {
      final repo = getIt<SQLiteUserRepository>();
      await repo.clearCurrentUser();
      setState(() {
        _currentUser = null;
      });
    } catch (e) {
      debugPrint('Error logging out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a237e), Color(0xFF0d47a1), Color(0xFF01579b)],
          ),
        ),
        child: Stack(
          children: [
            // User Profile - Top Right
            if (_currentUser != null)
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person, color: Colors.amber, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _currentUser!.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _logout,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.logout,
                            color: Colors.red[300],
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Main Menu Content
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Yu-Gi-Oh Logo style title
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.yellowAccent,
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
                      child: const Text(
                        'YU-GI-OH!\nMEMORY DUEL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1a237e),
                          shadows: [
                            Shadow(
                              color: Colors.white,
                              blurRadius: 2,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Start Button - require login
                    _MenuButton(
                      text: 'START GAME',
                      icon: Icons.play_arrow,
                      onPressed: () {
                        if (_currentUser == null) {
                          // Show warning dialog before redirecting to login
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFF1a237e),
                              title: const Text(
                                'ต้องเข้าสู่ระบบก่อน',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: const Text(
                                'กรุณาเข้าสู่ระบบหรือลงทะเบียนเพื่อเริ่มเล่นเกม',
                                style: TextStyle(color: Colors.white),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'ยกเลิก',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    ).then((_) => _loadCurrentUser());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    foregroundColor: const Color(0xFF1a237e),
                                  ),
                                  child: const Text('ไปหน้าเข้าสู่ระบบ'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          // Go to game if logged in
                          context.router.push(const MemoryGameRoute());
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    // Scoreboard Button - Show current user's best score
                    _MenuButton(
                      text: 'SCOREBOARD',
                      icon: Icons.emoji_events,
                      onPressed: () {
                        if (_currentUser != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ScoreboardScreen(currentUser: _currentUser!),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    // Deck Button
                    _MenuButton(
                      text: 'DECK',
                      icon: Icons.style,
                      onPressed: () {
                        context.router.push(const CardListRoute());
                      },
                    ),
                    const SizedBox(height: 20),
                    // User Login/Register Button
                    if (_currentUser == null)
                      _MenuButton(
                        text: 'ลงทะเบียน / เข้าสู่ระบบ',
                        icon: Icons.person_add,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          ).then((_) => _loadCurrentUser());
                        },
                      ),
                    if (_currentUser != null) ...[
                      // Leaderboard Button
                      _MenuButton(
                        text: 'LEADERBOARD',
                        icon: Icons.leaderboard,
                        onPressed: () async {
                          final repo = getIt<SQLiteUserRepository>();
                          final users = await repo.getAllUsers();

                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  LeaderboardScreen(users: users),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    // Extra space before EXIT button
                    const SizedBox(height: 30),
                    // Exit Button
                    _MenuButton(
                      text: 'EXIT',
                      icon: Icons.exit_to_app,
                      onPressed: () {
                        _showExitDialog(context);
                      },
                      isExit: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a237e),
        title: const Text('Exit Game?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to exit?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.amber)),
          ),
          TextButton(
            onPressed: () => exit(0),
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isExit;
  final EdgeInsetsGeometry? padding;

  const _MenuButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isExit = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isExit ? Colors.red.shade700 : Colors.amber,
        foregroundColor: isExit ? Colors.white : const Color(0xFF1a237e),
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(
            color: isExit ? Colors.red.shade300 : Colors.yellowAccent,
            width: 3,
          ),
        ),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.5),
      ),
      icon: Icon(icon, size: 28),
      label: Text(
        text,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
