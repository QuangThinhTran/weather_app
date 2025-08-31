import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_api_service.dart';
import '../models/weather_model.dart';
import '../../../../core/services/cache_service.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherApiService _apiService;
  final CacheService _cacheService;

  WeatherRepositoryImpl({
    required WeatherApiService apiService,
    required CacheService cacheService,
  })  : _apiService = apiService,
        _cacheService = cacheService;

  @override
  Future<Weather> getCurrentWeather(String cityName) async {
    try {
      // Check cache first
      final cachedData = await _cacheService.getCachedWeatherData(cityName);
      if (cachedData != null) {
        final weatherModel = WeatherModel.fromCacheJson(cachedData);
        return weatherModel.toEntity();
      }

      // Fetch from API
      final jsonData = await _apiService.getCurrentWeather(cityName);
      final weatherModel = WeatherModel.fromJson(jsonData);
      
      // Cache the data
      await _cacheService.cacheWeatherData(cityName, weatherModel.toJson());
      
      return weatherModel.toEntity();
    } catch (e) {
      throw WeatherRepositoryException('Failed to get current weather: $e');
    }
  }

  @override
  Future<Weather> getCurrentWeatherByCoordinates(double latitude, double longitude) async {
    try {
      final jsonData = await _apiService.getCurrentWeatherByCoordinates(latitude, longitude);
      final weatherModel = WeatherModel.fromJson(jsonData);
      
      // Cache by city name
      await _cacheService.cacheWeatherData(weatherModel.cityName, weatherModel.toJson());
      
      return weatherModel.toEntity();
    } catch (e) {
      throw WeatherRepositoryException('Failed to get weather by coordinates: $e');
    }
  }

  @override
  Future<Weather> getCachedWeather(String cityName) async {
    try {
      final cachedData = await _cacheService.getCachedWeatherData(cityName);
      if (cachedData != null) {
        final weatherModel = WeatherModel.fromCacheJson(cachedData);
        return weatherModel.toEntity();
      } else {
        throw WeatherRepositoryException('No cached weather data for $cityName');
      }
    } catch (e) {
      throw WeatherRepositoryException('Failed to get cached weather: $e');
    }
  }

  @override
  Future<void> cacheWeather(Weather weather) async {
    try {
      final weatherModel = WeatherModel.fromEntity(weather);
      await _cacheService.cacheWeatherData(weather.cityName, weatherModel.toJson());
    } catch (e) {
      throw WeatherRepositoryException('Failed to cache weather: $e');
    }
  }

  @override
  Future<bool> isWeatherCached(String cityName) async {
    try {
      final cachedData = await _cacheService.getCachedWeatherData(cityName);
      return cachedData != null;
    } catch (e) {
      return false;
    }
  }
}

class WeatherRepositoryException implements Exception {
  final String message;
  WeatherRepositoryException(this.message);

  @override
  String toString() => 'WeatherRepositoryException: $message';
}