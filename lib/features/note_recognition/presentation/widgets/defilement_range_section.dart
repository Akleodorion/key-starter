import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/providers/notation_language_provider.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/staff_range_widget.dart';
import 'package:key_starter/core/widgets/ui_text.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/defilement_settings_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/note_stepper_control.dart';

class DefilementRangeSection extends ConsumerWidget {
  const DefilementRangeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(defilementSettingsProvider);
    final language = ref.watch(notationLanguageProvider);
    final colors = AppColorTheme.of(context);
    final notifier = ref.read(defilementSettingsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UiText(
          'Étendue',
          size: 15,
          weight: FontWeight.w600,
          color: colors.text,
        ),
        const SizedBox(height: 2),
        UiText(
          'choisis la note la plus grave et la plus aiguë',
          size: 12,
          color: colors.text2,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.line),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: StaffRangeWidget(
                  clef: settings.clef,
                  minDiatonicStep: settings.minNoteStep,
                  maxDiatonicStep: settings.maxNoteStep,
                ),
              ),
              Divider(height: 1, thickness: 1, color: colors.line),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    NoteStepperControl(
                      label: 'de',
                      step: settings.minNoteStep,
                      language: language,
                      onDecrement: notifier.decrementMinNote,
                      onIncrement: notifier.incrementMinNote,
                    ),
                    const Spacer(),
                    NoteStepperControl(
                      label: 'à',
                      step: settings.maxNoteStep,
                      language: language,
                      onDecrement: notifier.decrementMaxNote,
                      onIncrement: notifier.incrementMaxNote,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
