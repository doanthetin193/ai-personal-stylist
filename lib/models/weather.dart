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
