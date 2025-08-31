# Weather App - API Integration Guide

## 1. API Overview

### Recommended API: WeatherAPI.com ⭐
**Why**: Free, Vietnamese support, easy to use, perfect for personal projects

- **Free Tier**: 1,000,000 calls/month (33,333/day)
- **API Key**: `d7978114e18e41f299f200335252908` 
- **Base URL**: `https://api.weatherapi.com/v1`
- **Vietnamese**: Support `lang=vi` parameter

---

## 2. Feature to API Mapping

| Feature | User Stories | API Endpoint | Purpose |
|---------|--------------|--------------|---------|
| **Current Weather** | US-001 to US-003 | `/current.json` | Display current weather data |
| **City Search** | US-004 to US-007 | `/search.json` | Search and autocomplete cities |
| **Weather Forecast** | US-012 to US-015 | `/forecast.json` | 3-day hourly/daily forecast |

---

## 3. API Endpoints Details

### 3.1 Current Weather
```dart
// GET /current.json
// Parameters: key, q (city or lat,lon), lang=vi

// Example Request:
https://api.weatherapi.com/v1/current.json?key=d7978114e18e41f299f200335252908&q=Ho Chi Minh City&lang=vi

// Response Data Mapping:
location.name → Weather.cityName
current.temp_c → Weather.temperature
current.condition.text → Weather.condition (Vietnamese)
current.humidity → Weather.humidity
current.wind_kph → Weather.windSpeed
current.pressure_mb → Weather.pressure
```

### 3.2 City Search
```dart
// GET /search.json  
// Parameters: key, q (search query)

// Example Request:
https://api.weatherapi.com/v1/search.json?key=d7978114e18e41f299f200335252908&q=Hanoi

// Response Data Mapping:
name → City.name
country → City.country
lat, lon → City.coordinates
```

### 3.3 Weather Forecast
```dart
// GET /forecast.json
// Parameters: key, q (city), days=3, lang=vi

// Example Request:
https://api.weatherapi.com/v1/forecast.json?key=d7978114e18e41f299f200335252908&q=Da Nang&days=3&lang=vi

// Response Data Mapping:
forecast.forecastday[].hour[] → Hourly forecast
forecast.forecastday[].day → Daily forecast
```

---

## 4. Architecture Integration

### 4.1 Clean Architecture Layers

```
Domain Layer (Business Logic)
├── entities/
│   ├── weather.dart          # Pure business object
│   ├── forecast.dart         # Forecast data structure  
│   └── city.dart            # City search results
├── repositories/
│   └── weather_repository.dart # Abstract interface
└── usecases/
    ├── get_current_weather.dart
    ├── search_cities.dart
    └── get_forecast.dart

Data Layer (API Integration)  
├── models/
│   ├── weather_model.dart    # JSON ↔ Entity conversion
│   ├── forecast_model.dart   # API response model
│   └── city_model.dart       # Search response model
├── datasources/
│   └── weather_remote_datasource.dart # API calls
└── repositories/
    └── weather_repository_impl.dart   # Implementation

Presentation Layer (UI)
├── bloc/
│   ├── weather_bloc.dart     # State management
│   ├── search_bloc.dart      # Search state
│   └── forecast_bloc.dart    # Forecast state
└── screens/
    ├── weather_screen.dart   # Main weather UI
    ├── search_screen.dart    # City search UI
    └── forecast_screen.dart  # Forecast UI
```

### 4.2 Data Flow Example

```dart
// 1. User Story US-001: Show current weather
WeatherScreen → WeatherBloc → GetCurrentWeatherUseCase → 
WeatherRepository → WeatherRemoteDataSource → WeatherAPI.com

// 2. User Story US-004: Search cities  
SearchScreen → SearchBloc → SearchCitiesUseCase → 
SearchRepository → SearchRemoteDataSource → WeatherAPI.com/search
```

---

## 5. Simple Implementation

### 5.1 API Service (Data Layer)
```dart
// lib/features/weather/data/datasources/weather_api_service.dart
import 'package:dio/dio.dart';

class WeatherApiService {
  final Dio _dio = Dio();
  static const String baseUrl = 'https://api.weatherapi.com/v1';
  static const String apiKey = 'd7978114e18e41f299f200335252908';

  // Current Weather (US-001, US-002, US-003)
  Future<Map<String, dynamic>> getCurrentWeather(String cityName) async {
    final response = await _dio.get(
      '$baseUrl/current.json',
      queryParameters: {
        'key': apiKey,
        'q': cityName,
        'lang': 'vi',
      },
    );
    return response.data;
  }

  // City Search (US-004, US-005, US-006) 
  Future<List<dynamic>> searchCities(String query) async {
    final response = await _dio.get(
      '$baseUrl/search.json',
      queryParameters: {
        'key': apiKey,
        'q': query,
      },
    );
    return response.data;
  }

  // Weather Forecast (US-012, US-013, US-014)
  Future<Map<String, dynamic>> getForecast(String cityName) async {
    final response = await _dio.get(
      '$baseUrl/forecast.json',
      queryParameters: {
        'key': apiKey,
        'q': cityName,
        'days': 3,
        'lang': 'vi',
      },
    );
    return response.data;
  }

  // GPS Weather (US-008, US-009, US-010)
  Future<Map<String, dynamic>> getCurrentWeatherByCoords(double lat, double lon) async {
    final response = await _dio.get(
      '$baseUrl/current.json',
      queryParameters: {
        'key': apiKey,
        'q': '$lat,$lon',
        'lang': 'vi',
      },
    );
    return response.data;
  }
}
```

### 5.2 Data Models (Simple JSON Parsing)
```dart
// lib/features/weather/data/models/weather_model.dart
class WeatherModel {
  final String cityName;
  final double temperature;
  final String condition;
  final int humidity;
  final double windSpeed;
  final double pressure;
  final String iconUrl;
  final DateTime lastUpdated;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.iconUrl,
    required this.lastUpdated,
  });

  // Simple factory constructor (no code generation needed)
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['location']['name'],
      temperature: json['current']['temp_c'].toDouble(),
      condition: json['current']['condition']['text'],
      humidity: json['current']['humidity'],
      windSpeed: json['current']['wind_kph'].toDouble(),
      pressure: json['current']['pressure_mb'].toDouble(),
      iconUrl: 'https:${json['current']['condition']['icon']}',
      lastUpdated: DateTime.parse(json['current']['last_updated']),
    );
  }
}
```

### 5.3 Repository Implementation
```dart
// lib/features/weather/data/repositories/weather_repository_impl.dart
import '../datasources/weather_api_service.dart';
import '../models/weather_model.dart';
import '../../domain/repositories/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherApiService apiService;

  WeatherRepositoryImpl({required this.apiService});

  @override
  Future<WeatherModel> getCurrentWeather(String cityName) async {
    try {
      final jsonData = await apiService.getCurrentWeather(cityName);
      return WeatherModel.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to fetch weather: $e');
    }
  }

  @override
  Future<List<CityModel>> searchCities(String query) async {
    try {
      final jsonData = await apiService.searchCities(query);
      return jsonData.map((json) => CityModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search cities: $e');
    }
  }
}
```

---

## 6. Error Handling & Offline

### 6.1 Simple Error Handling
```dart
// lib/core/errors/exceptions.dart
class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);
}

class NetworkException extends WeatherException {
  NetworkException() : super('No internet connection');
}

class CityNotFoundException extends WeatherException {
  CityNotFoundException() : super('City not found');
}
```

### 6.2 Basic Caching (No Complex Cache Management)
```dart
// lib/core/services/simple_cache_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SimpleCacheService {
  static const String _weatherCacheKey = 'weather_cache';
  
  Future<void> cacheWeatherData(String cityName, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'city': cityName,
    };
    await prefs.setString('${_weatherCacheKey}_$cityName', jsonEncode(cacheData));
  }
  
  Future<Map<String, dynamic>?> getCachedWeatherData(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString('${_weatherCacheKey}_$cityName');
    
    if (cachedString != null) {
      final cacheData = jsonDecode(cachedString);
      final timestamp = cacheData['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Use cache if data is less than 10 minutes old
      if (now - timestamp < 600000) { // 10 minutes = 600,000ms
        return cacheData['data'];
      }
    }
    return null;
  }
}
```

---

## 7. BLoC Integration Example

### 7.1 Simple Weather BLoC
```dart
// lib/features/weather/presentation/bloc/weather_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../data/models/weather_model.dart';

// Events
abstract class WeatherEvent {}
class LoadWeatherEvent extends WeatherEvent {
  final String cityName;
  LoadWeatherEvent(this.cityName);
}

// States  
abstract class WeatherState {}
class WeatherInitial extends WeatherState {}
class WeatherLoading extends WeatherState {}
class WeatherLoaded extends WeatherState {
  final WeatherModel weather;
  WeatherLoaded(this.weather);
}
class WeatherError extends WeatherState {
  final String message;
  WeatherError(this.message);
}

// BLoC
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepositoryImpl repository;

  WeatherBloc({required this.repository}) : super(WeatherInitial()) {
    on<LoadWeatherEvent>((event, emit) async {
      emit(WeatherLoading());
      try {
        final weather = await repository.getCurrentWeather(event.cityName);
        emit(WeatherLoaded(weather));
      } catch (e) {
        emit(WeatherError(e.toString()));
      }
    });
  }
}
```

---

## 8. Usage in UI

### 8.1 Simple Screen Implementation
```dart
// lib/features/weather/presentation/screens/weather_screen.dart
class WeatherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeatherBloc(
        repository: WeatherRepositoryImpl(
          apiService: WeatherApiService(),
        ),
      )..add(LoadWeatherEvent('Ho Chi Minh City')),
      child: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          if (state is WeatherLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is WeatherLoaded) {
            return WeatherDisplay(weather: state.weather);
          } else if (state is WeatherError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return Center(child: Text('Welcome to Weather App'));
        },
      ),
    );
  }
}
```

---

## 9. Key Integration Notes

### 9.1 Dependencies (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.3
  
  # Network
  dio: ^5.3.2
  
  # Local Storage
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Location
  geolocator: ^10.1.0
  
  # UI
  cached_network_image: ^3.3.0
```

### 9.2 No Complex Setup Needed
- ❌ No Retrofit code generation
- ❌ No JSON serialization generation  
- ❌ No complex dependency injection
- ❌ No unit testing setup
- ✅ Simple, direct API calls
- ✅ Manual JSON parsing
- ✅ Basic BLoC state management
- ✅ SharedPreferences for simple caching

---

## 10. Summary

### ✅ What This Setup Provides:
- **Simple API Integration**: Direct HTTP calls with Dio
- **Clean Architecture**: But simplified for personal project
- **Vietnamese Support**: Full localization via API
- **Offline Support**: Basic caching with SharedPreferences  
- **Error Handling**: Simple try-catch approach
- **Feature Mapping**: Each API endpoint serves specific user stories

### 🎯 Perfect For Personal Project:
- No over-engineering
- Easy to understand and maintain
- Quick to implement
- Production-ready but not enterprise-complex
- All functional requirements covered

**Ready to start implementation with this simplified but complete API integration strategy.**
