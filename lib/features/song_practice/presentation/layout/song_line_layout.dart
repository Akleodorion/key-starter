import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_measure.dart';

/// Écart minimal entre deux éléments d'une mesure, en fraction de mesure :
/// de quoi poser une tête de note sans chevaucher la suivante.
const minimumElementGap = 1 / 12;

/// Un événement placé dans sa ligne : son indice dans [Song.events] et sa
/// position horizontale, de 0 (début de la ligne) à 1 (fin).
class PlacedSongEvent extends Equatable {
  final int eventIndex;
  final double position;

  const PlacedSongEvent({required this.eventIndex, required this.position});

  @override
  List<Object?> get props => [eventIndex, position];
}

/// Un silence placé dans sa ligne : son indice dans [Song.rests] et sa
/// position horizontale, de 0 à 1 (le milieu de la mesure pour un silence
/// de mesure entière).
class PlacedSongRest extends Equatable {
  final int restIndex;
  final double position;

  const PlacedSongRest({required this.restIndex, required this.position});

  @override
  List<Object?> get props => [restIndex, position];
}

/// Point de passage du placement dans une mesure : un temps du morceau (en
/// divisions) et sa position dans la mesure, de 0 à 1.
typedef MeasureAnchor = ({double divisions, double fraction});

/// Une ligne de partition : quelques mesures consécutives, de largeur égale,
/// les événements et les silences qui y tombent, et pour chaque mesure ses
/// points de passage, entre lesquels le temps avance de façon régulière.
class SongLine extends Equatable {
  final List<SongMeasure> measures;
  final int measuresPerLine;
  final List<List<MeasureAnchor>> measureAnchors;
  final List<PlacedSongEvent> events;
  final List<PlacedSongRest> rests;

  const SongLine({
    required this.measures,
    required this.measuresPerLine,
    required this.measureAnchors,
    required this.events,
    this.rests = const [],
  });

  int get firstMeasureNumber => measures.first.number;
  int get measureCount => measures.length;

  /// Position dans la ligne, de 0 à 1, du temps [divisions] (compté depuis
  /// le début du morceau), qui doit tomber dans une mesure de la ligne.
  double positionAt(double divisions) {
    var slot = measures.lastIndexWhere(
      (measure) => measure.startDivisions <= divisions,
    );
    if (slot < 0) slot = 0;
    final anchors = measureAnchors[slot];
    var fractionInMeasure = 1.0;
    for (var index = 0; index < anchors.length - 1; index++) {
      final from = anchors[index];
      final to = anchors[index + 1];
      if (divisions <= to.divisions) {
        final progress = to.divisions == from.divisions
            ? 0.0
            : ((divisions - from.divisions) / (to.divisions - from.divisions))
                  .clamp(0.0, 1.0);
        fractionInMeasure =
            from.fraction + progress * (to.fraction - from.fraction);
        break;
      }
    }
    return (slot + fractionInMeasure) / measuresPerLine;
  }

  @override
  List<Object?> get props => [
    measures,
    measuresPerLine,
    measureAnchors,
    events,
    rests,
  ];
}

/// Découpe [song] en lignes de [measuresPerLine] mesures. Chaque mesure
/// occupe 1 / [measuresPerLine] de la ligne, même sur une dernière ligne
/// incomplète. Dans une mesure, chaque élément (note ou silence) est placé
/// selon son temps, mais jamais à moins de [minimumElementGap] du suivant :
/// les écarts plus larges cèdent la place nécessaire.
List<SongLine> layoutSongLines(Song song, {required int measuresPerLine}) => [
  for (
    var firstIndex = 0;
    firstIndex < song.measures.length;
    firstIndex += measuresPerLine
  )
    _layoutLine(
      song,
      song.measures.sublist(
        firstIndex,
        min(firstIndex + measuresPerLine, song.measures.length),
      ),
      measuresPerLine,
    ),
];

SongLine _layoutLine(
  Song song,
  List<SongMeasure> measures,
  int measuresPerLine,
) {
  final measureNumbers = {for (final measure in measures) measure.number};
  final skeleton = _lineSkeleton(song, measures, measuresPerLine);
  double wholeMeasureCenter(int measureNumber) =>
      (measures.indexWhere((measure) => measure.number == measureNumber) +
          0.5) /
      measuresPerLine;
  return SongLine(
    measures: measures,
    measuresPerLine: measuresPerLine,
    measureAnchors: skeleton.measureAnchors,
    events: [
      for (final (eventIndex, event) in song.events.indexed)
        if (measureNumbers.contains(event.measureNumber))
          PlacedSongEvent(
            eventIndex: eventIndex,
            position: skeleton.positionAt(event.onsetDivisions.toDouble()),
          ),
    ],
    rests: [
      for (final (restIndex, rest) in song.rests.indexed)
        if (measureNumbers.contains(rest.measureNumber))
          PlacedSongRest(
            restIndex: restIndex,
            position: rest.isWholeMeasure
                ? wholeMeasureCenter(rest.measureNumber)
                : skeleton.positionAt(rest.onsetDivisions.toDouble()),
          ),
    ],
  );
}

/// Ligne réduite à ses mesures et à leurs points de passage, sans éléments
/// placés : de quoi convertir un temps en position.
SongLine _lineSkeleton(
  Song song,
  List<SongMeasure> measures,
  int measuresPerLine,
) => SongLine(
  measures: measures,
  measuresPerLine: measuresPerLine,
  measureAnchors: [
    for (final measure in measures) _measureAnchors(song, measure),
  ],
  events: const [],
);

/// Points de passage d'une mesure : son début, le temps de chacun de ses
/// éléments et sa fin. Chaque écart part de sa durée réelle, est porté au
/// minimum s'il est trop court, puis les écarts qui ont de la marge sont
/// réduits d'autant ; si aucun n'en a assez, les éléments sont répartis
/// également.
List<MeasureAnchor> _measureAnchors(Song song, SongMeasure measure) {
  final start = measure.startDivisions;
  final end = start + measure.durationDivisions;
  final onsets = {
    start,
    for (final event in song.events)
      if (event.measureNumber == measure.number) event.onsetDivisions,
    for (final rest in song.rests)
      if (rest.measureNumber == measure.number && !rest.isWholeMeasure)
        rest.onsetDivisions,
  }.where((onset) => onset >= start && onset < end).toList()..sort();
  final divisions = [...onsets, end];
  final gaps = [
    for (var index = 0; index < divisions.length - 1; index++)
      max(
        (divisions[index + 1] - divisions[index]) / measure.durationDivisions,
        minimumElementGap,
      ),
  ];
  final excess = gaps.fold(0.0, (sum, gap) => sum + gap) - 1;
  if (excess > 1e-12) {
    final slacks = [for (final gap in gaps) max(0.0, gap - minimumElementGap)];
    final totalSlack = slacks.fold(0.0, (sum, slack) => sum + slack);
    for (var index = 0; index < gaps.length; index++) {
      gaps[index] = totalSlack >= excess
          ? gaps[index] - excess * slacks[index] / totalSlack
          : 1 / gaps.length;
    }
  }
  var fraction = 0.0;
  return [
    for (var index = 0; index < divisions.length; index++)
      (
        divisions: divisions[index].toDouble(),
        fraction: index == 0
            ? 0.0
            : index == divisions.length - 1
            ? 1.0
            : (fraction += gaps[index - 1]),
      ),
  ];
}

/// Ligne de la partition qui contient le temps [divisions] (compté depuis le
/// début du morceau) et sa position dans la ligne, de 0 (début) à 1 (fin),
/// pour des lignes de [measuresPerLine] mesures, selon le même placement que
/// les éléments. La fin de la dernière mesure reste au bout de sa ligne.
({int lineIndex, double fraction}) songLinePositionAt(
  Song song,
  double divisions, {
  required int measuresPerLine,
}) {
  var measureIndex = song.measures.lastIndexWhere(
    (measure) => measure.startDivisions <= divisions,
  );
  if (measureIndex < 0) measureIndex = 0;
  final lineIndex = measureIndex ~/ measuresPerLine;
  final firstIndex = lineIndex * measuresPerLine;
  final measures = song.measures.sublist(
    firstIndex,
    min(firstIndex + measuresPerLine, song.measures.length),
  );
  final line = _lineSkeleton(song, measures, measuresPerLine);
  return (lineIndex: lineIndex, fraction: line.positionAt(divisions));
}
