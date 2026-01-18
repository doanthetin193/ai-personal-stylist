import 'package:flutter_test/flutter_test.dart';
import 'package:ai_personal_stylist/models/weather.dart';

void main() {
  group('WeatherInfo', () {
    test('fromJson creates WeatherInfo from OpenWeatherMap API response', () {
      final json = {
        'main': {'temp': 28.5, 'feels_like': 30.2, 'humidity': 75},
        'wind': {'speed': 3.5},
        'weather': [
          {'description': 'scattered clouds', 'icon': '03d'},
        ],
        'name': 'Ho Chi Minh City',
      };

      final weather = WeatherInfo.fromJson(json);

      expect(weather.temperature, 28.5);
      expect(weather.feelsLike, 30.2);
      expect(weather.humidity, 75);
      expect(weather.windSpeed, 3.5);
      expect(weather.description, 'scattered clouds');
      expect(weather.icon, '03d');
      expect(weather.cityName, 'Ho Chi Minh City');
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final weather = WeatherInfo.fromJson(json);

      expect(weather.temperature, 25.0);
      expect(weather.feelsLike, 25.0);
      expect(weather.humidity, 50);
      expect(weather.windSpeed, 0.0);
      expect(weather.description, 'Clear');
      expect(weather.icon, '01d');
      expect(weather.cityName, 'Unknown');
    });

    test('temperatureDescription returns correct Vietnamese description', () {
      // Cold
      final cold = WeatherInfo(
        temperature: 10,
        feelsLike: 8,
        humidity: 80,
        windSpeed: 2,
        description: 'cloudy',
        icon: '04d',
        cityName: 'Hanoi',
        timestamp: DateTime.now(),
      );
      expect(cold.temperatureDescription, 'Lạnh');

      // Cool
      final cool = WeatherInfo(
        temperature: 20,
        feelsLike: 19,
        humidity: 70,
        windSpeed: 3,
        description: 'clear',
        icon: '01d',
        cityName: 'Dalat',
        timestamp: DateTime.now(),
      );
      expect(cool.temperatureDescription, 'Mát mẻ');

      // Warm
      final warm = WeatherInfo(
        temperature: 26,
        feelsLike: 27,
        humidity: 65,
        windSpeed: 2,
        description: 'sunny',
        icon: '01d',
        cityName: 'HCMC',
        timestamp: DateTime.now(),
      );
      expect(warm.temperatureDescription, 'Ấm áp');

      // Hot
      final hot = WeatherInfo(
        temperature: 32,
        feelsLike: 35,
        humidity: 60,
        windSpeed: 1,
        description: 'hot',
        icon: '01d',
        cityName: 'HCMC',
        timestamp: DateTime.now(),
      );
      expect(hot.temperatureDescription, 'Nóng');

      // Very hot
      final veryHot = WeatherInfo(
        temperature: 38,
        feelsLike: 42,
        humidity: 50,
        windSpeed: 0,
        description: 'extreme heat',
        icon: '01d',
        cityName: 'HCMC',
        timestamp: DateTime.now(),
      );
      expect(veryHot.temperatureDescription, 'Rất nóng');
    });

    test('toAIDescription contains all weather info', () {
      final weather = WeatherInfo(
        temperature: 28,
        feelsLike: 30,
        humidity: 75,
        windSpeed: 3,
        description: 'partly cloudy',
        icon: '02d',
        cityName: 'HCMC',
        timestamp: DateTime.now(),
      );

      final description = weather.toAIDescription();

      expect(description.contains('partly cloudy'), true);
      expect(description.contains('28'), true);
      expect(description.contains('30'), true);
      expect(description.contains('75'), true);
      expect(description.contains('3'), true);
    });

    test('iconUrl returns correct OpenWeatherMap URL', () {
      final weather = WeatherInfo(
        temperature: 28,
        feelsLike: 30,
        humidity: 75,
        windSpeed: 3,
        description: 'clear',
        icon: '01d',
        cityName: 'HCMC',
        timestamp: DateTime.now(),
      );

      expect(weather.iconUrl, 'https://openweathermap.org/img/wn/01d@2x.png');
    });

    test('clothingSuggestions returns tips for cold weather', () {
      final cold = WeatherInfo(
        temperature: 12,
        feelsLike: 10,
        humidity: 80,
        windSpeed: 2,
        description: 'cloudy',
        icon: '04d',
        cityName: 'Hanoi',
        timestamp: DateTime.now(),
      );

      final suggestions = cold.clothingSuggestions;

      expect(suggestions.isNotEmpty, true);
      expect(suggestions.any((s) => s.contains('áo khoác')), true);
    });

    test('clothingSuggestions returns tips for rainy weather', () {
      final rainy = WeatherInfo(
        temperature: 25,
        feelsLike: 26,
        humidity: 90,
        windSpeed: 5,
        description: 'light rain',
        icon: '10d',
        cityName: 'HCMC',
        timestamp: DateTime.now(),
      );

      final suggestions = rainy.clothingSuggestions;

      expect(
        suggestions.any((s) => s.contains('mưa') || s.contains('ô')),
        true,
      );
    });

    test('clothingSuggestions returns tips for windy weather', () {
      final windy = WeatherInfo(
        temperature: 25,
        feelsLike: 23,
        humidity: 60,
        windSpeed: 8,
        description: 'windy',
        icon: '03d',
        cityName: 'HCMC',
        timestamp: DateTime.now(),
      );

      final suggestions = windy.clothingSuggestions;

      expect(suggestions.any((s) => s.contains('Gió')), true);
    });
  });
}
