import '../../domain/entities/city.dart';

class CityModel {
  final String name;
  final String country;
  final String region;
  final double latitude;
  final double longitude;
  final String? url;

  const CityModel({
    required this.name,
    required this.country,
    required this.region,
    required this.latitude,
    required this.longitude,
    this.url,
  });

  // Factory constructor for API response parsing (WeatherAPI.com search)
  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['name'] as String,
      country: json['country'] as String,
      region: json['region'] as String,
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lon'] as num).toDouble(),
      url: json['url'] as String?,
    );
  }

  // Convert model to entity
  City toEntity() {
    return City(
      name: name,
      country: country,
      region: region,
      latitude: latitude,
      longitude: longitude,
      url: url,
    );
  }

  // Factory constructor for creating from entity
  factory CityModel.fromEntity(City city) {
    return CityModel(
      name: city.name,
      country: city.country,
      region: city.region,
      latitude: city.latitude,
      longitude: city.longitude,
      url: city.url,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'region': region,
      'lat': latitude,
      'lon': longitude,
      'url': url,
    };
  }

  @override
  String toString() {
    return 'CityModel(name: $name, country: $country, region: $region)';
  }
}