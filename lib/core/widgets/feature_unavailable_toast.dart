import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';

class FeatureUnavailableToast extends StatefulWidget {
  final String message;
  final VoidCallback onDismissed;

  const FeatureUnavailableToast({
    super.key,
    required this.message,
    required this.onDismissed,
  });

  @override
  State<FeatureUnavailableToast> createState() =>
      _FeatureUnavailableToastState();
}

class _FeatureUnavailableToastState extends State<FeatureUnavailableToast>
    with SingleTickerProviderStateMixin {
  static const _fadeInDuration = Duration(milliseconds: 220);
  static const _visibleDuration = Duration(milliseconds: 1000);
  static const _fadeOutDuration = Duration(milliseconds: 600);

  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _fadeInDuration);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    Future.delayed(_fadeInDuration + _visibleDuration, _fadeOut);
  }

  Future<void> _fadeOut() async {
    if (!mounted) return;
    await _controller.animateBack(
      0,
      duration: _fadeOutDuration,
      curve: Curves.easeIn,
    );
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: FadeTransition(
          opacity: _opacity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Material(
              color: colors.text,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  widget.message,
                  style: AppTextStyles.ui(
                    size: 14,
                    color: colors.bg,
                  ).copyWith(decoration: TextDecoration.none),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
