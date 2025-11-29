import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../utils/constants.dart';

class WeatherService {
  WeatherInfo? _cachedWeather;
  DateTime? _lastFetchTime;

  /// Get current weather
  Future<WeatherInfo?> getCurrentWeather({
    String city = AppConstants.defaultCity,
    String countryCode = AppConstants.defaultCountryCode,
  }) async {
    // Check cache
    if (_cachedWeather != null && _lastFetchTime != null) {
      final diff = DateTime.now().difference(_lastFetchTime!);
      if (diff < AppConstants.weatherCacheDuration) {
        return _cachedWeather;
      }
    }

    try {
      final apiKey = AppConstants.weatherApiKey;
      if (apiKey.isEmpty || apiKey == 'YOUR_OPENWEATHERMAP_API_KEY') {
        print('Warning: Weather API key not configured');
        return _getDefaultWeather();
      }

      final url = Uri.parse(
        '${AppConstants.weatherBaseUrl}/weather'
        '?q=$city,$countryCode'
        '&appid=$apiKey'
        '&units=metric'
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        _cachedWeather = WeatherInfo.fromJson(json);
        _lastFetchTime = DateTime.now();
        return _cachedWeather;
      } else {
        print('Weather API Error: ${response.statusCode}');
        return _getDefaultWeather();
      }
    } catch (e) {
      print('Weather Service Error: $e');
      return _getDefaultWeather();
    }
  }

  /// Get weather by coordinates
  Future<WeatherInfo?> getWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    try {
      final apiKey = AppConstants.weatherApiKey;
      if (apiKey.isEmpty || apiKey == 'YOUR_OPENWEATHERMAP_API_KEY') {
        return _getDefaultWeather();
      }

      final url = Uri.parse(
        '${AppConstants.weatherBaseUrl}/weather'
        '?lat=$lat&lon=$lon'
        '&appid=$apiKey'
        '&units=metric'
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        _cachedWeather = WeatherInfo.fromJson(json);
        _lastFetchTime = DateTime.now();
        return _cachedWeather;
      } else {
        print('Weather API Error: ${response.statusCode}');
        return _getDefaultWeather();
      }
    } catch (e) {
      print('Weather Service Error: $e');
      return _getDefaultWeather();
    }
  }

  /// Default weather khi không có API key hoặc lỗi
  WeatherInfo _getDefaultWeather() {
    return WeatherInfo(
      temperature: 28,
      feelsLike: 30,
      humidity: 70,
      windSpeed: 3,
      description: 'Partly cloudy',
      icon: '02d',
      cityName: 'Ho Chi Minh City',
      timestamp: DateTime.now(),
    );
  }

  /// Clear cache
  void clearCache() {
    _cachedWeather = null;
    _lastFetchTime = null;
  }
}
