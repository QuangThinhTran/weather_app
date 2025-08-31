import 'dart:convert';
import '../../domain/entities/forecast.dart';
import '../../domain/repositories/forecast_repository.dart';
import '../models/forecast_model.dart';
import '../../../weather/data/datasources/weather_api_service.dart';
import '../../../../core/services/cache_service.dart';

class ForecastRepositoryImpl implements ForecastRepository {
  final WeatherApiService _apiService;
  final CacheService _cacheService;
  static const String _forecastCacheKey = 'forecast_cache';

  ForecastRepositoryImpl({
    required WeatherApiService apiService,
    required CacheService cacheService,
  }) : _apiService = apiService, _cacheService = cacheService;

  @override
  Future<Forecast> getForecast(String cityName) async {
    try {
      print('ForecastRepository: Getting forecast for $cityName');
      
      // Try to get cached data first
      final cachedForecast = await getCachedForecast(cityName);
      if (cachedForecast != null) {
        print('ForecastRepository: Using cached forecast data');
        return cachedForecast;
      }

      // Fetch from API
      print('ForecastRepository: Fetching from API');
      final apiResponse = await _apiService.getForecast(cityName);
      final forecastModel = ForecastModel.fromJson(apiResponse);
      final forecast = forecastModel.toEntity();

      // Cache the result
      await cacheForecast(forecast);
      
      print('ForecastRepository: Successfully fetched and cached forecast');
      return forecast;
    } catch (e) {
      print('ForecastRepository: Error getting forecast: $e');
      
      // Try to return cached data even if expired
      final cachedForecast = await getCachedForecast(cityName);
      if (cachedForecast != null) {
        print('ForecastRepository: Returning expired cached data due to error');
        return cachedForecast;
      }
      
      rethrow;
    }
  }

  @override
  Future<Forecast> getForecastByCoordinates(double latitude, double longitude) async {
    try {
      print('ForecastRepository: Getting forecast by coordinates ($latitude, $longitude)');
      
      final apiResponse = await _apiService.getForecast('$latitude,$longitude');
      final forecastModel = ForecastModel.fromJson(apiResponse);
      final forecast = forecastModel.toEntity();

      // Cache with city name from response
      await cacheForecast(forecast);
      
      return forecast;
    } catch (e) {
      print('ForecastRepository: Error getting forecast by coordinates: $e');
      rethrow;
    }
  }

  @override
  Future<Forecast?> getCachedForecast(String cityName) async {
    try {
      final cacheKey = '${_forecastCacheKey}_${cityName.toLowerCase()}';
      final cachedString = await _cacheService.getString(cacheKey);
      
      if (cachedString != null) {
        final cacheData = jsonDecode(cachedString);
        final timestamp = cacheData['timestamp'] as int;
        final now = DateTime.now().millisecondsSinceEpoch;
        
        // Check if cache is still valid (30 minutes for forecast)
        const forecastCacheTimeout = 30 * 60 * 1000; // 30 minutes
        if (now - timestamp < forecastCacheTimeout) {
          final forecastModel = ForecastModel.fromCacheJson(cacheData['data']);
          return forecastModel.toEntity();
        } else {
          print('ForecastRepository: Cached forecast expired');
          await _cacheService.remove(cacheKey);
        }
      }
      
      return null;
    } catch (e) {
      print('ForecastRepository: Error reading cached forecast: $e');
      return null;
    }
  }

  @override
  Future<void> cacheForecast(Forecast forecast) async {
    try {
      final cacheKey = '${_forecastCacheKey}_${forecast.cityName.toLowerCase()}';
      final forecastModel = _convertEntityToModel(forecast);
      
      final cacheData = {
        'data': forecastModel.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'cityName': forecast.cityName,
      };
      
      final cacheString = jsonEncode(cacheData);
      await _cacheService.setString(cacheKey, cacheString);
      
      print('ForecastRepository: Cached forecast for ${forecast.cityName}');
    } catch (e) {
      print('ForecastRepository: Error caching forecast: $e');
      // Don't throw error for caching failures
    }
  }

  @override
  Future<bool> isForecastCached(String cityName) async {
    try {
      final cachedForecast = await getCachedForecast(cityName);
      return cachedForecast != null;
    } catch (e) {
      return false;
    }
  }

  ForecastModel _convertEntityToModel(Forecast forecast) {
    return ForecastModel(
      cityName: forecast.cityName,
      dailyForecasts: forecast.dailyForecasts.map((daily) => DailyForecastModel(
        date: daily.date,
        maxTemperature: daily.maxTemperature,
        minTemperature: daily.minTemperature,
        condition: daily.condition,
        iconUrl: daily.iconUrl,
        precipitationChance: daily.precipitationChance,
        maxWindSpeed: daily.maxWindSpeed,
        avgHumidity: daily.avgHumidity,
        uvIndex: daily.uvIndex,
      )).toList(),
      hourlyForecasts: forecast.hourlyForecasts.map((hourly) => HourlyForecastModel(
        dateTime: hourly.dateTime,
        temperature: hourly.temperature,
        condition: hourly.condition,
        iconUrl: hourly.iconUrl,
        precipitationChance: hourly.precipitationChance,
        windSpeed: hourly.windSpeed,
        humidity: hourly.humidity,
        feelsLike: hourly.feelsLike,
      )).toList(),
    );
  }
}