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
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingMedium,
        vertical: ThemeConstants.spacingSmall,
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
        child: Column(
          children: [
            // City name - centered, large
            Text(
              weather.cityName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: ThemeConstants.spacingMedium),
            
            // Temperature - very large, centered
            Text(
              '${weather.temperature.round()}°C',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w300,
                fontSize: 72,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: ThemeConstants.spacingSmall),
            
            // Weather Icon - centered, large
            Center(
              child: WeatherIcon(
                iconUrl: weather.iconUrl,
                size: 80,
              ),
            ),
            
            const SizedBox(height: ThemeConstants.spacingSmall),
            
            // Weather condition - centered
            Text(
              weather.condition,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            
            // Show offline indicator if needed
            if (showOfflineIndicator)
              Padding(
                padding: const EdgeInsets.only(top: ThemeConstants.spacingMedium),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConstants.spacingSmall,
                    vertical: ThemeConstants.spacingXSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_off,
                        size: 16,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: ThemeConstants.spacingXSmall),
                      Text(
                        'Offline Data',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Show cache indicator if needed
            if (isFromCache && !showOfflineIndicator)
              Padding(
                padding: const EdgeInsets.only(top: ThemeConstants.spacingMedium),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConstants.spacingSmall,
                    vertical: ThemeConstants.spacingXSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cached,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: ThemeConstants.spacingXSmall),
                      Text(
                        'Cached Data',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}