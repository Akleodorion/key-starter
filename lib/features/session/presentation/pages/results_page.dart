import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';
import 'package:key_starter/features/session/presentation/widgets/results_accuracy_card.dart';
import 'package:key_starter/features/session/presentation/widgets/results_actions.dart';
import 'package:key_starter/features/session/presentation/widgets/results_stats_list.dart';

/// Page de fin de session : affiche les résultats et propose de recommencer
/// ou de revenir à la configuration via [ResultsActions].
class ResultsPage extends StatelessWidget {
  final Session session;

  const ResultsPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
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
                    ResultsAccuracyCard(session: session),
                    const SizedBox(height: 24),
                    ResultsStatsList(session: session),
                  ],
                ),
              ),
            ),
            ResultsActions(session: session),
          ],
        ),
      ),
    );
  }
}
