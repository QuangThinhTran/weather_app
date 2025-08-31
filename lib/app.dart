import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/theme_constants.dart';
import 'features/weather/presentation/screens/weather_screen.dart';
import 'features/weather/presentation/bloc/weather_bloc.dart';
import 'features/search/presentation/bloc/search_bloc.dart';
import 'features/forecast/presentation/bloc/forecast_bloc.dart';
import 'service_locator.dart';

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<WeatherBloc>(
            create: (context) => sl<WeatherBloc>(),
          ),
          BlocProvider<SearchBloc>(
            create: (context) => sl<SearchBloc>(),
          ),
          BlocProvider<ForecastBloc>(
            create: (context) => sl<ForecastBloc>(),
          ),
        ],
        child: const WeatherScreen(),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: ThemeConstants.lightPrimary,
        secondary: ThemeConstants.lightSecondary,
        surface: ThemeConstants.lightSurface,
        background: ThemeConstants.lightBackground,
        error: ThemeConstants.lightError,
        onPrimary: ThemeConstants.lightOnPrimary,
        onSecondary: ThemeConstants.lightOnSecondary,
        onSurface: ThemeConstants.lightOnSurface,
        onBackground: ThemeConstants.lightOnBackground,
        onError: ThemeConstants.lightOnError,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: ThemeConstants.lightBackground,
        foregroundColor: ThemeConstants.lightOnBackground,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spacingLarge,
            vertical: ThemeConstants.spacingMedium,
          ),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: ThemeConstants.darkPrimary,
        secondary: ThemeConstants.darkSecondary,
        surface: ThemeConstants.darkSurface,
        background: ThemeConstants.darkBackground,
        error: ThemeConstants.darkError,
        onPrimary: ThemeConstants.darkOnPrimary,
        onSecondary: ThemeConstants.darkOnSecondary,
        onSurface: ThemeConstants.darkOnSurface,
        onBackground: ThemeConstants.darkOnBackground,
        onError: ThemeConstants.darkOnError,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: ThemeConstants.darkBackground,
        foregroundColor: ThemeConstants.darkOnBackground,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spacingLarge,
            vertical: ThemeConstants.spacingMedium,
          ),
        ),
      ),
    );
  }
}

// Temporary home page - will be replaced with proper Weather Screen later
class WeatherHomePage extends StatelessWidget {
  const WeatherHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            const Icon(
              Icons.wb_sunny,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: ThemeConstants.spacingLarge),
            const Text(
              'Weather App',
              style: TextStyle(
                fontSize: ThemeConstants.fontSizeXXLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingXLarge),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
                child: Column(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 40,
                      color: ThemeConstants.lightPrimary,
                    ),
                    const SizedBox(height: ThemeConstants.spacingMedium),
                    const Text(
                      'Ho Chi Minh City',
                      style: TextStyle(
                        fontSize: ThemeConstants.fontSizeLarge,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: ThemeConstants.spacingSmall),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '28°C',
                          style: TextStyle(
                            fontSize: ThemeConstants.fontSizeXXLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: ThemeConstants.spacingMedium),
                        Column(
                          children: [
                            const Icon(
                              Icons.wb_cloudy,
                              color: Color(0xFF757575),
                            ),
                            const Text(
                              'Partly Cloudy',
                              style: TextStyle(
                                fontSize: ThemeConstants.fontSizeSmall,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: ThemeConstants.spacingLarge),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(
                              Icons.water_drop,
                              size: 24,
                              color: const Color(0xFF757575),
                            ),
                            const SizedBox(height: ThemeConstants.spacingSmall),
                            const Text(
                              '75%',
                              style: TextStyle(
                                fontSize: ThemeConstants.fontSizeMedium,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text(
                              'Humidity',
                              style: TextStyle(
                                fontSize: ThemeConstants.fontSizeSmall,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(
                              Icons.air,
                              size: 24,
                              color: const Color(0xFF757575),
                            ),
                            const SizedBox(height: ThemeConstants.spacingSmall),
                            const Text(
                              '12 km/h',
                              style: TextStyle(
                                fontSize: ThemeConstants.fontSizeMedium,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text(
                              'Wind',
                              style: TextStyle(
                                fontSize: ThemeConstants.fontSizeSmall,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(
                              Icons.compress,
                              size: 24,
                              color: const Color(0xFF757575),
                            ),
                            const SizedBox(height: ThemeConstants.spacingSmall),
                            const Text(
                              '1013 hPa',
                              style: TextStyle(
                                fontSize: ThemeConstants.fontSizeMedium,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text(
                              'Pressure',
                              style: TextStyle(
                                fontSize: ThemeConstants.fontSizeSmall,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

}