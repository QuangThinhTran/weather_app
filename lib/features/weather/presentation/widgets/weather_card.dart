import 'package:flutter/material.dart';
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
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingMedium,
        vertical: ThemeConstants.spacingSmall,
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // City name - optimized text rendering
            _buildCityName(theme),
            
            const SizedBox(height: ThemeConstants.spacingMedium),
            
            // Temperature - optimized large text
            _buildTemperature(theme),
            
            const SizedBox(height: ThemeConstants.spacingSmall),
            
            // Weather Icon - optimized rendering
            _buildWeatherIcon(),
            
            const SizedBox(height: ThemeConstants.spacingSmall),
            
            // Weather condition - optimized text
            _buildWeatherCondition(theme),
            
            // Status indicators - optimized rendering
            if (showOfflineIndicator || (isFromCache && !showOfflineIndicator))
              _buildStatusIndicator(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCityName(ThemeData theme) {
    return Text(
      weather.cityName,
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTemperature(ThemeData theme) {
    return RepaintBoundary(
      child: Text(
        '${weather.temperature.round()}°C',
        style: theme.textTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.w300,
          fontSize: 72,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildWeatherIcon() {
    return RepaintBoundary(
      child: WeatherIcon(
        iconUrl: weather.iconUrl,
        size: 80,
      ),
    );
  }

  Widget _buildWeatherCondition(ThemeData theme) {
    return Text(
      weather.condition,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.8),
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStatusIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: ThemeConstants.spacingMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacingSmall,
          vertical: ThemeConstants.spacingXSmall,
        ),
        decoration: BoxDecoration(
          color: showOfflineIndicator
              ? theme.colorScheme.errorContainer
              : theme.colorScheme.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(ThemeConstants.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              showOfflineIndicator ? Icons.cloud_off : Icons.cached,
              size: 16,
              color: showOfflineIndicator
                  ? theme.colorScheme.error
                  : theme.colorScheme.secondary,
            ),
            const SizedBox(width: ThemeConstants.spacingXSmall),
            Text(
              showOfflineIndicator ? 'Offline Data' : 'Cached Data',
              style: theme.textTheme.bodySmall?.copyWith(
                color: showOfflineIndicator
                    ? theme.colorScheme.error
                    : theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}