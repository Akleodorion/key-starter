import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';

/// Logique de bornage partagée par les réglages d'exercices de séquence de
/// notes (Flashcard, Défilement) : bornes diatoniques par clef, invariants
/// nombre de notes / étendue min-max.
///
/// Les sous-classes ne fournissent que la valeur initiale via [build] — chaque
/// exercice garde son propre provider et sa propre instance d'état.
///
/// Voir aussi : [FlashcardSettingsNotifier], [DefilementSettingsNotifier]
abstract class NoteExerciseSettingsNotifier
    extends Notifier<NoteExerciseSettings> {
  static const int _minNoteCount = 10;
  static const int _maxNoteCount = 100;

  // Bornes diatoniques par clef
  static const int _trebleMinStep = -2; // La 3
  static const int _trebleMaxStep = 14; // Do 6
  static const int _bassMinStep = -14; // Do 2
  static const int _bassMaxStep = 2; // Mi 4

  int get _minStep =>
      state.clef == ClefMode.treble ? _trebleMinStep : _bassMinStep;
  int get _maxStep =>
      state.clef == ClefMode.treble ? _trebleMaxStep : _bassMaxStep;

  void setClef(ClefMode clef) {
    final newMinBound = clef == ClefMode.treble ? _trebleMinStep : _bassMinStep;
    final newMaxBound = clef == ClefMode.treble ? _trebleMaxStep : _bassMaxStep;
    final clampedMin = state.minNoteStep.clamp(newMinBound, newMaxBound - 1);
    final clampedMax = state.maxNoteStep.clamp(clampedMin + 1, newMaxBound);
    state = state.copyWith(
      clef: clef,
      minNoteStep: clampedMin,
      maxNoteStep: clampedMax,
    );
  }

  void incrementNoteCount() {
    if (state.noteCount < _maxNoteCount) {
      state = state.copyWith(noteCount: state.noteCount + 5);
    }
  }

  void decrementNoteCount() {
    if (state.noteCount > _minNoteCount) {
      state = state.copyWith(noteCount: state.noteCount - 5);
    }
  }

  void incrementMinNote() {
    if (state.minNoteStep < state.maxNoteStep - 1) {
      state = state.copyWith(minNoteStep: state.minNoteStep + 1);
    }
  }

  void decrementMinNote() {
    if (state.minNoteStep > _minStep) {
      state = state.copyWith(minNoteStep: state.minNoteStep - 1);
    }
  }

  void incrementMaxNote() {
    if (state.maxNoteStep < _maxStep) {
      state = state.copyWith(maxNoteStep: state.maxNoteStep + 1);
    }
  }

  void decrementMaxNote() {
    if (state.maxNoteStep > state.minNoteStep + 1) {
      state = state.copyWith(maxNoteStep: state.maxNoteStep - 1);
    }
  }
}
