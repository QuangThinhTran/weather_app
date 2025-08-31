import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WeatherIcon extends StatelessWidget {
  final String iconUrl;
  final double size;

  const WeatherIcon({
    super.key,
    required this.iconUrl,
    this.size = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: iconUrl,
      width: size,
      height: size,
      fit: BoxFit.contain,
      memCacheWidth: (size * MediaQuery.of(context).devicePixelRatio).round(),
      memCacheHeight: (size * MediaQuery.of(context).devicePixelRatio).round(),
      maxWidthDiskCache: (size * 2).round(),
      maxHeightDiskCache: (size * 2).round(),
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
      placeholder: (context, url) => SizedBox.square(
        dimension: size,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => _buildFallbackIcon(),
    );
  }

  Widget _buildFallbackIcon() {
    return Icon(
      _getWeatherIconFromUrl(iconUrl),
      size: size,
      color: _getWeatherColorFromUrl(iconUrl),
    );
  }

  IconData _getWeatherIconFromUrl(String url) {
    // Extract weather condition from URL and map to Material Icons
    final urlLower = url.toLowerCase();
    
    if (urlLower.contains('sun') || urlLower.contains('clear')) {
      return Icons.wb_sunny;
    } else if (urlLower.contains('cloud')) {
      if (urlLower.contains('partly')) {
        return Icons.wb_cloudy;
      }
      return Icons.cloud;
    } else if (urlLower.contains('rain') || urlLower.contains('drizzle')) {
      return Icons.grain;
    } else if (urlLower.contains('thunder') || urlLower.contains('storm')) {
      return Icons.flash_on;
    } else if (urlLower.contains('snow')) {
      return Icons.ac_unit;
    } else if (urlLower.contains('fog') || urlLower.contains('mist')) {
      return Icons.foggy;
    } else if (urlLower.contains('wind')) {
      return Icons.air;
    } else {
      return Icons.wb_cloudy; // Default fallback
    }
  }

  Color _getWeatherColorFromUrl(String url) {
    final urlLower = url.toLowerCase();
    
    if (urlLower.contains('sun') || urlLower.contains('clear')) {
      return Colors.orange;
    } else if (urlLower.contains('cloud')) {
      return Colors.blueGrey;
    } else if (urlLower.contains('rain') || urlLower.contains('drizzle')) {
      return Colors.blue;
    } else if (urlLower.contains('thunder') || urlLower.contains('storm')) {
      return Colors.deepPurple;
    } else if (urlLower.contains('snow')) {
      return Colors.lightBlue;
    } else if (urlLower.contains('fog') || urlLower.contains('mist')) {
      return Colors.grey;
    } else {
      return Colors.blueGrey; // Default fallback
    }
  }
}