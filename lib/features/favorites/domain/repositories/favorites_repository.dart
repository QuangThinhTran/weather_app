import '../entities/favorite_city.dart';

abstract class FavoritesRepository {
  Future<List<FavoriteCity>> getFavoriteCities();
  Future<void> addFavoriteCity(FavoriteCity city);
  Future<void> removeFavoriteCity(String cityName);
  Future<bool> isFavorite(String cityName);
  Future<void> updateFavoriteCityWeather(String cityName, double temperature, String condition, String iconUrl);
  Future<void> clearAllFavorites();
}