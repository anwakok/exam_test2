import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CardScannerService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<String?> scanCard(File file) async {
    final inputImage = InputImage.fromFile(file);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text.isNotEmpty ? recognizedText.text : null;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
