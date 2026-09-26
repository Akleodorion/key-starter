import 'package:equatable/equatable.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';

/// Paramètres d'une partie de l'exercice Tempo Accords : réglages de la
/// séquence d'accords et tempo choisi.
class ChordTempoExerciseConfig extends Equatable {
  final NoteExerciseSettings settings;
  final int bpm;

  const ChordTempoExerciseConfig({required this.settings, required this.bpm});

  @override
  List<Object?> get props => [settings, bpm];
}
