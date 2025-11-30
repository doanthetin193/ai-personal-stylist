import 'dart:io';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class GeminiService {
  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;
  bool _isInitialized = false;

  /// Initialize với API key
  void initialize(String apiKey) {
    if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY') {
      print('⚠️ Warning: Gemini API key not configured');
      return;
    }
    
    print('🔑 Initializing Gemini with API key: ${apiKey.substring(0, 10)}...');
    
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );
    
    _visionModel = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.3, // Lower for more consistent JSON
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );
    
    _isInitialized = true;
    print('✅ Gemini initialized successfully!');
  }

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  /// Analyze clothing image
  Future<Map<String, dynamic>?> analyzeClothingImage(File imageFile) async {
    if (!_isInitialized) {
      print('Gemini not initialized');
      return null;
    }

    try {
      final imageBytes = await imageFile.readAsBytes();
      return await analyzeClothingImageBytes(imageBytes);
    } catch (e) {
      print('Analyze Image Error: $e');
      return null;
    }
  }

  /// Analyze clothing image from bytes
  Future<Map<String, dynamic>?> analyzeClothingImageBytes(Uint8List imageBytes) async {
    if (!_isInitialized) {
      print('❌ Gemini not initialized - API key may be invalid');
      return null;
    }

    try {
      print('🔍 Starting Gemini analysis... (${imageBytes.length} bytes)');
      
      final prompt = TextPart(AIPrompts.analyzeClothing);
      final imagePart = DataPart('image/jpeg', imageBytes);
      
      final response = await _visionModel.generateContent([
        Content.multi([prompt, imagePart])
      ]).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout - Gemini took too long');
        },
      );

      final text = response.text;
      print('📝 Gemini response: $text');
      
      if (text == null || text.isEmpty) {
        print('❌ Empty response from Gemini');
        return null;
      }

      final result = safeParseJson(text);
      print('✅ Parsed result: $result');
      return result;
    } catch (e) {
      print('❌ Analyze Image Bytes Error: $e');
      return null;
    }
  }

  /// Suggest outfit based on wardrobe and conditions
  Future<Map<String, dynamic>?> suggestOutfit({
    required List<ClothingItem> wardrobe,
    required String weatherContext,
    required String occasion,
  }) async {
    if (!_isInitialized) {
      print('Gemini not initialized');
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
      );

      final response = await _model.generateContent([
        Content.text(prompt)
      ]).timeout(AppConstants.aiTimeout);

      final text = response.text;
      if (text == null || text.isEmpty) {
        print('Empty response from Gemini');
        return null;
      }

      return safeParseJson(text);
    } catch (e) {
      print('Suggest Outfit Error: $e');
      return null;
    }
  }

  /// Evaluate color harmony between two items
  Future<ColorHarmonyResult?> evaluateColorHarmony(
    ClothingItem item1,
    ClothingItem item2,
  ) async {
    if (!_isInitialized) {
      print('Gemini not initialized');
      return null;
    }

    try {
      final prompt = AIPrompts.colorHarmony(
        item1.toAIDescription(),
        item2.toAIDescription(),
      );

      final response = await _model.generateContent([
        Content.text(prompt)
      ]).timeout(AppConstants.aiTimeout);

      final text = response.text;
      if (text == null || text.isEmpty) {
        print('Empty response from Gemini');
        return null;
      }

      final json = safeParseJson(text);
      if (json == null) return null;

      return ColorHarmonyResult.fromJson(json);
    } catch (e) {
      print('Color Harmony Error: $e');
      return null;
    }
  }

  /// Get wardrobe cleanup suggestions
  Future<Map<String, dynamic>?> getCleanupSuggestions(
    List<ClothingItem> wardrobe,
  ) async {
    if (!_isInitialized) {
      print('Gemini not initialized');
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

      final response = await _model.generateContent([
        Content.text(prompt)
      ]).timeout(AppConstants.aiTimeout);

      final text = response.text;
      if (text == null || text.isEmpty) {
        print('Empty response from Gemini');
        return null;
      }

      return safeParseJson(text);
    } catch (e) {
      print('Cleanup Suggestions Error: $e');
      return null;
    }
  }

  }
