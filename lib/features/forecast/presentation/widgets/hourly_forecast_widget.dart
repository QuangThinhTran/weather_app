import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/forecast.dart';
import '../../../weather/domain/entities/weather.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/widgets/weather_icon.dart';
import 'detailed_weather_bottom_sheet.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<HourlyForecast> hourlyForecasts;
  final Weather? currentWeather;

  const HourlyForecastWidget({
    super.key,
    required this.hourlyForecasts,
    this.currentWeather,
  });

  @override
  Widget build(BuildContext context) {
    // Get next 24 hours starting from current hour (cached computation)
    final now = DateTime.now();
    final endTime = now.add(const Duration(hours: 24));
    final next24Hours = _getNext24Hours(now, endTime);

    if (next24Hours.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingMedium,
        vertical: ThemeConstants.spacingSmall,
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderRow(theme),
            const SizedBox(height: ThemeConstants.spacingMedium),
            RepaintBoundary(
              child: SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  cacheExtent: 800.0,
                  itemCount: next24Hours.length,
                  separatorBuilder: (context, index) => 
                      const SizedBox(width: ThemeConstants.spacingSmall),
                  itemBuilder: (context, index) {
                    final forecast = next24Hours[index];
                    final isNow = index == 0;
                    
                    return RepaintBoundary(
                      child: GestureDetector(
                        onTap: () => _showDetailedWeather(context, forecast),
                        child: _buildHourlyItem(theme, forecast, isNow),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<HourlyForecast> _getNext24Hours(DateTime now, DateTime endTime) {
    return hourlyForecasts
        .where((forecast) => forecast.dateTime.isAfter(now) && forecast.dateTime.isBefore(endTime))
        .take(24)
        .toList();
  }

  Widget _buildHeaderRow(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.schedule,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: ThemeConstants.spacingSmall),
        Text(
          'DỰ BÁO THEO GIỜ',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  void _showDetailedWeather(BuildContext context, HourlyForecast selectedHour) {
    // Get hourly forecasts for the selected day (optimized)
    final selectedDate = selectedHour.dateTime;
    final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final startOfDayMinusOne = startOfDay.subtract(const Duration(minutes: 1));
    
    final dayHourlyForecasts = hourlyForecasts
        .where((forecast) => 
            forecast.dateTime.isAfter(startOfDayMinusOne) &&
            forecast.dateTime.isBefore(endOfDay))
        .toList();
    
    final timeFormat = DateFormat('HH:mm');
    final displayTime = timeFormat.format(selectedHour.dateTime);
    
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DetailedWeatherBottomSheet(
        currentWeather: currentWeather,
        hourlyForecasts: dayHourlyForecasts,
        selectedHour: selectedHour,
        title: 'Chi tiết lúc $displayTime',
      ),
    );
  }

  Widget _buildHourlyItem(ThemeData theme, HourlyForecast forecast, bool isNow) {
    final timeFormat = DateFormat('HH:mm');
    final displayTime = isNow ? 'Bây giờ' : timeFormat.format(forecast.dateTime);
    
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(
        vertical: ThemeConstants.spacingSmall,
        horizontal: ThemeConstants.spacingXSmall,
      ),
      decoration: isNow ? BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusSmall),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ) : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Time
          Text(
            displayTime,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: isNow ? FontWeight.w600 : FontWeight.normal,
              color: isNow 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          
          // Weather icon
          RepaintBoundary(
            child: WeatherIcon(
              iconUrl: forecast.iconUrl,
              size: 28,
            ),
          ),
          
          // Temperature
          Text(
            '${forecast.temperature.round()}°',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isNow ? theme.colorScheme.primary : null,
            ),
          ),
          
          // Precipitation chance
          if (forecast.precipitationChance > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.water_drop,
                  size: 10,
                  color: Colors.blue.shade400,
                ),
                const SizedBox(width: 2),
                Text(
                  '${forecast.precipitationChance}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: Colors.blue.shade400,
                  ),
                ),
              ],
            )
          else
            const SizedBox(height: 12), // Maintain consistent height
        ],
      ),
    );
  }
}