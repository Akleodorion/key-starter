import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/features/song_practice/domain/entities/note_value.dart';
import 'package:key_starter/features/song_practice/domain/entities/staff_notation.dart';
import 'package:key_starter/features/song_practice/presentation/layout/beam_groups.dart';

StaffNotation sixteenth(List<BeamMark> beams) =>
    StaffNotation(value: const NoteValue(NoteType.sixteenth), beams: beams);

const quarter = StaffNotation(value: NoteValue(NoteType.quarter));

void main() {
  group('beamGroupsOf', () {
    test('ne groupe pas les notes sans barre de ligature', () {
      //arrange
      //act
      final sut = beamGroupsOf([quarter, quarter, null]);

      //assert
      expect(sut, isEmpty);
    });

    test('groupe les notes de begin à end, une barre par niveau', () {
      //arrange
      final notations = [
        quarter,
        sixteenth([BeamMark.begin, BeamMark.begin]),
        sixteenth([BeamMark.continued, BeamMark.end]),
        sixteenth([BeamMark.continued, BeamMark.begin]),
        sixteenth([BeamMark.end, BeamMark.end]),
      ];

      //act
      final sut = beamGroupsOf(notations);

      //assert
      expect(sut, const [
        BeamGroup(
          memberIndices: [1, 2, 3, 4],
          segments: [
            BeamSegment(level: 1, fromMember: 0, toMember: 3),
            BeamSegment(level: 2, fromMember: 0, toMember: 1),
            BeamSegment(level: 2, fromMember: 2, toMember: 3),
          ],
          hooks: [],
        ),
      ]);
    });

    test('garde les demi-barres vers la note suivante ou précédente', () {
      //arrange
      final notations = [
        sixteenth([BeamMark.begin, BeamMark.forwardHook]),
        sixteenth([BeamMark.end, BeamMark.backwardHook]),
      ];

      //act
      final sut = beamGroupsOf(notations);

      //assert
      expect(sut.single.hooks, const [
        BeamHook(level: 2, member: 0, pointsForward: true),
        BeamHook(level: 2, member: 1, pointsForward: false),
      ]);
    });

    test('ferme un groupe coupé par la fin de la ligne', () {
      //arrange
      final notations = [
        sixteenth([BeamMark.continued]),
        sixteenth([BeamMark.end]),
        sixteenth([BeamMark.begin]),
        sixteenth([BeamMark.continued]),
      ];

      //act
      final sut = beamGroupsOf(notations);

      //assert
      expect(sut.map((group) => group.memberIndices), [
        [0, 1],
        [2, 3],
      ]);
    });
  });
}
