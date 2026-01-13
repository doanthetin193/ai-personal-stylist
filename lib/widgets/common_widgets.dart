import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';

/// Weather display widget
class WeatherWidget extends StatelessWidget {
  final WeatherInfo weather;

  const WeatherWidget({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getWeatherColor().withValues(alpha: 0.8),
            _getWeatherColor(),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.network(
                weather.iconUrl,
                width: 64,
                height: 64,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.cloud, size: 48, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatTemperature(weather.temperature),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      weather.cityName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                Icons.thermostat,
                'Cảm giác ${formatTemperature(weather.feelsLike)}',
              ),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.water_drop, '${weather.humidity}%'),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.air, '${weather.windSpeed.round()} m/s'),
            ],
          ),
          if (weather.clothingSuggestions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              weather.clothingSuggestions.first,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }

  Color _getWeatherColor() {
    final temp = weather.temperature;
    if (temp < 15) return const Color(0xFF5B86E5);
    if (temp < 22) return const Color(0xFF36D1DC);
    if (temp < 28) return const Color(0xFF56CCF2);
    if (temp < 35) return const Color(0xFFF2994A);
    return const Color(0xFFEB5757);
  }
}

/// Occasion selector chip
class OccasionChip extends StatelessWidget {
  final String id;
  final String name;
  final String icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const OccasionChip({
    super.key,
    required this.id,
    required this.name,
    required this.icon,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

/// Score display widget
class ScoreDisplay extends StatelessWidget {
  final int score;
  final String? label;
  final double size;

  const ScoreDisplay({
    super.key,
    required this.score,
    this.label,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getScoreColor().withValues(alpha: 0.1),
            border: Border.all(color: _getScoreColor(), width: 3),
          ),
          child: Center(
            child: Text(
              '$score',
              style: TextStyle(
                fontSize: size * 0.35,
                fontWeight: FontWeight.bold,
                color: _getScoreColor(),
              ),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(
            label!,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ],
    );
  }

  Color _getScoreColor() {
    if (score >= 80) return AppTheme.successColor;
    if (score >= 60) return AppTheme.accentColor;
    if (score >= 40) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}
