import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../domain/entities/city.dart';
import '../../../../core/constants/theme_constants.dart';

class SearchResultsWidget extends StatefulWidget {
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
  State<SearchResultsWidget> createState() => _SearchResultsWidgetState();
}

class _SearchResultsWidgetState extends State<SearchResultsWidget> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cities.isEmpty) {
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
              child: Icon(
                Icons.location_off_rounded,
                size: 64,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingLarge),
            Text(
              'Không tìm thấy thành phố',
              style: TextStyle(
                fontSize: ThemeConstants.fontSizeLarge,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingSmall),
            Text(
              'Thử tìm kiếm với từ khóa khác',
              style: TextStyle(
                fontSize: ThemeConstants.fontSizeMedium,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enhanced Header with animation
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spacingMedium,
            vertical: ThemeConstants.spacingSmall,
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.withOpacity(0.4),
                                Colors.indigo.withOpacity(0.4),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(ThemeConstants.radiusSmall),
                          ),
                          child: Icon(
                            Icons.travel_explore_rounded,
                            color: Colors.white.withOpacity(0.9),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: ThemeConstants.spacingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kết quả tìm kiếm',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              Text(
                                'Cho từ khóa "${widget.query}"',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ThemeConstants.spacingMedium,
                            vertical: ThemeConstants.spacingSmall,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.withOpacity(0.3),
                                Colors.teal.withOpacity(0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_city_rounded,
                                color: Colors.white.withOpacity(0.8),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.cities.length}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Animated List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: ThemeConstants.spacingLarge),
            itemCount: widget.cities.length,
            itemBuilder: (context, index) {
              final city = widget.cities[index];
              
              return AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  // Calculate staggered animation values
                  final staggerDelay = index * 0.1;
                  final adjustedValue = (_animation.value - staggerDelay).clamp(0.0, 1.0);
                  final slideValue = 100.0 * (1 - adjustedValue);
                  final scaleValue = 0.8 + (0.2 * adjustedValue);
                  
                  return RepaintBoundary(
                    child: Transform.translate(
                      offset: Offset(slideValue, 0),
                      child: Transform.scale(
                        scale: scaleValue,
                        child: Opacity(
                          opacity: adjustedValue,
                          child: _buildCityListItem(context, city, index),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCityListItem(BuildContext context, City city, int index) {
    final colors = _getGradientColors(index);
    
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingMedium,
        vertical: ThemeConstants.spacingSmall,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: ThemeConstants.glassBlur,
            sigmaY: ThemeConstants.glassBlur,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors[0].withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
                onTap: () => widget.onCitySelected(city.name, city.displayName),
                child: Padding(
                  padding: const EdgeInsets.all(ThemeConstants.spacingLarge),
                  child: Row(
                    children: [
                      // Enhanced City icon with dynamic colors
                      Hero(
                        tag: 'city_${city.name}',
                        child: Container(
                          padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: colors,
                            ),
                            borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
                            boxShadow: [
                              BoxShadow(
                                color: colors[0].withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            _getCityIcon(index),
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: ThemeConstants.spacingLarge),
                      
                      // Enhanced City details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              city.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.4),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: colors[1].withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.location_on_rounded,
                                    size: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(width: ThemeConstants.spacingSmall),
                                Expanded(
                                  child: Text(
                                    '${city.region}, ${city.country}',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.white.withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Enhanced Action button
                      Container(
                        padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Xem',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Colors.white.withOpacity(0.9),
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
        ),
      ),
    );
  }

  List<Color> _getGradientColors(int index) {
    final colorSets = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
      [const Color(0xFFfa709a), const Color(0xFFfee140)],
      [const Color(0xFFa8edea), const Color(0xFFfed6e3)],
      [const Color(0xFF89f7fe), const Color(0xFF66a6ff)],
      [const Color(0xFFffecd2), const Color(0xFFfcb69f)],
    ];
    return colorSets[index % colorSets.length];
  }

  IconData _getCityIcon(int index) {
    final icons = [
      Icons.location_city_rounded,
      Icons.business_rounded,
      Icons.apartment_rounded,
      Icons.domain_rounded,
      Icons.home_work_rounded,
      Icons.corporate_fare_rounded,
      Icons.villa_rounded,
      Icons.holiday_village_rounded,
    ];
    return icons[index % icons.length];
  }
}