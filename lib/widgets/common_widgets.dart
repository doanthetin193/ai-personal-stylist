import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/weather.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';

/// Weather display widget
class WeatherWidget extends StatelessWidget {
  final WeatherInfo weather;
  final bool compact;

  const WeatherWidget({
    super.key,
    required this.weather,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact();
    }
    return _buildFull();
  }

  Widget _buildCompact() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CachedNetworkImage(
            imageUrl: weather.iconUrl,
            width: 32,
            height: 32,
            errorWidget: (_, __, ___) => const Icon(Icons.cloud, size: 24),
          ),
          const SizedBox(width: 8),
          Text(
            formatTemperature(weather.temperature),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            weather.cityName,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFull() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getWeatherColor().withOpacity(0.8),
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
              CachedNetworkImage(
                imageUrl: weather.iconUrl,
                width: 64,
                height: 64,
                errorWidget: (_, __, ___) => const Icon(
                  Icons.cloud,
                  size: 48,
                  color: Colors.white,
                ),
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
                        color: Colors.white.withOpacity(0.9),
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
              _buildInfoChip(Icons.thermostat, 
                  'Cảm giác ${formatTemperature(weather.feelsLike)}'),
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
                color: Colors.white.withOpacity(0.9),
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
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
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
                    color: AppTheme.primaryColor.withOpacity(0.3),
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

/// Filter chip for wardrobe
class FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const FilterChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryColor.withOpacity(0.1) 
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
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
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
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
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor()),
              ),
              Text(
                '$score',
                style: TextStyle(
                  fontSize: size * 0.3,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(),
                ),
              ),
            ],
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(
            label!,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
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
