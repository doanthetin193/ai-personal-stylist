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

  String? _apiKey;
  bool _isInitialized = false;

  /// Initialize với API key
  void initialize(String apiKey) {
    if (apiKey.isEmpty || apiKey == 'YOUR_GROQ_API_KEY') {
      print('⚠️ Warning: Groq API key not configured');
      return;
    }

    print('🔑 Initializing Groq with API key: ${apiKey.substring(0, 10)}...');
    _apiKey = apiKey;
    _isInitialized = true;
    print('✅ Groq initialized successfully!');
  }

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  /// Analyze clothing image from bytes (Vision)
  Future<Map<String, dynamic>?> analyzeClothingImageBytes(
    Uint8List imageBytes,
  ) async {
    if (!_isInitialized || _apiKey == null) {
      print('❌ Groq not initialized - API key may be invalid');
      return null;
    }

    try {
      print('🔍 Starting Groq analysis... (${imageBytes.length} bytes)');

      // Convert image to base64
      final base64Image = base64Encode(imageBytes);

      // Build request body (OpenAI-compatible format)
      final body = jsonEncode({
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
      });

      // Make API call
      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Timeout - Groq took too long');
            },
          );

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
  }) async {
    if (!_isInitialized || _apiKey == null) {
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
      );

      // Build request body
      final body = jsonEncode({
        'model': 'llama-3.3-70b-versatile', // Text-only model, more powerful
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 1024,
        'temperature': 0.7,
      });

      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(AppConstants.aiTimeout);

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
    if (!_isInitialized || _apiKey == null) {
      print('❌ Groq not initialized');
      return null;
    }

    try {
      final prompt = AIPrompts.colorHarmony(
        item1.toAIDescription(),
        item2.toAIDescription(),
      );

      final body = jsonEncode({
        'model': 'llama-3.3-70b-versatile',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 1024,
        'temperature': 0.5,
      });

      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(AppConstants.aiTimeout);

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
    List<ClothingItem> wardrobe,
  ) async {
    if (!_isInitialized || _apiKey == null) {
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

      final prompt = AIPrompts.cleanupSuggestion(wardrobeContext);

      final body = jsonEncode({
        'model': 'llama-3.3-70b-versatile',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 1024,
        'temperature': 0.7,
      });

      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(AppConstants.aiTimeout);

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
