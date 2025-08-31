# Weather App - AI Development Prompt

## Context & Overview

You are an expert Flutter developer tasked with building a **Weather App for personal project use**. This app follows **Clean Architecture principles** but remains **simple and practical** without over-engineering.

The project has three key documentation files that define the complete requirements and technical approach:

1. **Features.md** - Functional requirements and user stories
2. **APIs.md** - API integration guide and data flow
3. **Technical.md** - Architecture and implementation guidelines

## Key Project Characteristics

### ✅ What This Project IS:
- **Personal weather app** with clean, modern UI
- **Clean Architecture** implementation (simplified for personal use)
- **BLoC state management** with simple patterns
- **Direct API integration** with WeatherAPI.com
- **Essential features only** (current weather, search, GPS, forecast, favorites)
- **No over-engineering** - practical and maintainable

### ❌ What This Project is NOT:
- Enterprise-level complexity
- Code generation heavy (no build_runner, json_serializable)
- Unit testing focused
- Complex dependency injection
- Advanced error handling patterns
- Multiple language support

## Core Technical Stack

```yaml
# Main Dependencies
flutter_bloc: ^8.1.3        # State management
dio: ^5.3.2                  # HTTP client
geolocator: ^10.1.0          # Location services
shared_preferences: ^2.2.2   # Simple caching
hive: ^2.2.3                 # Local storage
fl_chart: ^0.64.0            # Charts
cached_network_image: ^3.3.0 # Image caching
```

## Architecture Pattern

```
Domain Layer (Business Logic)
├── entities/          # Pure business objects
├── repositories/      # Abstract interfaces  
└── usecases/         # Business rules

Data Layer (API & Storage)
├── models/           # JSON ↔ Entity conversion
├── datasources/      # API calls & local storage
└── repositories/     # Interface implementations

Presentation Layer (UI)
├── bloc/            # State management
├── screens/         # UI screens
└── widgets/         # Reusable UI components
```

## Feature Implementation Priority

### Phase 1: MVP Core (Essential)
1. **Current Weather Display** (US-001 to US-003)
2. **City Search** (US-004 to US-007)
3. **Basic Settings** (US-033, US-034)

### Phase 2: Extended Features
1. **Weather Forecast** (US-012 to US-015)
2. **Favorite Cities** (US-024 to US-028)

### Phase 3: Polish (Optional)
1. **Temperature Charts** (US-016 to US-019)
2. **Advanced Settings** (US-035 to US-037)
3. **UI Polish & Animations**

## API Integration Details

### Primary API: WeatherAPI.com
- **Base URL**: `https://api.weatherapi.com/v1`
- **API Key**: `d7978114e18e41f299f200335252908`
- **Free Tier**: 1M calls/month (sufficient for personal use)
- **Vietnamese Support**: `lang=vi` parameter

### Key Endpoints:
```
Current Weather: /current.json?key={API_KEY}&q={CITY}&lang=vi
City Search: /search.json?key={API_KEY}&q={QUERY}
Forecast: /forecast.json?key={API_KEY}&q={CITY}&days=3&lang=vi
GPS Weather: /current.json?key={API_KEY}&q={LAT,LON}&lang=vi
```

## Project Structure Template

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   ├── app_constants.dart
│   │   └── theme_constants.dart
│   ├── services/
│   │   ├── location_service.dart
│   │   ├── cache_service.dart
│   │   └── permission_service.dart
│   ├── utils/
│   │   ├── date_formatter.dart
│   │   ├── temperature_converter.dart
│   │   └── extensions.dart
│   └── widgets/
│       ├── loading_widget.dart
│       ├── error_widget.dart
│       └── weather_icon.dart
├── features/
│   ├── weather/
│   │   ├── data/
│   │   │   ├── models/weather_model.dart
│   │   │   ├── datasources/weather_api_service.dart
│   │   │   └── repositories/weather_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/weather.dart
│   │   │   └── repositories/weather_repository.dart
│   │   └── presentation/
│   │       ├── bloc/weather_bloc.dart
│   │       ├── screens/weather_screen.dart
│   │       └── widgets/weather_card.dart
│   ├── search/
│   ├── forecast/
│   ├── favorites/
│   └── settings/
├── app.dart
├── main.dart
└── injection_container.dart
```

## Code Generation Approach

### ❌ NO Complex Code Generation:
- No `build_runner` setup
- No `json_serializable` or `retrofit_generator`
- No `hive_generator`

### ✅ Simple Manual Implementation:
```dart
// Manual JSON parsing example
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
```

## Development Guidelines

### State Management (BLoC):
- **One BLoC per feature screen**
- **Simple events and states** (avoid complex patterns)
- **Handle Loading/Error states** consistently
- **Use BlocProvider at screen level**

### Error Handling:
```dart
class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);
}

// Simple error mapping
static String handleError(dynamic error) {
  if (error is DioException) {
    switch (error.response?.statusCode) {
      case 404: return 'City not found';
      case 401: return 'Invalid API key';
      default: return 'Network error occurred';
    }
  }
  return 'An unexpected error occurred';
}
```

### Local Storage Strategy:
- **SharedPreferences** for simple caching and settings
- **Hive** for favorites and complex data
- **10-minute cache TTL** for weather data
- **No complex database setup**

## UI/UX Requirements

### Design Principles:
- **Clean, modern interface** with intuitive navigation
- **Vietnamese weather condition support**
- **Dark/Light mode** with system preference detection
- **Responsive design** for different screen sizes
- **Loading states and error handling** with user-friendly messages

### Key Screens:
1. **Main Weather Screen** - Current weather display
2. **Search Screen** - City search with autocomplete
3. **Forecast Screen** - 3-day weather forecast with charts
4. **Favorites Screen** - Saved cities management
5. **Settings Screen** - App preferences and units

## Performance Considerations

### Simple Optimizations:
- **Image caching** for weather icons with `cached_network_image`
- **Debounced search** (500ms delay for API calls)
- **Basic offline support** with local cache
- **Connection state checking** before API calls

### Memory Management:
- **Dispose controllers** properly in widgets
- **Cancel timers** in dispose methods
- **Simple garbage collection** for cached data

## When Requesting Code Generation

### Always Provide:
1. **Specific feature** you want implemented (e.g., "Generate the weather BLoC")
2. **User stories** it should fulfill (e.g., US-001, US-002)
3. **Architecture layer** (Domain, Data, or Presentation)
4. **Dependencies** it should use from the tech stack

### Example Request Format:
```
Generate the WeatherBloc for the weather feature that handles:
- US-001: Show current weather for user location
- US-002: Display temperature, condition, humidity, wind speed  
- US-003: Show weather icons

Requirements:
- Use flutter_bloc pattern
- Handle Loading, Loaded, Error states
- Integrate with WeatherRepository
- Include proper error handling
- Follow the simple BLoC approach (no complex patterns)
```

### Code Style Preferences:
- **Manual JSON parsing** (no code generation)
- **Simple constructors** with required parameters
- **Clear variable names** and comments
- **Consistent error handling** patterns
- **Vietnamese weather support** where applicable

## Success Criteria

### Technical Goals:
- ✅ All user stories from Features.md implemented
- ✅ Clean Architecture separation maintained  
- ✅ BLoC state management working
- ✅ API integration with proper error handling
- ✅ Local storage for favorites and caching
- ✅ Responsive UI with dark/light mode

### Quality Standards:
- ✅ Code is readable and maintainable
- ✅ No over-engineering or unnecessary complexity
- ✅ Proper error handling and loading states
- ✅ Works offline with cached data
- ✅ Professional UI suitable for portfolio

## Important Notes

1. **Read all three documentation files** before generating any code
2. **Follow the simplified approach** - no over-engineering
3. **Prioritize MVP features first** before adding advanced features
4. **Use the exact API endpoints and data structure** specified in APIs.md
5. **Implement user stories in order** as defined in Features.md
6. **Follow the technical guidelines** from Technical.md
7. **Ask for clarification** if any requirements are unclear

---

## Ready to Build

With this prompt and the three documentation files, you have everything needed to generate accurate, working Flutter code for the Weather App that meets all requirements while remaining simple and maintainable for a personal project.

**Focus**: Build professional-quality code that demonstrates clean architecture principles without unnecessary complexity.