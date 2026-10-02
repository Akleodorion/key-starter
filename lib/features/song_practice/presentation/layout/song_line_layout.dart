import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_measure.dart';

/// Un événement placé dans sa ligne : son indice dans [Song.events] et sa
/// position horizontale, de 0 (début de la ligne) à 1 (fin).
class PlacedSongEvent extends Equatable {
  final int eventIndex;
  final double position;

  const PlacedSongEvent({required this.eventIndex, required this.position});

  @override
  List<Object?> get props => [eventIndex, position];
}

/// Une ligne de partition : quelques mesures consécutives, de largeur égale,
/// et les événements qui y tombent.
class SongLine extends Equatable {
  final List<SongMeasure> measures;
  final List<PlacedSongEvent> events;

  const SongLine({required this.measures, required this.events});

  int get firstMeasureNumber => measures.first.number;
  int get measureCount => measures.length;

  @override
  List<Object?> get props => [measures, events];
}

/// Découpe [song] en lignes de [measuresPerLine] mesures. Chaque mesure
/// occupe 1 / [measuresPerLine] de la ligne, même sur une dernière ligne
/// incomplète, et chaque événement y est placé selon son temps.
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
) => SongLine(
  measures: measures,
  events: [
    for (var slot = 0; slot < measures.length; slot++)
      for (var eventIndex = 0; eventIndex < song.events.length; eventIndex++)
        if (song.events[eventIndex].measureNumber == measures[slot].number)
          PlacedSongEvent(
            eventIndex: eventIndex,
            position:
                (slot +
                    (song.events[eventIndex].onsetDivisions -
                            measures[slot].startDivisions) /
                        measures[slot].durationDivisions) /
                measuresPerLine,
          ),
  ],
);
