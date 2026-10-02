import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_event.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_section.dart';
import 'package:key_starter/features/song_practice/presentation/providers/hand_selection.dart';

/// Notes jugées pour [event] : celles des mains travaillées seulement.
TwoStaffEvent expectedNotes(SongEvent event, HandSelection hands) =>
    switch (hands) {
      HandSelection.both => event.notes,
      HandSelection.rightOnly => TwoStaffEvent(
        trebleSteps: event.notes.trebleSteps,
        bassSteps: const [],
      ),
      HandSelection.leftOnly => TwoStaffEvent(
        trebleSteps: const [],
        bassSteps: event.notes.bassSteps,
      ),
    };

/// Indices, dans [song], des événements de [section] où [hands] ont au
/// moins une note à jouer.
List<int> playableEventIndices(
  Song song,
  HandSelection hands,
  SongSection section,
) => [
  for (var index = 0; index < song.events.length; index++)
    if (section.contains(song.events[index].measureNumber) &&
        _hasNotes(expectedNotes(song.events[index], hands)))
      index,
];

bool _hasNotes(TwoStaffEvent notes) =>
    notes.trebleSteps.isNotEmpty || notes.bassSteps.isNotEmpty;
