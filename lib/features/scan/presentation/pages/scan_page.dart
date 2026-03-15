import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:game/injection.dart';
import 'package:game/features/ai/data/ai_cache_service.dart';
import 'package:game/features/scan/data/card_scanner_service.dart';

@RoutePage()
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final CardScannerService _scannerService = getIt<CardScannerService>();
  final AICacheService _aiCacheService = getIt<AICacheService>();
  final ImagePicker _picker = ImagePicker();

  File? _image;
  String? _scannedText;
  String? _aiExplanation;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _scannedText = null;
        _aiExplanation = null;
      });
      await _scanCard();
    }
  }

  Future<void> _scanCard() async {
    if (_image == null) return;

    setState(() => _isLoading = true);

    try {
      final text = await _scannerService.scanCard(_image!);
      setState(() => _scannedText = text);

      if (text != null && text.isNotEmpty) {
        // Get hint without effect for now (effect will be empty)
        final hint = await _aiCacheService.getCardHint(text, '');
        setState(() => _aiExplanation = hint);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _scannerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Card')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_image != null) Image.file(_image!, height: 200),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
            ),
            const SizedBox(height: 16),
            if (_isLoading) const CircularProgressIndicator(),
            if (_scannedText != null) ...[
              const Text(
                'Scanned Text:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_scannedText!),
              const SizedBox(height: 16),
            ],
            if (_aiExplanation != null) ...[
              const Text(
                'AI Hint:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_aiExplanation!),
            ],
          ],
        ),
      ),
    );
  }
}
