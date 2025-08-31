import 'package:flutter/material.dart';
import '../../../../core/models/weather_advice.dart';
import '../../../../core/constants/theme_constants.dart';

class WeatherAdviceWidget extends StatelessWidget {
  final List<WeatherAdvice> advices;

  const WeatherAdviceWidget({
    super.key,
    required this.advices,
  });

  @override
  Widget build(BuildContext context) {
    if (advices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingMedium,
        vertical: ThemeConstants.spacingSmall,
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: ThemeConstants.spacingSmall),
                Text(
                  'GỢI Ý THỜI TIẾT',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeConstants.spacingMedium),
            
            // Show top 3 most important advices
            ...advices.take(3).map((advice) => Padding(
              padding: const EdgeInsets.only(bottom: ThemeConstants.spacingSmall),
              child: _buildAdviceItem(context, advice),
            )).toList(),
            
            // Show "more" indicator if there are additional advices
            if (advices.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: ThemeConstants.spacingSmall),
                child: Text(
                  '+${advices.length - 3} gợi ý khác',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceItem(BuildContext context, WeatherAdvice advice) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
      decoration: BoxDecoration(
        color: _getPriorityColor(advice.priority, context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusSmall),
        border: Border.all(
          color: _getPriorityColor(advice.priority, context).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getPriorityColor(advice.priority, context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              advice.icon,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          
          const SizedBox(width: ThemeConstants.spacingMedium),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  advice.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getPriorityColor(advice.priority, context),
                  ),
                ),
                const SizedBox(height: ThemeConstants.spacingXSmall),
                Text(
                  advice.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          // Priority indicator
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: _getPriorityColor(advice.priority, context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _getPriorityText(advice.priority),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(WeatherAdvicePriority priority, BuildContext context) {
    switch (priority) {
      case WeatherAdvicePriority.urgent:
        return Colors.red;
      case WeatherAdvicePriority.high:
        return Colors.orange;
      case WeatherAdvicePriority.medium:
        return Colors.amber.shade700;
      case WeatherAdvicePriority.low:
        return Colors.blue;
    }
  }

  String _getPriorityText(WeatherAdvicePriority priority) {
    switch (priority) {
      case WeatherAdvicePriority.urgent:
        return 'KHẨN';
      case WeatherAdvicePriority.high:
        return 'CAO';
      case WeatherAdvicePriority.medium:
        return 'TB';
      case WeatherAdvicePriority.low:
        return 'THẤP';
    }
  }
}