import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_state.dart';
import '../bloc/search_event.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/search_results_widget.dart';
import '../widgets/search_history_widget.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/constants/app_constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Load search history when screen opens
    context.read<SearchBloc>().add(const LoadSearchHistory());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm Kiếm Thành Phố'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuSelection(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_history',
                child: ListTile(
                  leading: Icon(Icons.clear_all),
                  title: Text('Xóa Lịch Sử'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
            child: Column(
              children: [
                SearchBarWidget(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onClear: _onSearchCleared,
                ),
              ],
            ),
          ),
          
          // Search Results/History
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: ThemeConstants.spacingMedium),
                        Text('Đang tìm kiếm...'),
                      ],
                    ),
                  );
                } else if (state is SearchLoaded) {
                  return SearchResultsWidget(
                    cities: state.cities,
                    query: state.query,
                    onCitySelected: _onCitySelected,
                  );
                } else if (state is SearchHistoryLoaded) {
                  return SearchHistoryWidget(
                    history: state.history,
                    onHistoryItemSelected: _onHistoryItemSelected,
                    onClearHistory: _clearSearchHistory,
                  );
                } else if (state is SearchEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: ThemeConstants.spacingMedium),
                        Text(
                          'Không tìm thấy thành phố',
                          style: TextStyle(
                            fontSize: ThemeConstants.fontSizeLarge,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: ThemeConstants.spacingSmall),
                        Text(
                          'Thử tìm kiếm với tên thành phố khác',
                          style: TextStyle(
                            fontSize: ThemeConstants.fontSizeMedium,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is SearchError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: ThemeConstants.spacingMedium),
                        const Text(
                          'Lỗi Tìm Kiếm',
                          style: TextStyle(
                            fontSize: ThemeConstants.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: ThemeConstants.spacingSmall),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: ThemeConstants.fontSizeMedium,
                          ),
                        ),
                        const SizedBox(height: ThemeConstants.spacingLarge),
                        ElevatedButton.icon(
                          onPressed: () => _retrySearch(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử Lại'),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Initial state - show search tip
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: ThemeConstants.spacingMedium),
                        Text(
                          'Tìm Kiếm Thành Phố',
                          style: TextStyle(
                            fontSize: ThemeConstants.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: ThemeConstants.spacingSmall),
                        Text(
                          'Nhập tên thành phố để xem thông tin thời tiết',
                          style: TextStyle(
                            fontSize: ThemeConstants.fontSizeMedium,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    if (query.trim().isEmpty) {
      context.read<SearchBloc>().add(const LoadSearchHistory());
      return;
    }

    if (query.trim().length < AppConstants.minSearchLength) {
      return;
    }

    // Debounce search
    _debounceTimer = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () {
        context.read<SearchBloc>().add(SearchCities(query.trim()));
      },
    );
  }

  void _onSearchCleared() {
    _searchController.clear();
    context.read<SearchBloc>().add(const LoadSearchHistory());
  }

  void _onCitySelected(String cityName, String displayName) {
    // Add to search history
    context.read<SearchBloc>().addToHistory(cityName);
    
    // Return the selected city to previous screen
    Navigator.of(context).pop(cityName);
  }

  void _onHistoryItemSelected(String cityName) {
    _searchController.text = cityName;
    _onCitySelected(cityName, cityName);
  }

  void _clearSearchHistory() {
    context.read<SearchBloc>().add(const ClearSearchHistory());
  }

  void _retrySearch() {
    if (_searchController.text.trim().isNotEmpty) {
      context.read<SearchBloc>().add(SearchCities(_searchController.text.trim()));
    } else {
      context.read<SearchBloc>().add(const LoadSearchHistory());
    }
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'clear_history':
        _showClearHistoryDialog();
        break;
    }
  }

  void _quickSearch(String cityName) {
    _searchController.text = cityName;
    context.read<SearchBloc>().add(SearchCities(cityName));
  }

  void _showClearHistoryDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa Lịch Sử Tìm Kiếm'),
        content: const Text('Bạn có chắc chắn muốn xóa toàn bộ lịch sử tìm kiếm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearSearchHistory();
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}