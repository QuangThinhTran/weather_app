import '../entities/city.dart';

abstract class SearchRepository {
  Future<List<City>> searchCities(String query);
  Future<List<String>> getSearchHistory();
  Future<void> addToSearchHistory(String cityName);
  Future<void> clearSearchHistory();
}