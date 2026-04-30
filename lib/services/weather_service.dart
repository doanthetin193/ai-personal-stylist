import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../utils/constants.dart';

class WeatherService {
  WeatherInfo? _cachedWeather;
  DateTime? _lastFetchTime;
  final Map<String, ForecastInfo> _forecastCache = {};
  final Map<String, DateTime> _forecastCacheTime = {};

  /// Get current weather
  Future<WeatherInfo?> getCurrentWeather({
    String city = AppConstants.defaultCity,
    String countryCode = AppConstants.defaultCountryCode,
  }) async {
    final normalizedCity = _normalizeCityInput(city);

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
        '?q=$normalizedCity,$countryCode'
        '&appid=$apiKey'
        '&units=metric',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

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
      cityName: AppConstants.defaultCity,
      timestamp: DateTime.now(),
    );
  }

  /// Clear cache
  void clearCache() {
    _cachedWeather = null;
    _lastFetchTime = null;
    _forecastCache.clear();
    _forecastCacheTime.clear();
  }

  /// Get forecast cho một ngày cụ thể (OpenWeather 5-day / 3-hour)
  Future<ForecastInfo?> getForecastForDate({
    required DateTime targetDate,
    String city = AppConstants.defaultCity,
    String countryCode = AppConstants.defaultCountryCode,
  }) async {
    final normalizedCity = _normalizeCityInput(city);
    final dayOnly = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final cacheKey =
        '${normalizedCity.toLowerCase()}_${countryCode.toLowerCase()}_${dayOnly.toIso8601String()}';

    final cached = _forecastCache[cacheKey];
    final cachedAt = _forecastCacheTime[cacheKey];
    if (cached != null && cachedAt != null) {
      final diff = DateTime.now().difference(cachedAt);
      if (diff < AppConstants.weatherCacheDuration) {
        return cached;
      }
    }

    try {
      final apiKey = AppConstants.weatherApiKey;
      if (apiKey.isEmpty || apiKey == 'YOUR_OPENWEATHERMAP_API_KEY') {
        final current = await getCurrentWeather(
          city: normalizedCity,
          countryCode: countryCode,
        );
        if (current == null) return null;

        return ForecastInfo(
          targetDate: dayOnly,
          minTemp: current.temperature - 1,
          maxTemp: current.temperature + 1,
          feelsLike: current.feelsLike,
          humidity: current.humidity,
          windSpeed: current.windSpeed,
          rainProbability: current.description.toLowerCase().contains('rain')
              ? 0.7
              : 0.2,
          description: current.description,
          icon: current.icon,
          cityName: current.cityName,
          generatedAt: DateTime.now(),
          daysAhead: dayOnly.difference(DateTime.now()).inDays,
        );
      }

      final now = DateTime.now();
      final maxAllowedDate = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 7));
      if (dayOnly.isAfter(maxAllowedDate)) {
        return null;
      }

      final url = Uri.parse(
        '${AppConstants.weatherBaseUrl}/forecast'
        '?q=$normalizedCity,$countryCode'
        '&appid=$apiKey'
        '&units=metric',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        print('Forecast API Error: ${response.statusCode}');
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final entries = (json['list'] as List<dynamic>? ?? [])
          .map(_asStringKeyMap)
          .where((entry) => entry.isNotEmpty)
          .toList();

      if (entries.isEmpty) return null;

      final sameDayEntries = entries.where((entry) {
        final dt = DateTime.fromMillisecondsSinceEpoch(
          ((entry['dt'] ?? 0) as num).toInt() * 1000,
          isUtc: true,
        ).toLocal();

        return dt.year == dayOnly.year &&
            dt.month == dayOnly.month &&
            dt.day == dayOnly.day;
      }).toList();

      final sourceEntries = sameDayEntries.isNotEmpty
          ? sameDayEntries
          : _pickNearestDayEntries(entries, dayOnly);

      if (sourceEntries.isEmpty) return null;

      final temps = sourceEntries
          .map(
            (e) => _readNestedNum(
              e,
              parentKey: 'main',
              key: 'temp',
              fallback: 25.0,
            ),
          )
          .toList();
      final feels = sourceEntries
          .map(
            (e) => _readNestedNum(
              e,
              parentKey: 'main',
              key: 'feels_like',
              fallback: 25.0,
            ),
          )
          .toList();
      final humidities = sourceEntries
          .map(
            (e) => _readNestedNum(
              e,
              parentKey: 'main',
              key: 'humidity',
              fallback: 60.0,
            ),
          )
          .toList();
      final winds = sourceEntries
          .map(
            (e) => _readNestedNum(
              e,
              parentKey: 'wind',
              key: 'speed',
              fallback: 0.0,
            ),
          )
          .toList();
      final pops = sourceEntries
          .map((e) => _readNum(e['pop'], fallback: 0.0))
          .toList();

      final weatherList = sourceEntries.first['weather'] as List<dynamic>?;
      final firstWeather = weatherList != null && weatherList.isNotEmpty
          ? _asStringKeyMap(weatherList.first)
          : <String, dynamic>{};
      final cityName =
          ((_asStringKeyMap(json['city']))['name'] ?? normalizedCity)
              .toString();

      final forecast = ForecastInfo(
        targetDate: dayOnly,
        minTemp: temps.reduce((a, b) => a < b ? a : b),
        maxTemp: temps.reduce((a, b) => a > b ? a : b),
        feelsLike: _avg(feels),
        humidity: _avg(humidities).round(),
        windSpeed: _avg(winds),
        rainProbability: pops.isEmpty
            ? 0.0
            : pops.reduce((a, b) => a > b ? a : b).clamp(0.0, 1.0),
        description: (firstWeather['description'] ?? 'Clear').toString(),
        icon: (firstWeather['icon'] ?? '01d').toString(),
        cityName: cityName,
        generatedAt: DateTime.now(),
        daysAhead: dayOnly
            .difference(DateTime(now.year, now.month, now.day))
            .inDays,
      );

      _forecastCache[cacheKey] = forecast;
      _forecastCacheTime[cacheKey] = DateTime.now();
      return forecast;
    } catch (e) {
      print('Forecast Service Error: $e');
      return null;
    }
  }

  List<Map<String, dynamic>> _pickNearestDayEntries(
    List<Map<String, dynamic>> entries,
    DateTime targetDay,
  ) {
    entries.sort((a, b) {
      final aDt = DateTime.fromMillisecondsSinceEpoch(
        ((a['dt'] ?? 0) as num).toInt() * 1000,
        isUtc: true,
      ).toLocal();
      final bDt = DateTime.fromMillisecondsSinceEpoch(
        ((b['dt'] ?? 0) as num).toInt() * 1000,
        isUtc: true,
      ).toLocal();

      final aDiff = aDt.difference(targetDay).inHours.abs();
      final bDiff = bDt.difference(targetDay).inHours.abs();
      return aDiff.compareTo(bDiff);
    });

    return entries.take(3).toList();
  }

  double _avg(List<double> values) {
    if (values.isEmpty) return 0;
    final sum = values.fold<double>(0, (p, e) => p + e);
    return sum / values.length;
  }

  Map<String, dynamic> _asStringKeyMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }

    return <String, dynamic>{};
  }

  double _readNum(dynamic value, {required double fallback}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  double _readNestedNum(
    Map<String, dynamic> source, {
    required String parentKey,
    required String key,
    required double fallback,
  }) {
    final parentMap = _asStringKeyMap(source[parentKey]);
    return _readNum(parentMap[key], fallback: fallback);
  }

  String _normalizeCityInput(String city) {
    final cleaned = city.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) return AppConstants.defaultCity;

    final normalized = _stripDiacritics(cleaned).toLowerCase();
    const aliases = <String, String>{
      'qui nhon': 'Quy Nhon',
      'quinhon': 'Quy Nhon',
      'quy nhon': 'Quy Nhon',
      'tp hcm': 'Ho Chi Minh City',
      'tphcm': 'Ho Chi Minh City',
      'hcm': 'Ho Chi Minh City',
      'sai gon': 'Ho Chi Minh City',
      'saigon': 'Ho Chi Minh City',
      'ha noi': 'Ha Noi',
      'hanoi': 'Ha Noi',
      'da nang': 'Da Nang',
      'danang': 'Da Nang',
    };

    return aliases[normalized] ?? cleaned;
  }

  String _stripDiacritics(String input) {
    final map = <String, String>{
      'à': 'a',
      'á': 'a',
      'ạ': 'a',
      'ả': 'a',
      'ã': 'a',
      'â': 'a',
      'ầ': 'a',
      'ấ': 'a',
      'ậ': 'a',
      'ẩ': 'a',
      'ẫ': 'a',
      'ă': 'a',
      'ằ': 'a',
      'ắ': 'a',
      'ặ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'è': 'e',
      'é': 'e',
      'ẹ': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ê': 'e',
      'ề': 'e',
      'ế': 'e',
      'ệ': 'e',
      'ể': 'e',
      'ễ': 'e',
      'ì': 'i',
      'í': 'i',
      'ị': 'i',
      'ỉ': 'i',
      'ĩ': 'i',
      'ò': 'o',
      'ó': 'o',
      'ọ': 'o',
      'ỏ': 'o',
      'õ': 'o',
      'ô': 'o',
      'ồ': 'o',
      'ố': 'o',
      'ộ': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ơ': 'o',
      'ờ': 'o',
      'ớ': 'o',
      'ợ': 'o',
      'ở': 'o',
      'ỡ': 'o',
      'ù': 'u',
      'ú': 'u',
      'ụ': 'u',
      'ủ': 'u',
      'ũ': 'u',
      'ư': 'u',
      'ừ': 'u',
      'ứ': 'u',
      'ự': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ỳ': 'y',
      'ý': 'y',
      'ỵ': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'đ': 'd',
      'À': 'A',
      'Á': 'A',
      'Ạ': 'A',
      'Ả': 'A',
      'Ã': 'A',
      'Â': 'A',
      'Ầ': 'A',
      'Ấ': 'A',
      'Ậ': 'A',
      'Ẩ': 'A',
      'Ẫ': 'A',
      'Ă': 'A',
      'Ằ': 'A',
      'Ắ': 'A',
      'Ặ': 'A',
      'Ẳ': 'A',
      'Ẵ': 'A',
      'È': 'E',
      'É': 'E',
      'Ẹ': 'E',
      'Ẻ': 'E',
      'Ẽ': 'E',
      'Ê': 'E',
      'Ề': 'E',
      'Ế': 'E',
      'Ệ': 'E',
      'Ể': 'E',
      'Ễ': 'E',
      'Ì': 'I',
      'Í': 'I',
      'Ị': 'I',
      'Ỉ': 'I',
      'Ĩ': 'I',
      'Ò': 'O',
      'Ó': 'O',
      'Ọ': 'O',
      'Ỏ': 'O',
      'Õ': 'O',
      'Ô': 'O',
      'Ồ': 'O',
      'Ố': 'O',
      'Ộ': 'O',
      'Ổ': 'O',
      'Ỗ': 'O',
      'Ơ': 'O',
      'Ờ': 'O',
      'Ớ': 'O',
      'Ợ': 'O',
      'Ở': 'O',
      'Ỡ': 'O',
      'Ù': 'U',
      'Ú': 'U',
      'Ụ': 'U',
      'Ủ': 'U',
      'Ũ': 'U',
      'Ư': 'U',
      'Ừ': 'U',
      'Ứ': 'U',
      'Ự': 'U',
      'Ử': 'U',
      'Ữ': 'U',
      'Ỳ': 'Y',
      'Ý': 'Y',
      'Ỵ': 'Y',
      'Ỷ': 'Y',
      'Ỹ': 'Y',
      'Đ': 'D',
    };

    final buffer = StringBuffer();
    for (final char in input.split('')) {
      buffer.write(map[char] ?? char);
    }
    return buffer.toString();
  }
}
