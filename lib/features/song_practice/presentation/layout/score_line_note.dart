import 'package:equatable/equatable.dart';
import 'package:key_starter/core/enums/note_state.dart';

/// Un événement tel qu'il est dessiné sur une ligne de partition : sa
/// position (0 à 1), ses notes et l'état affiché de chaque portée.
class ScoreLineNote extends Equatable {
  final double position;
  final List<int> trebleSteps;
  final List<int> bassSteps;
  final NoteState trebleState;
  final NoteState bassState;

  const ScoreLineNote({
    required this.position,
    required this.trebleSteps,
    required this.bassSteps,
    required this.trebleState,
    required this.bassState,
  });

  @override
  List<Object?> get props => [
    position,
    trebleSteps,
    bassSteps,
    trebleState,
    bassState,
  ];
}
