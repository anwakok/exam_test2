import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:game/features/cards/domain/entities/card.dart' as yugi;

@RoutePage()
class CardDetailPage extends StatefulWidget {
  final yugi.Card card;

  const CardDetailPage({super.key, required this.card});

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  String? _aiSummary;
  String? _translatedDescription;
  bool _isLoading = false;
  bool _isTranslating = false;
  final Dio _dio = Dio();

  Future<void> _getAISummary() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

      debugPrint('API Key length: ${apiKey.length}');
      debugPrint(
        'API Key first 10 chars: ${apiKey.isNotEmpty ? apiKey.substring(0, 10) : 'EMPTY'}',
      );

      if (apiKey.isEmpty) {
        setState(() {
          _aiSummary = 'ไม่พบ API Key กรุณาตรวจสอบไฟล์ .env';
          _isLoading = false;
        });
        return;
      }

      final prompt =
          'การ์ด: ${widget.card.name}\n'
          'ATK: ${widget.card.atk}, DEF: ${widget.card.def}\n'
          'รายละเอียด: ${widget.card.description ?? 'ไม่มีข้อมูล'}\n\n'
          'กรุณาวิเคราะห์และสรุปข้อมูลดังนี้ (ตอบเป็นภาษาไทย):\n'
          '1. เหมาะใช้กับ Deck อะไร (แนะนำ 2-3 ประเภท)\n'
          '2. ข้อดี/จุดเด่นของการ์ดนี้\n'
          '3. ข้อเสีย/จุดอ่อนของการ์ดนี้\n'
          '4. คำแนะนำการใช้งาน\n\n'
          'ตอบสั้นๆ กระชับ ไม่เกิน 5 บรรทัดต่อหัวข้อ';

      debugPrint('Sending request with prompt: $prompt');

      final response = await _dio.post(
        "https://api.groq.com/openai/v1/chat/completions",
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content":
                  "คุณเป็นผู้เชี่ยวชาญ Yu-Gi-Oh ที่ให้คำแนะนำการใช้การ์ดในรูปแบบที่กระชับและเป็นระบบ ตอบเป็นภาษาไทยเท่านั้น",
            },
            {"role": "user", "content": prompt},
          ],
        },
      );

      debugPrint('Response status: ${response.statusCode}');

      final summary = response.data["choices"][0]["message"]["content"];

      setState(() {
        _aiSummary = summary;
        _isLoading = false;
      });
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');

      String errorMsg = 'เกิดข้อผิดพลาด: ${e.message}';
      if (e.response?.statusCode == 400) {
        errorMsg = 'คำขอไม่ถูกต้อง (400) - ตรวจสอบ API Key หรือรูปแบบคำขอ';
      } else if (e.response?.statusCode == 401) {
        errorMsg = 'API Key ไม่ถูกต้อง (401) - Key หมดอายุหรือถูกระงับ';
      } else if (e.response?.statusCode == 429) {
        errorMsg = 'ใช้งาน API เกินขีดจำกัด (429) - กรุณารอสักครู่';
      }
      setState(() {
        _aiSummary = errorMsg;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      setState(() {
        _aiSummary = 'ไม่สามารถโหลดข้อมูล AI ได้: $e';
        _isLoading = false;
      });
    }
  }

  void _showAISummaryDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1a237e),
          title: const Flexible(
            child: Row(
              children: [
                Icon(Icons.psychology, color: Colors.amber),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'AI วิเคราะห์',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: _aiSummary == null
                ? const Text(
                    'กดปุ่ม "วิเคราะห์เลย!" เพื่อวิเคราะห์การ์ดใบนี้',
                    style: TextStyle(color: Colors.white70),
                  )
                : _aiSummary!.startsWith('ไม่สามารถ') ||
                      _aiSummary!.startsWith('ไม่พบ') ||
                      _aiSummary!.startsWith('คำขอ') ||
                      _aiSummary!.startsWith('API') ||
                      _aiSummary!.startsWith('ใช้งาน') ||
                      _aiSummary!.startsWith('เกิดข้อ')
                ? Text(
                    _aiSummary!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                  )
                : Text(
                    _aiSummary!,
                    style: GoogleFonts.sarabun(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
          ),
          actions: [
            if (_aiSummary == null || _isLoading)
              ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setDialogState(() {});
                        await _getAISummary();
                        setDialogState(() {});
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: const Color(0xFF1a237e),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_isLoading ? 'กำลังวิเคราะห์...' : 'วิเคราะห์เลย!'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ปิด', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _translateDescription() async {
    if (_isTranslating) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

      if (apiKey.isEmpty) {
        setState(() {
          _translatedDescription = 'ไม่พบ API Key กรุณาตรวจสอบไฟล์ .env';
          _isTranslating = false;
        });
        return;
      }

      final prompt =
          'กรุณาแปลคำอธิบายการ์ดนี้เป็นภาษาไทยอย่างถูกต้องและเข้าใจง่าย:\n\n'
          '${widget.card.description ?? ''}\n\n'
          'ให้แปลเป็นภาษาไทยที่เป็นธรรมชาติ ไม่ต้องคำต้นฉบับ';

      final response = await _dio.post(
        "https://api.groq.com/openai/v1/chat/completions",
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content":
                  "คุณเป็นนักแปลมืออาชีพ แปลคำอธิบายการ์ด Yu-Gi-Oh เป็นภาษาไทยที่เข้าใจง่ายและถูกต้อง",
            },
            {"role": "user", "content": prompt},
          ],
        },
      );

      final translation = response.data["choices"][0]["message"]["content"];

      setState(() {
        _translatedDescription = translation;
        _isTranslating = false;
      });
    } on DioException catch (e) {
      String errorMsg = 'เกิดข้อผิดพลาด: ${e.message}';
      if (e.response?.statusCode == 400) {
        errorMsg = 'คำขอไม่ถูกต้อง (400)';
      } else if (e.response?.statusCode == 401) {
        errorMsg = 'API Key ไม่ถูกต้อง (401)';
      } else if (e.response?.statusCode == 429) {
        errorMsg = 'ใช้งานเกินขีดจำกัด (429)';
      }
      setState(() {
        _translatedDescription = errorMsg;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() {
        _translatedDescription = 'ไม่สามารถแปลได้: $e';
        _isTranslating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดการ์ด'),
        backgroundColor: const Color(0xFF1a237e),
        foregroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Card Image - constrained to screen bounds
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: Hero(
                tag: 'card-${widget.card.id}',
                child: widget.card.imageUrl != null
                    ? FittedBox(
                        fit: BoxFit.contain,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 400,
                            maxHeight: 580,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: widget.card.imageUrl!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                    : Container(
                        height: 300,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'รายละเอียดการ์ด',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a237e),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ประเภทการ์ด
                  if (widget.card.type != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.category, color: Color(0xFF1a237e)),
                        const SizedBox(width: 8),
                        Text(
                          'ประเภท: ${widget.card.type}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  // พลังโจมตี/ป้องกัน (เฉพาะมอนสเตอร์)
                  if (widget.card.isMonsterCard) ...[
                    Row(
                      children: [
                        Chip(
                          label: Text('พลังโจมตี: ${widget.card.atk}'),
                          backgroundColor: Colors.red[100],
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text('พลังป้องกัน: ${widget.card.def}'),
                          backgroundColor: Colors.blue[100],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  // AI Summary Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showAISummaryDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1a237e),
                        foregroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.psychology),
                      label: const Text(
                        'สรุปข้อมูลด้วย AI',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_aiSummary != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1a237e).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF1a237e),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.amber),
                              SizedBox(width: 8),
                              Text(
                                'AI Analysis',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF1a237e),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Text(
                            _aiSummary!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text(
                    'รายละเอียดการ์ด',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a237e),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.card.description != null) ...[
                    Row(
                      children: [
                        const Text(
                          'คำอธิบาย',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1a237e),
                          ),
                        ),
                        const Spacer(),
                        // Toggle button between Thai and English
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              if (_translatedDescription != null) {
                                // Switch back to English (original)
                                _translatedDescription = null;
                              } else {
                                // Switch to Thai (will trigger translation)
                                _translateDescription();
                              }
                            });
                          },
                          icon: Icon(
                            _translatedDescription != null
                                ? Icons.translate
                                : Icons.translate,
                            size: 18,
                          ),
                          label: Text(
                            _translatedDescription != null ? 'EN' : 'แปลไทย',
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF1a237e),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (_translatedDescription != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.translate,
                                  color: Color(0xFF1a237e),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'ภาษาไทย',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[700],
                                  ),
                                ),
                                const Spacer(),
                                // Toggle back to English
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _translatedDescription = null;
                                    });
                                  },
                                  icon: const Icon(Icons.language, size: 16),
                                  label: const Text('EN'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF1a237e),
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(50, 30),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _translatedDescription!,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        widget.card.description!,
                        style: const TextStyle(fontSize: 16),
                      ),
                  ] else
                    const Text(
                      'ไม่มีคำอธิบาย',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
