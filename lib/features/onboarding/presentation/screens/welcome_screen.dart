import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../shared/widgets.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoScaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 30), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _logoScaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: context.bg,
        body: Stack(
          children: [
            _BackgroundGradient(isDark: isDark),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.screenPadding,
                ),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    _LogoSection(
                      fadeAnimation: _fadeAnimation,
                      logoScaleAnimation: _logoScaleAnimation,
                    ),
                    SizedBox(height: context.spacingXxl + 16),
                    _WelcomeText(
                      fadeAnimation: _fadeAnimation,
                      slideAnimation: _slideAnimation,
                    ),
                    SizedBox(height: context.spacingXxl + 24),
                    _PrimaryButton(fadeAnimation: _fadeAnimation),
                    SizedBox(height: context.spacingSm + 4),
                    _SecondaryButton(fadeAnimation: _fadeAnimation),
                    const Spacer(flex: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundGradient extends StatelessWidget {
  final bool isDark;

  const _BackgroundGradient({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0B0B0F),
                  const Color(0xFF0F1419),
                  const Color(0xFF0B0B0F),
                ]
              : [
                  const Color(0xFFF9F9FB),
                  const Color(0xFFF2F2F7),
                  const Color(0xFFF9F9FB),
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: _AnimatedOrb(
              color: isDark
                  ? const Color(0xFF007AFF).withValues(alpha: 0.12)
                  : const Color(0xFF007AFF).withValues(alpha: 0.08),
              size: 320,
            ),
          ),
          Positioned(
            bottom: -120,
            left: -100,
            child: _AnimatedOrb(
              color: isDark
                  ? const Color(0xFF5AC8FA).withValues(alpha: 0.1)
                  : const Color(0xFF5AC8FA).withValues(alpha: 0.06),
              size: 400,
            ),
          ),
          Positioned(
            top: 180,
            left: -60,
            child: _AnimatedOrb(
              color: isDark
                  ? const Color(0xFFAF52DE).withValues(alpha: 0.06)
                  : const Color(0xFFAF52DE).withValues(alpha: 0.03),
              size: 260,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedOrb extends StatefulWidget {
  final Color color;
  final double size;

  const _AnimatedOrb({required this.color, required this.size});

  @override
  State<_AnimatedOrb> createState() => _AnimatedOrbState();
}

class _AnimatedOrbState extends State<_AnimatedOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _orbController;
  late Animation<double> _orbAnimation;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _orbAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _orbController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _orbAnimation,
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

class _LogoSection extends StatefulWidget {
  final Animation<double> fadeAnimation;
  final Animation<double> logoScaleAnimation;

  const _LogoSection({
    required this.fadeAnimation,
    required this.logoScaleAnimation,
  });

  @override
  State<_LogoSection> createState() => _LogoSectionState();
}

class _LogoSectionState extends State<_LogoSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _breathAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.fadeAnimation,
      child: ScaleTransition(
        scale: widget.logoScaleAnimation,
        child: ScaleTransition(
          scale: _breathAnimation,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.surface,
              boxShadow: [
                BoxShadow(
                  color: context.accent.withValues(alpha: 0.18),
                  blurRadius: 36,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: context.divider.withValues(alpha: 0.08),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Center(
              child: ClipOval(
                child: Image.asset(
                  'assets/logo.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeText extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const _WelcomeText({
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Column(
          children: [
            Text(
              'Bleeper',
              style: context.h1.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                fontSize: 34,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'A calm place to share thoughts,\nnot noise.',
              style: context.bodyMedium.copyWith(color: context.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const _PrimaryButton({required this.fadeAnimation});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: BleeperButton(
        label: 'Get Started',
        onPressed: () => context.go('/features'),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const _SecondaryButton({required this.fadeAnimation});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: TextButton(
          onPressed: () => context.go('/login'),
          child: Text(
            'I already have an account',
            style: context.bodyMedium.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
