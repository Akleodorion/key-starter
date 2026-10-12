import 'package:equatable/equatable.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_symbol.dart';

/// Ce que donne une tentative d'accord après une touche enfoncée ou relâchée.
sealed class ChordAttemptOutcome extends Equatable {
  const ChordAttemptOutcome();

  @override
  List<Object?> get props => [];
}

/// L'accord n'est pas encore complet : on attend d'autres touches.
class ChordAttemptPending extends ChordAttemptOutcome {
  const ChordAttemptPending();
}

/// Les touches tenues contiennent l'accord, fondamentale en bas.
class ChordAttemptCorrect extends ChordAttemptOutcome {
  const ChordAttemptCorrect();
}

/// Une note étrangère a été jouée, ou tout a été relâché avant que l'accord
/// soit juste.
class ChordAttemptWrong extends ChordAttemptOutcome {
  const ChordAttemptWrong();
}

/// Suit les touches d'une case jouée sans tempo et dit quand l'accord
/// [expected] est juste ou faux.
///
/// Les touches de [alreadyHeld] (tenues depuis la case précédente) sont
/// ignorées jusqu'à leur relâchement : pour jouer la case, on rejoue
/// l'accord.
class ChordAttemptTracker {
  final ChordSymbol expected;
  final Set<int> _ignoredKeys;
  final Set<int> _heldKeys = {};

  ChordAttemptTracker({required this.expected, Set<int> alreadyHeld = const {}})
    : _ignoredKeys = {...alreadyHeld};

  ChordAttemptOutcome press(int midiNumber) {
    _ignoredKeys.remove(midiNumber);
    _heldKeys.add(midiNumber);
    if (!expected.pitchClasses.contains(midiNumber % 12)) {
      return const ChordAttemptWrong();
    }
    return _isComplete
        ? const ChordAttemptCorrect()
        : const ChordAttemptPending();
  }

  ChordAttemptOutcome release(int midiNumber) {
    if (_ignoredKeys.remove(midiNumber) || !_heldKeys.remove(midiNumber)) {
      return const ChordAttemptPending();
    }
    return _heldKeys.isEmpty
        ? const ChordAttemptWrong()
        : const ChordAttemptPending();
  }

  bool get _isComplete {
    final heldPitchClasses = {for (final key in _heldKeys) key % 12};
    final lowestKey = _heldKeys.reduce(
      (lowest, key) => key < lowest ? key : lowest,
    );
    return heldPitchClasses.containsAll(expected.pitchClasses) &&
        lowestKey % 12 == expected.bassPitchClass;
  }
}
