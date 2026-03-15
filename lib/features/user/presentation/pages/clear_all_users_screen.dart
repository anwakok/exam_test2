import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClearAllUsersScreen extends StatelessWidget {
  const ClearAllUsersScreen({super.key});

  Future<void> _clearAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('users');
      await prefs.remove('current_user');
      await prefs.remove('memory_game_scores');
      debugPrint('All user data cleared successfully');
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a237e),
      appBar: AppBar(
        title: const Text('ลบผู้ใช้ทั้งหมด'),
        backgroundColor: const Color(0xFF1a237e),
        foregroundColor: Colors.amber,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.delete_forever,
                size: 100,
                color: Colors.red,
              ),
              const SizedBox(height: 30),
              const Text(
                'ลบผู้ใช้ทั้งหมด',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                '⚠️ การดำเนินการนี้จะ:\n\n• ลบผู้ใช้ทั้งหมดที่สมัครไว้\n• ลบข้อมูลการเล่นทั้งหมด\n• ลบข้อมูล leaderboard ทั้งหมด\n• ลบคะแนนทั้งหมด\n• รีเซ็ตระบบให้เหมือนใหม่\n\n❌ ไม่สามารถกู้คืนได้!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    // Show confirmation dialog
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF1a237e),
                        title: const Text(
                          'ยืนยันการลบ?',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text(
                          'คุณแน่ใจหรือไม่ที่จะลบผู้ใช้ทั้งหมด?\nการกระทำนี้ไม่สามารถย้อนกลับได้',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text(
                              'ยกเลิก',
                              style: TextStyle(color: Colors.amber),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'ลบทั้งหมด',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await _clearAllUsers();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ลบผู้ใช้ทั้งหมดสำเร็จแล้ว'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 3),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ลบผู้ใช้ทั้งหมด',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'ยกเลิก',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
