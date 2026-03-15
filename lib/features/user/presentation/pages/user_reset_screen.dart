import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserResetScreen extends StatelessWidget {
  const UserResetScreen({super.key});

  Future<void> _clearExistingUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('users');
      await prefs.remove('current_user');
      debugPrint('Existing users cleared successfully');
    } catch (e) {
      debugPrint('Error clearing users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a237e),
      appBar: AppBar(
        title: const Text('ล้างข้อมูลผู้ใช้'),
        backgroundColor: const Color(0xFF1a237e),
        foregroundColor: Colors.amber,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people_alt, size: 100, color: Colors.amber),
              const SizedBox(height: 30),
              const Text(
                'ล้างข้อมูลผู้ใช้ที่สมัครไว้',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'การดำเนินการนี้จะ:\n• ลบผู้ใช้ทั้งหมดที่สมัครไว้\n• ลบข้อมูลการเล่นทั้งหมด\n• ลบข้อมูล leaderboard ทั้งหมด\n• ให้ผู้ใช้ใหม่สมัครใหม่ได้\n\nไม่สามารถกู้คืนได้!',
                style: TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await _clearExistingUsers();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'ล้างข้อมูลผู้ใช้ที่สมัครไว้สำเร็จแล้ว',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ล้างผู้ใช้ที่สมัครไว้',
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
