import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';

class WeatherActions extends StatelessWidget {
  final VoidCallback onSearchPressed;
  final VoidCallback onLocationPressed;
  final VoidCallback? onRefreshPressed;
  final bool isLoading;

  const WeatherActions({
    super.key,
    required this.onSearchPressed,
    required this.onLocationPressed,
    this.onRefreshPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          icon: Icons.search,
          label: 'Search City',
          onPressed: isLoading ? null : onSearchPressed,
        ),
        _buildActionButton(
          context,
          icon: Icons.my_location,
          label: 'Use Location',
          onPressed: isLoading ? null : onLocationPressed,
        ),
        if (onRefreshPressed != null)
          _buildActionButton(
            context,
            icon: isLoading ? Icons.hourglass_empty : Icons.refresh,
            label: 'Refresh',
            onPressed: isLoading ? null : onRefreshPressed,
          ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          iconSize: 32,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
          ),
        ),
        const SizedBox(height: ThemeConstants.spacingSmall),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}