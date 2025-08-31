import 'injection_container.dart';
import 'features/weather/presentation/bloc/weather_bloc.dart';
import 'features/search/presentation/bloc/search_bloc.dart';
import 'features/forecast/presentation/bloc/forecast_bloc.dart';

// Global service locator instance
final sl = ServiceLocator();

class ServiceLocator {
  final _container = InjectionContainer();

  Future<void> init() async {
    await _container.init();
  }

  // Generic get method
  T call<T>() {
    if (T == WeatherBloc) {
      return _container.createWeatherBloc() as T;
    } else if (T == SearchBloc) {
      return _container.createSearchBloc() as T;
    } else if (T == ForecastBloc) {
      return _container.createForecastBloc() as T;
    } else {
      throw Exception('Type $T is not registered in ServiceLocator');
    }
  }

  void dispose() {
    _container.dispose();
  }
}