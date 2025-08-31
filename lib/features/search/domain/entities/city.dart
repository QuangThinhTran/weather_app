import 'package:equatable/equatable.dart';

class City extends Equatable {
  final String name;
  final String country;
  final String region;
  final double latitude;
  final double longitude;
  final String? url;

  const City({
    required this.name,
    required this.country,
    required this.region,
    required this.latitude,
    required this.longitude,
    this.url,
  });

  String get displayName => '$name, $country';
  
  String get coordinates => '$latitude,$longitude';

  @override
  List<Object?> get props => [
        name,
        country,
        region,
        latitude,
        longitude,
        url,
      ];

  @override
  String toString() {
    return 'City(name: $name, country: $country, region: $region)';
  }
}