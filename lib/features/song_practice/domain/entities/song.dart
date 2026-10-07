import 'package:equatable/equatable.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_event.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_measure.dart';

/// Un morceau à travailler : ses mesures et la suite de ses événements, dans
/// l'ordre du temps. Les durées sont comptées en divisions de noire
/// ([divisionsPerQuarter] par noire) ; le chiffrage est [beatsPerMeasure]
/// temps de [beatUnit] (4 = noire, 8 = croche).
class Song extends Equatable {
  final String title;
  final List<SongMeasure> measures;
  final List<SongEvent> events;
  final int divisionsPerQuarter;
  final int beatsPerMeasure;
  final int beatUnit;

  const Song({
    required this.title,
    required this.measures,
    required this.events,
    this.divisionsPerQuarter = 1,
    this.beatsPerMeasure = 4,
    this.beatUnit = 4,
  });

  int get measureCount => measures.length;

  @override
  List<Object?> get props => [
    title,
    measures,
    events,
    divisionsPerQuarter,
    beatsPerMeasure,
    beatUnit,
  ];
}
