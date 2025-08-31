import 'package:dio/dio.dart';

// Core Services
import 'core/services/location_service.dart';
import 'core/services/cache_service.dart';

// Data Sources
import 'features/weather/data/datasources/weather_api_service.dart';

// Repositories
import 'features/weather/domain/repositories/weather_repository.dart';
import 'features/weather/data/repositories/weather_repository_impl.dart';
import 'features/search/domain/repositories/search_repository.dart';
import 'features/search/data/repositories/search_repository_impl.dart';
import 'features/forecast/domain/repositories/forecast_repository.dart';
import 'features/forecast/data/repositories/forecast_repository_impl.dart';

// BLoCs
import 'features/weather/presentation/bloc/weather_bloc.dart';
import 'features/search/presentation/bloc/search_bloc.dart';
import 'features/forecast/presentation/bloc/forecast_bloc.dart';

class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  // Singletons
  late final Dio _dio;
  late final LocationService _locationService;
  late final CacheService _cacheService;
  late final WeatherApiService _weatherApiService;
  late final WeatherRepository _weatherRepository;
  late final SearchRepository _searchRepository;
  late final ForecastRepository _forecastRepository;

  Future<void> init() async {
    // Initialize core services
    _dio = Dio();
    _locationService = LocationService();
    _cacheService = CacheService.instance;
    await _cacheService.init();

    // Initialize API services
    _weatherApiService = WeatherApiService(dio: _dio);

    // Initialize repositories
    _weatherRepository = WeatherRepositoryImpl(
      apiService: _weatherApiService,
      cacheService: _cacheService,
    );
    
    _searchRepository = SearchRepositoryImpl(
      apiService: _weatherApiService,
      cacheService: _cacheService,
    );
    
    _forecastRepository = ForecastRepositoryImpl(
      apiService: _weatherApiService,
      cacheService: _cacheService,
    );
  }

  // Core Services
  LocationService get locationService => _locationService;
  CacheService get cacheService => _cacheService;

  // API Services
  WeatherApiService get weatherApiService => _weatherApiService;

  // Repositories
  WeatherRepository get weatherRepository => _weatherRepository;
  SearchRepository get searchRepository => _searchRepository;
  ForecastRepository get forecastRepository => _forecastRepository;

  // BLoCs (Factory methods - create new instances)
  WeatherBloc createWeatherBloc() {
    return WeatherBloc(
      weatherRepository: _weatherRepository,
      locationService: _locationService,
    );
  }

  SearchBloc createSearchBloc() {
    return SearchBloc(
      searchRepository: _searchRepository,
    );
  }

  ForecastBloc createForecastBloc() {
    return ForecastBloc(
      forecastRepository: _forecastRepository,
    );
  }


  // Cleanup method
  void dispose() {
    _dio.close();
  }
}