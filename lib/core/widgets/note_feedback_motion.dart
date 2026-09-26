import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/utils/note_feedback_motion.dart';

/// Rejoue l'effet de retour d'une note de portée chaque fois que
/// [noteState] passe à juste ou faux : [builder] reçoit à chaque frame
/// l'échelle (gonflement) et le décalage horizontal (tremblement) à appliquer,
/// l'effet durant [duration].
class NoteFeedbackMotion extends StatefulWidget {
  final NoteState noteState;
  final Duration duration;
  final Widget Function(BuildContext context, double scale, double shift)
  builder;

  const NoteFeedbackMotion({
    super.key,
    required this.noteState,
    required this.builder,
    this.duration = noteFeedbackDuration,
  });

  @override
  State<NoteFeedbackMotion> createState() => _NoteFeedbackMotionState();
}

class _NoteFeedbackMotionState extends State<NoteFeedbackMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: widget.duration,
    vsync: this,
  );

  @override
  void didUpdateWidget(NoteFeedbackMotion oldWidget) {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => widget.builder(
        context,
        noteFeedbackScale(widget.noteState, _controller.value),
        noteFeedbackShift(widget.noteState, _controller.value),
      ),
    );
  }
}
