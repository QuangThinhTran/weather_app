import 'weather_api_service.dart';

class MockWeatherApiService extends WeatherApiService {
  
  @override
  Future<Map<String, dynamic>> getCurrentWeather(String cityName) async {
    print('Mock Weather API: getCurrentWeather($cityName)');
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Return mock data for Vietnamese cities
    if (cityName.toLowerCase().contains('ho chi minh') || 
        cityName.toLowerCase().contains('saigon')) {
      return _getHoChiMinhWeather();
    } else if (cityName.toLowerCase().contains('hanoi') || 
               cityName.toLowerCase().contains('hà nội')) {
      return _getHanoiWeather();
    } else if (cityName.toLowerCase().contains('da nang') || 
               cityName.toLowerCase().contains('đà nẵng')) {
      return _getDaNangWeather();
    } else {
      return _getDefaultWeather(cityName);
    }
  }

  @override
  Future<Map<String, dynamic>> getCurrentWeatherByCoordinates(double latitude, double longitude) async {
    print('Mock Weather API: getCurrentWeatherByCoordinates($latitude, $longitude)');
    await Future.delayed(const Duration(seconds: 1));
    
    // Return mock data based on coordinates (rough approximation for Vietnam)
    if (latitude > 20.5 && latitude < 21.5 && longitude > 105.5 && longitude < 106.5) {
      return _getHanoiWeather();
    } else if (latitude > 10.5 && latitude < 11.5 && longitude > 106.5 && longitude < 107.5) {
      return _getHoChiMinhWeather();
    } else {
      return _getDefaultWeather('Current Location');
    }
  }

  @override
  Future<Map<String, dynamic>> getForecast(String cityName) async {
    print('Mock Weather API: getForecast($cityName)');
    await Future.delayed(const Duration(seconds: 1));
    
    final currentWeather = await getCurrentWeather(cityName);
    return {
      ...currentWeather,
      'forecast': {
        'forecastday': [
          _getForecastDay(DateTime.now(), 28, 'Nắng'),
          _getForecastDay(DateTime.now().add(const Duration(days: 1)), 30, 'Có mưa'),
          _getForecastDay(DateTime.now().add(const Duration(days: 2)), 26, 'Nhiều mây'),
        ]
      }
    };
  }

  @override
  Future<List<dynamic>> searchCities(String query) async {
    print('Mock Weather API: searchCities($query)');
    await Future.delayed(const Duration(milliseconds: 500));
    
    final cities = [
      {'name': 'Ho Chi Minh City', 'region': 'Ho Chi Minh', 'country': 'Vietnam'},
      {'name': 'Hanoi', 'region': 'Hanoi', 'country': 'Vietnam'},
      {'name': 'Da Nang', 'region': 'Da Nang', 'country': 'Vietnam'},
      {'name': 'Can Tho', 'region': 'Can Tho', 'country': 'Vietnam'},
      {'name': 'Hai Phong', 'region': 'Hai Phong', 'country': 'Vietnam'},
      {'name': 'Nha Trang', 'region': 'Khanh Hoa', 'country': 'Vietnam'},
      {'name': 'Hue', 'region': 'Thua Thien-Hue', 'country': 'Vietnam'},
    ];
    
    return cities.where((city) => 
      city['name']!.toLowerCase().contains(query.toLowerCase()) ||
      city['region']!.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  Map<String, dynamic> _getHoChiMinhWeather() {
    return {
      'location': {
        'name': 'Ho Chi Minh City',
        'region': 'Ho Chi Minh',
        'country': 'Vietnam',
        'lat': 10.75,
        'lon': 106.67,
      },
      'current': {
        'last_updated': DateTime.now().toIso8601String(),
        'temp_c': 28.5,
        'condition': {
          'text': 'Nắng',
          'icon': '//cdn.weatherapi.com/weather/64x64/day/113.png'
        },
        'humidity': 75,
        'wind_kph': 12.5,
        'pressure_mb': 1013.2,
        'feelslike_c': 32.1,
        'uv': 7.5,
        'vis_km': 10.0,
      }
    };
  }

  Map<String, dynamic> _getHanoiWeather() {
    return {
      'location': {
        'name': 'Hanoi',
        'region': 'Hanoi',
        'country': 'Vietnam',
        'lat': 21.03,
        'lon': 105.85,
      },
      'current': {
        'last_updated': DateTime.now().toIso8601String(),
        'temp_c': 25.2,
        'condition': {
          'text': 'Nhiều mây',
          'icon': '//cdn.weatherapi.com/weather/64x64/day/119.png'
        },
        'humidity': 80,
        'wind_kph': 8.3,
        'pressure_mb': 1015.1,
        'feelslike_c': 27.8,
        'uv': 5.2,
        'vis_km': 8.5,
      }
    };
  }

  Map<String, dynamic> _getDaNangWeather() {
    return {
      'location': {
        'name': 'Da Nang',
        'region': 'Da Nang',
        'country': 'Vietnam',
        'lat': 16.07,
        'lon': 108.22,
      },
      'current': {
        'last_updated': DateTime.now().toIso8601String(),
        'temp_c': 27.1,
        'condition': {
          'text': 'Có mưa nhẹ',
          'icon': '//cdn.weatherapi.com/weather/64x64/day/296.png'
        },
        'humidity': 85,
        'wind_kph': 15.2,
        'pressure_mb': 1012.8,
        'feelslike_c': 30.5,
        'uv': 6.1,
        'vis_km': 7.2,
      }
    };
  }

  Map<String, dynamic> _getDefaultWeather(String cityName) {
    return {
      'location': {
        'name': cityName,
        'region': '',
        'country': 'Vietnam',
        'lat': 16.0,
        'lon': 106.0,
      },
      'current': {
        'last_updated': DateTime.now().toIso8601String(),
        'temp_c': 26.0,
        'condition': {
          'text': 'Nắng ít mây',
          'icon': '//cdn.weatherapi.com/weather/64x64/day/116.png'
        },
        'humidity': 70,
        'wind_kph': 10.0,
        'pressure_mb': 1014.0,
        'feelslike_c': 28.5,
        'uv': 6.0,
        'vis_km': 9.0,
      }
    };
  }

  Map<String, dynamic> _getForecastDay(DateTime date, double temp, String condition) {
    return {
      'date': date.toIso8601String().split('T')[0],
      'day': {
        'maxtemp_c': temp + 2,
        'mintemp_c': temp - 5,
        'condition': {
          'text': condition,
          'icon': '//cdn.weatherapi.com/weather/64x64/day/116.png'
        }
      }
    };
  }
}