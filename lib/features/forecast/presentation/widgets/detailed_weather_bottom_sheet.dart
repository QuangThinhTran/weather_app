import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/forecast.dart';
import '../../../weather/domain/entities/weather.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/widgets/weather_icon.dart';
import '../../../weather/presentation/widgets/weather_advice_widget.dart';
import '../../../../core/services/weather_advice_service.dart';

class DetailedWeatherBottomSheet extends StatelessWidget {
  final Weather? currentWeather;
  final List<HourlyForecast> hourlyForecasts;
  final DailyForecast? selectedDay;
  final HourlyForecast? selectedHour;
  final String title;

  const DetailedWeatherBottomSheet({
    super.key,
    this.currentWeather,
    required this.hourlyForecasts,
    this.selectedDay,
    this.selectedHour,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with drag handle
              Container(
                padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: ThemeConstants.spacingMedium),
                    
                    // Title and close button
                    Row(
                      children: [
                        Icon(
                          Icons.cloud,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: ThemeConstants.spacingSmall),
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    ThemeConstants.spacingMedium,
                    0,
                    ThemeConstants.spacingMedium,
                    ThemeConstants.spacingXLarge,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Temperature curve chart
                      _buildTemperatureChart(context),
                      const SizedBox(height: ThemeConstants.spacingLarge),
                      
                      // Precipitation probability chart  
                      _buildPrecipitationChart(context),
                      const SizedBox(height: ThemeConstants.spacingLarge),
                      
                      // Rainfall summary
                      _buildRainfallSummary(context),
                      const SizedBox(height: ThemeConstants.spacingLarge),
                      
                      // Weather advice for selected day/hour
                      _buildWeatherAdviceSection(context),
                      const SizedBox(height: ThemeConstants.spacingLarge),
                      
                      // Additional details
                      _buildAdditionalDetails(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTemperatureChart(BuildContext context) {
    if (hourlyForecasts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đường cong nhiệt độ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: ThemeConstants.spacingMedium),
              Container(
                height: 120,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.thermostat,
                        size: 32,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Không có dữ liệu theo giờ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
    
    final List<FlSpot> temperatureSpots = [];
    final List<HourlyIconData> iconData = [];
    
    // Get hourly data - use selected day's data or next 24 hours
    final List<HourlyForecast> displayHours;
    if (selectedDay != null) {
      // Show data for the selected day
      final selectedDate = selectedDay!.date;
      final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      displayHours = hourlyForecasts
          .where((forecast) => 
              forecast.dateTime.isAfter(startOfDay.subtract(const Duration(minutes: 1))) &&
              forecast.dateTime.isBefore(endOfDay))
          .toList();
    } else if (selectedHour != null) {
      // Show data for the selected hour's day
      final selectedDate = selectedHour!.dateTime;
      final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      displayHours = hourlyForecasts
          .where((forecast) => 
              forecast.dateTime.isAfter(startOfDay.subtract(const Duration(minutes: 1))) &&
              forecast.dateTime.isBefore(endOfDay))
          .toList();
    } else {
      // Default: next 24 hours
      final now = DateTime.now();
      displayHours = hourlyForecasts
          .where((forecast) => 
              forecast.dateTime.isAfter(now) && 
              forecast.dateTime.isBefore(now.add(const Duration(hours: 24))))
          .take(24)
          .toList();
    }
    
    // If no hourly data for selected period, show message
    if (displayHours.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đường cong nhiệt độ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: ThemeConstants.spacingMedium),
              Container(
                height: 120,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.thermostat,
                        size: 32,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedDay != null 
                            ? 'Không có dữ liệu cho ngày này'
                            : 'Không có dữ liệu theo giờ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
    
    final next24Hours = displayHours;
    
    for (int i = 0; i < next24Hours.length; i++) {
      final forecast = next24Hours[i];
      temperatureSpots.add(FlSpot(i.toDouble(), forecast.temperature));
      iconData.add(HourlyIconData(
        hour: i.toDouble(),
        temperature: forecast.temperature,
        iconUrl: forecast.iconUrl,
      ));
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đường cong nhiệt độ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingMedium),
            
            Container(
              height: 180,
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeConstants.spacingSmall,
                vertical: ThemeConstants.spacingSmall,
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                      strokeWidth: 0.5,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 5,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            '${value.round()}°',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: 6,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${value.round()}h',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: temperatureSpots,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.orange.shade400,
                          Colors.orange.shade600,
                        ],
                      ),
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 3,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Colors.orange.shade500,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.orange.shade300.withOpacity(0.4),
                            Colors.orange.shade100.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ],
                  minX: 0,
                  maxX: (next24Hours.length - 1).toDouble(),
                  minY: temperatureSpots.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 3,
                  maxY: temperatureSpots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 3,
                ),
              ),
            ),
            
            // Temperature labels on chart
            const SizedBox(height: ThemeConstants.spacingSmall),
            Container(
              height: 36,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: next24Hours.asMap().entries.where((entry) => entry.key % 6 == 0).map((entry) {
                  final forecast = entry.value;
                  return Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${forecast.temperature.round()}°',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 1),
                        WeatherIcon(
                          iconUrl: forecast.iconUrl,
                          size: 14,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrecipitationChart(BuildContext context) {
    if (hourlyForecasts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Khả năng có mưa (%)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: ThemeConstants.spacingMedium),
              Container(
                height: 120,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.water_drop,
                        size: 32,
                        color: Colors.blue.shade300,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Không có dữ liệu theo giờ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
    
    // Use same logic as temperature chart for consistent data display
    final List<HourlyForecast> displayHours;
    if (selectedDay != null) {
      final selectedDate = selectedDay!.date;
      final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      displayHours = hourlyForecasts
          .where((forecast) => 
              forecast.dateTime.isAfter(startOfDay.subtract(const Duration(minutes: 1))) &&
              forecast.dateTime.isBefore(endOfDay))
          .toList();
    } else if (selectedHour != null) {
      final selectedDate = selectedHour!.dateTime;
      final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      displayHours = hourlyForecasts
          .where((forecast) => 
              forecast.dateTime.isAfter(startOfDay.subtract(const Duration(minutes: 1))) &&
              forecast.dateTime.isBefore(endOfDay))
          .toList();
    } else {
      final now = DateTime.now();
      displayHours = hourlyForecasts
          .where((forecast) => 
              forecast.dateTime.isAfter(now) && 
              forecast.dateTime.isBefore(now.add(const Duration(hours: 24))))
          .take(24)
          .toList();
    }
    
    // If no hourly data for selected period, show message
    if (displayHours.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Khả năng có mưa (%)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: ThemeConstants.spacingMedium),
              Container(
                height: 120,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.water_drop,
                        size: 32,
                        color: Colors.blue.shade300,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedDay != null 
                            ? 'Không có dữ liệu cho ngày này'
                            : 'Không có dữ liệu theo giờ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
    
    final next24Hours = displayHours;
    final precipitationData = next24Hours
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.precipitationChance.toDouble()))
        .toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Khả năng có mưa (%)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingMedium),
            
            Container(
              height: 140,
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeConstants.spacingSmall,
                vertical: ThemeConstants.spacingSmall,
              ),
              child: precipitationData.any((spot) => spot.y > 0) 
                  ? LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 25,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.blue.shade100.withOpacity(0.5),
                            strokeWidth: 0.5,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              interval: 25,
                              getTitlesWidget: (value, meta) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Text(
                                  '${value.round()}%',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 24,
                              interval: 6,
                              getTitlesWidget: (value, meta) => Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${value.round()}h',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: precipitationData,
                            isCurved: true,
                            curveSmoothness: 0.2,
                            color: Colors.blue.shade500,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                if (spot.y > 20) {
                                  return FlDotCirclePainter(
                                    radius: 2.5,
                                    color: Colors.white,
                                    strokeWidth: 1.5,
                                    strokeColor: Colors.blue.shade600,
                                  );
                                }
                                return FlDotCirclePainter(
                                  radius: 0,
                                  color: Colors.transparent,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.blue.shade300.withOpacity(0.4),
                                  Colors.blue.shade100.withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                        ],
                        minX: 0,
                        maxX: (next24Hours.length - 1).toDouble(),
                        minY: 0,
                        maxY: 100,
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wb_sunny,
                            size: 32,
                            color: Colors.orange.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Không có khả năng mưa',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            
            // Precipitation summary row
            if (precipitationData.any((spot) => spot.y > 0))
              Padding(
                padding: const EdgeInsets.only(top: ThemeConstants.spacingSmall),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPrecipitationStat(
                      context,
                      'Cao nhất',
                      '${precipitationData.map((e) => e.y).reduce((a, b) => a > b ? a : b).round()}%',
                      Colors.blue.shade600,
                    ),
                    _buildPrecipitationStat(
                      context,
                      'Trung bình',
                      '${(precipitationData.map((e) => e.y).reduce((a, b) => a + b) / precipitationData.length).round()}%',
                      Colors.blue.shade400,
                    ),
                    _buildPrecipitationStat(
                      context,
                      selectedHour != null ? 'Lúc đã chọn' : 'Hiện tại',
                      selectedHour != null 
                          ? '${selectedHour!.precipitationChance}%'
                          : '${next24Hours.isNotEmpty ? next24Hours.first.precipitationChance : 0}%',
                      Colors.blue.shade500,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRainfallSummary(BuildContext context) {
    // Calculate total rainfall for past 24 hours (mock data for now)
    final totalRainfall = 31.0; // mm
    final maxRainfall = 50.0; // mm (for progress bar)
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🌧️', style: TextStyle(fontSize: 20)),
                const SizedBox(width: ThemeConstants.spacingSmall),
                Text(
                  '24 giờ qua: ${totalRainfall.round()} mm',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeConstants.spacingMedium),
            
            // Rainfall progress bar
            Container(
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue.shade50,
              ),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue.shade50,
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: (totalRainfall / maxRainfall).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade300,
                            Colors.blue.shade600,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        '${((totalRainfall / maxRainfall) * 100).round()}% of ${maxRainfall.round()}mm',
                        style: TextStyle(
                          color: totalRainfall > maxRainfall * 0.5 ? Colors.white : Colors.blue.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: ThemeConstants.spacingSmall),
            Text(
              _getRainfallDescription(totalRainfall),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildWeatherAdviceSection(BuildContext context) {
    // Create weather advice based on selected day or hour
    Weather weatherForAdvice;
    Forecast? forecastForAdvice;
    
    if (selectedDay != null) {
      // Create weather object from selected day
      weatherForAdvice = Weather(
        cityName: currentWeather?.cityName ?? 'Unknown',
        country: currentWeather?.country ?? 'Unknown',
        temperature: (selectedDay!.maxTemperature + selectedDay!.minTemperature) / 2,
        condition: selectedDay!.condition,
        iconUrl: selectedDay!.iconUrl,
        humidity: selectedDay!.avgHumidity.round(),
        windSpeed: selectedDay!.maxWindSpeed,
        pressure: currentWeather?.pressure ?? 1013.0,
        feelsLike: (selectedDay!.maxTemperature + selectedDay!.minTemperature) / 2,
        uvIndex: selectedDay!.uvIndex,
        visibility: currentWeather?.visibility ?? 10.0,
        lastUpdated: DateTime.now(),
        latitude: currentWeather?.latitude,
        longitude: currentWeather?.longitude,
        sunrise: currentWeather?.sunrise,
        sunset: currentWeather?.sunset,
      );
      
      // Create forecast with selected day data
      forecastForAdvice = Forecast(
        cityName: currentWeather?.cityName ?? 'Unknown',
        dailyForecasts: [selectedDay!],
        hourlyForecasts: hourlyForecasts,
      );
    } else if (selectedHour != null) {
      // Create weather object from selected hour
      weatherForAdvice = Weather(
        cityName: currentWeather?.cityName ?? 'Unknown',
        country: currentWeather?.country ?? 'Unknown',
        temperature: selectedHour!.temperature,
        condition: selectedHour!.condition,
        iconUrl: selectedHour!.iconUrl,
        humidity: selectedHour!.humidity,
        windSpeed: selectedHour!.windSpeed,
        pressure: currentWeather?.pressure ?? 1013.0,
        feelsLike: selectedHour!.feelsLike,
        uvIndex: currentWeather?.uvIndex ?? 0.0,
        visibility: currentWeather?.visibility ?? 10.0,
        lastUpdated: DateTime.now(),
        latitude: currentWeather?.latitude,
        longitude: currentWeather?.longitude,
        sunrise: currentWeather?.sunrise,
        sunset: currentWeather?.sunset,
      );
      
      // Create forecast with selected hour's day data
      final selectedDate = selectedHour!.dateTime;
      final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final dayHourlyForecasts = hourlyForecasts
          .where((forecast) => 
              forecast.dateTime.isAfter(startOfDay.subtract(const Duration(minutes: 1))) &&
              forecast.dateTime.isBefore(endOfDay))
          .toList();
      
      forecastForAdvice = Forecast(
        cityName: currentWeather?.cityName ?? 'Unknown',
        dailyForecasts: [],
        hourlyForecasts: dayHourlyForecasts,
      );
    } else {
      // Default: use current weather
      weatherForAdvice = currentWeather ?? Weather(
        cityName: 'Unknown',
        country: 'Unknown',
        temperature: 25.0,
        condition: 'Unknown',
        iconUrl: '',
        humidity: 50,
        windSpeed: 10.0,
        pressure: 1013.0,
        feelsLike: 25.0,
        uvIndex: 5.0,
        visibility: 10.0,
        lastUpdated: DateTime.now(),
      );
      
      forecastForAdvice = Forecast(
        cityName: weatherForAdvice.cityName,
        dailyForecasts: [],
        hourlyForecasts: hourlyForecasts,
      );
    }
    
    final advices = WeatherAdviceService.getWeatherAdvice(weatherForAdvice, forecastForAdvice);
    
    if (advices.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selectedDay != null 
              ? 'Gợi ý cho ${_getVietnameseDayName(selectedDay!.date)}'
              : selectedHour != null
                  ? 'Gợi ý cho lúc ${_formatTime(selectedHour!.dateTime)}'
                  : 'Gợi ý thời tiết',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: ThemeConstants.spacingMedium),
        WeatherAdviceWidget(advices: advices),
      ],
    );
  }

  Widget _buildAdditionalDetails(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chi tiết bổ sung',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingMedium),
            
            if (selectedDay != null) ...[
              _buildDetailRow(context, '🌡️', 'Nhiệt độ cao nhất', '${selectedDay!.maxTemperature.round()}°C'),
              _buildDetailRow(context, '❄️', 'Nhiệt độ thấp nhất', '${selectedDay!.minTemperature.round()}°C'),
              _buildDetailRow(context, '💨', 'Tốc độ gió tối đa', '${selectedDay!.maxWindSpeed.round()} km/h'),
              _buildDetailRow(context, '💧', 'Độ ẩm trung bình', '${selectedDay!.avgHumidity.round()}%'),
              _buildDetailRow(context, '☀️', 'Chỉ số UV', '${selectedDay!.uvIndex.round()}'),
            ] else if (selectedHour != null) ...[
              _buildDetailRow(context, '🌡️', 'Nhiệt độ', '${selectedHour!.temperature.round()}°C'),
              _buildDetailRow(context, '🌡️', 'Cảm giác như', '${selectedHour!.feelsLike.round()}°C'),
              _buildDetailRow(context, '💨', 'Tốc độ gió', '${selectedHour!.windSpeed.round()} km/h'),
              _buildDetailRow(context, '💧', 'Độ ẩm', '${selectedHour!.humidity}%'),
              _buildDetailRow(context, '🌧️', 'Khả năng mưa', '${selectedHour!.precipitationChance}%'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ThemeConstants.spacingSmall),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: ThemeConstants.spacingMedium),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrecipitationStat(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  String _getRainfallDescription(double rainfall) {
    if (rainfall == 0) return 'Không có mưa trong 24 giờ qua';
    if (rainfall < 5) return 'Mưa rất nhỏ';
    if (rainfall < 15) return 'Mưa nhẹ';
    if (rainfall < 30) return 'Mưa vừa';
    if (rainfall < 50) return 'Mưa to';
    return 'Mưa rất to';
  }

  String _getVietnameseDayName(DateTime date) {
    final dayNames = {
      1: 'Thứ 2',
      2: 'Thứ 3',
      3: 'Thứ 4',
      4: 'Thứ 5',
      5: 'Thứ 6',
      6: 'Thứ 7',
      7: 'Chủ nhật',
    };
    
    return dayNames[date.weekday] ?? 'Thứ ${date.weekday}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class HourlyIconData {
  final double hour;
  final double temperature;
  final String iconUrl;

  HourlyIconData({
    required this.hour,
    required this.temperature,
    required this.iconUrl,
  });
}