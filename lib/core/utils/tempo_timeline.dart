import 'dart:math';

import 'package:equatable/equatable.dart';

/// Chronologie de l'exercice Tempo : un décompte de [countInBeats] temps,
/// puis une note par temps, placée au milieu de son temps, rangées par lignes
/// de [notesPerLine]. Chaque note se joue dans une fenêtre de ±[windowBeats]
/// temps autour de son instant.
///
/// Tous les instants sont mesurés depuis le début du décompte.
class TempoTimeline extends Equatable {
  static const int countInBeats = 4;
  static const int notesPerLine = 4;
  static const double windowBeats = 0.25;

  final int bpm;
  final int noteCount;

  const TempoTimeline({required this.bpm, required this.noteCount});

  double get _beatMs => 60000 / bpm;

  Duration get beatDuration => _durationFromMs(_beatMs);

  int get lineCount => (noteCount / notesPerLine).ceil();

  Duration noteTime(int index) => _durationFromMs(_noteMs(index));

  Duration windowClose(int index) =>
      _durationFromMs(_noteMs(index) + windowBeats * _beatMs);

  /// Index de la note dont la fenêtre contient [elapsed], ou null.
  int? windowIndexAt(Duration elapsed) {
    final nearestIndex = (_beatsSincePlayStart(elapsed) - 0.5).round();
    if (nearestIndex < 0 || nearestIndex >= noteCount) return null;
    final distanceMs = (_ms(elapsed) - _noteMs(nearestIndex)).abs();
    return distanceMs <= windowBeats * _beatMs ? nearestIndex : null;
  }

  bool isCountIn(Duration elapsed) => _beatsSincePlayStart(elapsed) < 0;

  /// Temps restants du décompte (4, 3, 2, 1), ou null une fois la barre partie.
  int? countInBeatAt(Duration elapsed) {
    if (!isCountIn(elapsed)) return null;
    return countInBeats - (_ms(elapsed) / _beatMs).floor();
  }

  /// Index de la note dont la barre traverse le temps.
  int barNoteIndexAt(Duration elapsed) =>
      min(_barBeats(elapsed).floor(), noteCount - 1);

  /// Ligne sur laquelle se trouve la barre.
  int barLineAt(Duration elapsed) => (_barBeats(elapsed) / notesPerLine)
      .floor()
      .clamp(0, lineCount - 1)
      .toInt();

  /// Position de la barre dans sa ligne, de 0 (début) à 1 (fin).
  double barFractionAt(Duration elapsed) {
    final beatsInLine = _barBeats(elapsed) - barLineAt(elapsed) * notesPerLine;
    return (beatsInLine / notesPerLine).clamp(0, 1);
  }

  /// Ligne affichée en haut de l'écran. Entre deux lignes, la valeur passe
  /// continûment de k à k + 1 pendant le demi-temps sans fenêtre, ce qui
  /// anime la remontée des lignes.
  double topLineAt(Duration elapsed) {
    final beats = _barBeats(elapsed);
    const halfGap = windowBeats;
    final nextBoundary = ((beats + halfGap) / notesPerLine).floor();
    final boundaryBeats = nextBoundary * notesPerLine;
    final double topLine;
    if (nextBoundary > 0 && (beats - boundaryBeats).abs() <= halfGap) {
      final progress = (beats - boundaryBeats + halfGap) / (2 * halfGap);
      topLine = nextBoundary - 1 + progress;
    } else {
      topLine = (beats / notesPerLine).floorToDouble();
    }
    return topLine.clamp(0, lineCount - 1).toDouble();
  }

  double _noteMs(int index) => (countInBeats + index + 0.5) * _beatMs;

  double _beatsSincePlayStart(Duration elapsed) =>
      _ms(elapsed) / _beatMs - countInBeats;

  double _barBeats(Duration elapsed) =>
      _beatsSincePlayStart(elapsed).clamp(0, noteCount.toDouble());

  static double _ms(Duration duration) => duration.inMicroseconds / 1000;

  static Duration _durationFromMs(double milliseconds) =>
      Duration(microseconds: (milliseconds * 1000).round());

  @override
  List<Object?> get props => [bpm, noteCount];
}
