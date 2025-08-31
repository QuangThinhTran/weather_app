class TemperatureConverter {
  static double celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  static double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  static String formatTemperature(double temperature, bool useCelsius) {
    if (useCelsius) {
      return '${temperature.round()}°C';
    } else {
      return '${celsiusToFahrenheit(temperature).round()}°F';
    }
  }

  static String formatTemperatureRange(double minTemp, double maxTemp, bool useCelsius) {
    if (useCelsius) {
      return '${maxTemp.round()}°/${minTemp.round()}°';
    } else {
      return '${celsiusToFahrenheit(maxTemp).round()}°/${celsiusToFahrenheit(minTemp).round()}°';
    }
  }

  static double convertTemperature(double temperature, bool useCelsius) {
    return useCelsius ? temperature : celsiusToFahrenheit(temperature);
  }
}

class WindSpeedConverter {
  static double kmhToMph(double kmh) {
    return kmh * 0.621371;
  }

  static double mphToKmh(double mph) {
    return mph * 1.60934;
  }

  static String formatWindSpeed(double windSpeed, String unit) {
    switch (unit.toLowerCase()) {
      case 'mph':
        return '${kmhToMph(windSpeed).round()} mph';
      case 'km/h':
      default:
        return '${windSpeed.round()} km/h';
    }
  }
}

class PressureConverter {
  static double mbToInHg(double mb) {
    return mb * 0.02953;
  }

  static double inHgToMb(double inHg) {
    return inHg * 33.8639;
  }

  static String formatPressure(double pressure, [String unit = 'hPa']) {
    switch (unit.toLowerCase()) {
      case 'inhg':
        return '${mbToInHg(pressure).toStringAsFixed(2)} inHg';
      case 'hpa':
      case 'mb':
      default:
        return '${pressure.round()} hPa';
    }
  }
}