import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';
import 'package:key_starter/features/session/presentation/pages/lesson_page.dart';
import 'package:uuid/uuid.dart';

class ResultsPage extends StatelessWidget {
  final Session session;

  const ResultsPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final result = session.result!;
    final accuracy = (result.accuracy * 100).round();
    final minutes = result.durationSec ~/ 60;
    final seconds = result.durationSec % 60;
    final duration = minutes > 0
        ? '${minutes}m ${seconds.toString().padLeft(2, '0')}s'
        : '${seconds}s';

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Text('Résultats', style: AppTextStyles.display(size: 32)),
                    const SizedBox(height: 32),

                    // Accuracy — big hero stat
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      decoration: BoxDecoration(
                        color: accuracy >= 80 ? AppColors.okSoft : AppColors.errSoft,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$accuracy%',
                            style: AppTextStyles.display(size: 64).copyWith(
                              color: accuracy >= 80 ? AppColors.ok : AppColors.err,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${result.correctCount} / ${result.totalNotes} notes correctes',
                            style: AppTextStyles.ui(
                              size: 15,
                              color: accuracy >= 80 ? AppColors.ok : AppColors.err,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Secondary stats
                    _StatRow(
                      label: 'Durée',
                      value: duration,
                      icon: Icons.timer_outlined,
                    ),
                    const Divider(height: 1, color: AppColors.line),
                    _StatRow(
                      label: 'Meilleure série',
                      value: '${result.bestStreak} consécutives',
                      icon: Icons.local_fire_department_outlined,
                    ),
                    const Divider(height: 1, color: AppColors.line),
                    _StatRow(
                      label: 'Temps de réponse moyen',
                      value: '${result.avgResponseMs} ms',
                      icon: Icons.speed_outlined,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () {
                    final fresh = Session(
                      id: const Uuid().v4(),
                      clef: session.clef,
                      minNote: session.minNote,
                      maxNote: session.maxNote,
                      totalNotes: session.totalNotes,
                      showNoteName: session.showNoteName,
                      language: session.language,
                      startedAt: DateTime.now(),
                    );
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => LessonPage(session: fresh),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Recommencer',
                    style: AppTextStyles.ui(
                      size: 16,
                      weight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Nouvelle session',
                    style: AppTextStyles.ui(
                      size: 16,
                      weight: FontWeight.w600,
                      color: Colors.white,
                    ),
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

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.inkMute),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.ui(size: 15, color: AppColors.inkSoft)),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.ui(size: 15, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
