import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/constants/theme_constants.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _glowAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _glowAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _glowAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _glowAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            ThemeConstants.darkGradientStart.withOpacity(0.4),
                            ThemeConstants.darkGradientEnd.withOpacity(0.4),
                          ]
                        : [
                            ThemeConstants.lightGradientStart.withOpacity(0.4),
                            ThemeConstants.lightGradientEnd.withOpacity(0.4),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(_isFocused ? 0.4 : 0.2),
                      blurRadius: _isFocused ? 25 : 15,
                      offset: const Offset(0, 4),
                      spreadRadius: _isFocused ? 2 : 0,
                    ),
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(_isFocused ? _glowAnimation.value * 0.3 : 0.1),
                      blurRadius: _isFocused ? 30 : 10,
                      offset: const Offset(0, 2),
                      spreadRadius: _isFocused ? 3 : 0,
                    ),
                  ],
                ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
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
                        Colors.white.withOpacity(_isFocused ? 0.25 : 0.15),
                        Colors.white.withOpacity(_isFocused ? 0.15 : 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
                    border: Border.all(
                      color: _isFocused 
                          ? Colors.white.withOpacity(0.6)
                          : Colors.white.withOpacity(0.3),
                      width: _isFocused ? 2.5 : 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: widget.controller,
                    onChanged: widget.onChanged,
                    onTap: () {
                      setState(() => _isFocused = true);
                      _animationController.forward();
                      _glowAnimationController.repeat();
                    },
                    onEditingComplete: () {
                      setState(() => _isFocused = false);
                      _animationController.reverse();
                      _glowAnimationController.stop();
                    },
                    onTapOutside: (event) {
                      setState(() => _isFocused = false);
                      _animationController.reverse();
                      _glowAnimationController.stop();
                      FocusScope.of(context).unfocus();
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm thành phố...',
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: 16,
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: _isFocused ? LinearGradient(
                              colors: [
                                Colors.blue.withOpacity(0.3),
                                Colors.purple.withOpacity(0.3),
                              ],
                            ) : null,
                            borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
                          ),
                          child: Icon(
                            Icons.search_rounded,
                            color: Colors.black.withOpacity(_isFocused ? 0.8 : 0.6),
                            size: _isFocused ? 26 : 24,
                          ),
                        ),
                      ),
                      suffixIcon: widget.controller.text.isNotEmpty
                          ? Container(
                              margin: const EdgeInsets.only(right: ThemeConstants.spacingSmall),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
                                  onTap: widget.onClear,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(ThemeConstants.spacingSmall),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.red.withOpacity(0.2),
                                          Colors.orange.withOpacity(0.2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.clear_rounded,
                                      color: Colors.black.withOpacity(0.7),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: ThemeConstants.spacingLarge,
                        vertical: ThemeConstants.spacingLarge,
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
            );
          },
          ),
        );
      },
    );
  }
}