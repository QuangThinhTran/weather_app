import '../../domain/entities/forecast.dart';

class ForecastModel {
  final String cityName;
  final List<DailyForecastModel> dailyForecasts;
  final List<HourlyForecastModel> hourlyForecasts;

  const ForecastModel({
    required this.cityName,
    required this.dailyForecasts,
    required this.hourlyForecasts,
  });

  // Factory constructor for API response parsing (WeatherAPI.com forecast)
  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>;
    final forecast = json['forecast'] as Map<String, dynamic>;
    final forecastDays = forecast['forecastday'] as List<dynamic>;

    final dailyForecasts = forecastDays
        .map((day) => DailyForecastModel.fromJson(day as Map<String, dynamic>))
        .toList();

    final hourlyForecasts = <HourlyForecastModel>[];
    for (final day in forecastDays) {
      final hours = day['hour'] as List<dynamic>;
      for (final hour in hours) {
        hourlyForecasts.add(
          HourlyForecastModel.fromJson(hour as Map<String, dynamic>),
        );
      }
    }

    return ForecastModel(
      cityName: location['name'] as String,
      dailyForecasts: dailyForecasts,
      hourlyForecasts: hourlyForecasts,
    );
  }

  // Convert model to entity
  Forecast toEntity() {
    return Forecast(
      cityName: cityName,
      dailyForecasts: dailyForecasts.map((model) => model.toEntity()).toList(),
      hourlyForecasts: hourlyForecasts.map((model) => model.toEntity()).toList(),
    );
  }

  // Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'dailyForecasts': dailyForecasts.map((model) => model.toJson()).toList(),
      'hourlyForecasts': hourlyForecasts.map((model) => model.toJson()).toList(),
    };
  }

  // Factory constructor for cache data
  factory ForecastModel.fromCacheJson(Map<String, dynamic> json) {
    return ForecastModel(
      cityName: json['cityName'] as String,
      dailyForecasts: (json['dailyForecasts'] as List<dynamic>)
          .map((item) => DailyForecastModel.fromCacheJson(item as Map<String, dynamic>))
          .toList(),
      hourlyForecasts: (json['hourlyForecasts'] as List<dynamic>)
          .map((item) => HourlyForecastModel.fromCacheJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'ForecastModel(cityName: $cityName, daily: ${dailyForecasts.length}, hourly: ${hourlyForecasts.length})';
  }
}

class DailyForecastModel {
  final DateTime date;
  final double maxTemperature;
  final double minTemperature;
  final String condition;
  final String iconUrl;
  final int precipitationChance;
  final double maxWindSpeed;
  final double avgHumidity;
  final double uvIndex;

  const DailyForecastModel({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.condition,
    required this.iconUrl,
    required this.precipitationChance,
    required this.maxWindSpeed,
    required this.avgHumidity,
    required this.uvIndex,
  });

  factory DailyForecastModel.fromJson(Map<String, dynamic> json) {
    final day = json['day'] as Map<String, dynamic>;
    final condition = day['condition'] as Map<String, dynamic>;

    return DailyForecastModel(
      date: DateTime.parse(json['date'] as String),
      maxTemperature: (day['maxtemp_c'] as num).toDouble(),
      minTemperature: (day['mintemp_c'] as num).toDouble(),
      condition: condition['text'] as String,
      iconUrl: 'https:${condition['icon'] as String}',
      precipitationChance: (day['daily_chance_of_rain'] as num).toInt(),
      maxWindSpeed: (day['maxwind_kph'] as num).toDouble(),
      avgHumidity: (day['avghumidity'] as num).toDouble(),
      uvIndex: (day['uv'] as num).toDouble(),
    );
  }

  DailyForecast toEntity() {
    return DailyForecast(
      date: date,
      maxTemperature: maxTemperature,
      minTemperature: minTemperature,
      condition: condition,
      iconUrl: iconUrl,
      precipitationChance: precipitationChance,
      maxWindSpeed: maxWindSpeed,
      avgHumidity: avgHumidity,
      uvIndex: uvIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'maxTemperature': maxTemperature,
      'minTemperature': minTemperature,
      'condition': condition,
      'iconUrl': iconUrl,
      'precipitationChance': precipitationChance,
      'maxWindSpeed': maxWindSpeed,
      'avgHumidity': avgHumidity,
      'uvIndex': uvIndex,
    };
  }

  factory DailyForecastModel.fromCacheJson(Map<String, dynamic> json) {
    return DailyForecastModel(
      date: DateTime.parse(json['date'] as String),
      maxTemperature: (json['maxTemperature'] as num).toDouble(),
      minTemperature: (json['minTemperature'] as num).toDouble(),
      condition: json['condition'] as String,
      iconUrl: json['iconUrl'] as String,
      precipitationChance: json['precipitationChance'] as int,
      maxWindSpeed: (json['maxWindSpeed'] as num).toDouble(),
      avgHumidity: (json['avgHumidity'] as num).toDouble(),
      uvIndex: (json['uvIndex'] as num).toDouble(),
    );
  }
}

class HourlyForecastModel {
  final DateTime dateTime;
  final double temperature;
  final String condition;
  final String iconUrl;
  final int precipitationChance;
  final double windSpeed;
  final int humidity;
  final double feelsLike;

  const HourlyForecastModel({
    required this.dateTime,
    required this.temperature,
    required this.condition,
    required this.iconUrl,
    required this.precipitationChance,
    required this.windSpeed,
    required this.humidity,
    required this.feelsLike,
  });

  factory HourlyForecastModel.fromJson(Map<String, dynamic> json) {
    final condition = json['condition'] as Map<String, dynamic>;

    return HourlyForecastModel(
      dateTime: DateTime.parse(json['time'] as String),
      temperature: (json['temp_c'] as num).toDouble(),
      condition: condition['text'] as String,
      iconUrl: 'https:${condition['icon'] as String}',
      precipitationChance: (json['chance_of_rain'] as num).toInt(),
      windSpeed: (json['wind_kph'] as num).toDouble(),
      humidity: json['humidity'] as int,
      feelsLike: (json['feelslike_c'] as num).toDouble(),
    );
  }

  HourlyForecast toEntity() {
    return HourlyForecast(
      dateTime: dateTime,
      temperature: temperature,
      condition: condition,
      iconUrl: iconUrl,
      precipitationChance: precipitationChance,
      windSpeed: windSpeed,
      humidity: humidity,
      feelsLike: feelsLike,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'temperature': temperature,
      'condition': condition,
      'iconUrl': iconUrl,
      'precipitationChance': precipitationChance,
      'windSpeed': windSpeed,
      'humidity': humidity,
      'feelsLike': feelsLike,
    };
  }

  factory HourlyForecastModel.fromCacheJson(Map<String, dynamic> json) {
    return HourlyForecastModel(
      dateTime: DateTime.parse(json['dateTime'] as String),
      temperature: (json['temperature'] as num).toDouble(),
      condition: json['condition'] as String,
      iconUrl: json['iconUrl'] as String,
      precipitationChance: json['precipitationChance'] as int,
      windSpeed: (json['windSpeed'] as num).toDouble(),
      humidity: json['humidity'] as int,
      feelsLike: (json['feelsLike'] as num).toDouble(),
    );
  }
}