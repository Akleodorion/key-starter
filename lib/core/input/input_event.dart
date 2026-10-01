import 'package:equatable/equatable.dart';

/// Ce que la Source d'entrée active a reçu de l'élève (voir CONTEXT.md).
sealed class InputEvent extends Equatable {
  final int midiNumber;

  const InputEvent(this.midiNumber);
}

/// Une note jouée : Note On en MIDI. [attackTime] est l'instant où le son a
/// commencé, à utiliser pour mesurer un temps de réponse.
class NotePlayed extends InputEvent {
  final DateTime attackTime;

  const NotePlayed(super.midiNumber, {required this.attackTime});

  @override
  List<Object?> get props => [midiNumber, attackTime];
}

/// Une note relâchée : Note Off en MIDI.
class NoteReleased extends InputEvent {
  const NoteReleased(super.midiNumber);

  @override
  List<Object?> get props => [midiNumber];
}
