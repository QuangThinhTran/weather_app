import 'package:flutter/material.dart';
import '../../domain/entities/weather.dart';
import '../../../../core/constants/theme_constants.dart';

class WeatherDetailsSection extends StatelessWidget {
  final Weather weather;

  const WeatherDetailsSection({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingMedium,
        vertical: ThemeConstants.spacingSmall,
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
        child: Column(
          children: [
            // Row 1: Sunrise/Sunset
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem(
                  context,
                  icon: '🌅',
                  label: 'Bình minh',
                  value: weather.sunrise ?? '--:--',
                ),
                _buildDetailItem(
                  context,
                  icon: '🌇',
                  label: 'Hoàng hôn', 
                  value: weather.sunset ?? '--:--',
                ),
              ],
            ),
            
            const SizedBox(height: ThemeConstants.spacingMedium),
            
            // Row 2: Wind/Humidity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem(
                  context,
                  icon: '💨',
                  label: 'Tốc độ gió',
                  value: '${weather.windSpeed.round()} km/h',
                ),
                _buildDetailItem(
                  context,
                  icon: '💧',
                  label: 'Độ ẩm',
                  value: '${weather.humidity}%',
                ),
              ],
            ),
            
            const SizedBox(height: ThemeConstants.spacingMedium),
            
            // Row 3: Feels like/UV
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem(
                  context,
                  icon: '🌡',
                  label: 'Cảm giác như',
                  value: '${weather.feelsLike.round()}°',
                ),
                _buildDetailItem(
                  context,
                  icon: 'UV',
                  label: _getUVDescription(weather.uvIndex),
                  value: weather.uvIndex.round().toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon == 'UV')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getUVColor(double.tryParse(value) ?? 0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    icon,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                Text(
                  icon,
                  style: const TextStyle(fontSize: 18),
                ),
              const SizedBox(width: ThemeConstants.spacingSmall),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeConstants.spacingXSmall),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getUVDescription(double uvIndex) {
    if (uvIndex <= 2) return 'Thấp';
    if (uvIndex <= 5) return 'Trung bình';
    if (uvIndex <= 7) return 'Cao';
    if (uvIndex <= 10) return 'Rất cao';
    return 'Cực cao';
  }

  Color _getUVColor(double uvIndex) {
    if (uvIndex <= 2) return Colors.green;
    if (uvIndex <= 5) return Colors.yellow.shade700;
    if (uvIndex <= 7) return Colors.orange;
    if (uvIndex <= 10) return Colors.red;
    return Colors.purple;
  }
}