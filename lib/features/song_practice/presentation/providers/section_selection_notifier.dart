import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/song_practice/domain/entities/bundled_song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_section.dart';

/// Plage de mesures choisie pour chaque morceau, gardée le temps de la
/// session ; null = le morceau entier.
final sectionSelectionProvider =
    NotifierProvider.family<
      SectionSelectionNotifier,
      SongSection?,
      BundledSong
    >((bundledSong) => SectionSelectionNotifier());

class SectionSelectionNotifier extends Notifier<SongSection?> {
  @override
  SongSection? build() => null;

  void select(SongSection section) => state = section;
}
