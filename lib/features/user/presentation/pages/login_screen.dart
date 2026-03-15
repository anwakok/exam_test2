import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:game/features/user/data/sqlite_user_repository.dart';
import 'package:game/injection.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = getIt<SQLiteUserRepository>();

      if (_isLogin) {
        // Login
        final user = await repo.getUserByUsername(
          _usernameController.text.trim(),
        );
        if (user == null) {
          setState(() {
            _errorMessage = 'ไม่พบชื่อผู้ใช้นี้ กรุณาลองใหม่หรือสมัครสมาชิก';
          });
        } else if (user.password != _passwordController.text) {
          setState(() {
            _errorMessage = 'รหัสผ่านไม่ถูกต้อง';
          });
        } else {
          await repo.setCurrentUser(user.id);
          if (mounted) {
            Navigator.pop(context); // Go back to main menu
          }
        }
      } else {
        // Register
        await repo.createUser(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('สมัครสมาชิกสำเร็จ!'),
              backgroundColor: Colors.green,
            ),
          );
          // Switch to login mode
          setState(() {
            _isLogin = true;
            _emailController.clear();
            _passwordController.clear();
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a237e),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Text(
                'YU-GI-OH!\nMEMORY DUEL',
                textAlign: TextAlign.center,
                style: GoogleFonts.bebasNeue(
                  fontSize: 48,
                  color: Colors.amber,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 60),
              Expanded(
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin ? 'เข้าสู่ระบบ' : 'สมัครสมาชิก',
                              style: GoogleFonts.sarabun(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1a237e),
                              ),
                            ),
                            const SizedBox(height: 32),
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'ชื่อผู้ใช้',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'กรุณากรอกชื่อผู้ใช้';
                                }
                                if (value.trim().length < 3) {
                                  return 'ชื่อผู้ใช้ต้องมีอย่างน้อย 3 ตัวอักษร';
                                }
                                if (value.trim().length > 20) {
                                  return 'ชื่อผู้ใช้ต้องไม่เกิน 20 ตัวอักษร';
                                }
                                if (!RegExp(
                                  r'^[a-zA-Z0-9ก-๙]+$',
                                ).hasMatch(value.trim())) {
                                  return 'ชื่อผู้ใช้ต้องเป็นตัวอักษรภาษาอังกฤษ ตัวเลข หรือภาษาไทยเท่านั้น';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'รหัสผ่าน',
                                prefixIcon: const Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณากรอกรหัสผ่าน';
                                }
                                if (value.length < 8) {
                                  return 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';
                                }
                                if (!RegExp(
                                  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)',
                                ).hasMatch(value)) {
                                  final missing = <String>[];
                                  if (!RegExp(r'[a-z]').hasMatch(value)) {
                                    missing.add('ตัวพิมพ์เล็ก');
                                  }
                                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                    missing.add('ตัวพิมพ์ใหญ่');
                                  }
                                  if (!RegExp(r'\d').hasMatch(value)) {
                                    missing.add('ตัวเลข');
                                  }
                                  return 'รหัสผ่านต้องมี: ${missing.join(', ')}';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            if (!_isLogin) ...[
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'อีเมล (ไม่จำเป็น)',
                                  prefixIcon: const Icon(Icons.email),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value != null &&
                                      value.trim().isNotEmpty) {
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value.trim())) {
                                      return 'กรุณากรอกอีเมลที่ถูกต้อง';
                                    }
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error,
                                      color: Colors.red[600],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: GoogleFonts.sarabun(
                                          color: Colors.red[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1a237e),
                                  foregroundColor: Colors.amber,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.amber,
                                      )
                                    : Text(
                                        _isLogin
                                            ? 'เข้าสู่ระบบ'
                                            : 'สมัครสมาชิก',
                                        style: GoogleFonts.sarabun(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                  _emailController.clear();
                                  _passwordController.clear();
                                  _errorMessage = null;
                                });
                              },
                              child: Text(
                                _isLogin
                                    ? 'ยังไม่มีบัญชี? สมัครเลย!'
                                    : 'มีบัญชีอยู่แล้ว? เข้าสู่ระบบ',
                                style: GoogleFonts.sarabun(
                                  color: const Color(0xFF1a237e),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
