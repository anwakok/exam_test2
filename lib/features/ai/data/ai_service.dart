import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class AIService {
  Future<String> getCardHint(String name, String effect);
}

class GroqAIService implements AIService {
  final Dio dio;

  GroqAIService(this.dio);

  @override
  Future<String> getCardHint(String name, String effect) async {
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

    final response = await dio.post(
      "https://api.groq.com/openai/v1/chat/completions",
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        "model": "llama3-70b-8192",
        "messages": [
          {
            "role": "system",
            "content":
                "You are a Yu-Gi-Oh expert providing strategic hints and tips. Keep responses concise (2-3 sentences max). Focus on: when to use the card, good combos, and strategic advice. Do not explain the effect (user already knows it from the API).",
          },
          {
            "role": "user",
            "content":
                "Card: $name\nEffect: $effect\n\nGive me a strategic hint for using this card effectively in duels.",
          },
        ],
      },
    );

    return response.data["choices"][0]["message"]["content"];
  }
}
