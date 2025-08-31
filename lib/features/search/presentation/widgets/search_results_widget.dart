import 'package:flutter/material.dart';
import '../../domain/entities/city.dart';
import '../../../../core/constants/theme_constants.dart';

class SearchResultsWidget extends StatelessWidget {
  final List<City> cities;
  final String query;
  final Function(String cityName, String displayName) onCitySelected;

  const SearchResultsWidget({
    super.key,
    required this.cities,
    required this.query,
    required this.onCitySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (cities.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: ThemeConstants.spacingMedium),
            Text(
              'No cities found',
              style: TextStyle(
                fontSize: ThemeConstants.fontSizeLarge,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spacingMedium,
            vertical: ThemeConstants.spacingSmall,
          ),
          child: Text(
            'Search Results for "$query"',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              return _buildCityListItem(context, city);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCityListItem(BuildContext context, City city) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingMedium,
        vertical: ThemeConstants.spacingSmall,
      ),
      elevation: 2,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.location_city,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          city.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${city.region}, ${city.country}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => onCitySelected(city.name, city.displayName),
      ),
    );
  }
}