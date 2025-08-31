import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  final String cityName;
  final String country;
  final double temperature;
  final String condition;
  final String iconUrl;
  final int humidity;
  final double windSpeed;
  final double pressure;
  final double feelsLike;
  final double uvIndex;
  final double visibility;
  final DateTime lastUpdated;
  final double? latitude;
  final double? longitude;
  final String? sunrise;
  final String? sunset;

  const Weather({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.condition,
    required this.iconUrl,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.feelsLike,
    required this.uvIndex,
    required this.visibility,
    required this.lastUpdated,
    this.latitude,
    this.longitude,
    this.sunrise,
    this.sunset,
  });

  @override
  List<Object?> get props => [
        cityName,
        country,
        temperature,
        condition,
        iconUrl,
        humidity,
        windSpeed,
        pressure,
        feelsLike,
        uvIndex,
        visibility,
        lastUpdated,
        latitude,
        longitude,
        sunrise,
        sunset,
      ];

  @override
  String toString() {
    return 'Weather(cityName: $cityName, temperature: $temperature°C, condition: $condition)';
  }
}