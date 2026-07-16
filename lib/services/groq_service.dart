import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// Service để gọi Groq API (Llama 3.2 Vision)
/// Thay thế cho GeminiService
class GroqService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';

  List<String> _apiKeys = [];
  int _currentKeyIndex = 0;
  bool _isInitialized = false;

  /// Initialize với danh sách API keys
  void initialize(List<String> apiKeys) {
    if (apiKeys.isEmpty) {
      print('⚠️ Warning: Groq API keys not configured');
      return;
    }

    _apiKeys = apiKeys.where((key) => key.isNotEmpty && key != 'YOUR_GROQ_API_KEY').toList();
    if (_apiKeys.isEmpty) {
      print('⚠️ Warning: No valid Groq API keys found');
      return;
    }

    print('🔑 Initializing Groq with \${_apiKeys.length} API keys');
    _isInitialized = true;
    _currentKeyIndex = 0;
    print('✅ Groq initialized successfully!');
  }

  Future<http.Response> _postWithRetry(String endpoint, Map<String, dynamic> bodyJson, Duration timeout) async {
    int attempts = 0;
    final maxAttempts = _apiKeys.length;
    final bodyStr = jsonEncode(bodyJson);

    while (attempts < maxAttempts) {
      final apiKey = _apiKeys[_currentKeyIndex];
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: bodyStr,
      ).timeout(timeout);

      if (response.statusCode == 429) {
        print('⚠️ Rate limit (429) hit for key index $_currentKeyIndex. Rotating key...');
        _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
        attempts++;
      } else {
        return response;
      }
    }
    
    throw Exception('All API keys hit rate limits (429)');
  }

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  /// Analyze clothing image from bytes (Vision)
  Future<Map<String, dynamic>?> analyzeClothingImageBytes(
    Uint8List imageBytes,
  ) async {
    if (!_isInitialized || _apiKeys.isEmpty) {
      print('❌ Groq not initialized - API key may be invalid');
      return null;
    }

    try {
      print('🔍 Starting Groq analysis... (${imageBytes.length} bytes)');

      // Convert image to base64
      final base64Image = base64Encode(imageBytes);

      // Build request body (OpenAI-compatible format)
      final body = {
        'model': 'meta-llama/llama-4-scout-17b-16e-instruct',
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': AIPrompts.analyzeClothing},
              {
                'type': 'image_url',
                'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
              },
            ],
          },
        ],
        'max_tokens': 1024,
        'temperature': 0.3,
      };

      // Make API call
      final response = await _postWithRetry('/chat/completions', body, const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final content = json['choices'][0]['message']['content'] as String;
        print('📝 Groq response: $content');

        final result = safeParseJson(content);
        print('✅ Parsed result: $result');
        return result;
      } else {
        print('❌ Groq API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Analyze Image Error: $e');
      return null;
    }
  }

  /// Suggest outfit based on wardrobe and conditions (Text only)
  Future<Map<String, dynamic>?> suggestOutfit({
    required List<ClothingItem> wardrobe,
    required String weatherContext,
    required String occasion,
    String? stylePreference,
    String? genderProfile,
    String? styleProfile,
    String? fengShuiContext,
    String? bodyProfileContext,
  }) async {
    if (!_isInitialized || _apiKeys.isEmpty) {
      print('❌ Groq not initialized');
      return null;
    }

    if (wardrobe.isEmpty) {
      print('Wardrobe is empty');
      return null;
    }

    try {
      // Build wardrobe context
      final wardrobeContext = wardrobe
          .map((item) => item.toAIDescription())
          .join('\n');

      final prompt = AIPrompts.suggestOutfit(
        wardrobeContext: wardrobeContext,
        weatherContext: weatherContext,
        occasion: occasion,
        stylePreference: stylePreference,
        genderProfile: genderProfile,
        styleProfile: styleProfile,
        fengShuiContext: fengShuiContext,
        bodyProfileContext: bodyProfileContext,
      );

      // Build request body
      final body = {
        'model': 'llama-3.3-70b-versatile', // Text-only model, more powerful
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 1024,
        'temperature': 0.7,
      };

      final response = await _postWithRetry('/chat/completions', body, AppConstants.aiTimeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final content = json['choices'][0]['message']['content'] as String;
        return safeParseJson(content);
      } else {
        print('Groq API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Suggest Outfit Error: $e');
      return null;
    }
  }

  /// Evaluate color harmony between two items (Text only)
  Future<ColorHarmonyResult?> evaluateColorHarmony(
    ClothingItem item1,
    ClothingItem item2,
  ) async {
    if (!_isInitialized || _apiKeys.isEmpty) {
      print('❌ Groq not initialized');
      return null;
    }

    try {
      final prompt = AIPrompts.colorHarmony(
        item1.toAIDescription(),
        item2.toAIDescription(),
      );

      final body = {
        'model': 'llama-3.3-70b-versatile',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 1024,
        'temperature': 0.5,
      };

      final response = await _postWithRetry('/chat/completions', body, AppConstants.aiTimeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final content = json['choices'][0]['message']['content'] as String;

        final parsedJson = safeParseJson(content);
        if (parsedJson == null) return null;

        return ColorHarmonyResult.fromJson(parsedJson);
      } else {
        print('Groq API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Color Harmony Error: $e');
      return null;
    }
  }

  /// Get wardrobe cleanup suggestions (Text only)
  Future<Map<String, dynamic>?> getCleanupSuggestions(
    List<ClothingItem> wardrobe, {
    String? genderProfile,
    String? styleProfile,
  }) async {
    if (!_isInitialized || _apiKeys.isEmpty) {
      print('❌ Groq not initialized');
      return null;
    }

    if (wardrobe.isEmpty) {
      print('Wardrobe is empty');
      return null;
    }

    try {
      final wardrobeContext = wardrobe
          .map((item) => item.toAIDescription())
          .join('\n');

      final prompt = AIPrompts.cleanupSuggestion(
        wardrobeContext,
        genderProfile: genderProfile,
        styleProfile: styleProfile,
      );

      final body = {
        'model': 'llama-3.3-70b-versatile',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 1024,
        'temperature': 0.7,
      };

      final response = await _postWithRetry('/chat/completions', body, AppConstants.aiTimeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final content = json['choices'][0]['message']['content'] as String;
        return safeParseJson(content);
      } else {
        print('Groq API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Cleanup Suggestions Error: $e');
      return null;
    }
  }
}
