import 'package:equatable/equatable.dart';

abstract class ForecastEvent extends Equatable {
  const ForecastEvent();

  @override
  List<Object?> get props => [];
}

class LoadForecast extends ForecastEvent {
  final String cityName;

  const LoadForecast(this.cityName);

  @override
  List<Object?> get props => [cityName];
}

class LoadForecastByCoordinates extends ForecastEvent {
  final double latitude;
  final double longitude;

  const LoadForecastByCoordinates(this.latitude, this.longitude);

  @override
  List<Object?> get props => [latitude, longitude];
}

class RefreshForecast extends ForecastEvent {
  const RefreshForecast();
}