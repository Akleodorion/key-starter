import 'package:equatable/equatable.dart';

/// Paramètres figés d'une série Notes simples, choisis avant le lancement.
class SimpleNoteExerciseConfig extends Equatable {
  final int noteCount;
  final bool includeBlackKeys;

  const SimpleNoteExerciseConfig({
    required this.noteCount,
    required this.includeBlackKeys,
  });

  @override
  List<Object?> get props => [noteCount, includeBlackKeys];
}
