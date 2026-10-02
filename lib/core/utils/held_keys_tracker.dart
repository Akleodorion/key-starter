import 'package:equatable/equatable.dart';

/// Où en est une tentative jugée par touches tenues.
sealed class HeldKeysOutcome extends Equatable {
  const HeldKeysOutcome();
}

/// Moins de touches que prévu sont tenues : on attend.
class HeldKeysPending extends HeldKeysOutcome {
  const HeldKeysPending();

  @override
  List<Object?> get props => [];
}

/// Le nombre prévu de touches est tenu ensemble : la tentative est à juger.
class HeldKeysComplete extends HeldKeysOutcome {
  final Set<int> heldMidiNumbers;

  const HeldKeysComplete(this.heldMidiNumbers);

  @override
  List<Object?> get props => [heldMidiNumbers];
}

/// Une touche a été relâchée avant que le nombre prévu soit tenu : la
/// tentative est jugée sur toutes les touches jouées jusque-là.
class HeldKeysAbandoned extends HeldKeysOutcome {
  final Set<int> playedMidiNumbers;

  const HeldKeysAbandoned(this.playedMidiNumbers);

  @override
  List<Object?> get props => [playedMidiNumbers];
}

/// Décide quand juger un groupe de notes sans tempo : dès que le nombre de
/// touches attendu est tenu en même temps, quel que soit l'ordre d'attaque.
class HeldKeysTracker {
  final int expectedKeyCount;
  final Set<int> _heldMidiNumbers = {};
  final Set<int> _playedMidiNumbers = {};

  HeldKeysTracker({required this.expectedKeyCount});

  HeldKeysOutcome press(int midiNumber) {
    _heldMidiNumbers.add(midiNumber);
    _playedMidiNumbers.add(midiNumber);
    if (_heldMidiNumbers.length < expectedKeyCount) {
      return const HeldKeysPending();
    }
    return HeldKeysComplete(Set.of(_heldMidiNumbers));
  }

  HeldKeysOutcome release(int midiNumber) {
    if (!_heldMidiNumbers.remove(midiNumber)) return const HeldKeysPending();
    return HeldKeysAbandoned(Set.of(_playedMidiNumbers));
  }
}
