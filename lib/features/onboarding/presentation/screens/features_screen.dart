import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../shared/widgets.dart';

class FeaturesScreen extends StatefulWidget {
  const FeaturesScreen({super.key});

  @override
  State<FeaturesScreen> createState() => _FeaturesScreenState();
}

class _FeaturesScreenState extends State<FeaturesScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<_FeatureItem> _features = const [
    _FeatureItem(
      icon: HugeIconsStrokeRounded.bubbleChat,
      title: 'Share thoughts as Bleeps',
      description: 'simple bleeps, clean conversations',
      color: 0xFF007AFF,
    ),
    _FeatureItem(
      icon: HugeIconsStrokeRounded.group01,
      title: 'Join Circles',
      description: 'no chaos, just communities',
      color: 0xFF5AC8FA,
    ),
    _FeatureItem(
      icon: HugeIconsStrokeRounded.userSearch01,
      title: 'Find people who get it',
      description: 'connect with real minds',
      color: 0xFFAF52DE,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final isLastPage = _currentPage == _features.length - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: context.bg,
        body: Stack(
          children: [
            _BackgroundOrbs(isDark: isDark),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.screenPadding,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        children: _features
                            .map((f) => _FeaturePage(item: f))
                            .toList(),
                      ),
                    ),
                    _AnimatedIndicator(
                      currentPage: _currentPage,
                      totalPages: _features.length,
                    ),
                    SizedBox(height: context.spacingXxl + 16),
                    BleeperButton(
                      label: isLastPage ? 'Get Started' : 'Next',
                      onPressed: isLastPage
                          ? () => context.go('/signup')
                          : () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                            ),
                    ),
                    SizedBox(height: context.spacingXxl),
                  ],
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: context.screenPadding,
              child: TextButton(
                onPressed: () => context.go('/signup'),
                child: Text(
                  'Skip',
                  style: context.bodyMedium.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundOrbs extends StatelessWidget {
  final bool isDark;

  const _BackgroundOrbs({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -150,
          right: -100,
          child: _BreathingOrb(
            color: isDark
                ? const Color(0xFF007AFF).withValues(alpha: 0.08)
                : const Color(0xFF007AFF).withValues(alpha: 0.05),
            size: 350,
          ),
        ),
        Positioned(
          bottom: -180,
          left: -120,
          child: _BreathingOrb(
            color: isDark
                ? const Color(0xFF5AC8FA).withValues(alpha: 0.06)
                : const Color(0xFF5AC8FA).withValues(alpha: 0.04),
            size: 400,
          ),
        ),
      ],
    );
  }
}

class _BreathingOrb extends StatefulWidget {
  final Color color;
  final double size;

  const _BreathingOrb({required this.color, required this.size});

  @override
  State<_BreathingOrb> createState() => _BreathingOrbState();
}

class _BreathingOrbState extends State<_BreathingOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.96,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
          boxShadow: [
            BoxShadow(
              color: widget.color,
              blurRadius: widget.size * 0.4,
              spreadRadius: widget.size * 0.1,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _AnimatedIndicator({
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (i) {
        final isActive = i == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? context.accent
                : context.textTertiary.withValues(alpha: 0.4),
          ),
        );
      }),
    );
  }
}

class _FeatureItem {
  final List<List<dynamic>> icon;
  final String title;
  final String description;
  final int color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _FeaturePage extends StatelessWidget {
  final _FeatureItem item;
  const _FeaturePage({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.screenPadding,
        vertical: context.spacingXl,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(item.color).withValues(alpha: 0.12),
              boxShadow: [
                BoxShadow(
                  color: Color(item.color).withValues(alpha: 0.15),
                  blurRadius: 32,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: HugeIcon(icon: item.icon, size: 40, color: Color(item.color)),
          ),
          SizedBox(height: context.spacingXxl + 16),
          Text(item.title, style: context.h1, textAlign: TextAlign.center),
          SizedBox(height: context.spacingMd + 4),
          Text(
            item.description,
            style: context.bodyMedium.copyWith(color: context.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
