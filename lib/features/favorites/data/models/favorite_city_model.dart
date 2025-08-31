import '../../domain/entities/favorite_city.dart';

class FavoriteCityModel {
  final String name;
  final String country;
  final String region;
  final double latitude;
  final double longitude;
  final DateTime addedAt;
  final double? lastKnownTemperature;
  final String? lastKnownCondition;
  final String? lastKnownIcon;

  const FavoriteCityModel({
    required this.name,
    required this.country,
    required this.region,
    required this.latitude,
    required this.longitude,
    required this.addedAt,
    this.lastKnownTemperature,
    this.lastKnownCondition,
    this.lastKnownIcon,
  });

  // Convert model to entity
  FavoriteCity toEntity() {
    return FavoriteCity(
      name: name,
      country: country,
      region: region,
      latitude: latitude,
      longitude: longitude,
      addedAt: addedAt,
      lastKnownTemperature: lastKnownTemperature,
      lastKnownCondition: lastKnownCondition,
      lastKnownIcon: lastKnownIcon,
    );
  }

  // Factory constructor for creating from entity
  factory FavoriteCityModel.fromEntity(FavoriteCity favoriteCity) {
    return FavoriteCityModel(
      name: favoriteCity.name,
      country: favoriteCity.country,
      region: favoriteCity.region,
      latitude: favoriteCity.latitude,
      longitude: favoriteCity.longitude,
      addedAt: favoriteCity.addedAt,
      lastKnownTemperature: favoriteCity.lastKnownTemperature,
      lastKnownCondition: favoriteCity.lastKnownCondition,
      lastKnownIcon: favoriteCity.lastKnownIcon,
    );
  }

  // Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'region': region,
      'latitude': latitude,
      'longitude': longitude,
      'addedAt': addedAt.toIso8601String(),
      'lastKnownTemperature': lastKnownTemperature,
      'lastKnownCondition': lastKnownCondition,
      'lastKnownIcon': lastKnownIcon,
    };
  }

  // Factory constructor from JSON
  factory FavoriteCityModel.fromJson(Map<String, dynamic> json) {
    return FavoriteCityModel(
      name: json['name'] as String,
      country: json['country'] as String,
      region: json['region'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      addedAt: DateTime.parse(json['addedAt'] as String),
      lastKnownTemperature: (json['lastKnownTemperature'] as num?)?.toDouble(),
      lastKnownCondition: json['lastKnownCondition'] as String?,
      lastKnownIcon: json['lastKnownIcon'] as String?,
    );
  }

  FavoriteCityModel copyWith({
    String? name,
    String? country,
    String? region,
    double? latitude,
    double? longitude,
    DateTime? addedAt,
    double? lastKnownTemperature,
    String? lastKnownCondition,
    String? lastKnownIcon,
  }) {
    return FavoriteCityModel(
      name: name ?? this.name,
      country: country ?? this.country,
      region: region ?? this.region,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addedAt: addedAt ?? this.addedAt,
      lastKnownTemperature: lastKnownTemperature ?? this.lastKnownTemperature,
      lastKnownCondition: lastKnownCondition ?? this.lastKnownCondition,
      lastKnownIcon: lastKnownIcon ?? this.lastKnownIcon,
    );
  }

  @override
  String toString() {
    return 'FavoriteCityModel(name: $name, country: $country, temp: $lastKnownTemperature°C)';
  }
}