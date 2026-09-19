import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/utils/staff_paint_utils.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/defilement_exercise_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/defilement_exercise_state.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';

const double _noteSpacing = 80.0;
const double _clefPanelWidth = 70.0;

/// Portée qui défile, liée à [defilementExerciseProvider] : toute la séquence
/// de notes est dessinée à la suite, et la portée glisse pour amener la note
/// courante au repère (bord gauche de la zone défilante) à chaque réponse.
class DefilementStaffWidget extends ConsumerStatefulWidget {
  final NoteExerciseSettings settings;
  final double height;

  const DefilementStaffWidget({
    super.key,
    required this.settings,
    this.height = 100,
  });

  @override
  ConsumerState<DefilementStaffWidget> createState() =>
      _DefilementStaffWidgetState();
}

class _DefilementStaffWidgetState extends ConsumerState<DefilementStaffWidget> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lineColor = AppColorTheme.of(context).text;

    ref.listen(defilementExerciseProvider(widget.settings), (previous, next) {
      final previousIndex = previous is DefilementExerciseRunning
          ? previous.currentIndex
          : null;
      final nextRunning = next is DefilementExerciseRunning ? next : null;
      if (nextRunning == null || previousIndex == nextRunning.currentIndex) {
        return;
      }
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        nextRunning.currentIndex * _noteSpacing,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });

    final exerciseState = ref.watch(
      defilementExerciseProvider(widget.settings),
    );
    final running = exerciseState is DefilementExerciseRunning
        ? exerciseState
        : null;
    final noteSteps = running?.noteSteps ?? const <int>[];
    final currentIndex = running?.currentIndex ?? 0;
    final noteState = running?.noteState ?? NoteState.idle;

    return SizedBox(
      height: widget.height,
      child: Row(
        children: [
          SizedBox(
            width: _clefPanelWidth,
            height: widget.height,
            child: CustomPaint(
              painter: _DefilementPinnedClefPainter(
                clef: widget.settings.clef,
                lineColor: lineColor,
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final canvasWidth =
                    noteSteps.length * _noteSpacing + constraints.maxWidth;
                return Stack(
                  children: [
                    SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: CustomPaint(
                        size: Size(canvasWidth, widget.height),
                        painter: _DefilementScrollingStaffPainter(
                          noteSteps: noteSteps,
                          currentIndex: currentIndex,
                          noteState: noteState,
                          clef: widget.settings.clef,
                          lineColor: lineColor,
                        ),
                      ),
                    ),
                    // Repère fixe : la note courante glisse jusqu'ici.
                    Positioned(
                      left: _noteSpacing / 2 - 1,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 2,
                        color: lineColor.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Dessine juste les lignes et le glyphe de clef, toujours visibles à gauche
/// de la zone défilante.
class _DefilementPinnedClefPainter extends CustomPainter {
  final ClefMode clef;
  final Color lineColor;

  const _DefilementPinnedClefPainter({
    required this.clef,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final staffTop = staffTopFor(size);
    paintStaffLines(
      canvas,
      staffTop: staffTop,
      x1: 20,
      x2: size.width,
      lineColor: lineColor,
    );
    paintClefGlyph(
      canvas,
      clef: clef,
      x: 22,
      staffTop: staffTop,
      color: lineColor,
    );
  }

  @override
  bool shouldRepaint(_DefilementPinnedClefPainter old) =>
      old.clef != clef || old.lineColor != lineColor;
}

/// Dessine la portée et toute la séquence de notes ; seule la note à
/// [currentIndex] est colorée selon [noteState].
class _DefilementScrollingStaffPainter extends CustomPainter {
  final List<int> noteSteps;
  final int currentIndex;
  final NoteState noteState;
  final ClefMode clef;
  final Color lineColor;

  const _DefilementScrollingStaffPainter({
    required this.noteSteps,
    required this.currentIndex,
    required this.noteState,
    required this.clef,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final staffTop = staffTopFor(size);
    paintStaffLines(
      canvas,
      staffTop: staffTop,
      x1: 0,
      x2: size.width,
      lineColor: lineColor,
    );

    for (var index = 0; index < noteSteps.length; index++) {
      final isCurrent = index == currentIndex;
      final color = isCurrent
          ? switch (noteState) {
              NoteState.correct => AppColors.stateGreen,
              NoteState.wrong => AppColors.stateRed,
              NoteState.idle => lineColor,
            }
          : AppColors.notesFg;

      paintNote(
        canvas,
        noteX: index * _noteSpacing + _noteSpacing / 2,
        step: noteSteps[index],
        clef: clef,
        staffTop: staffTop,
        color: color,
      );
    }
  }

  @override
  bool shouldRepaint(_DefilementScrollingStaffPainter old) =>
      old.currentIndex != currentIndex ||
      old.noteState != noteState ||
      old.clef != clef ||
      old.lineColor != lineColor ||
      !listEquals(old.noteSteps, noteSteps);
}
