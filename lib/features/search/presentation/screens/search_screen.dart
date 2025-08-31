import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
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

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  late AnimationController _backgroundAnimationController;
  late AnimationController _heroAnimationController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _heroAnimation;

  @override
  void initState() {
    super.initState();
    
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundAnimationController);
    
    _heroAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroAnimationController,
      curve: Curves.elasticOut,
    ));
    
    // Load search history when screen opens
    context.read<SearchBloc>().add(const LoadSearchHistory());
    
    // Start hero animation
    _heroAnimationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _backgroundAnimationController.dispose();
    _heroAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: PopupMenuButton<String>(
              onSelected: (value) => _handleMenuSelection(value),
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
              color: Colors.white.withOpacity(0.95),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'clear_history',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all_rounded, color: theme.colorScheme.primary),
                      const SizedBox(width: ThemeConstants.spacingSmall),
                      const Text('Xóa Lịch Sử'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getAnimatedGradientColors(isDark),
                stops: const [0.0, 0.3, 0.7, 1.0],
                transform: GradientRotation(_backgroundAnimation.value * 2 * math.pi),
              ),
            ),
            child: Stack(
              children: [
                // Floating particles background
                ..._buildFloatingParticles(),
                
                // Main content with proper flexible layout
                Positioned.fill(
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Hero Title with animation - Fixed height
                        SizedBox(
                          height: 140,
                          child: AnimatedBuilder(
                            animation: _heroAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _heroAnimation.value,
                                child: Opacity(
                                  opacity: _heroAnimation.value.clamp(0.0, 1.0),
                                  child: Container(
                                    margin: const EdgeInsets.all(ThemeConstants.spacingMedium),
                                    padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.2),
                                          Colors.white.withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: ThemeConstants.glassBlur,
                                          sigmaY: ThemeConstants.glassBlur,
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.travel_explore_rounded,
                                              size: 32,
                                              color: Colors.white.withOpacity(0.9),
                                            ),
                                            const SizedBox(height: ThemeConstants.spacingSmall),
                                            Text(
                                              'Khám Phá Thời Tiết',
                                              style: theme.textTheme.titleLarge?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black.withOpacity(0.3),
                                                    offset: const Offset(0, 2),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // Enhanced Search Bar - Fixed height
                        Container(
                          height: 80,
                          padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingMedium),
                          child: Hero(
                            tag: 'search_bar',
                            child: SearchBarWidget(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              onClear: _onSearchCleared,
                            ),
                          ),
                        ),
                        
                        // Search Results/History - Flexible to fill remaining space
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(ThemeConstants.spacingMedium),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: ThemeConstants.glassBlur,
                                  sigmaY: ThemeConstants.glassBlur,
                                ),
                                child: BlocBuilder<SearchBloc, SearchState>(
                                  builder: (context, state) {
                                  if (state is SearchLoading) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.2),
                                                width: 1,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: 60,
                                                  height: 60,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 3,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      Colors.white.withOpacity(0.8),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: ThemeConstants.spacingMedium),
                                                Text(
                                                  'Đang tìm kiếm...',
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.9),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: ThemeConstants.spacingSmall),
                                                Text(
                                                  'Vui lòng chờ một chút',
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.7),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
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
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(ThemeConstants.spacingXLarge),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.2),
                                                width: 1,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.orange.withOpacity(0.3),
                                                        Colors.red.withOpacity(0.3),
                                                      ],
                                                    ),
                                                    borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
                                                  ),
                                                  child: Icon(
                                                    Icons.location_off_rounded,
                                                    size: 64,
                                                    color: Colors.white.withOpacity(0.8),
                                                  ),
                                                ),
                                                const SizedBox(height: ThemeConstants.spacingLarge),
                                                Text(
                                                  'Không tìm thấy thành phố',
                                                  style: TextStyle(
                                                    fontSize: ThemeConstants.fontSizeLarge,
                                                    color: Colors.white.withOpacity(0.9),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: ThemeConstants.spacingSmall),
                                                Text(
                                                  'Thử tìm kiếm với tên thành phố khác',
                                                  style: TextStyle(
                                                    fontSize: ThemeConstants.fontSizeMedium,
                                                    color: Colors.white.withOpacity(0.7),
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
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
                                              color: Colors.grey,
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
                                    // Initial state - show search tip with enhanced design
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(ThemeConstants.spacingXLarge),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.blue.withOpacity(0.2),
                                                  Colors.purple.withOpacity(0.2),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.blue.withOpacity(0.4),
                                                        Colors.indigo.withOpacity(0.4),
                                                      ],
                                                    ),
                                                    borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
                                                  ),
                                                  child: Icon(
                                                    Icons.search_rounded,
                                                    size: 64,
                                                    color: Colors.white.withOpacity(0.9),
                                                  ),
                                                ),
                                                const SizedBox(height: ThemeConstants.spacingLarge),
                                                Text(
                                                  'Khám Phá Thời Tiết',
                                                  style: TextStyle(
                                                    fontSize: ThemeConstants.fontSizeLarge,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white.withOpacity(0.9),
                                                  ),
                                                ),
                                                const SizedBox(height: ThemeConstants.spacingSmall),
                                                Text(
                                                  'Nhập tên thành phố để xem thông tin thời tiết chi tiết',
                                                  style: TextStyle(
                                                    fontSize: ThemeConstants.fontSizeMedium,
                                                    color: Colors.white.withOpacity(0.7),
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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

  List<Color> _getAnimatedGradientColors(bool isDark) {
    final animationValue = _backgroundAnimation.value;
    
    if (isDark) {
      return [
        Color.lerp(const Color(0xFF1E3A8A), const Color(0xFF3B82F6), animationValue)!,
        Color.lerp(const Color(0xFF3B82F6), const Color(0xFF8B5CF6), animationValue)!,
        Color.lerp(const Color(0xFF8B5CF6), const Color(0xFFEC4899), animationValue)!,
        Color.lerp(const Color(0xFFEC4899), const Color(0xFF1E3A8A), animationValue)!,
      ];
    } else {
      return [
        Color.lerp(const Color(0xFF3B82F6), const Color(0xFF06B6D4), animationValue)!,
        Color.lerp(const Color(0xFF06B6D4), const Color(0xFF8B5CF6), animationValue)!,
        Color.lerp(const Color(0xFF8B5CF6), const Color(0xFFF59E0B), animationValue)!,
        Color.lerp(const Color(0xFFF59E0B), const Color(0xFF3B82F6), animationValue)!,
      ];
    }
  }

  List<Widget> _buildFloatingParticles() {
    return List.generate(8, (index) {
      final delay = index * 0.5;
      return AnimatedBuilder(
        animation: _backgroundAnimationController,
        builder: (context, child) {
          final progress = (_backgroundAnimationController.value + delay) % 1.0;
          final size = 4.0 + (index % 3) * 2.0;
          final opacity = 0.1 + (math.sin(progress * 2 * math.pi) * 0.1).abs();
          
          return Positioned(
            left: (progress * MediaQuery.of(context).size.width) - size,
            top: 100 + (index * 50.0) + (math.sin(progress * 4 * math.pi) * 30),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(opacity),
                borderRadius: BorderRadius.circular(size / 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(opacity * 0.5),
                    blurRadius: size,
                    spreadRadius: size / 4,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}