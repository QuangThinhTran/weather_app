import 'package:equatable/equatable.dart';

enum WeatherAdvicePriority {
  urgent,   // Red - Critical warnings (storms, extreme weather)
  high,     // Orange - Important reminders (rain, high UV)
  medium,   // Yellow - Helpful suggestions (hat, warm clothes)
  low,      // Blue - General info (humidity, mild conditions)
}

enum WeatherAdviceType {
  rain,
  storm, 
  sun,
  uv,
  cold,
  wind,
  humidity,
  forecast,
}

class WeatherAdvice extends Equatable {
  final String icon;
  final String title;
  final String description;
  final WeatherAdvicePriority priority;
  final WeatherAdviceType type;

  const WeatherAdvice({
    required this.icon,
    required this.title,
    required this.description,
    required this.priority,
    required this.type,
  });

  @override
  List<Object> get props => [icon, title, description, priority, type];

  @override
  String toString() => 'WeatherAdvice(title: $title, priority: $priority)';
}