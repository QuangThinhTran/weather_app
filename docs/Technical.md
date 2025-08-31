# Flutter Weather App - Technical Guidelines (Personal Project)

## 1. Project Setup & Dependencies

### Flutter Version
- **Flutter SDK**: Use Flutter 3.24.x or latest stable version
- **Dart SDK**: Comes bundled with Flutter
- **Channel**: Always use `stable` channel

```bash
flutter channel stable
flutter upgrade
```

### Simplified Dependencies (No Over-Engineering)
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management (Simple BLoC)
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Network (Direct API calls)
  dio: ^5.3.2
  
  # Local Storage (Basic caching)
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Location Services
  geolocator: ^10.1.0
  permission_handler: ^11.0.1
  
  # UI & Charts
  fl_chart: ^0.64.0
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  
  # Utilities
  intl: ^0.18.1
  connectivity_plus: ^5.0.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1

# No complex code generation needed:
# ❌ build_runner, retrofit_generator, json_serializable
# ❌ mocktail, bloc_test (no unit testing)
# ❌ hive_generator (manual models)
```

---

## 2. Simplified Project Structure

### Feature-First Structure (Clean but Simple)
```
lib/
├── core/                           # Shared functionality
│   ├── constants/
│   │   ├── api_constants.dart      # API endpoints, keys
│   │   ├── app_constants.dart      # App-wide constants
│   │   └── theme_constants.dart    # Colors, typography
│   │
│   ├── services/
│   │   ├── location_service.dart   # GPS & location handling
│   │   ├── cache_service.dart      # Simple SharedPreferences
│   │   └── permission_service.dart # Permission management
│   │
│   ├── utils/
│   │   ├── date_formatter.dart     # Date/time formatting
│   │   ├── temperature_converter.dart # Unit conversions
│   │   └── extensions.dart         # Dart extensions
│   │
│   └── widgets/
│       ├── loading_widget.dart     # Common loading states
│       ├── error_widget.dart       # Error display
│       └── weather_icon.dart       # Weather icon widget
│
├── features/
│   ├── weather/                    # Current weather feature
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── weather_model.dart     # Simple JSON model (manual parsing)
│   │   │   ├── datasources/
│   │   │   │   └── weather_api_service.dart # Direct API calls
│   │   │   └── repositories/
│   │   │       └── weather_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── weather.dart           # Business object
│   │   │   └── repositories/
│   │   │       └── weather_repository.dart # Interface
│   │   │
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── weather_bloc.dart      # Simple BLoC
│   │       │   ├── weather_event.dart     # Events
│   │       │   └── weather_state.dart     # States
│   │       ├── screens/
│   │       │   └── weather_screen.dart    # Main weather display
│   │       └── widgets/
│   │           ├── weather_card.dart      # Weather info card
│   │           └── weather_details.dart   # Detailed info
│   │
│   ├── search/                     # City search feature
│   │   ├── data/
│   │   │   ├── models/city_model.dart
│   │   │   └── datasources/search_api_service.dart
│   │   ├── domain/
│   │   │   └── entities/city.dart
│   │   └── presentation/
│   │       ├── bloc/search_bloc.dart
│   │       └── screens/search_screen.dart
│   │
│   ├── forecast/                   # Weather forecast feature
│   │   ├── data/models/forecast_model.dart
│   │   ├── domain/entities/forecast.dart
│   │   └── presentation/
│   │       ├── bloc/forecast_bloc.dart
│   │       └── widgets/temperature_chart.dart
│   │
│   ├── favorites/                  # Favorite cities feature
│   │   ├── data/models/favorite_city_model.dart
│   │   ├── domain/entities/favorite_city.dart
│   │   └── presentation/
│   │       ├── bloc/favorites_bloc.dart
│   │       └── screens/favorites_screen.dart
│   │
│   └── settings/                   # App settings
│       ├── data/models/user_preferences_model.dart
│       ├── domain/entities/user_preferences.dart
│       └── presentation/
│           ├── bloc/settings_bloc.dart
│           └── screens/settings_screen.dart
│
├── app.dart                        # App configuration
├── main.dart                       # App entry point
└── injection_container.dart        # Simple dependency injection
```

---

## 3. Simplified Architecture Implementation

### Clean Architecture (But Not Over-Engineered)

#### Domain Layer (Business Logic)
```dart
// Simple entity without complex patterns
class Weather {
  final String cityName;
  final double temperature;
  final String condition;
  final double humidity;
  final double windSpeed;
  final double pressure;
  final DateTime lastUpdated;

  const Weather({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.lastUpdated,
  });
}

// Simple repository interface
abstract class WeatherRepository {
  Future<Weather> getCurrentWeather(String cityName);
  Future<Weather> getWeatherByCoordinates(double lat, double lon);
  Future<List<Weather>> getWeatherForecast(String cityName);
}
```

#### Data Layer (API Integration)
```dart
// Simple API service (no code generation)
class WeatherApiService {
  final Dio _dio = Dio();
  static const String baseUrl = 'https://api.weatherapi.com/v1';
  static const String apiKey = 'd7978114e18e41f299f200335252908';

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
}

// Simple model (manual JSON parsing)
class WeatherModel {
  final String cityName;
  final double temperature;
  final String condition;
  final int humidity;
  final double windSpeed;
  final double pressure;
  final DateTime lastUpdated;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.lastUpdated,
  });

  // Simple factory constructor (no json_serializable)
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['location']['name'],
      temperature: json['current']['temp_c'].toDouble(),
      condition: json['current']['condition']['text'],
      humidity: json['current']['humidity'],
      windSpeed: json['current']['wind_kph'].toDouble(),
      pressure: json['current']['pressure_mb'].toDouble(),
      lastUpdated: DateTime.parse(json['current']['last_updated']),
    );
  }

  // Convert to domain entity
  Weather toEntity() {
    return Weather(
      cityName: cityName,
      temperature: temperature,
      condition: condition,
      humidity: humidity,
      windSpeed: windSpeed,
      pressure: pressure,
      lastUpdated: lastUpdated,
    );
  }
}
```

#### Presentation Layer (Simple BLoC)
```dart
// Simple BLoC without complex patterns
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository repository;

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

// Simple events and states
abstract class WeatherEvent {}
class LoadWeatherEvent extends WeatherEvent {
  final String cityName;
  LoadWeatherEvent(this.cityName);
}

abstract class WeatherState {}
class WeatherInitial extends WeatherState {}
class WeatherLoading extends WeatherState {}
class WeatherLoaded extends WeatherState {
  final Weather weather;
  WeatherLoaded(this.weather);
}
class WeatherError extends WeatherState {
  final String message;
  WeatherError(this.message);
}
```

---

## 4. Simple State Management Strategy

### BLoC Pattern (Simplified)
- Use **flutter_bloc** for state management
- **No complex BLoC-to-BLoC communication** (keep it simple)
- **No advanced patterns** like Cubit unless needed
- Use **BlocProvider** at screen level

### State Management Best Practices:
1. **One BLoC per feature screen**
2. **Simple events and states** 
3. **Handle Loading/Error states** consistently
4. **No complex state transitions**
5. **Use BlocListener** only when needed (navigation, snackbars)

---

## 5. Simple Local Storage Strategy

### No Complex Database Setup
```dart
// Simple caching with SharedPreferences
class SimpleCacheService {
  static const String _weatherCacheKey = 'weather_cache';
  
  Future<void> cacheWeatherData(String cityName, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
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
      if (now - timestamp < 600000) {
        return cacheData['data'];
      }
    }
    return null;
  }
}

// Simple Hive setup for favorites
class FavoritesStorage {
  static const String _favoritesBox = 'favorites';
  
  Future<void> saveFavoriteCity(String cityName) async {
    final box = await Hive.openBox(_favoritesBox);
    final favorites = box.get('cities', defaultValue: <String>[]);
    if (!favorites.contains(cityName)) {
      favorites.add(cityName);
      await box.put('cities', favorites);
    }
  }
  
  Future<List<String>> getFavoriteCities() async {
    final box = await Hive.openBox(_favoritesBox);
    return List<String>.from(box.get('cities', defaultValue: <String>[]));
  }
}
```

---

## 6. Error Handling & Performance

### Simple Error Handling
```dart
// Simple exception classes
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

// Simple error handler
class SimpleErrorHandler {
  static String handleError(dynamic error) {
    if (error is DioException) {
      switch (error.response?.statusCode) {
        case 404:
          return 'City not found';
        case 401:
          return 'Invalid API key';
        case 429:
          return 'Too many requests';
        default:
          return 'Network error occurred';
      }
    }
    return 'An unexpected error occurred';
  }
}
```

### Performance Optimization (Simple)
```dart
// Simple image caching for weather icons
class WeatherIcon extends StatelessWidget {
  final String iconUrl;
  final double size;

  const WeatherIcon({
    Key? key,
    required this.iconUrl,
    this.size = 64.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: 'https:$iconUrl',
      width: size,
      height: size,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}

// Simple debounced search
class SearchBar extends StatefulWidget {
  final Function(String) onSearch;
  
  const SearchBar({Key? key, required this.onSearch}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  Timer? _debounceTimer;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
          if (value.isNotEmpty) {
            widget.onSearch(value);
          }
        });
      },
      decoration: const InputDecoration(
        hintText: 'Search for cities...',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
```

---

## 7. Feature-to-Technical Mapping

### Simplified Mapping (No Over-Engineering)

| **Feature** | **User Stories** | **Technical Implementation** |
|-------------|------------------|------------------------------|
| **Current Weather** | US-001 to US-003 | WeatherBloc + WeatherApiService + Simple caching |
| **City Search** | US-004 to US-007 | SearchBloc + Search API + SharedPreferences history |
| **GPS Location** | US-008 to US-011 | LocationService (Geolocator) + Permission handling |
| **Forecast** | US-012 to US-015 | ForecastBloc + Forecast API + fl_chart for visualization |
| **Favorites** | US-024 to US-028 | FavoritesBloc + Hive local storage |
| **Dark Mode** | US-020 to US-023 | ThemeBloc + SharedPreferences for theme state |
| **Settings** | US-033 to US-037 | SettingsBloc + SharedPreferences for user preferences |

---

## 8. Development Workflow (Simplified)

### 1. Setup Phase:
```bash
# Create project
flutter create weather_app --org com.yourname.weather
cd weather_app

# Add dependencies (no code generation)
flutter pub add flutter_bloc dio geolocator hive shared_preferences fl_chart cached_network_image
```

### 2. Implementation Order (Keep it Simple):
1. **Core Setup**: Constants, simple services, basic widgets
2. **Current Weather**: Entity → Model → API Service → Repository → BLoC → UI
3. **City Search**: Follow same pattern as weather
4. **GPS Integration**: LocationService + permission handling
5. **Forecast**: Similar to current weather but with chart widget
6. **Favorites**: Local storage with Hive
7. **Settings**: SharedPreferences for user preferences
8. **Polish**: Theming, error handling, loading states

### 3. No Code Generation Needed:
```bash
# ❌ No need for these commands:
# flutter packages pub run build_runner build
# flutter packages pub run build_runner watch

# ✅ Just regular development:
flutter run
flutter build apk
```

---

## 9. Key Simplifications for Personal Project

### ❌ What We're NOT Doing (Over-Engineering):
- **No complex dependency injection** (GetIt, Injectable)
- **No code generation** (json_serializable, retrofit, build_runner)
- **No unit testing setup** (mocktail, bloc_test)
- **No complex caching strategies** (dio_cache_interceptor)
- **No advanced error handling** (dartz Either, Result pattern)
- **No complex state management** (BLoC-to-BLoC communication)
- **No internationalization framework** (intl package with ARB files)

### ✅ What We're Keeping (Simple but Effective):
- **Clean Architecture principles** (but simplified)
- **Feature-first structure** (easy to navigate)
- **BLoC state management** (but simple events/states)
- **Manual JSON parsing** (straightforward, no magic)
- **Basic local storage** (SharedPreferences + Hive)
- **Simple error handling** (try-catch with user-friendly messages)
- **Direct API calls** (Dio without complex setup)

---

## 10. Production Considerations (Personal Project Level)

### Security & Best Practices:
```dart
// Hide API key (basic level)
class ApiConstants {
  static const String weatherApiKey = String.fromEnvironment(
    'WEATHER_API_KEY',
    defaultValue: 'd7978114e18e41f299f200335252908',
  );
}

// Basic network timeout
Dio createDio() {
  return Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
}
```

### App Deployment:
```yaml
# android/app/build.gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}

# Permissions in android/app/src/main/AndroidManifest.xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

---

## 11. Conclusion

### ✅ **This Technical Setup Provides:**
- **Simple but Clean Architecture**: Easy to understand and maintain
- **No Over-Engineering**: Perfect for personal project scope
- **Production Ready**: All functional requirements covered
- **Scalable Foundation**: Can add complexity later if needed
- **Quick Development**: No complex setup or code generation delays

### 🎯 **Perfect Balance For Personal Project:**
- Clean Architecture principles ✅
- Simple implementation ✅  
- No unnecessary complexity ❌
- All features working ✅
- Easy to maintain ✅

**Ready to build a professional weather app without over-engineering complexity.**
