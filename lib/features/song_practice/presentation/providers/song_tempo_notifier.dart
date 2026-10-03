import 'package:flutter_riverpod/flutter_riverpod.dart';

final songTempoProvider = NotifierProvider<SongTempoNotifier, int?>(
  SongTempoNotifier.new,
);

/// Tempo choisi pour jouer un morceau, en noires par minute, gardé le temps
/// de la session pour tous les morceaux ; null = Libre (sans tempo).
class SongTempoNotifier extends Notifier<int?> {
  static const int _minBpm = 40;
  static const int _maxBpm = 120;
  static const int _bpmStep = 5;

  @override
  int? build() => 60;

  void increment() {
    final bpm = state;
    if (bpm == null) {
      state = _minBpm;
    } else if (bpm < _maxBpm) {
      state = bpm + _bpmStep;
    }
  }

  void decrement() {
    final bpm = state;
    if (bpm == null) return;
    state = bpm > _minBpm ? bpm - _bpmStep : null;
  }
}
