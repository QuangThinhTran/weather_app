import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../../../core/services/location_service.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository _weatherRepository;
  final LocationService _locationService;
  String? _currentCity;

  WeatherBloc({
    required WeatherRepository weatherRepository,
    required LocationService locationService,
  })  : _weatherRepository = weatherRepository,
        _locationService = locationService,
        super(WeatherInitial()) {
    
    on<LoadWeatherByCity>(_onLoadWeatherByCity);
    on<LoadWeatherByLocation>(_onLoadWeatherByLocation);
    on<RefreshWeather>(_onRefreshWeather);
    on<LoadCachedWeather>(_onLoadCachedWeather);
  }

  Future<void> _onLoadWeatherByCity(
    LoadWeatherByCity event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());
    
    try {
      final weather = await _weatherRepository.getCurrentWeather(event.cityName);
      _currentCity = event.cityName;
      emit(WeatherLoaded(weather));
    } catch (e) {
      // Try to get cached weather as fallback
      try {
        final cachedWeather = await _weatherRepository.getCachedWeather(event.cityName);
        emit(WeatherError(
          'Failed to fetch current weather: ${e.toString()}',
          cachedWeather: cachedWeather,
        ));
      } catch (_) {
        emit(WeatherError('Failed to fetch weather: ${e.toString()}'));
      }
    }
  }

  Future<void> _onLoadWeatherByLocation(
    LoadWeatherByLocation event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());
    
    try {
      final weather = await _weatherRepository.getCurrentWeatherByCoordinates(
        event.latitude,
        event.longitude,
      );
      _currentCity = weather.cityName;
      emit(WeatherLoaded(weather));
    } catch (e) {
      emit(WeatherError('Failed to fetch weather by location: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshWeather(
    RefreshWeather event,
    Emitter<WeatherState> emit,
  ) async {
    if (state is WeatherLoaded) {
      final currentWeather = (state as WeatherLoaded).weather;
      _currentCity = currentWeather.cityName;
    }

    if (_currentCity != null) {
      add(LoadWeatherByCity(_currentCity!));
    } else {
      // Try to get current location
      try {
        final position = await _locationService.getCurrentPosition();
        if (position != null) {
          add(LoadWeatherByLocation(position.latitude, position.longitude));
        } else {
          emit(const WeatherLocationPermissionDenied('Unable to get current location'));
        }
      } catch (e) {
        emit(WeatherError('Failed to get location: ${e.toString()}'));
      }
    }
  }

  Future<void> _onLoadCachedWeather(
    LoadCachedWeather event,
    Emitter<WeatherState> emit,
  ) async {
    try {
      final cachedWeather = await _weatherRepository.getCachedWeather(event.cityName);
      emit(WeatherLoaded(cachedWeather, isFromCache: true));
    } catch (e) {
      emit(WeatherError('No cached weather available: ${e.toString()}'));
    }
  }

  // Method to get current location and load weather
  Future<void> loadWeatherForCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        add(LoadWeatherByLocation(position.latitude, position.longitude));
      } else {
        emit(const WeatherLocationPermissionDenied('Location permission denied'));
      }
    } catch (e) {
      if (e is LocationException) {
        emit(WeatherLocationPermissionDenied(e.toString()));
      } else {
        emit(WeatherError('Failed to get location: ${e.toString()}'));
      }
    }
  }
}