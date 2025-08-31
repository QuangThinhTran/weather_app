import '../entities/forecast.dart';

abstract class ForecastRepository {
  Future<Forecast> getForecast(String cityName);
  Future<Forecast> getForecastByCoordinates(double latitude, double longitude);
  Future<Forecast?> getCachedForecast(String cityName);
  Future<void> cacheForecast(Forecast forecast);
  Future<bool> isForecastCached(String cityName);
}