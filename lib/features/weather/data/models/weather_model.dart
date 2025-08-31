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

    // Try to get astronomy data from forecast if available
    String? sunrise;
    String? sunset;
    
    if (json['forecast'] != null) {
      final forecast = json['forecast'] as Map<String, dynamic>;
      final forecastDays = forecast['forecastday'] as List<dynamic>?;
      if (forecastDays != null && forecastDays.isNotEmpty) {
        final todayForecast = forecastDays[0] as Map<String, dynamic>;
        final astro = todayForecast['astro'] as Map<String, dynamic>?;
        if (astro != null) {
          sunrise = astro['sunrise'] as String?;
          sunset = astro['sunset'] as String?;
        }
      }
    }

    return WeatherModel(
      cityName: location['name'] as String,
      country: location['country'] as String,
      temperature: (current['temp_c'] as num).toDouble(),
      condition: condition['text'] as String,
      iconUrl: 'https:${condition['icon'] as String}',
      humidity: current['humidity'] as int,
      windSpeed: (current['wind_kph'] as num).toDouble(),
      pressure: (current['pressure_mb'] as num).toDouble(),
      feelsLike: (current['feelslike_c'] as num).toDouble(),
      uvIndex: (current['uv'] as num).toDouble(),
      visibility: (current['vis_km'] as num).toDouble(),
      lastUpdated: DateTime.parse(current['last_updated'] as String),
      latitude: (location['lat'] as num?)?.toDouble(),
      longitude: (location['lon'] as num?)?.toDouble(),
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
      temperature: (json['temperature'] as num).toDouble(),
      condition: json['condition'] as String,
      iconUrl: json['iconUrl'] as String,
      humidity: json['humidity'] as int,
      windSpeed: (json['windSpeed'] as num).toDouble(),
      pressure: (json['pressure'] as num).toDouble(),
      feelsLike: (json['feelsLike'] as num).toDouble(),
      uvIndex: (json['uvIndex'] as num).toDouble(),
      visibility: (json['visibility'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      sunrise: json['sunrise'] as String?,
      sunset: json['sunset'] as String?,
    );
  }

  @override
  String toString() {
    return 'WeatherModel(cityName: $cityName, temperature: $temperature°C, condition: $condition)';
  }
}