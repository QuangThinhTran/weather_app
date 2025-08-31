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

    return Container(
      margin: const EdgeInsets.all(ThemeConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(theme),
          const SizedBox(height: ThemeConstants.spacingMedium),
          RepaintBoundary(
            child: SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                cacheExtent: 800.0,
                itemCount: next24Hours.length,
                padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingMedium),
                separatorBuilder: (context, index) => 
                    const SizedBox(width: ThemeConstants.spacingMedium),
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
    );
  }

  List<HourlyForecast> _getNext24Hours(DateTime now, DateTime endTime) {
    return hourlyForecasts
        .where((forecast) => forecast.dateTime.isAfter(now) && forecast.dateTime.isBefore(endTime))
        .take(24)
        .toList();
  }

  Widget _buildHeaderRow(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingMedium),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ThemeConstants.spacingSmall),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusSmall),
            ),
            child: Icon(
              Icons.schedule_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: ThemeConstants.spacingMedium),
          Text(
            'DỰ BÁO THEO GIỜ',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
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
    
    return AnimatedContainer(
      duration: ThemeConstants.animationFast,
      width: 80,
      padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
      decoration: BoxDecoration(
        color: isNow 
            ? Colors.white.withOpacity(0.3)
            : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
        border: Border.all(
          color: isNow 
              ? Colors.white.withOpacity(0.6)
              : Colors.white.withOpacity(0.3),
          width: isNow ? 2 : 1,
        ),
        boxShadow: isNow ? [
          BoxShadow(
            color: Colors.white.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Time
          Text(
            displayTime,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
              color: Colors.white.withOpacity(0.95),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
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
                    color: Colors.lightBlueAccent,
                    fontWeight: FontWeight.w500,
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