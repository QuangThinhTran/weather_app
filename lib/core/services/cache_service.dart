import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class CacheService {
  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService._();
  CacheService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Weather data caching
  Future<void> cacheWeatherData(String cityName, Map<String, dynamic> data) async {
    await init();
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'city': cityName,
    };
    
    final cacheKey = '${AppConstants.weatherCacheKey}_${cityName.toLowerCase()}';
    await _prefs!.setString(cacheKey, jsonEncode(cacheData));
  }

  Future<Map<String, dynamic>?> getCachedWeatherData(String cityName) async {
    await init();
    final cacheKey = '${AppConstants.weatherCacheKey}_${cityName.toLowerCase()}';
    final cachedString = _prefs!.getString(cacheKey);
    
    if (cachedString != null) {
      try {
        final cacheData = jsonDecode(cachedString);
        final timestamp = cacheData['timestamp'] as int;
        final now = DateTime.now().millisecondsSinceEpoch;
        
        // Check if cache is still valid (10 minutes)
        if (now - timestamp < AppConstants.cacheTimeoutMs) {
          return cacheData['data'] as Map<String, dynamic>;
        } else {
          // Cache expired, remove it
          await _prefs!.remove(cacheKey);
        }
      } catch (e) {
        // Invalid cache data, remove it
        await _prefs!.remove(cacheKey);
      }
    }
    return null;
  }

  // Search history
  Future<void> saveSearchHistory(List<String> searchHistory) async {
    await init();
    await _prefs!.setStringList(AppConstants.searchHistoryKey, searchHistory);
  }

  Future<List<String>> getSearchHistory() async {
    await init();
    return _prefs!.getStringList(AppConstants.searchHistoryKey) ?? [];
  }

  Future<void> addToSearchHistory(String cityName) async {
    final history = await getSearchHistory();
    
    // Remove if already exists
    history.remove(cityName);
    
    // Add to beginning
    history.insert(0, cityName);
    
    // Limit to max history
    if (history.length > AppConstants.maxSearchHistory) {
      history.removeRange(AppConstants.maxSearchHistory, history.length);
    }
    
    await saveSearchHistory(history);
  }

  Future<void> clearSearchHistory() async {
    await init();
    await _prefs!.remove(AppConstants.searchHistoryKey);
  }

  // App settings
  Future<void> saveAppTheme(String theme) async {
    await init();
    await _prefs!.setString(AppConstants.themeKey, theme);
  }

  Future<String> getAppTheme() async {
    await init();
    return _prefs!.getString(AppConstants.themeKey) ?? 'system';
  }

  Future<void> saveTemperatureUnit(bool useCelsius) async {
    await init();
    await _prefs!.setBool('temperature_unit_celsius', useCelsius);
  }

  Future<bool> getTemperatureUnit() async {
    await init();
    return _prefs!.getBool('temperature_unit_celsius') ?? AppConstants.defaultUseCelsius;
  }

  Future<void> saveWindUnit(String windUnit) async {
    await init();
    await _prefs!.setString('wind_unit', windUnit);
  }

  Future<String> getWindUnit() async {
    await init();
    return _prefs!.getString('wind_unit') ?? AppConstants.defaultWindUnit;
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    await init();
    final keys = _prefs!.getKeys();
    final weatherCacheKeys = keys.where((key) => key.startsWith(AppConstants.weatherCacheKey));
    
    for (final key in weatherCacheKeys) {
      await _prefs!.remove(key);
    }
  }

  Future<void> clearAll() async {
    await init();
    await _prefs!.clear();
  }

  // Generic string methods for settings
  Future<String?> getString(String key) async {
    await init();
    return _prefs!.getString(key);
  }

  Future<void> setString(String key, String value) async {
    await init();
    await _prefs!.setString(key, value);
  }

  Future<bool> remove(String key) async {
    await init();
    return await _prefs!.remove(key);
  }
}