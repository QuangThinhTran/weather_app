import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../bloc/weather_bloc.dart';
import '../bloc/weather_state.dart';
import '../bloc/weather_event.dart';
import '../widgets/weather_card.dart';
import '../widgets/weather_details_section.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../../search/presentation/bloc/search_bloc.dart';
import '../../../forecast/presentation/bloc/forecast_bloc.dart';
import '../../../forecast/presentation/bloc/forecast_event.dart';
import '../../../forecast/presentation/bloc/forecast_state.dart';
import '../../../forecast/presentation/widgets/hourly_forecast_widget.dart';
import '../../../forecast/presentation/widgets/daily_forecast_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../service_locator.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  late AnimationController _heroAnimationController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _heroAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    
    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundAnimationController);
    
    _heroAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroAnimationController,
      curve: Curves.elasticOut,
    ));
    
    // Load weather for current location or default city
    _loadInitialWeather();
    
    // Start hero animation
    _heroAnimationController.forward();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _heroAnimationController.dispose();
    super.dispose();
  }

  void _loadInitialWeather() {
    final weatherBloc = context.read<WeatherBloc>();
    final forecastBloc = context.read<ForecastBloc>();
    
    // Load default city (Ho Chi Minh) first
    const cityName = 'Ho Chi Minh';
    weatherBloc.add(const LoadWeatherByCity(cityName));
    forecastBloc.add(const LoadForecast(cityName));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: ThemeConstants.spacingMedium),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
              child: InkWell(
                borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
                onTap: () => _navigateToSearch(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_rounded, 
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tìm kiếm',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _backgroundAnimation,
          builder: (context, child) {
            return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getAnimatedGradientColors(isDark),
                stops: const [0.0, 0.3, 0.7, 1.0],
                transform: GradientRotation(_backgroundAnimation.value * math.pi * 0.5),
              ),
            ),
            child: Stack(
              children: [
                // Enhanced floating particles
                ..._buildEnhancedFloatingParticles(),
                
                // Main weather content with animations
                child!,
              ],
            ),
          );
        },
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<WeatherBloc>().add(const RefreshWeather());
          },
          backgroundColor: Colors.white.withOpacity(0.9),
          color: theme.colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
                child: BlocBuilder<WeatherBloc, WeatherState>(
                  builder: (context, state) {
                    if (state is WeatherLoading) {
                      return Column(
                        children: [
                          const SizedBox(height: ThemeConstants.spacingXLarge),
                          _buildLoadingWidget(theme),
                        ],
                      );
                    } else if (state is WeatherLoaded) {
                      return Column(
                        children: [
                          const SizedBox(height: ThemeConstants.spacingLarge),
                          
                          // Enhanced Weather Card with hero animation
                          AnimatedBuilder(
                            animation: _heroAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 0.8 + (0.2 * _heroAnimation.value),
                                child: Opacity(
                                  opacity: _heroAnimation.value.clamp(0.0, 1.0),
                                  child: Transform.translate(
                                    offset: Offset(0, 50 * (1 - _heroAnimation.value)),
                                    child: Hero(
                                      tag: 'weather_card',
                                      child: _buildEnhancedWeatherCard(
                                        weather: state.weather,
                                        isFromCache: state.isFromCache,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: ThemeConstants.spacingLarge),
                          
                          // Enhanced Weather Details with staggered animation
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 800 + 400),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(30 * (1 - value), 0),
                                child: Opacity(
                                  opacity: value,
                                  child: _buildEnhancedGlassContainer(
                                    child: WeatherDetailsSection(
                                      weather: state.weather,
                                    ),
                                    isDark: isDark,
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: ThemeConstants.spacingLarge),
                          
                          // Forecast sections with enhanced glass morphism
                          BlocBuilder<ForecastBloc, ForecastState>(
                            builder: (context, forecastState) {
                              if (forecastState is ForecastLoaded) {
                                return Column(
                                  children: [
                                    // Enhanced Hourly forecast with animation
                                    TweenAnimationBuilder<double>(
                                      tween: Tween<double>(begin: 0.0, end: 1.0),
                                      duration: Duration(milliseconds: 1000 + 600),
                                      builder: (context, value, child) {
                                        return Transform.translate(
                                          offset: Offset(-30 * (1 - value), 0),
                                          child: Opacity(
                                            opacity: value,
                                            child: _buildEnhancedGlassContainer(
                                              child: HourlyForecastWidget(
                                                hourlyForecasts: forecastState.forecast.hourlyForecasts,
                                                currentWeather: state.weather,
                                              ),
                                              isDark: isDark,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: ThemeConstants.spacingLarge),
                                    
                                    // Enhanced Daily forecast with animation
                                    TweenAnimationBuilder<double>(
                                      tween: Tween<double>(begin: 0.0, end: 1.0),
                                      duration: Duration(milliseconds: 1200 + 800),
                                      builder: (context, value, child) {
                                        return Transform.translate(
                                          offset: Offset(40 * (1 - value), 0),
                                          child: Opacity(
                                            opacity: value,
                                            child: _buildEnhancedGlassContainer(
                                              child: DailyForecastWidget(
                                                dailyForecasts: forecastState.forecast.dailyForecasts,
                                                hourlyForecasts: forecastState.forecast.hourlyForecasts,
                                                currentWeather: state.weather,
                                              ),
                                              isDark: isDark,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              } else if (forecastState is ForecastError && forecastState.cachedForecast != null) {
                                return Column(
                                  children: [
                                    // Show cached forecast with enhanced glass effect
                                    _buildEnhancedGlassContainer(
                                      child: HourlyForecastWidget(
                                        hourlyForecasts: forecastState.cachedForecast!.hourlyForecasts,
                                        currentWeather: state.weather,
                                      ),
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: ThemeConstants.spacingLarge),
                                    _buildEnhancedGlassContainer(
                                      child: DailyForecastWidget(
                                        dailyForecasts: forecastState.cachedForecast!.dailyForecasts,
                                        hourlyForecasts: forecastState.cachedForecast!.hourlyForecasts,
                                        currentWeather: state.weather,
                                      ),
                                      isDark: isDark,
                                    ),
                                  ],
                                );
                              } else if (forecastState is ForecastLoading) {
                                return Column(
                                  children: [
                                    _buildEnhancedGlassContainer(
                                      child: Container(
                                        padding: const EdgeInsets.all(ThemeConstants.spacingXLarge),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: 60,
                                              height: 60,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 3,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  Colors.white.withOpacity(0.8)
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: ThemeConstants.spacingMedium),
                                            Text(
                                              'Đang tải dự báo...',
                                              style: theme.textTheme.bodyLarge?.copyWith(
                                                color: Colors.white.withOpacity(0.9),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: ThemeConstants.spacingSmall),
                                            Text(
                                              'Vui lòng chờ một chút',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: Colors.white.withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      isDark: isDark,
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          
                          const SizedBox(height: ThemeConstants.spacingLarge),
                        ],
                      );
                    } else if (state is WeatherError) {
                      if (state.cachedWeather != null) {
                        // Show cached data with error indication
                        return Column(
                          children: [
                            const SizedBox(height: ThemeConstants.spacingLarge),
                            WeatherCard(
                              weather: state.cachedWeather!,
                              isFromCache: true,
                              showOfflineIndicator: true,
                            ),
                            const SizedBox(height: ThemeConstants.spacingMedium),
                            Container(
                              padding: const EdgeInsets.all(ThemeConstants.spacingSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(ThemeConstants.radiusSmall),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.cloud_off,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  const SizedBox(width: ThemeConstants.spacingSmall),
                                  Expanded(
                                    child: Text(
                                      'Hiển thị dữ liệu đã lưu - Không thể kết nối mạng',
                                      style: TextStyle(
                                        fontSize: ThemeConstants.fontSizeSmall,
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        return WeatherErrorWidget(
                          message: state.message,
                          onRetry: () => _refreshWeather(context),
                          showLocationButton: true,
                          onUseLocation: () => _useCurrentLocation(context),
                        );
                      }
                    } else if (state is WeatherLocationPermissionDenied) {
                      return WeatherErrorWidget(
                        message: state.message,
                        onRetry: () => _navigateToSearch(context),
                        showLocationButton: false,
                      );
                    } else {
                      // Initial state - show search prompt
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.wb_sunny,
                              size: 80,
                              color: Colors.orange,
                            ),
                            const SizedBox(height: ThemeConstants.spacingLarge),
                            const Text(
                              'Chào mừng đến với\nDự Báo Thời Tiết',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: ThemeConstants.fontSizeXXLarge,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: ThemeConstants.spacingXLarge),
                            ElevatedButton.icon(
                              onPressed: () => _navigateToSearch(context),
                              icon: const Icon(Icons.search, size: 24),
                              label: const Text(
                                'Tìm Kiếm Thành Phố',
                                style: TextStyle(fontSize: 18),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: ThemeConstants.spacingXLarge,
                                  vertical: ThemeConstants.spacingMedium,
                                ),
                              ),
                            ),
                            const SizedBox(height: ThemeConstants.spacingMedium),
                            OutlinedButton.icon(
                              onPressed: () => _useCurrentLocation(context),
                              icon: const Icon(Icons.my_location, size: 20),
                              label: const Text('Sử dụng vị trí hiện tại'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: ThemeConstants.spacingLarge,
                                  vertical: ThemeConstants.spacingSmall,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }

  void _navigateToSearch(BuildContext context) async {
    final selectedCity = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<SearchBloc>(),
          child: const SearchScreen(),
        ),
      ),
    );

    if (selectedCity != null && mounted) {
      // Load weather and forecast for selected city
      context.read<WeatherBloc>().add(LoadWeatherByCity(selectedCity));
      context.read<ForecastBloc>().add(LoadForecast(selectedCity));
    }
  }

  void _useCurrentLocation(BuildContext context) {
    context.read<WeatherBloc>().loadWeatherForCurrentLocation();
    // Note: Forecast will be loaded automatically when weather loads successfully
  }

  void _refreshWeather(BuildContext context) {
    context.read<WeatherBloc>().add(const RefreshWeather());
    context.read<ForecastBloc>().add(const RefreshForecast());
  }

  Widget _buildLoadingWidget(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.spacingXLarge),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
            strokeWidth: 3,
          ),
          const SizedBox(height: ThemeConstants.spacingLarge),
          Text(
            'Đang tải dữ liệu thời tiết...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedGlassContainer({
    required Widget child,
    required bool isDark,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: ThemeConstants.glassBlur * 1.2,
          sigmaY: ThemeConstants.glassBlur * 1.2,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(isDark ? 0.15 : 0.25),
                Colors.white.withOpacity(isDark ? 0.05 : 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 15),
                spreadRadius: -5,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildEnhancedWeatherCard({
    required dynamic weather,
    required bool isFromCache,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingMedium),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXXLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: ThemeConstants.glassBlur * 1.5,
            sigmaY: ThemeConstants.glassBlur * 1.5,
          ),
          child: Container(
            padding: const EdgeInsets.all(ThemeConstants.spacingXLarge),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusXXLarge),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 50,
                  offset: const Offset(0, 25),
                  spreadRadius: -10,
                ),
              ],
            ),
            child: WeatherCard(
              weather: weather,
              isFromCache: isFromCache,
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getAnimatedGradientColors(bool isDark) {
    final animationValue = _backgroundAnimation.value;
    
    if (isDark) {
      return [
        Color.lerp(const Color(0xFF1a1a2e), const Color(0xFF16213e), animationValue)!,
        Color.lerp(const Color(0xFF16213e), const Color(0xFF0f3460), animationValue)!,
        Color.lerp(const Color(0xFF0f3460), const Color(0xFF533483), animationValue)!,
        Color.lerp(const Color(0xFF533483), const Color(0xFF1a1a2e), animationValue)!,
      ];
    } else {
      return [
        Color.lerp(const Color(0xFF667eea), const Color(0xFF764ba2), animationValue)!,
        Color.lerp(const Color(0xFF764ba2), const Color(0xFF667eea), animationValue)!,
        Color.lerp(const Color(0xFF667eea), const Color(0xFFf093fb), animationValue)!,
        Color.lerp(const Color(0xFFf093fb), const Color(0xFF667eea), animationValue)!,
      ];
    }
  }

  List<Widget> _buildEnhancedFloatingParticles() {
    return List.generate(12, (index) {
      final delay = index * 0.3;
      final size = 6.0 + (index % 4) * 3.0;
      
      return AnimatedBuilder(
        animation: _backgroundAnimationController,
        builder: (context, child) {
          final progress = (_backgroundAnimationController.value + delay) % 1.0;
          final opacity = 0.1 + (math.sin(progress * 2 * math.pi) * 0.15).abs();
          final yOffset = math.sin(progress * 3 * math.pi) * 40;
          
          return Positioned(
            left: (progress * (MediaQuery.of(context).size.width + size)) - size,
            top: 80 + (index * 45.0) + yOffset,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(opacity),
                    Colors.white.withOpacity(opacity * 0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
                borderRadius: BorderRadius.circular(size / 2),
              ),
            ),
          );
        },
      );
    });
  }

}