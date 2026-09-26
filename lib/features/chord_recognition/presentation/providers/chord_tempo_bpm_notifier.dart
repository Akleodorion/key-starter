import 'package:flutter_riverpod/flutter_riverpod.dart';

final chordTempoBpmProvider = NotifierProvider<ChordTempoBpmNotifier, int>(
  ChordTempoBpmNotifier.new,
);

/// Tempo de l'exercice Tempo Accords, en battements par minute, gardé en mémoire
/// le temps de la session.
class ChordTempoBpmNotifier extends Notifier<int> {
  static const int _minBpm = 40;
  static const int _maxBpm = 120;
  static const int _bpmStep = 5;

  @override
  int build() => 60;

  void increment() {
    if (state < _maxBpm) state = state + _bpmStep;
  }

  void decrement() {
    if (state > _minBpm) state = state - _bpmStep;
  }
}
