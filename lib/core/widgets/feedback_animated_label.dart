import 'dart:math';

import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/widgets/display_text.dart';

/// Grand libellé de consigne : vert avec un saut si la réponse est juste,
/// rouge avec un tremblement si elle est fausse.
class FeedbackAnimatedLabel extends StatefulWidget {
  final String label;
  final NoteState noteState;

  const FeedbackAnimatedLabel({
    super.key,
    required this.label,
    required this.noteState,
  });

  @override
  State<FeedbackAnimatedLabel> createState() => _FeedbackAnimatedLabelState();
}

class _FeedbackAnimatedLabelState extends State<FeedbackAnimatedLabel>
    with SingleTickerProviderStateMixin {
  static const _jumpHeight = 24.0;
  static const _jumpScaleGain = 0.12;
  static const _shakeAmplitude = 12.0;
  static const _shakeOscillations = 3;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 400),
    vsync: this,
  );

  @override
  void didUpdateWidget(FeedbackAnimatedLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.noteState != oldWidget.noteState &&
        widget.noteState != NoteState.idle) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = switch (widget.noteState) {
      NoteState.correct => AppColors.stateGreen,
      NoteState.wrong => AppColors.stateRed,
      NoteState.idle => AppColorTheme.of(context).text,
    };

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final arc = sin(progress * pi);
        final isCorrect = widget.noteState == NoteState.correct;
        final isWrong = widget.noteState == NoteState.wrong;
        final horizontalShift = isWrong
            ? sin(progress * pi * 2 * _shakeOscillations) *
                  _shakeAmplitude *
                  (1 - progress)
            : 0.0;
        final verticalShift = isCorrect ? -arc * _jumpHeight : 0.0;
        final scale = isCorrect ? 1 + arc * _jumpScaleGain : 1.0;

        return Transform.translate(
          offset: Offset(horizontalShift, verticalShift),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: DisplayText(widget.label, size: 120, color: labelColor),
    );
  }
}
