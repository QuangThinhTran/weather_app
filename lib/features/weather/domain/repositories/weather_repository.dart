import '../entities/weather.dart';

abstract class WeatherRepository {
  Future<Weather> getCurrentWeather(String cityName);
  Future<Weather> getCurrentWeatherByCoordinates(double latitude, double longitude);
  Future<Weather> getCachedWeather(String cityName);
  Future<void> cacheWeather(Weather weather);
  Future<bool> isWeatherCached(String cityName);
}