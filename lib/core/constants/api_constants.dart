class ApiConstants {
  // WeatherAPI.com configuration
  static const String baseUrl = 'https://api.weatherapi.com/v1';
  static const String apiKey = 'd7978114e18e41f299f200335252908';
  
  // API Endpoints
  static const String currentWeather = '/current.json';
  static const String citySearch = '/search.json';
  static const String forecast = '/forecast.json';
  
  // API Parameters
  static const String languageVi = 'vi';
  static const int forecastDays = 3;
  
  // Request timeouts
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 10000;
}