import 'package:equatable/equatable.dart';

class FavoriteCity extends Equatable {
  final String name;
  final String country;
  final String region;
  final double latitude;
  final double longitude;
  final DateTime addedAt;
  final double? lastKnownTemperature;
  final String? lastKnownCondition;
  final String? lastKnownIcon;

  const FavoriteCity({
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

  String get displayName => '$name, $country';
  
  String get coordinates => '$latitude,$longitude';

  FavoriteCity copyWith({
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
    return FavoriteCity(
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
  List<Object?> get props => [
        name,
        country,
        region,
        latitude,
        longitude,
        addedAt,
        lastKnownTemperature,
        lastKnownCondition,
        lastKnownIcon,
      ];

  @override
  String toString() {
    return 'FavoriteCity(name: $name, country: $country, temp: $lastKnownTemperature°C)';
  }
}