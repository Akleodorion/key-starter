import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/core/utils/note_utils.dart';

/// Verdict d'une portée : les touches qui lui sont attribuées et leur
/// correspondance exacte avec les notes attendues.
class StaffPartVerdict extends Equatable {
  final bool isCorrect;
  final Set<int> playedMidiNumbers;

  const StaffPartVerdict({
    required this.isCorrect,
    required this.playedMidiNumbers,
  });

  @override
  List<Object?> get props => [isCorrect, playedMidiNumbers];
}

/// Verdict d'un [TwoStaffEvent] : juste seulement si les deux portées le sont.
class TwoStaffVerdict extends Equatable {
  final StaffPartVerdict treble;
  final StaffPartVerdict bass;

  const TwoStaffVerdict({required this.treble, required this.bass});

  bool get isCorrect => treble.isCorrect && bass.isCorrect;

  @override
  List<Object?> get props => [treble, bass];
}

/// Attribue chaque touche jouée à une portée puis juge chaque portée en
/// correspondance exacte. Une touche attendue va à sa portée ; une autre
/// touche va à la clé de sol si elle est au-dessus du point de partage (le
/// milieu entre la note de fa la plus haute et la note de sol la plus basse),
/// à la clé de fa sinon.
TwoStaffVerdict judgeTwoStaffEvent(
  TwoStaffEvent event,
  Set<int> playedMidiNumbers,
) {
  final trebleTargets = event.trebleSteps.map(midiFromDiatonicStep).toSet();
  final bassTargets = event.bassSteps.map(midiFromDiatonicStep).toSet();
  final splitPoint = _splitPoint(trebleTargets, bassTargets);

  bool belongsToTreble(int midiNumber) {
    if (trebleTargets.contains(midiNumber)) return true;
    if (bassTargets.contains(midiNumber)) return false;
    return midiNumber > splitPoint;
  }

  final treblePlayed = playedMidiNumbers.where(belongsToTreble).toSet();
  final bassPlayed = playedMidiNumbers.difference(treblePlayed);
  return TwoStaffVerdict(
    treble: StaffPartVerdict(
      isCorrect: setEquals(treblePlayed, trebleTargets),
      playedMidiNumbers: treblePlayed,
    ),
    bass: StaffPartVerdict(
      isCorrect: setEquals(bassPlayed, bassTargets),
      playedMidiNumbers: bassPlayed,
    ),
  );
}

double _splitPoint(Set<int> trebleTargets, Set<int> bassTargets) {
  if (bassTargets.isEmpty) return double.negativeInfinity;
  if (trebleTargets.isEmpty) return double.infinity;
  return (bassTargets.reduce(max) + trebleTargets.reduce(min)) / 2;
}
