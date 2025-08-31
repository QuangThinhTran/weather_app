import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../service_locator.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    // Load weather for current location or default city
    _loadInitialWeather();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dự Báo Thời Tiết'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _navigateToSearch(context),
            tooltip: 'Tìm kiếm thành phố',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<WeatherBloc>().add(const RefreshWeather());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
          child: BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, state) {
              if (state is WeatherLoading) {
                return const Column(
                  children: [
                    SizedBox(height: ThemeConstants.spacingXLarge),
                    WeatherCardLoadingWidget(),
                  ],
                );
              } else if (state is WeatherLoaded) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: ThemeConstants.spacingLarge),
                      WeatherCard(
                        weather: state.weather,
                        isFromCache: state.isFromCache,
                      ),
                      const SizedBox(height: ThemeConstants.spacingSmall),
                      
                      // Weather Details Section (Sunrise/Sunset, Wind/Humidity, etc.)
                      WeatherDetailsSection(
                        weather: state.weather,
                      ),
                      const SizedBox(height: ThemeConstants.spacingSmall),
                      
                      
                      // Forecast sections
                      BlocBuilder<ForecastBloc, ForecastState>(
                        builder: (context, forecastState) {
                          if (forecastState is ForecastLoaded) {
                            return Column(
                              children: [
                                // Hourly forecast
                                HourlyForecastWidget(
                                  hourlyForecasts: forecastState.forecast.hourlyForecasts,
                                  currentWeather: state.weather,
                                ),
                                const SizedBox(height: ThemeConstants.spacingSmall),
                                
                                // Daily forecast
                                DailyForecastWidget(
                                  dailyForecasts: forecastState.forecast.dailyForecasts,
                                  hourlyForecasts: forecastState.forecast.hourlyForecasts,
                                  currentWeather: state.weather,
                                ),
                              ],
                            );
                          } else if (forecastState is ForecastError && forecastState.cachedForecast != null) {
                            return Column(
                              children: [
                                // Show cached forecast with error indication
                                HourlyForecastWidget(
                                  hourlyForecasts: forecastState.cachedForecast!.hourlyForecasts,
                                  currentWeather: state.weather,
                                ),
                                const SizedBox(height: ThemeConstants.spacingSmall),
                                DailyForecastWidget(
                                  dailyForecasts: forecastState.cachedForecast!.dailyForecasts,
                                  hourlyForecasts: forecastState.cachedForecast!.hourlyForecasts,
                                  currentWeather: state.weather,
                                ),
                              ],
                            );
                          } else if (forecastState is ForecastLoading) {
                            return Column(
                              children: [
                                Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: ThemeConstants.spacingMedium,
                                    vertical: ThemeConstants.spacingSmall,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(ThemeConstants.spacingLarge),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      
                      const SizedBox(height: ThemeConstants.spacingLarge),
                    ],
                  ),
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

}