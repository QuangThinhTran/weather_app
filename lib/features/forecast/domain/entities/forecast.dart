import 'package:equatable/equatable.dart';

class Forecast extends Equatable {
  final String cityName;
  final List<DailyForecast> dailyForecasts;
  final List<HourlyForecast> hourlyForecasts;

  const Forecast({
    required this.cityName,
    required this.dailyForecasts,
    required this.hourlyForecasts,
  });

  @override
  List<Object> get props => [cityName, dailyForecasts, hourlyForecasts];

  @override
  String toString() {
    return 'Forecast(cityName: $cityName, daily: ${dailyForecasts.length}, hourly: ${hourlyForecasts.length})';
  }
}

class DailyForecast extends Equatable {
  final DateTime date;
  final double maxTemperature;
  final double minTemperature;
  final String condition;
  final String iconUrl;
  final int precipitationChance;
  final double maxWindSpeed;
  final double avgHumidity;
  final double uvIndex;

  const DailyForecast({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.condition,
    required this.iconUrl,
    required this.precipitationChance,
    required this.maxWindSpeed,
    required this.avgHumidity,
    required this.uvIndex,
  });

  @override
  List<Object> get props => [
        date,
        maxTemperature,
        minTemperature,
        condition,
        iconUrl,
        precipitationChance,
        maxWindSpeed,
        avgHumidity,
        uvIndex,
      ];

  @override
  String toString() {
    return 'DailyForecast(date: $date, temp: ${maxTemperature}°/${minTemperature}°, condition: $condition)';
  }
}

class HourlyForecast extends Equatable {
  final DateTime dateTime;
  final double temperature;
  final String condition;
  final String iconUrl;
  final int precipitationChance;
  final double windSpeed;
  final int humidity;
  final double feelsLike;

  const HourlyForecast({
    required this.dateTime,
    required this.temperature,
    required this.condition,
    required this.iconUrl,
    required this.precipitationChance,
    required this.windSpeed,
    required this.humidity,
    required this.feelsLike,
  });

  @override
  List<Object> get props => [
        dateTime,
        temperature,
        condition,
        iconUrl,
        precipitationChance,
        windSpeed,
        humidity,
        feelsLike,
      ];

  @override
  String toString() {
    return 'HourlyForecast(time: $dateTime, temp: ${temperature}°C, condition: $condition)';
  }
}