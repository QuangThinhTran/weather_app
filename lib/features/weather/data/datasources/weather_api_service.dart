import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';

class WeatherApiService {
  final Dio _dio;
  
  WeatherApiService({Dio? dio}) : _dio = dio ?? _createDio();

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeoutMs),
      ),
    );
  }

  Future<Map<String, dynamic>> getCurrentWeather(String cityName) async {
    try {
      // Use forecast API with days=1 to get current weather + astronomy data
      final url = '${ApiConstants.baseUrl}${ApiConstants.forecast}';
      final params = {
        'key': ApiConstants.apiKey,
        'q': cityName,
        'days': 1,
        'lang': ApiConstants.languageVi,
      };
      
      print('Weather API Request: $url');
      print('Parameters: $params');
      
      final response = await _dio.get(url, queryParameters: params);
      
      print('Weather API Response: ${response.statusCode}');
      print('Weather API Data: ${response.data}');
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch weather data',
        );
      }
    } on DioException catch (e) {
      print('DioException: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 404) {
        throw WeatherApiException('City not found');
      } else if (e.response?.statusCode == 401) {
        throw WeatherApiException('Invalid API key');
      } else if (e.response?.statusCode == 429) {
        throw WeatherApiException('Too many requests');
      } else {
        throw WeatherApiException('Network error: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error: $e');
      throw WeatherApiException('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> getCurrentWeatherByCoordinates(double latitude, double longitude) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.forecast}',
        queryParameters: {
          'key': ApiConstants.apiKey,
          'q': '$latitude,$longitude',
          'days': 1,
          'lang': ApiConstants.languageVi,
        },
      );
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch weather data',
        );
      }
    } on DioException catch (e) {
      throw WeatherApiException('Failed to fetch weather by coordinates: ${e.message}');
    } catch (e) {
      throw WeatherApiException('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> getForecast(String cityName) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.forecast}',
        queryParameters: {
          'key': ApiConstants.apiKey,
          'q': cityName,
          'days': ApiConstants.forecastDays,
          'lang': ApiConstants.languageVi,
        },
      );
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch forecast data',
        );
      }
    } on DioException catch (e) {
      throw WeatherApiException('Failed to fetch forecast: ${e.message}');
    } catch (e) {
      throw WeatherApiException('Unexpected error: $e');
    }
  }

  Future<List<dynamic>> searchCities(String query) async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.citySearch}';
      final params = {
        'key': ApiConstants.apiKey,
        'q': query,
      };
      
      print('Search API Request: $url');
      print('Search Parameters: $params');
      
      final response = await _dio.get(url, queryParameters: params);
      
      print('Search API Response: ${response.statusCode}');
      print('Search API Data: ${response.data}');
      
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to search cities',
        );
      }
    } on DioException catch (e) {
      print('Search DioException: ${e.response?.statusCode} - ${e.response?.data}');
      throw WeatherApiException('Failed to search cities: ${e.message}');
    } catch (e) {
      print('Search Unexpected error: $e');
      throw WeatherApiException('Unexpected error: $e');
    }
  }
}

class WeatherApiException implements Exception {
  final String message;
  WeatherApiException(this.message);

  @override
  String toString() => 'WeatherApiException: $message';
}