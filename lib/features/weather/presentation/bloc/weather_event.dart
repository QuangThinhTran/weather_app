import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object?> get props => [];
}

class LoadWeatherByCity extends WeatherEvent {
  final String cityName;

  const LoadWeatherByCity(this.cityName);

  @override
  List<Object> get props => [cityName];
}

class LoadWeatherByLocation extends WeatherEvent {
  final double latitude;
  final double longitude;

  const LoadWeatherByLocation(this.latitude, this.longitude);

  @override
  List<Object> get props => [latitude, longitude];
}

class RefreshWeather extends WeatherEvent {
  const RefreshWeather();
}

class LoadCachedWeather extends WeatherEvent {
  final String cityName;

  const LoadCachedWeather(this.cityName);

  @override
  List<Object> get props => [cityName];
}