import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_section.dart';

/// Chronologie d'une section jouée au tempo : un décompte d'une mesure
/// (selon le chiffrage), puis la barre qui avance de [bpm] noires par minute
/// du début de la première mesure de [section] à la fin de la dernière.
///
/// Chaque événement jugé (repéré par sa position dans [judgedEventIndices])
/// se joue dans une fenêtre de ±¼ de temps autour de son instant, chaque côté
/// réduit à la moitié de l'écart avec l'événement jugé voisin pour que deux
/// fenêtres ne se chevauchent jamais.
///
/// Tous les instants sont mesurés depuis le début du décompte.
class SongTempoTimeline extends Equatable {
  static const double windowBeats = 0.25;

  final Song song;
  final SongSection section;
  final List<int> judgedEventIndices;
  final int bpm;

  const SongTempoTimeline({
    required this.song,
    required this.section,
    required this.judgedEventIndices,
    required this.bpm,
  });

  double get _quarterMs => 60000 / bpm;

  double get _divisionMs => _quarterMs / song.divisionsPerQuarter;

  double get _beatMs => _quarterMs * 4 / song.beatUnit;

  double get _countInMs => song.beatsPerMeasure * _beatMs;

  int get _sectionStartDivisions =>
      song.measures[section.firstMeasureNumber - 1].startDivisions;

  int get _sectionEndDivisions {
    final lastMeasure = song.measures[section.lastMeasureNumber - 1];
    return lastMeasure.startDivisions + lastMeasure.durationDivisions;
  }

  int get eventCount => judgedEventIndices.length;

  Duration get countInDuration => _durationFromMs(_countInMs);

  /// Fin de la section : la barre arrive au bout de sa dernière mesure.
  Duration get endTime =>
      _durationFromMs(_msAtDivisions(_sectionEndDivisions.toDouble()));

  /// Indice dans le morceau de l'événement jugé à [position].
  int eventIndexAt(int position) => judgedEventIndices[position];

  Duration eventTime(int position) => _durationFromMs(_eventMs(position));

  Duration windowOpen(int position) {
    var halfWidthMs = windowBeats * _beatMs;
    if (position > 0) {
      halfWidthMs = min(
        halfWidthMs,
        (_eventMs(position) - _eventMs(position - 1)) / 2,
      );
    }
    return _durationFromMs(_eventMs(position) - halfWidthMs);
  }

  Duration windowClose(int position) {
    var halfWidthMs = windowBeats * _beatMs;
    if (position < eventCount - 1) {
      halfWidthMs = min(
        halfWidthMs,
        (_eventMs(position + 1) - _eventMs(position)) / 2,
      );
    }
    return _durationFromMs(_eventMs(position) + halfWidthMs);
  }

  /// Position de l'événement jugé dont la fenêtre contient [elapsed], ou null.
  int? windowPositionAt(Duration elapsed) {
    for (var position = 0; position < eventCount; position++) {
      if (elapsed < windowOpen(position)) return null;
      if (elapsed <= windowClose(position)) return position;
    }
    return null;
  }

  bool isCountIn(Duration elapsed) => _ms(elapsed) < _countInMs;

  /// Temps restants du décompte (4, 3, 2, 1 en 4/4), ou null une fois la
  /// barre partie.
  int? countInBeatAt(Duration elapsed) {
    if (!isCountIn(elapsed)) return null;
    return song.beatsPerMeasure - (_ms(elapsed) / _beatMs).floor();
  }

  /// Temps du morceau, en divisions, sous la barre : le début de la section
  /// pendant le décompte, sa fin une fois arrivée au bout.
  double barDivisionsAt(Duration elapsed) =>
      (_sectionStartDivisions + (_ms(elapsed) - _countInMs) / _divisionMs)
          .clamp(
            _sectionStartDivisions.toDouble(),
            _sectionEndDivisions.toDouble(),
          )
          .toDouble();

  double _eventMs(int position) => _msAtDivisions(
    song.events[judgedEventIndices[position]].onsetDivisions.toDouble(),
  );

  double _msAtDivisions(double divisions) =>
      _countInMs + (divisions - _sectionStartDivisions) * _divisionMs;

  static double _ms(Duration duration) => duration.inMicroseconds / 1000;

  static Duration _durationFromMs(double milliseconds) =>
      Duration(microseconds: (milliseconds * 1000).round());

  @override
  List<Object?> get props => [song, section, judgedEventIndices, bpm];
}
