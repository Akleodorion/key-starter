import 'package:equatable/equatable.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';

/// Paramètres d'une partie de l'exercice Tempo : réglages de la séquence de
/// notes et tempo choisi.
class TempoExerciseConfig extends Equatable {
  final NoteExerciseSettings settings;
  final int bpm;

  const TempoExerciseConfig({required this.settings, required this.bpm});

  @override
  List<Object?> get props => [settings, bpm];
}
