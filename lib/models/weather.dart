/// Model cho thông tin thời tiết
class WeatherInfo {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final String cityName;
  final DateTime timestamp;

  WeatherInfo({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.cityName,
    required this.timestamp,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    final main = json['main'] ?? {};
    final wind = json['wind'] ?? {};
    final weather = (json['weather'] as List?)?.firstOrNull ?? {};

    return WeatherInfo(
      temperature: (main['temp'] ?? 25).toDouble(),
      feelsLike: (main['feels_like'] ?? 25).toDouble(),
      humidity: main['humidity'] ?? 50,
      windSpeed: (wind['speed'] ?? 0).toDouble(),
      description: weather['description'] ?? 'Clear',
      icon: weather['icon'] ?? '01d',
      cityName: json['name'] ?? 'Unknown',
      timestamp: DateTime.now(),
    );
  }

  /// Chuyển nhiệt độ thành mô tả
  String get temperatureDescription {
    if (temperature < 15) return 'Lạnh';
    if (temperature < 22) return 'Mát mẻ';
    if (temperature < 28) return 'Ấm áp';
    if (temperature < 35) return 'Nóng';
    return 'Rất nóng';
  }

  /// Tạo mô tả cho AI
  String toAIDescription() {
    return '''
          Weather: $description
          Temperature: ${temperature.round()}°C (feels like ${feelsLike.round()}°C)
          Humidity: $humidity%
          Wind: ${windSpeed.round()} m/s
          Condition: $temperatureDescription
          ''';
  }

  /// Icon URL
  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  /// Gợi ý từ thời tiết
  List<String> get clothingSuggestions {
    final suggestions = <String>[];

    if (temperature < 15) {
      suggestions.add('Nên mặc áo khoác dày');
      suggestions.add('Có thể cần áo len hoặc hoodie');
    } else if (temperature < 22) {
      suggestions.add('Thời tiết mát, phù hợp áo khoác nhẹ');
    } else if (temperature > 30) {
      suggestions.add('Nên chọn đồ thoáng mát');
      suggestions.add('Ưu tiên chất liệu cotton');
    }

    if (description.toLowerCase().contains('rain')) {
      suggestions.add('Mang theo áo mưa hoặc ô');
    }

    if (windSpeed > 5) {
      suggestions.add('Gió mạnh, tránh đồ quá mỏng');
    }

    return suggestions;
  }
}

/// Forecast cho một ngày cụ thể (dùng cho Plan Ahead)
class ForecastInfo {
  final DateTime targetDate;
  final double minTemp;
  final double maxTemp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final double rainProbability; // 0.0 -> 1.0
  final String description;
  final String icon;
  final String cityName;
  final DateTime generatedAt;
  final int daysAhead;

  ForecastInfo({
    required this.targetDate,
    required this.minTemp,
    required this.maxTemp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.rainProbability,
    required this.description,
    required this.icon,
    required this.cityName,
    required this.generatedAt,
    required this.daysAhead,
  });

  double get avgTemp => (minTemp + maxTemp) / 2;

  int get uncertaintyScore {
    // Forecast xa ngày thì bất định cao hơn.
    final score = 20 + (daysAhead * 12);
    if (score > 95) return 95;
    if (score < 20) return 20;
    return score;
  }

  String get rainDescription {
    final pct = (rainProbability * 100).round();
    if (pct < 20) return 'Khả năng mưa thấp ($pct%)';
    if (pct < 50) return 'Có thể mưa ($pct%)';
    return 'Khả năng mưa cao ($pct%)';
  }

  String toAIDescription() {
    final rainPct = (rainProbability * 100).round();
    return '''
Forecast date: ${targetDate.toIso8601String()}
Location: $cityName
Weather: $description
Temperature range: ${minTemp.round()}-${maxTemp.round()}°C
Feels like: ${feelsLike.round()}°C
Humidity: $humidity%
Wind: ${windSpeed.toStringAsFixed(1)} m/s
Rain probability: $rainPct%
Forecast uncertainty score: $uncertaintyScore/100
''';
  }
}
