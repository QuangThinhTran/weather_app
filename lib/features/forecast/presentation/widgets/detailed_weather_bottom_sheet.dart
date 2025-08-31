import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../domain/entities/forecast.dart';
import '../../../weather/domain/entities/weather.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/widgets/weather_icon.dart';
import '../../../weather/presentation/widgets/weather_advice_widget.dart';
import '../../../../core/services/weather_advice_service.dart';

class DetailedWeatherBottomSheet extends StatefulWidget {
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
  State<DetailedWeatherBottomSheet> createState() => _DetailedWeatherBottomSheetState();
}

class _DetailedWeatherBottomSheetState extends State<DetailedWeatherBottomSheet> 
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _backgroundController;
  late List<AnimationController> _cardControllers;
  
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _backgroundAnimation;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _cardControllers = List.generate(4, (index) => 
      AnimationController(
        duration: Duration(milliseconds: 400 + (index * 200)),
        vsync: this,
      )
    );
    
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut)
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutQuart)
    );
    
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_backgroundController);
    
    _cardAnimations = _cardControllers.map((controller) => 
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut)
      )
    ).toList();
    
    _startAnimations();
  }
  
  void _startAnimations() async {
    _slideController.forward();
    _fadeController.forward();
    
    for (int i = 0; i < _cardControllers.length; i++) {
      await Future.delayed(Duration(milliseconds: 300 + (i * 150)));
      if (mounted) _cardControllers[i].forward();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _backgroundController.dispose();
    for (final controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getAnimatedBackgroundColors(isDark),
              transform: GradientRotation(_backgroundAnimation.value * math.pi * 0.3),
            ),
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * _slideAnimation.value),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(ThemeConstants.radiusXXLarge),
                        topRight: Radius.circular(ThemeConstants.radiusXXLarge),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: ThemeConstants.glassBlur * 1.5,
                          sigmaY: ThemeConstants.glassBlur * 1.5,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(isDark ? 0.15 : 0.25),
                                Colors.white.withOpacity(isDark ? 0.05 : 0.15),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(ThemeConstants.radiusXXLarge),
                              topRight: Radius.circular(ThemeConstants.radiusXXLarge),
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Enhanced header with animations
                              _buildEnhancedHeader(context),
                              
                              // Animated content
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    ThemeConstants.spacingMedium,
                                    0,
                                    ThemeConstants.spacingMedium,
                                    ThemeConstants.spacingXLarge,
                                  ),
                                  child: AnimatedBuilder(
                                    animation: _fadeAnimation,
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Animated cards
                                            _buildAnimatedCard(0, _buildEnhancedTemperatureChart(context)),
                                            const SizedBox(height: ThemeConstants.spacingLarge),
                                            
                                            _buildAnimatedCard(1, _buildEnhancedPrecipitationChart(context)),
                                            const SizedBox(height: ThemeConstants.spacingLarge),
                                            
                                            _buildAnimatedCard(2, _buildEnhancedRainfallSummary(context)),
                                            const SizedBox(height: ThemeConstants.spacingLarge),
                                            
                                            _buildAnimatedCard(3, _buildEnhancedWeatherAdviceSection(context)),
                                            const SizedBox(height: ThemeConstants.spacingLarge),
                                            
                                            _buildEnhancedAdditionalDetails(context),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEnhancedHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -30 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
            child: Container(
              padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle with glow effect
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.8),
                          Colors.white.withOpacity(0.4),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: ThemeConstants.spacingLarge),
                  
                  // Enhanced title row
                  Container(
                    padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667eea).withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.analytics_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: ThemeConstants.spacingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Phân tích chi tiết thời tiết',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedCard(int index, Widget child) {
    return AnimatedBuilder(
      animation: _cardAnimations[index],
      builder: (context, animatedChild) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _cardAnimations[index].value),
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - _cardAnimations[index].value)),
            child: Opacity(
              opacity: _cardAnimations[index].value.clamp(0.0, 1.0),
              child: child,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedTemperatureChart(BuildContext context) {
    if (widget.hourlyForecasts.isEmpty) {
      return _buildEmptyState(
        context,
        Icons.thermostat_rounded,
        'Đường cong nhiệt độ',
        'Không có dữ liệu theo giờ',
        const Color(0xFFFF9800),
      );
    }
    
    final displayHours = _getDisplayHours();
    if (displayHours.isEmpty) {
      return _buildEmptyState(
        context,
        Icons.thermostat_rounded,
        'Đường cong nhiệt độ',
        widget.selectedDay != null 
            ? 'Không có dữ liệu cho ngày này'
            : 'Không có dữ liệu theo giờ',
        const Color(0xFFFF9800),
      );
    }
    
    final temperatureSpots = displayHours
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.temperature))
        .toList();
    
    return _buildEnhancedCard(
      context,
      'Đường cong nhiệt độ',
      Icons.thermostat_rounded,
      const Color(0xFFFF9800),
      Column(
        children: [
          Container(
            height: 200,
            padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 5,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.round()}°',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: math.max(displayHours.length / 6, 1).toDouble(),
                      getTitlesWidget: (value, meta) => Text(
                        '${value.round()}h',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: temperatureSpots,
                    isCurved: true,
                    curveSmoothness: 0.4,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD54F), Color(0xFFFF9800)],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: const Color(0xFFFF9800),
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFFFD54F).withOpacity(0.3),
                          const Color(0xFFFF9800).withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ],
                minX: 0,
                maxX: (displayHours.length - 1).toDouble(),
                minY: temperatureSpots.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 3,
                maxY: temperatureSpots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 3,
              ),
            ),
          ),
          // Enhanced temperature summary
          Container(
            padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF9800).withOpacity(0.2),
                  const Color(0xFFFF9800).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTempStat(context, 'Cao nhất', '${temperatureSpots.map((e) => e.y).reduce((a, b) => a > b ? a : b).round()}°', const Color(0xFFFF5722)),
                _buildTempStat(context, 'Thấp nhất', '${temperatureSpots.map((e) => e.y).reduce((a, b) => a < b ? a : b).round()}°', const Color(0xFF2196F3)),
                _buildTempStat(context, 'Trung bình', '${(temperatureSpots.map((e) => e.y).reduce((a, b) => a + b) / temperatureSpots.length).round()}°', const Color(0xFF4CAF50)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPrecipitationChart(BuildContext context) {
    final displayHours = _getDisplayHours();
    if (displayHours.isEmpty || !displayHours.any((h) => h.precipitationChance > 0)) {
      return _buildEmptyState(
        context,
        Icons.wb_sunny_rounded,
        'Khả năng có mưa',
        'Không có khả năng mưa',
        const Color(0xFF2196F3),
      );
    }
    
    final precipitationData = displayHours
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.precipitationChance.toDouble()))
        .toList();
    
    return _buildEnhancedCard(
      context,
      'Khả năng có mưa (%)',
      Icons.water_drop_rounded,
      const Color(0xFF2196F3),
      Column(
        children: [
          Container(
            height: 180,
            padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 25,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.round()}%',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: math.max(displayHours.length / 6, 1).toDouble(),
                      getTitlesWidget: (value, meta) => Text(
                        '${value.round()}h',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: precipitationData,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF42A5F5), Color(0xFF2196F3)],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        if (spot.y > 20) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: const Color(0xFF2196F3),
                          );
                        }
                        return FlDotCirclePainter(radius: 0, color: Colors.transparent);
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF42A5F5).withOpacity(0.3),
                          const Color(0xFF2196F3).withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ],
                minX: 0,
                maxX: (displayHours.length - 1).toDouble(),
                minY: 0,
                maxY: 100,
              ),
            ),
          ),
          // Enhanced precipitation summary
          Container(
            padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2196F3).withOpacity(0.2),
                  const Color(0xFF2196F3).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPrecipitationStat(
                  context,
                  'Cao nhất',
                  '${precipitationData.map((e) => e.y).reduce((a, b) => a > b ? a : b).round()}%',
                  const Color(0xFF1565C0),
                ),
                _buildPrecipitationStat(
                  context,
                  'Trung bình',
                  '${(precipitationData.map((e) => e.y).reduce((a, b) => a + b) / precipitationData.length).round()}%',
                  const Color(0xFF1976D2),
                ),
                _buildPrecipitationStat(
                  context,
                  widget.selectedHour != null ? 'Lúc đã chọn' : 'Hiện tại',
                  widget.selectedHour != null 
                      ? '${widget.selectedHour!.precipitationChance}%'
                      : '${displayHours.isNotEmpty ? displayHours.first.precipitationChance : 0}%',
                  const Color(0xFF2196F3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedRainfallSummary(BuildContext context) {
    final totalRainfall = 31.0;
    final maxRainfall = 50.0;
    final percentage = (totalRainfall / maxRainfall).clamp(0.0, 1.0);
    
    return _buildEnhancedCard(
      context,
      'Tổng kết lượng mưa 24h',
      Icons.grain_rounded,
      const Color(0xFF00BCD4),
      Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E5FF), Color(0xFF00BCD4)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: ThemeConstants.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${totalRainfall.round()} mm',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _getRainfallDescription(totalRainfall),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: ThemeConstants.spacingLarge),
          
          // Enhanced progress bar
          Container(
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.05),
                        Colors.white.withOpacity(0.02),
                      ],
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E5FF), Color(0xFF00BCD4)],
                        stops: [0.0, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00BCD4).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Text(
                      '${(percentage * 100).round()}% của ${maxRainfall.round()}mm',
                      style: TextStyle(
                        color: percentage > 0.5 ? Colors.white : Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedWeatherAdviceSection(BuildContext context) {
    final weatherForAdvice = _getWeatherForAdvice();
    final forecastForAdvice = _getForecastForAdvice();
    final advices = WeatherAdviceService.getWeatherAdvice(weatherForAdvice, forecastForAdvice);
    
    if (advices.isEmpty) {
      return _buildEmptyState(
        context,
        Icons.lightbulb_outline_rounded,
        'Gợi ý thời tiết',
        'Không có gợi ý cho thời điểm này',
        const Color(0xFFFFC107),
      );
    }
    
    return _buildEnhancedCard(
      context,
      widget.selectedDay != null 
          ? 'Gợi ý cho ${_getVietnameseDayName(widget.selectedDay!.date)}'
          : widget.selectedHour != null
              ? 'Gợi ý cho lúc ${_formatTime(widget.selectedHour!.dateTime)}'
              : 'Gợi ý thời tiết',
      Icons.lightbulb_rounded,
      const Color(0xFFFFC107),
      WeatherAdviceWidget(advices: advices),
    );
  }

  Widget _buildEnhancedAdditionalDetails(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: ThemeConstants.spacingMedium),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.info_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: ThemeConstants.spacingMedium),
                        Text(
                          'Chi tiết bổ sung',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: ThemeConstants.spacingLarge),
                  
                  // Details grid
                  if (widget.selectedDay != null) ...[
                    _buildEnhancedDetailRow(context, Icons.thermostat_rounded, 'Nhiệt độ cao nhất', '${widget.selectedDay!.maxTemperature.round()}°C', const Color(0xFFFF5722)),
                    _buildEnhancedDetailRow(context, Icons.ac_unit_rounded, 'Nhiệt độ thấp nhất', '${widget.selectedDay!.minTemperature.round()}°C', const Color(0xFF2196F3)),
                    _buildEnhancedDetailRow(context, Icons.air_rounded, 'Tốc độ gió tối đa', '${widget.selectedDay!.maxWindSpeed.round()} km/h', const Color(0xFF00BCD4)),
                    _buildEnhancedDetailRow(context, Icons.water_drop_rounded, 'Độ ẩm trung bình', '${widget.selectedDay!.avgHumidity.round()}%', const Color(0xFF4CAF50)),
                    _buildEnhancedDetailRow(context, Icons.wb_sunny_rounded, 'Chỉ số UV', '${widget.selectedDay!.uvIndex.round()}', const Color(0xFFFFC107)),
                  ] else if (widget.selectedHour != null) ...[
                    _buildEnhancedDetailRow(context, Icons.thermostat_rounded, 'Nhiệt độ', '${widget.selectedHour!.temperature.round()}°C', const Color(0xFFFF5722)),
                    _buildEnhancedDetailRow(context, Icons.thermostat_rounded, 'Cảm giác như', '${widget.selectedHour!.feelsLike.round()}°C', const Color(0xFFFF9800)),
                    _buildEnhancedDetailRow(context, Icons.air_rounded, 'Tốc độ gió', '${widget.selectedHour!.windSpeed.round()} km/h', const Color(0xFF00BCD4)),
                    _buildEnhancedDetailRow(context, Icons.water_drop_rounded, 'Độ ẩm', '${widget.selectedHour!.humidity}%', const Color(0xFF4CAF50)),
                    _buildEnhancedDetailRow(context, Icons.grain_rounded, 'Khả năng mưa', '${widget.selectedHour!.precipitationChance}%', const Color(0xFF2196F3)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedCard(BuildContext context, String title, IconData icon, Color color, Widget content) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: ThemeConstants.spacingMedium),
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ThemeConstants.spacingLarge),
                content,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, IconData icon, String title, String message, Color color) {
    return _buildEnhancedCard(
      context,
      title,
      icon,
      color,
      Container(
        height: 120,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 32, color: Colors.white.withOpacity(0.8)),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTempStat(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedDetailRow(BuildContext context, IconData icon, String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeConstants.spacingMedium),
      padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: ThemeConstants.spacingMedium),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.spacingMedium,
              vertical: ThemeConstants.spacingSmall,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Utility methods
  List<Color> _getAnimatedBackgroundColors(bool isDark) {
    final animationValue = _backgroundAnimation.value;
    
    if (isDark) {
      return [
        Color.lerp(const Color(0xFF1a1a2e), const Color(0xFF16213e), animationValue)!,
        Color.lerp(const Color(0xFF16213e), const Color(0xFF0f3460), animationValue)!,
        Color.lerp(const Color(0xFF0f3460), const Color(0xFF1a1a2e), animationValue)!,
      ];
    } else {
      return [
        Color.lerp(const Color(0xFF667eea), const Color(0xFF764ba2), animationValue)!,
        Color.lerp(const Color(0xFF764ba2), const Color(0xFFf093fb), animationValue)!,
        Color.lerp(const Color(0xFFf093fb), const Color(0xFF667eea), animationValue)!,
      ];
    }
  }

  List<HourlyForecast> _getDisplayHours() {
    if (widget.selectedDay != null) {
      final selectedDate = widget.selectedDay!.date;
      final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      return widget.hourlyForecasts
          .where((forecast) => 
              forecast.dateTime.isAfter(startOfDay.subtract(const Duration(minutes: 1))) &&
              forecast.dateTime.isBefore(endOfDay))
          .toList();
    } else if (widget.selectedHour != null) {
      final selectedDate = widget.selectedHour!.dateTime;
      final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      return widget.hourlyForecasts
          .where((forecast) => 
              forecast.dateTime.isAfter(startOfDay.subtract(const Duration(minutes: 1))) &&
              forecast.dateTime.isBefore(endOfDay))
          .toList();
    } else {
      final now = DateTime.now();
      return widget.hourlyForecasts
          .where((forecast) => 
              forecast.dateTime.isAfter(now) && 
              forecast.dateTime.isBefore(now.add(const Duration(hours: 24))))
          .take(24)
          .toList();
    }
  }

  Weather _getWeatherForAdvice() {
    if (widget.selectedDay != null) {
      return Weather(
        cityName: widget.currentWeather?.cityName ?? 'Unknown',
        country: widget.currentWeather?.country ?? 'Unknown',
        temperature: (widget.selectedDay!.maxTemperature + widget.selectedDay!.minTemperature) / 2,
        condition: widget.selectedDay!.condition,
        iconUrl: widget.selectedDay!.iconUrl,
        humidity: widget.selectedDay!.avgHumidity.round(),
        windSpeed: widget.selectedDay!.maxWindSpeed,
        pressure: widget.currentWeather?.pressure ?? 1013.0,
        feelsLike: (widget.selectedDay!.maxTemperature + widget.selectedDay!.minTemperature) / 2,
        uvIndex: widget.selectedDay!.uvIndex,
        visibility: widget.currentWeather?.visibility ?? 10.0,
        lastUpdated: DateTime.now(),
        latitude: widget.currentWeather?.latitude,
        longitude: widget.currentWeather?.longitude,
        sunrise: widget.currentWeather?.sunrise,
        sunset: widget.currentWeather?.sunset,
      );
    } else if (widget.selectedHour != null) {
      return Weather(
        cityName: widget.currentWeather?.cityName ?? 'Unknown',
        country: widget.currentWeather?.country ?? 'Unknown',
        temperature: widget.selectedHour!.temperature,
        condition: widget.selectedHour!.condition,
        iconUrl: widget.selectedHour!.iconUrl,
        humidity: widget.selectedHour!.humidity,
        windSpeed: widget.selectedHour!.windSpeed,
        pressure: widget.currentWeather?.pressure ?? 1013.0,
        feelsLike: widget.selectedHour!.feelsLike,
        uvIndex: widget.currentWeather?.uvIndex ?? 0.0,
        visibility: widget.currentWeather?.visibility ?? 10.0,
        lastUpdated: DateTime.now(),
        latitude: widget.currentWeather?.latitude,
        longitude: widget.currentWeather?.longitude,
        sunrise: widget.currentWeather?.sunrise,
        sunset: widget.currentWeather?.sunset,
      );
    } else {
      return widget.currentWeather ?? Weather(
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
    }
  }

  Forecast _getForecastForAdvice() {
    if (widget.selectedDay != null) {
      return Forecast(
        cityName: widget.currentWeather?.cityName ?? 'Unknown',
        dailyForecasts: [widget.selectedDay!],
        hourlyForecasts: widget.hourlyForecasts,
      );
    } else if (widget.selectedHour != null) {
      final selectedDate = widget.selectedHour!.dateTime;
      final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final dayHourlyForecasts = widget.hourlyForecasts
          .where((forecast) => 
              forecast.dateTime.isAfter(startOfDay.subtract(const Duration(minutes: 1))) &&
              forecast.dateTime.isBefore(endOfDay))
          .toList();
      
      return Forecast(
        cityName: widget.currentWeather?.cityName ?? 'Unknown',
        dailyForecasts: [],
        hourlyForecasts: dayHourlyForecasts,
      );
    } else {
      return Forecast(
        cityName: widget.currentWeather?.cityName ?? 'Unknown',
        dailyForecasts: [],
        hourlyForecasts: widget.hourlyForecasts,
      );
    }
  }

  Widget _buildPrecipitationStat(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
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