import 'package:equatable/equatable.dart';
import '../../domain/entities/weather.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final Weather weather;
  final bool isFromCache;

  const WeatherLoaded(this.weather, {this.isFromCache = false});

  @override
  List<Object> get props => [weather, isFromCache];
}

class WeatherError extends WeatherState {
  final String message;
  final Weather? cachedWeather;

  const WeatherError(this.message, {this.cachedWeather});

  @override
  List<Object?> get props => [message, cachedWeather];
}

class WeatherLocationPermissionDenied extends WeatherState {
  final String message;

  const WeatherLocationPermissionDenied(this.message);

  @override
  List<Object> get props => [message];
}