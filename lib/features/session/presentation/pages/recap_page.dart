import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/widgets/ui_text.dart';
import 'package:key_starter/features/session/presentation/widgets/recap_stats_card.dart';
import 'package:key_starter/features/session/presentation/widgets/recap_top_bar.dart';

class RecapPage extends StatefulWidget {
  final String exerciseLabel;
  final int correctCount;
  final int totalNotes;
  final int avgResponseMs;
  final int bestStreak;
  final VoidCallback onRetry;

  const RecapPage({
    super.key,
    required this.exerciseLabel,
    required this.correctCount,
    required this.totalNotes,
    required this.avgResponseMs,
    required this.bestStreak,
    required this.onRetry,
  });

  @override
  State<RecapPage> createState() => _RecapPageState();
}

class _RecapPageState extends State<RecapPage> {
  bool _handingOffToExercise = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    if (!_handingOffToExercise) {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RecapTopBar(exerciseLabel: widget.exerciseLabel),
              const SizedBox(height: 32),
              RecapStatsCard(
                correctCount: widget.correctCount,
                totalNotes: widget.totalNotes,
                avgResponseMs: widget.avgResponseMs,
                bestStreak: widget.bestStreak,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.text,
                          side: BorderSide(color: colors.line),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: UiText(
                          'Retour',
                          size: 16,
                          weight: FontWeight.w600,
                          color: colors.text,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: () {
                          _handingOffToExercise = true;
                          widget.onRetry();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.notesFg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        icon: const Icon(
                          Icons.replay_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const UiText(
                          'Refaire',
                          size: 16,
                          weight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
