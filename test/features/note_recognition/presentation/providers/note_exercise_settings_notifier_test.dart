import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/defilement_settings_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/flashcard_settings_notifier.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  group(
    'NoteExerciseSettingsNotifier (logique partagée Flashcard/Défilement)',
    () {
      test('état initial : clé de Sol, 15 notes, étendue -2 à 4', () {
        //assert
        final settings = container.read(flashcardSettingsProvider);
        expect(settings.clef, ClefMode.treble);
        expect(settings.noteCount, 15);
        expect(settings.minNoteStep, -2);
        expect(settings.maxNoteStep, 4);
      });

      test('setClef reborne min/max dans les limites de la nouvelle clé', () {
        //act
        container
            .read(flashcardSettingsProvider.notifier)
            .setClef(ClefMode.bass);

        //assert
        final settings = container.read(flashcardSettingsProvider);
        expect(settings.clef, ClefMode.bass);
        expect(settings.minNoteStep, greaterThanOrEqualTo(-14));
        expect(settings.maxNoteStep, lessThanOrEqualTo(2));
        expect(settings.minNoteStep, lessThan(settings.maxNoteStep));
      });

      test('incrementNoteCount avance par pas de 5 sans dépasser 100', () {
        //arrange
        final notifier = container.read(flashcardSettingsProvider.notifier);
        for (var i = 0; i < 20; i++) {
          notifier.incrementNoteCount();
        }

        //assert
        expect(container.read(flashcardSettingsProvider).noteCount, 100);
      });

      test('decrementNoteCount recule par pas de 5 sans descendre sous 10', () {
        //arrange
        final notifier = container.read(flashcardSettingsProvider.notifier);
        for (var i = 0; i < 5; i++) {
          notifier.decrementNoteCount();
        }

        //assert
        expect(container.read(flashcardSettingsProvider).noteCount, 10);
      });

      test(
        'incrementMinNote/decrementMaxNote respectent l\'invariant min < max',
        () {
          //arrange
          final notifier = container.read(flashcardSettingsProvider.notifier);
          for (var i = 0; i < 10; i++) {
            notifier.incrementMinNote();
            notifier.decrementMaxNote();
          }

          //assert
          final settings = container.read(flashcardSettingsProvider);
          expect(settings.minNoteStep, lessThan(settings.maxNoteStep));
        },
      );
    },
  );

  group('Indépendance des providers Flashcard et Défilement', () {
    test(
      'modifier flashcardSettingsProvider ne change pas defilementSettingsProvider',
      () {
        //act
        container
            .read(flashcardSettingsProvider.notifier)
            .setClef(ClefMode.bass);
        container.read(flashcardSettingsProvider.notifier).incrementNoteCount();

        //assert
        final defilementSettings = container.read(defilementSettingsProvider);
        expect(defilementSettings.clef, ClefMode.treble);
        expect(defilementSettings.noteCount, 15);
      },
    );
  });
}
