import 'package:equatable/equatable.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_event.dart';

/// Un morceau à travailler : la suite de ses événements, dans l'ordre du temps.
class Song extends Equatable {
  final String title;
  final int measureCount;
  final List<SongEvent> events;

  const Song({
    required this.title,
    required this.measureCount,
    required this.events,
  });

  @override
  List<Object?> get props => [title, measureCount, events];
}
