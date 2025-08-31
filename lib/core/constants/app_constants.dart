class AppConstants {
  // App Information
  static const String appName = 'Weather App';
  static const String appVersion = '1.0.0';
  
  // Cache Configuration
  static const int cacheTimeoutMinutes = 10;
  static const int cacheTimeoutMs = cacheTimeoutMinutes * 60 * 1000;
  
  // Local Storage Keys
  static const String weatherCacheKey = 'weather_cache';
  static const String favoritesBoxKey = 'favorites';
  static const String settingsKey = 'user_settings';
  static const String searchHistoryKey = 'search_history';
  static const String themeKey = 'app_theme';
  
  // Limits
  static const int maxFavoriteCities = 10;
  static const int maxSearchHistory = 10;
  
  // Default Values
  static const String defaultCity = 'Ho Chi Minh City';
  static const bool defaultUseCelsius = true;
  static const String defaultWindUnit = 'km/h';
  
  // Search Configuration
  static const int searchDebounceMs = 500;
  static const int minSearchLength = 2;
}