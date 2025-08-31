import '../../domain/entities/weather.dart';

class WeatherModel {
  final String cityName;
  final String country;
  final double temperature;
  final String condition;
  final String iconUrl;
  final int humidity;
  final double windSpeed;
  final double pressure;
  final double feelsLike;
  final double uvIndex;
  final double visibility;
  final DateTime lastUpdated;
  final double? latitude;
  final double? longitude;
  final String? sunrise;
  final String? sunset;

  const WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.condition,
    required this.iconUrl,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.feelsLike,
    required this.uvIndex,
    required this.visibility,
    required this.lastUpdated,
    this.latitude,
    this.longitude,
    this.sunrise,
    this.sunset,
  });

  // Factory constructor for API response parsing (WeatherAPI.com)
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>;
    final condition = current['condition'] as Map<String, dynamic>;

    // Efficiently extract astronomy data from forecast if available
    String? sunrise;
    String? sunset;
    
    final forecast = json['forecast'] as Map<String, dynamic>?;
    if (forecast != null) {
      final forecastDays = forecast['forecastday'] as List<dynamic>?;
      if (forecastDays?.isNotEmpty == true) {
        final astro = (forecastDays![0] as Map<String, dynamic>)['astro'] as Map<String, dynamic>?;
        if (astro != null) {
          sunrise = astro['sunrise'] as String?;
          sunset = astro['sunset'] as String?;
        }
      }
    }

    return WeatherModel(
      cityName: location['name'] as String,
      country: location['country'] as String,
      temperature: _safeToDouble(current['temp_c']),
      condition: condition['text'] as String,
      iconUrl: 'https:${condition['icon'] as String}',
      humidity: current['humidity'] as int,
      windSpeed: _safeToDouble(current['wind_kph']),
      pressure: _safeToDouble(current['pressure_mb']),
      feelsLike: _safeToDouble(current['feelslike_c']),
      uvIndex: _safeToDouble(current['uv']),
      visibility: _safeToDouble(current['vis_km']),
      lastUpdated: DateTime.parse(current['last_updated'] as String),
      latitude: _safeToDouble(location['lat']),
      longitude: _safeToDouble(location['lon']),
      sunrise: sunrise,
      sunset: sunset,
    );
  }

  // Convert model to entity
  Weather toEntity() {
    return Weather(
      cityName: cityName,
      country: country,
      temperature: temperature,
      condition: condition,
      iconUrl: iconUrl,
      humidity: humidity,
      windSpeed: windSpeed,
      pressure: pressure,
      feelsLike: feelsLike,
      uvIndex: uvIndex,
      visibility: visibility,
      lastUpdated: lastUpdated,
      latitude: latitude,
      longitude: longitude,
      sunrise: sunrise,
      sunset: sunset,
    );
  }

  // Factory constructor for creating from entity
  factory WeatherModel.fromEntity(Weather weather) {
    return WeatherModel(
      cityName: weather.cityName,
      country: weather.country,
      temperature: weather.temperature,
      condition: weather.condition,
      iconUrl: weather.iconUrl,
      humidity: weather.humidity,
      windSpeed: weather.windSpeed,
      pressure: weather.pressure,
      feelsLike: weather.feelsLike,
      uvIndex: weather.uvIndex,
      visibility: weather.visibility,
      lastUpdated: weather.lastUpdated,
      latitude: weather.latitude,
      longitude: weather.longitude,
      sunrise: weather.sunrise,
      sunset: weather.sunset,
    );
  }

  // Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'country': country,
      'temperature': temperature,
      'condition': condition,
      'iconUrl': iconUrl,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'pressure': pressure,
      'feelsLike': feelsLike,
      'uvIndex': uvIndex,
      'visibility': visibility,
      'lastUpdated': lastUpdated.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'sunrise': sunrise,
      'sunset': sunset,
    };
  }

  // Factory constructor for cache data
  factory WeatherModel.fromCacheJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['cityName'] as String,
      country: json['country'] as String,
      temperature: _safeToDouble(json['temperature']),
      condition: json['condition'] as String,
      iconUrl: json['iconUrl'] as String,
      humidity: json['humidity'] as int,
      windSpeed: _safeToDouble(json['windSpeed']),
      pressure: _safeToDouble(json['pressure']),
      feelsLike: _safeToDouble(json['feelsLike']),
      uvIndex: _safeToDouble(json['uvIndex']),
      visibility: _safeToDouble(json['visibility']),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      latitude: _safeToDouble(json['latitude']),
      longitude: _safeToDouble(json['longitude']),
      sunrise: json['sunrise'] as String?,
      sunset: json['sunset'] as String?,
    );
  }

  static double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return (value as num).toDouble();
  }

  @override
  String toString() => 'WeatherModel($cityName, ${temperature}°C, $condition)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeatherModel &&
        other.cityName == cityName &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode => Object.hash(cityName, lastUpdated);
}