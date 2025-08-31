import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: ThemeConstants.spacingMedium),
            Text(
              'Oops! Có lỗi xảy ra',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeConstants.spacingSmall),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: ThemeConstants.spacingLarge),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử Lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class WeatherErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool showLocationButton;
  final VoidCallback? onUseLocation;

  const WeatherErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.showLocationButton = false,
    this.onUseLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: ThemeConstants.spacingMedium),
            Text(
              'Không Có Dữ Liệu Thời Tiết',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeConstants.spacingSmall),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeConstants.spacingLarge),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onRetry != null) ...[
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử Lại'),
                  ),
                  if (showLocationButton && onUseLocation != null)
                    const SizedBox(width: ThemeConstants.spacingMedium),
                ],
                if (showLocationButton && onUseLocation != null)
                  OutlinedButton.icon(
                    onPressed: onUseLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Dùng Vị Trí'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}