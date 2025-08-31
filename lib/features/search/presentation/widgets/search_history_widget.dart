import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';

class SearchHistoryWidget extends StatelessWidget {
  final List<String> history;
  final Function(String cityName) onHistoryItemSelected;
  final VoidCallback onClearHistory;

  const SearchHistoryWidget({
    super.key,
    required this.history,
    required this.onHistoryItemSelected,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: ThemeConstants.spacingMedium),
            Text(
              'Chưa có lịch sử tìm kiếm',
              style: TextStyle(
                fontSize: ThemeConstants.fontSizeLarge,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: ThemeConstants.spacingSmall),
            Text(
              'Tìm kiếm thành phố để tạo lịch sử',
              style: TextStyle(
                fontSize: ThemeConstants.fontSizeMedium,
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
            'Tìm Kiếm Gần Đây',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final cityName = history[index];
              return _buildHistoryItem(context, cityName, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(BuildContext context, String cityName, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingMedium,
        vertical: ThemeConstants.spacingSmall,
      ),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.history,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          cityName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Tìm kiếm gần đây',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: () => onHistoryItemSelected(cityName),
      ),
    );
  }
}