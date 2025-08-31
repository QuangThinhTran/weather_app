import '../../domain/entities/city.dart';
import '../../domain/repositories/search_repository.dart';
import '../../../weather/data/datasources/weather_api_service.dart';
import '../models/city_model.dart';
import '../../../../core/services/cache_service.dart';

class SearchRepositoryImpl implements SearchRepository {
  final WeatherApiService _apiService;
  final CacheService _cacheService;

  SearchRepositoryImpl({
    required WeatherApiService apiService,
    required CacheService cacheService,
  })  : _apiService = apiService,
        _cacheService = cacheService;

  @override
  Future<List<City>> searchCities(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      final jsonData = await _apiService.searchCities(query);
      final cityModels = jsonData
          .map((json) => CityModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return cityModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw SearchRepositoryException('Failed to search cities: $e');
    }
  }

  @override
  Future<List<String>> getSearchHistory() async {
    try {
      return await _cacheService.getSearchHistory();
    } catch (e) {
      throw SearchRepositoryException('Failed to get search history: $e');
    }
  }

  @override
  Future<void> addToSearchHistory(String cityName) async {
    try {
      await _cacheService.addToSearchHistory(cityName);
    } catch (e) {
      throw SearchRepositoryException('Failed to add to search history: $e');
    }
  }

  @override
  Future<void> clearSearchHistory() async {
    try {
      await _cacheService.clearSearchHistory();
    } catch (e) {
      throw SearchRepositoryException('Failed to clear search history: $e');
    }
  }
}

class SearchRepositoryException implements Exception {
  final String message;
  SearchRepositoryException(this.message);

  @override
  String toString() => 'SearchRepositoryException: $message';
}