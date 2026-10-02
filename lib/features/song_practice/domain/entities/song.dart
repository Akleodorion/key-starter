import 'package:equatable/equatable.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_event.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_measure.dart';

/// Un morceau à travailler : ses mesures et la suite de ses événements, dans
/// l'ordre du temps.
class Song extends Equatable {
  final String title;
  final List<SongMeasure> measures;
  final List<SongEvent> events;

  const Song({
    required this.title,
    required this.measures,
    required this.events,
  });

  int get measureCount => measures.length;

  @override
  List<Object?> get props => [title, measures, events];
}
