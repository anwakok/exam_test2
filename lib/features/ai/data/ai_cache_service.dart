import 'package:hive_flutter/hive_flutter.dart';
import 'ai_service.dart';

class AICacheService {
  final AIService _aiService;
  late Box<String> _box;

  AICacheService(this._aiService);

  Future<void> init() async {
    _box = await Hive.openBox<String>('ai_cache');
  }

  Future<String> getCardHint(String cardName, String effect) async {
    final cacheKey = '${cardName}_$effect';
    if (_box.containsKey(cacheKey)) {
      return _box.get(cacheKey)!;
    }

    final hint = await _aiService.getCardHint(cardName, effect);
    await _box.put(cacheKey, hint);
    return hint;
  }

  Future<void> clearCache() async {
    await _box.clear();
  }
}
