import 'package:equatable/equatable.dart';
import '../../domain/entities/forecast.dart';

abstract class ForecastState extends Equatable {
  const ForecastState();

  @override
  List<Object?> get props => [];
}

class ForecastInitial extends ForecastState {
  const ForecastInitial();
}

class ForecastLoading extends ForecastState {
  const ForecastLoading();
}

class ForecastLoaded extends ForecastState {
  final Forecast forecast;
  final bool isFromCache;

  const ForecastLoaded({
    required this.forecast,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [forecast, isFromCache];
}

class ForecastError extends ForecastState {
  final String message;
  final Forecast? cachedForecast;

  const ForecastError({
    required this.message,
    this.cachedForecast,
  });

  @override
  List<Object?> get props => [message, cachedForecast];
}