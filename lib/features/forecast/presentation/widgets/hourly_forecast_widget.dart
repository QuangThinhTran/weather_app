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
    // Get next 24 hours starting from current hour
    final now = DateTime.now();
    final next24Hours = hourlyForecasts
        .where((forecast) => 
            forecast.dateTime.isAfter(now) && 
            forecast.dateTime.isBefore(now.add(const Duration(hours: 24))))
        .take(24)
        .toList();

    if (next24Hours.isEmpty) {
      return const SizedBox.shrink();
    }

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
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: ThemeConstants.spacingSmall),
                Text(
                  'DỰ BÁO THEO GIỜ',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeConstants.spacingMedium),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: next24Hours.length,
                separatorBuilder: (context, index) => 
                    const SizedBox(width: ThemeConstants.spacingSmall),
                itemBuilder: (context, index) {
                  final forecast = next24Hours[index];
                  final isNow = index == 0;
                  
                  return GestureDetector(
                    onTap: () => _showDetailedWeather(context, forecast),
                    child: _buildHourlyItem(context, forecast, isNow),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailedWeather(BuildContext context, HourlyForecast selectedHour) {
    // Get hourly forecasts for the selected day
    final selectedDate = selectedHour.dateTime;
    final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final dayHourlyForecasts = hourlyForecasts
        .where((forecast) => 
            forecast.dateTime.isAfter(startOfDay.subtract(const Duration(minutes: 1))) &&
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

  Widget _buildHourlyItem(BuildContext context, HourlyForecast forecast, bool isNow) {
    final timeFormat = DateFormat('HH:mm');
    final displayTime = isNow ? 'Bây giờ' : timeFormat.format(forecast.dateTime);
    
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(
        vertical: ThemeConstants.spacingSmall,
        horizontal: ThemeConstants.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: isNow 
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusSmall),
        border: isNow 
            ? Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Time
          Text(
            displayTime,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: isNow ? FontWeight.w600 : FontWeight.normal,
              color: isNow 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          
          // Weather icon
          WeatherIcon(
            iconUrl: forecast.iconUrl,
            size: 28,
          ),
          
          // Temperature
          Text(
            '${forecast.temperature.round()}°',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isNow 
                  ? Theme.of(context).colorScheme.primary
                  : null,
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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