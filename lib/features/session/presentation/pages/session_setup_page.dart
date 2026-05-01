import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';
import 'package:key_starter/core/widgets/clef_segmented_control.dart';
import 'package:key_starter/core/widgets/note_display_picker.dart';
import 'package:key_starter/core/widgets/note_range_widget.dart';
import 'package:key_starter/core/widgets/session_notes_slider.dart';
import 'package:key_starter/core/widgets/staff_widget.dart';
import 'package:key_starter/features/session/presentation/pages/lesson_page.dart';
import 'package:key_starter/features/session/presentation/providers/session_setup_notifier.dart';
import 'package:key_starter/features/session/presentation/providers/session_setup_state.dart';

class SessionSetupPage extends ConsumerWidget {
  const SessionSetupPage({super.key});

  static const _bottomStep = {ClefMode.treble: 2, ClefMode.bass: -10};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<SessionSetupState>(sessionSetupNotifierProvider, (_, next) {
      if (next is SessionSetupCreated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => LessonPage(session: next.session)),
        );
      }
    });

    final state = ref.watch(sessionSetupNotifierProvider);

    return switch (state) {
      SessionSetupInitial() || SessionSetupLoading() => _buildLoading(),
      SessionSetupLoaded() => _buildForm(context, ref, state),
      SessionSetupError() => _buildError(state.message),
      SessionSetupCreated() => _buildLoading(),
    };
  }

  Widget _buildLoading() => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );

  Widget _buildError(String message) => Scaffold(
        body: Center(child: Text(message)),
      );

  Widget _buildForm(
    BuildContext context,
    WidgetRef ref,
    SessionSetupLoaded state,
  ) {
    final notifier = ref.read(sessionSetupNotifierProvider.notifier);
    final diatonicStep = _bottomStep[state.clef]! + 4;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StaffWidget(
                      diatonicStep: diatonicStep,
                      clef: state.clef,
                    ),
                    const SizedBox(height: 24),
                    ClefSegmentedControl(
                      value: state.clef,
                      onChanged: notifier.setClef,
                    ),
                    const SizedBox(height: 24),
                    NoteRangeWidget(
                      clef: state.clef,
                      minStep: state.minStep,
                      maxStep: state.maxStep,
                      onMinChanged: notifier.setMinStep,
                      onMaxChanged: notifier.setMaxStep,
                    ),
                    const SizedBox(height: 24),
                    SessionNotesSlider(
                      value: state.totalNotes,
                      onChanged: notifier.setTotalNotes,
                    ),
                    const SizedBox(height: 24),
                    NoteDisplayPicker(
                      value: state.noteLanguage,
                      onChanged: notifier.setNoteLanguage,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () => notifier.startSession(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Commencer',
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
