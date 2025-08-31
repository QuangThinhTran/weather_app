import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'forecast_event.dart';
import 'forecast_state.dart';
import '../../domain/repositories/forecast_repository.dart';

class ForecastBloc extends Bloc<ForecastEvent, ForecastState> {
  final ForecastRepository _forecastRepository;
  String? _lastCityName;

  ForecastBloc({
    required ForecastRepository forecastRepository,
  }) : _forecastRepository = forecastRepository,
       super(const ForecastInitial()) {
    
    on<LoadForecast>(_onLoadForecast);
    on<LoadForecastByCoordinates>(_onLoadForecastByCoordinates);
    on<RefreshForecast>(_onRefreshForecast);
  }

  Future<void> _onLoadForecast(LoadForecast event, Emitter<ForecastState> emit) async {
    print('ForecastBloc: Loading forecast for ${event.cityName}');
    emit(const ForecastLoading());
    
    try {
      _lastCityName = event.cityName;
      
      // Check if we have cached data first
      final cachedForecast = await _forecastRepository.getCachedForecast(event.cityName);
      if (cachedForecast != null) {
        print('ForecastBloc: Emitting cached forecast data');
        emit(ForecastLoaded(forecast: cachedForecast, isFromCache: true));
      }

      // Try to get fresh data
      final forecast = await _forecastRepository.getForecast(event.cityName);
      print('ForecastBloc: Successfully loaded forecast');
      emit(ForecastLoaded(forecast: forecast, isFromCache: false));
      
    } catch (e) {
      print('ForecastBloc: Error loading forecast: $e');
      
      // Try to get cached data as fallback
      try {
        final cachedForecast = await _forecastRepository.getCachedForecast(event.cityName);
        if (cachedForecast != null) {
          emit(ForecastError(
            message: 'Unable to load fresh forecast data',
            cachedForecast: cachedForecast,
          ));
        } else {
          emit(ForecastError(message: _getErrorMessage(e)));
        }
      } catch (cacheError) {
        emit(ForecastError(message: _getErrorMessage(e)));
      }
    }
  }

  Future<void> _onLoadForecastByCoordinates(
    LoadForecastByCoordinates event, 
    Emitter<ForecastState> emit
  ) async {
    print('ForecastBloc: Loading forecast by coordinates (${event.latitude}, ${event.longitude})');
    emit(const ForecastLoading());
    
    try {
      final forecast = await _forecastRepository.getForecastByCoordinates(
        event.latitude, 
        event.longitude
      );
      _lastCityName = forecast.cityName;
      
      print('ForecastBloc: Successfully loaded forecast by coordinates');
      emit(ForecastLoaded(forecast: forecast, isFromCache: false));
      
    } catch (e) {
      print('ForecastBloc: Error loading forecast by coordinates: $e');
      emit(ForecastError(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onRefreshForecast(RefreshForecast event, Emitter<ForecastState> emit) async {
    if (_lastCityName == null) {
      print('ForecastBloc: No city to refresh forecast for');
      return;
    }
    
    print('ForecastBloc: Refreshing forecast for $_lastCityName');
    
    // Don't show loading state for refresh, keep current data visible
    final currentState = state;
    
    try {
      final forecast = await _forecastRepository.getForecast(_lastCityName!);
      print('ForecastBloc: Successfully refreshed forecast');
      emit(ForecastLoaded(forecast: forecast, isFromCache: false));
      
    } catch (e) {
      print('ForecastBloc: Error refreshing forecast: $e');
      
      // Keep current state if refresh fails and show error briefly
      if (currentState is ForecastLoaded) {
        emit(ForecastError(
          message: 'Unable to refresh forecast data',
          cachedForecast: currentState.forecast,
        ));
        
        // Return to loaded state after showing error briefly
        Timer(const Duration(seconds: 2), () {
          if (!isClosed && state is ForecastError) {
            emit(ForecastLoaded(
              forecast: currentState.forecast,
              isFromCache: true,
            ));
          }
        });
      } else {
        emit(ForecastError(message: _getErrorMessage(e)));
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('city not found') || errorString.contains('404')) {
      return 'Không tìm thấy thành phố này';
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet';
    } else if (errorString.contains('timeout')) {
      return 'Kết nối quá chậm. Vui lòng thử lại';
    } else if (errorString.contains('api key') || errorString.contains('401')) {
      return 'Lỗi API key. Vui lòng liên hệ developer';
    } else if (errorString.contains('too many requests') || errorString.contains('429')) {
      return 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
    } else {
      return 'Không thể tải dự báo thời tiết. Vui lòng thử lại';
    }
  }
}