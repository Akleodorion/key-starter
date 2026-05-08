import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/widgets/primary_button.dart';
import 'package:key_starter/features/session/presentation/providers/session_setup_notifier.dart';
import 'package:key_starter/features/session/presentation/widgets/midi_status_bar.dart';
import 'package:key_starter/features/session/presentation/widgets/session_clef_segmented_control.dart';
import 'package:key_starter/features/session/presentation/widgets/session_note_display_picker.dart';
import 'package:key_starter/features/session/presentation/widgets/session_note_range_widget.dart';
import 'package:key_starter/features/session/presentation/widgets/session_total_notes_slider.dart';

/// Layout de la page de configuration d'une session.
///
/// Chaque widget de saisie est autonome et lit directement
/// [sessionSetupNotifierProvider] — ce widget ne transmet aucune donnée.
class SessionSetupLayout extends ConsumerWidget {
  const SessionSetupLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(sessionSetupNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: MidiStatusBar(),
            ),
            const Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SessionClefSegmentedControl(),
                    SizedBox(height: 12),
                    SessionNoteRangeWidget(),
                    SizedBox(height: 12),
                    SessionTotalNotesSlider(),
                    SizedBox(height: 12),
                    SessionNoteDisplayPicker(),
                  ],
                ),
              ),
            ),
            PrimaryButton(label: 'Commencer', onPressed: notifier.startSession),
          ],
        ),
      ),
    );
  }
}
