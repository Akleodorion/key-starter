import 'package:equatable/equatable.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_section.dart';
import 'package:key_starter/features/song_practice/presentation/providers/hand_selection.dart';

class SongPlayConfig extends Equatable {
  final Song song;
  final HandSelection hands;
  final SongSection section;

  const SongPlayConfig({
    required this.song,
    required this.hands,
    required this.section,
  });

  @override
  List<Object?> get props => [song, hands, section];
}
