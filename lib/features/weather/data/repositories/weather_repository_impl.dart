import 'dart:async';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_api_service.dart';
import '../models/weather_model.dart';
import '../../../../core/services/cache_service.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherApiService _apiService;
  final CacheService _cacheService;
  final Map<String, Completer<Weather>> _pendingRequests = {};
  final Map<String, Weather> _memoryCache = {};
  static const int _memoryCacheMaxSize = 10;
  static const Duration _memoryCacheDuration = Duration(minutes: 5);
  final Map<String, DateTime> _memoryCacheTimestamps = {};

  WeatherRepositoryImpl({
    required WeatherApiService apiService,
    required CacheService cacheService,
  })  : _apiService = apiService,
        _cacheService = cacheService;

  @override
  Future<Weather> getCurrentWeather(String cityName) async {
    final normalizedCity = cityName.trim().toLowerCase();
    
    // Check memory cache first
    if (_isMemoryCacheValid(normalizedCity)) {
      return _memoryCache[normalizedCity]!;
    }

    // Check if request is already in progress
    if (_pendingRequests.containsKey(normalizedCity)) {
      return _pendingRequests[normalizedCity]!.future;
    }

    final completer = Completer<Weather>();
    _pendingRequests[normalizedCity] = completer;

    try {
      // Check persistent cache
      final cachedData = await _cacheService.getCachedWeatherData(cityName);
      if (cachedData != null) {
        final weatherModel = WeatherModel.fromCacheJson(cachedData);
        final weather = weatherModel.toEntity();
        _updateMemoryCache(normalizedCity, weather);
        completer.complete(weather);
        return weather;
      }

      // Fetch from API
      final jsonData = await _apiService.getCurrentWeather(cityName);
      final weatherModel = WeatherModel.fromJson(jsonData);
      final weather = weatherModel.toEntity();
      
      // Cache the data (fire and forget)
      unawaited(_cacheService.cacheWeatherData(cityName, weatherModel.toJson()));
      
      _updateMemoryCache(normalizedCity, weather);
      completer.complete(weather);
      return weather;
    } catch (e) {
      completer.completeError(WeatherRepositoryException('Failed to get current weather: $e'));
      rethrow;
    } finally {
      _pendingRequests.remove(normalizedCity);
    }
  }

  @override
  Future<Weather> getCurrentWeatherByCoordinates(double latitude, double longitude) async {
    final coordKey = '${latitude.toStringAsFixed(2)},${longitude.toStringAsFixed(2)}';
    
    // Check if request is already in progress
    if (_pendingRequests.containsKey(coordKey)) {
      return _pendingRequests[coordKey]!.future;
    }

    final completer = Completer<Weather>();
    _pendingRequests[coordKey] = completer;

    try {
      final jsonData = await _apiService.getCurrentWeatherByCoordinates(latitude, longitude);
      final weatherModel = WeatherModel.fromJson(jsonData);
      final weather = weatherModel.toEntity();
      
      // Cache by city name (fire and forget)
      unawaited(_cacheService.cacheWeatherData(weatherModel.cityName, weatherModel.toJson()));
      
      final normalizedCity = weatherModel.cityName.trim().toLowerCase();
      _updateMemoryCache(normalizedCity, weather);
      
      completer.complete(weather);
      return weather;
    } catch (e) {
      completer.completeError(WeatherRepositoryException('Failed to get weather by coordinates: $e'));
      rethrow;
    } finally {
      _pendingRequests.remove(coordKey);
    }
  }

  @override
  Future<Weather> getCachedWeather(String cityName) async {
    final normalizedCity = cityName.trim().toLowerCase();
    
    // Check memory cache first
    if (_memoryCache.containsKey(normalizedCity)) {
      return _memoryCache[normalizedCity]!;
    }

    try {
      final cachedData = await _cacheService.getCachedWeatherData(cityName);
      if (cachedData != null) {
        final weatherModel = WeatherModel.fromCacheJson(cachedData);
        final weather = weatherModel.toEntity();
        _updateMemoryCache(normalizedCity, weather);
        return weather;
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
      final normalizedCity = weather.cityName.trim().toLowerCase();
      
      // Update memory cache
      _updateMemoryCache(normalizedCity, weather);
      
      // Update persistent cache (fire and forget)
      unawaited(_cacheService.cacheWeatherData(weather.cityName, weatherModel.toJson()));
    } catch (e) {
      throw WeatherRepositoryException('Failed to cache weather: $e');
    }
  }

  @override
  Future<bool> isWeatherCached(String cityName) async {
    final normalizedCity = cityName.trim().toLowerCase();
    
    // Check memory cache first
    if (_memoryCache.containsKey(normalizedCity)) {
      return true;
    }

    try {
      final cachedData = await _cacheService.getCachedWeatherData(cityName);
      return cachedData != null;
    } catch (e) {
      return false;
    }
  }

  bool _isMemoryCacheValid(String normalizedCity) {
    if (!_memoryCache.containsKey(normalizedCity)) return false;
    
    final timestamp = _memoryCacheTimestamps[normalizedCity];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _memoryCacheDuration;
  }

  void _updateMemoryCache(String normalizedCity, Weather weather) {
    // Remove oldest entries if cache is full
    if (_memoryCache.length >= _memoryCacheMaxSize) {
      final oldestEntry = _memoryCacheTimestamps.entries.reduce(
        (a, b) => a.value.isBefore(b.value) ? a : b,
      );
      _memoryCache.remove(oldestEntry.key);
      _memoryCacheTimestamps.remove(oldestEntry.key);
    }
    
    _memoryCache[normalizedCity] = weather;
    _memoryCacheTimestamps[normalizedCity] = DateTime.now();
  }
  void clearMemoryCache() {
    _memoryCache.clear();
    _memoryCacheTimestamps.clear();
  }
}

void unawaited(Future<void> future) {
  // Helper function to explicitly ignore futures
}

class WeatherRepositoryException implements Exception {
  final String message;
  WeatherRepositoryException(this.message);

  @override
  String toString() => 'WeatherRepositoryException: $message';
}