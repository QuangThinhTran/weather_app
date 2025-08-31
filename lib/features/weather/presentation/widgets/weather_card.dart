import 'package:flutter/material.dart';
import 'dart:ui';
import '../../domain/entities/weather.dart';
import '../../../../core/widgets/weather_icon.dart';
import '../../../../core/constants/theme_constants.dart';

class WeatherCard extends StatelessWidget {
  final Weather weather;
  final bool isFromCache;
  final bool showOfflineIndicator;

  const WeatherCard({
    super.key,
    required this.weather,
    this.isFromCache = false,
    this.showOfflineIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedContainer(
      duration: ThemeConstants.animationMedium,
      margin: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingMedium,
        vertical: ThemeConstants.spacingSmall,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  ThemeConstants.darkGradientStart,
                  ThemeConstants.darkGradientEnd,
                ]
              : [
                  ThemeConstants.lightGradientStart,
                  ThemeConstants.lightGradientEnd,
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.2),
            blurRadius: ThemeConstants.elevationHigh,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: ThemeConstants.glassBlur,
            sigmaY: ThemeConstants.glassBlur,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isDark ? 0.1 : 0.2),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(ThemeConstants.spacingXLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // City name with enhanced styling
                  _buildCityName(theme, isDark),
                  
                  const SizedBox(height: ThemeConstants.spacingLarge),
                  
                  // Temperature with glow effect
                  _buildTemperature(theme, isDark),
                  
                  const SizedBox(height: ThemeConstants.spacingMedium),
                  
                  // Weather Icon with enhanced styling
                  _buildWeatherIcon(),
                  
                  const SizedBox(height: ThemeConstants.spacingMedium),
                  
                  // Weather condition with better styling
                  _buildWeatherCondition(theme, isDark),
                  
                  // Status indicators with modern design
                  if (showOfflineIndicator || (isFromCache && !showOfflineIndicator))
                    _buildStatusIndicator(theme, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCityName(ThemeData theme, bool isDark) {
    return Text(
      weather.cityName,
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.white,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTemperature(ThemeData theme, bool isDark) {
    return RepaintBoundary(
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.8),
          ],
        ).createShader(bounds),
        child: Text(
          '${weather.temperature.round()}°',
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w200,
            fontSize: 84,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildWeatherIcon() {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.15),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: WeatherIcon(
          iconUrl: weather.iconUrl,
          size: 64,
        ),
      ),
    );
  }

  Widget _buildWeatherCondition(ThemeData theme, bool isDark) {
    return Text(
      weather.condition,
      style: theme.textTheme.titleMedium?.copyWith(
        color: Colors.white.withOpacity(0.9),
        fontWeight: FontWeight.w500,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStatusIndicator(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: ThemeConstants.spacingLarge),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacingMedium,
          vertical: ThemeConstants.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: showOfflineIndicator
              ? Colors.red.withOpacity(0.2)
              : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
          border: Border.all(
            color: showOfflineIndicator
                ? Colors.red.withOpacity(0.4)
                : Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              showOfflineIndicator ? Icons.cloud_off_rounded : Icons.cached_rounded,
              size: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(width: ThemeConstants.spacingSmall),
            Text(
              showOfflineIndicator ? 'Dữ liệu Offline' : 'Dữ liệu Cache',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}