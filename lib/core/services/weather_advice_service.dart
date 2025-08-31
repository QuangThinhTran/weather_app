import '../models/weather_advice.dart';
import '../../features/weather/domain/entities/weather.dart';
import '../../features/forecast/domain/entities/forecast.dart';

class WeatherAdviceService {
  static List<WeatherAdvice> getWeatherAdvice(Weather weather, [Forecast? forecast]) {
    final List<WeatherAdvice> advices = [];
    
    // Analyze current weather condition
    final condition = weather.condition.toLowerCase();
    final temperature = weather.temperature;
    final uvIndex = weather.uvIndex;
    final humidity = weather.humidity;
    final windSpeed = weather.windSpeed;
    
    // Rain/Storm advice
    if (_isRainyWeather(condition)) {
      advices.add(WeatherAdvice(
        icon: '☔',
        title: 'Nhớ mang ô',
        description: 'Hôm nay có mưa, đừng quên mang theo ô để tránh ướt.',
        priority: WeatherAdvicePriority.high,
        type: WeatherAdviceType.rain,
      ));
    }
    
    // Heavy rain/storm warning
    if (_isHeavyRainOrStorm(condition)) {
      advices.add(WeatherAdvice(
        icon: '⛈️',
        title: 'Cảnh báo mưa to',
        description: 'Mưa to hoặc bão. Hạn chế ra ngoài nếu không cần thiết.',
        priority: WeatherAdvicePriority.urgent,
        type: WeatherAdviceType.storm,
      ));
    }
    
    // Hot/Sunny weather advice
    if (_isSunnyHotWeather(condition, temperature)) {
      advices.add(WeatherAdvice(
        icon: '🧢',
        title: 'Đội mũ khi ra ngoài',
        description: 'Trời nắng gắt, hãy đội mũ và uống nhiều nước.',
        priority: WeatherAdvicePriority.medium,
        type: WeatherAdviceType.sun,
      ));
    }
    
    // UV warning
    if (uvIndex > 7) {
      advices.add(WeatherAdvice(
        icon: '🧴',
        title: 'Thoa kem chống nắng',
        description: 'Chỉ số UV cao (${uvIndex.round()}), cần bảo vệ da khỏi tia UV.',
        priority: WeatherAdvicePriority.high,
        type: WeatherAdviceType.uv,
      ));
    }
    
    // Cold weather advice
    if (temperature < 15) {
      advices.add(WeatherAdvice(
        icon: '🧥',
        title: 'Mặc áo ấm',
        description: 'Nhiệt độ thấp (${temperature.round()}°C), hãy mặc áo ấm.',
        priority: WeatherAdvicePriority.medium,
        type: WeatherAdviceType.cold,
      ));
    }
    
    // Windy weather advice
    if (windSpeed > 30) {
      advices.add(WeatherAdvice(
        icon: '🌪️',
        title: 'Gió mạnh',
        description: 'Gió mạnh ${windSpeed.round()} km/h, cẩn thận khi di chuyển.',
        priority: WeatherAdvicePriority.medium,
        type: WeatherAdviceType.wind,
      ));
    }
    
    // High humidity advice
    if (humidity > 85) {
      advices.add(WeatherAdvice(
        icon: '💧',
        title: 'Độ ẩm cao',
        description: 'Độ ẩm ${humidity}%, có thể cảm thấy oi bức.',
        priority: WeatherAdvicePriority.low,
        type: WeatherAdviceType.humidity,
      ));
    }
    
    // Check forecast for rain prediction
    if (forecast != null) {
      final todayForecast = _getTodayForecast(forecast);
      if (todayForecast != null && todayForecast.precipitationChance > 60) {
        advices.add(WeatherAdvice(
          icon: '🌧️',
          title: 'Có thể có mưa',
          description: 'Khả năng mưa ${todayForecast.precipitationChance}% hôm nay.',
          priority: WeatherAdvicePriority.medium,
          type: WeatherAdviceType.forecast,
        ));
      }
    }
    
    // Sort by priority (urgent -> high -> medium -> low)
    advices.sort((a, b) => a.priority.index.compareTo(b.priority.index));
    
    return advices;
  }
  
  static bool _isRainyWeather(String condition) {
    final rainyKeywords = [
      'rain', 'mưa', 'drizzle', 'shower', 'precipitation',
      'light rain', 'moderate rain', 'heavy rain',
      'mưa rào', 'mưa nhỏ', 'mưa vừa', 'mưa to'
    ];
    
    return rainyKeywords.any((keyword) => condition.contains(keyword.toLowerCase()));
  }
  
  static bool _isHeavyRainOrStorm(String condition) {
    final stormKeywords = [
      'heavy rain', 'storm', 'thunderstorm', 'downpour',
      'mưa to', 'mưa tầm tã', 'bão', 'giông', 'sấm chớp'
    ];
    
    return stormKeywords.any((keyword) => condition.contains(keyword.toLowerCase()));
  }
  
  static bool _isSunnyHotWeather(String condition, double temperature) {
    final sunnyKeywords = [
      'sunny', 'clear', 'hot', 'nắng', 'quang đãng', 'nóng'
    ];
    
    final isSunny = sunnyKeywords.any((keyword) => condition.contains(keyword.toLowerCase()));
    return isSunny || temperature > 30;
  }
  
  static DailyForecast? _getTodayForecast(Forecast forecast) {
    final today = DateTime.now();
    try {
      return forecast.dailyForecasts.firstWhere(
        (daily) => 
          daily.date.year == today.year &&
          daily.date.month == today.month &&
          daily.date.day == today.day,
      );
    } catch (e) {
      return forecast.dailyForecasts.isNotEmpty ? forecast.dailyForecasts.first : null;
    }
  }
}