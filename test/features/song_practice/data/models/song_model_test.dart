import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/features/song_practice/data/models/song_model.dart';
import 'package:key_starter/features/song_practice/domain/entities/note_value.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_measure.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_rest.dart';
import 'package:key_starter/features/song_practice/domain/entities/staff_notation.dart';

const commonTime = '<time><beats>4</beats><beat-type>4</beat-type></time>';

/// Partition MusicXML minimale d'une partie piano à deux portées, en Do
/// majeur et 4/4 (unité : la croche), dont les mesures sont [measures].
String scoreWith(
  List<String> measures, {
  String attributes = '',
  int divisions = 2,
  String time = commonTime,
}) {
  final measureElements = [
    for (var index = 0; index < measures.length; index++)
      '<measure number="${index + 1}">'
          '${index == 0 ? '<attributes><divisions>$divisions</divisions><key><fifths>0</fifths></key>'
                    '$time<staves>2</staves>$attributes</attributes>' : ''}'
          '${measures[index]}'
          '</measure>',
  ].join();
  return '<?xml version="1.0" encoding="UTF-8"?>'
      '<score-partwise version="4.0">'
      '<part-list><score-part id="P1"><part-name>Piano</part-name></score-part></part-list>'
      '<part id="P1">$measureElements</part>'
      '</score-partwise>';
}

String note(
  String step,
  int octave, {
  int duration = 2,
  int staff = 1,
  int voice = 1,
  bool chord = false,
  String extra = '',
}) =>
    '<note>${chord ? '<chord/>' : ''}'
    '<pitch><step>$step</step><octave>$octave</octave></pitch>'
    '<duration>$duration</duration><voice>$voice</voice><staff>$staff</staff>$extra'
    '</note>';

String rest({
  int duration = 2,
  int staff = 1,
  int voice = 1,
  String extra = '',
  bool wholeMeasure = false,
}) =>
    '<note><rest${wholeMeasure ? ' measure="yes"' : ''}/><duration>$duration</duration>'
    '<voice>$voice</voice>$extra<staff>$staff</staff></note>';

/// Partition dont le titre est donné par [titleElements] (`<work>`,
/// `<movement-title>`…), placés avant la liste des parties.
String scoreTitled(String titleElements) => scoreWith([
  note('C', 4, duration: 8),
]).replaceFirst('<part-list>', '$titleElements<part-list>');

String backup(int duration) =>
    '<backup><duration>$duration</duration></backup>';

Matcher throwsUnsupported(String reason) => throwsA(
  isA<UnsupportedSongException>().having(
    (exception) => exception.reason,
    'reason',
    reason,
  ),
);

void main() {
  group('SongModel', () {
    group('fromMusicXml', () {
      test(
        'lit une note de main droite comme un événement en mesure 1, au temps 0',
        () {
          //arrange
          final xml = scoreWith([note('E', 4, duration: 8)]);

          //act
          final sut = SongModel.fromMusicXml(xml, fallbackTitle: 'Essai');

          //assert
          expect(sut.title, 'Essai');
          expect(sut.measureCount, 1);
          expect(sut.events, hasLength(1));
          expect(sut.events.single.measureNumber, 1);
          expect(sut.events.single.onsetDivisions, 0);
          expect(
            sut.events.single.notes,
            const TwoStaffEvent(trebleSteps: [2], bassSteps: []),
          );
        },
      );

      test(
        'rattache la main gauche écrite après un retour arrière au premier temps de la mesure',
        () {
          //arrange
          final xml = scoreWith([
            note('E', 4) +
                note('F', 4, duration: 6) +
                backup(8) +
                note('C', 3, duration: 8, staff: 2, voice: 5),
          ]);

          //act
          final sut = SongModel.fromMusicXml(xml, fallbackTitle: 'Essai');

          //assert
          expect(sut.events, hasLength(2));
          expect(
            sut.events[0].notes,
            const TwoStaffEvent(trebleSteps: [2], bassSteps: [-7]),
          );
          expect(sut.events[0].trebleDurationDivisions, 2);
          expect(sut.events[0].bassDurationDivisions, 8);
          expect(sut.events[1].onsetDivisions, 2);
          expect(
            sut.events[1].notes,
            const TwoStaffEvent(trebleSteps: [3], bassSteps: []),
          );
          expect(sut.events[1].trebleDurationDivisions, 6);
          expect(sut.events[1].bassDurationDivisions, 0);
        },
      );

      test('regroupe une note marquée accord avec la note qui la précède', () {
        //arrange
        final xml = scoreWith([
          note('E', 4, duration: 8) +
              backup(8) +
              note('C', 3, duration: 8, staff: 2, voice: 5) +
              note('G', 3, duration: 8, staff: 2, voice: 5, chord: true),
        ]);

        //act
        final sut = SongModel.fromMusicXml(xml, fallbackTitle: 'Essai');

        //assert
        expect(sut.events, hasLength(1));
        expect(
          sut.events.single.notes,
          const TwoStaffEvent(trebleSteps: [2], bassSteps: [-7, -3]),
        );
      });

      test(
        'fait avancer le temps sur un silence et garde un événement où seule la main gauche joue',
        () {
          //arrange
          final xml = scoreWith([
            note('C', 4) +
                note('D', 4) +
                rest(duration: 4) +
                backup(8) +
                rest(duration: 4, staff: 2, voice: 5) +
                note('G', 3, duration: 4, staff: 2, voice: 5),
          ]);

          //act
          final sut = SongModel.fromMusicXml(xml, fallbackTitle: 'Essai');

          //assert
          expect(sut.events.map((event) => event.onsetDivisions), [0, 2, 4]);
          expect(
            sut.events.last.notes,
            const TwoStaffEvent(trebleSteps: [], bassSteps: [-3]),
          );
        },
      );

      test('enchaîne le temps et les numéros d\'une mesure à la suivante', () {
        //arrange
        final xml = scoreWith([
          note('C', 4, duration: 8),
          note('D', 4, duration: 4) + note('E', 4, duration: 4),
        ]);

        //act
        final sut = SongModel.fromMusicXml(xml, fallbackTitle: 'Essai');

        //assert
        expect(sut.measures, const [
          SongMeasure(number: 1, startDivisions: 0, durationDivisions: 8),
          SongMeasure(number: 2, startDivisions: 8, durationDivisions: 8),
        ]);
        expect(sut.events.map((event) => event.onsetDivisions), [0, 8, 12]);
        expect(sut.events.map((event) => event.measureNumber), [1, 2, 2]);
      });

      test('refuse une note altérée', () {
        //arrange
        final xml = scoreWith([
          '<note><pitch><step>F</step><alter>1</alter><octave>4</octave></pitch>'
              '<duration>8</duration><voice>1</voice><staff>1</staff></note>',
        ]);

        //act
        //assert
        expect(
          () => SongModel.fromMusicXml(xml, fallbackTitle: 'Essai'),
          throwsUnsupported(
            'Les altérations (♯, ♭) ne sont pas encore prises en charge.',
          ),
        );
      });

      test('refuse une armure autre que Do majeur', () {
        //arrange
        final xml = scoreWith([
          note('C', 4, duration: 8),
        ]).replaceFirst('<fifths>0</fifths>', '<fifths>1</fifths>');

        //act
        //assert
        expect(
          () => SongModel.fromMusicXml(xml, fallbackTitle: 'Essai'),
          throwsUnsupported(
            'Seule la tonalité de Do majeur est prise en charge pour l\'instant.',
          ),
        );
      });

      test('refuse une partition à plusieurs parties', () {
        //arrange
        final xml = scoreWith([note('C', 4, duration: 8)]).replaceFirst(
          '</score-partwise>',
          '<part id="P2"></part></score-partwise>',
        );

        //act
        //assert
        expect(
          () => SongModel.fromMusicXml(xml, fallbackTitle: 'Essai'),
          throwsUnsupported(
            'Le morceau doit contenir une seule partie de piano.',
          ),
        );
      });

      test('refuse plus de deux portées', () {
        //arrange
        final xml = scoreWith([
          note('C', 4, duration: 8),
        ]).replaceFirst('<staves>2</staves>', '<staves>3</staves>');

        //act
        //assert
        expect(
          () => SongModel.fromMusicXml(xml, fallbackTitle: 'Essai'),
          throwsUnsupported('Le morceau doit tenir sur deux portées au plus.'),
        );
      });

      test('refuse les notes liées', () {
        //arrange
        final xml = scoreWith([
          note('C', 4, duration: 8, extra: '<tie type="start"/>'),
        ]);

        //act
        //assert
        expect(
          () => SongModel.fromMusicXml(xml, fallbackTitle: 'Essai'),
          throwsUnsupported(
            'Les notes liées ne sont pas encore prises en charge.',
          ),
        );
      });

      test('refuse les triolets', () {
        //arrange
        final xml = scoreWith([
          note(
            'C',
            4,
            duration: 8,
            extra:
                '<time-modification><actual-notes>3</actual-notes>'
                '<normal-notes>2</normal-notes></time-modification>',
          ),
        ]);

        //act
        //assert
        expect(
          () => SongModel.fromMusicXml(xml, fallbackTitle: 'Essai'),
          throwsUnsupported('Les triolets ne sont pas encore pris en charge.'),
        );
      });

      test('refuse les notes d\'ornement', () {
        //arrange
        final xml = scoreWith([
          '<note><grace/><pitch><step>D</step><octave>4</octave></pitch>'
              '<voice>1</voice><staff>1</staff></note>'
              '${note('C', 4, duration: 8)}',
        ]);

        //act
        //assert
        expect(
          () => SongModel.fromMusicXml(xml, fallbackTitle: 'Essai'),
          throwsUnsupported(
            'Les notes d\'ornement ne sont pas encore prises en charge.',
          ),
        );
      });

      test('refuse deux voix sur une même portée', () {
        //arrange
        final xml = scoreWith([
          note('E', 4, duration: 8) +
              backup(8) +
              note('C', 4, duration: 8, voice: 2),
        ]);

        //act
        //assert
        expect(
          () => SongModel.fromMusicXml(xml, fallbackTitle: 'Essai'),
          throwsUnsupported(
            'Une seule voix par portée est prise en charge pour l\'instant.',
          ),
        );
      });

      test('lit les divisions de noire et le chiffrage', () {
        //arrange
        final xml = scoreWith(
          [note('C', 4, duration: 12)],
          divisions: 4,
          time: '<time><beats>3</beats><beat-type>4</beat-type></time>',
        );

        //act
        final sut = SongModel.fromMusicXml(xml, fallbackTitle: 'Essai');

        //assert
        expect(sut.divisionsPerQuarter, 4);
        expect(sut.beatsPerMeasure, 3);
        expect(sut.beatUnit, 4);
      });

      test('prend 4/4 quand la partition n\'a pas de chiffrage', () {
        //arrange
        final xml = scoreWith([note('C', 4, duration: 8)], time: '');

        //act
        final sut = SongModel.fromMusicXml(xml, fallbackTitle: 'Essai');

        //assert
        expect(sut.beatsPerMeasure, 4);
        expect(sut.beatUnit, 4);
      });

      test('refuse un changement de chiffrage en cours de morceau', () {
        //arrange
        final xml = scoreWith([
          note('C', 4, duration: 8),
          '<attributes><time><beats>3</beats><beat-type>4</beat-type></time></attributes>'
              '${note('D', 4, duration: 6)}',
        ]);

        //act
        //assert
        expect(
          () => SongModel.fromMusicXml(xml, fallbackTitle: 'Essai'),
          throwsUnsupported(
            'Les changements de chiffrage ne sont pas encore pris en charge.',
          ),
        );
      });

      test('refuse un changement de divisions en cours de morceau', () {
        //arrange
        final xml = scoreWith([
          note('C', 4, duration: 8),
          '<attributes><divisions>4</divisions></attributes>'
              '${note('D', 4, duration: 16)}',
        ]);

        //act
        //assert
        expect(
          () => SongModel.fromMusicXml(xml, fallbackTitle: 'Essai'),
          throwsUnsupported(
            'Les changements d\'unité de durée ne sont pas encore pris en charge.',
          ),
        );
      });

      group('figures', () {
        test('lit la figure et les points écrits dans la partition', () {
          //arrange
          final xml = scoreWith([
            note('C', 4, duration: 7, extra: '<type>half</type><dot/><dot/>') +
                note('D', 4, duration: 1, extra: '<type>eighth</type>'),
          ]);

          //act
          final sut = SongModel.fromMusicXml(xml, fallbackTitle: 'Essai');

          //assert
          expect(
            sut.events[0].trebleNotation!.value,
            const NoteValue(NoteType.half, dotCount: 2),
          );
          expect(
            sut.events[1].trebleNotation!.value,
            const NoteValue(NoteType.eighth),
          );
          expect(sut.events[0].bassNotation, isNull);
        });

        for (final (typeName, noteType) in [
          ('breve', NoteType.breve),
          ('whole', NoteType.whole),
          ('quarter', NoteType.quarter),
          ('16th', NoteType.sixteenth),
          ('32nd', NoteType.thirtySecond),
          ('64th', NoteType.sixtyFourth),
          ('128th', NoteType.oneHundredTwentyEighth),
          ('256th', NoteType.twoHundredFiftySixth),
          ('512th', NoteType.fiveHundredTwelfth),
          ('1024th', NoteType.oneThousandTwentyFourth),
        ]) {
          test('reconnaît la figure $typeName', () {
            //arrange
            final xml = scoreWith([
              note('C', 4, duration: 8, extra: '<type>$typeName</type>'),
            ]);

            //act
            final sut = SongModel.fromMusicXml(xml, fallbackTitle: 'Essai');

            //assert
            expect(sut.events.single.trebleNotation!.value.type, noteType);
          });
        }

        test('déduit la figure de la durée quand elle n\'est pas écrite', () {
          //arrange
          final xml = scoreWith([note('C', 4, duration: 6) + note('D', 4)]);

          //act
          final sut = SongModel.fromMusicXml(xml, fallbackTitle: 'Essai');

          //assert
          expect(
            sut.events[0].trebleNotation!.value,
            const NoteValue(NoteType.half, dotCount: 1),
          );
          expect(
            sut.events[1].trebleNotation!.value,
            const NoteValue(NoteType.quarter),
          );
        });

        for (final typeName in ['long', 'maxima']) {
          test('refuse la figure $typeName', () {
            //arrange
            final xml = scoreWith([
              note('C', 4, duration: 8, extra: '<type>$typeName</type>'),
            ]);

            //act
            //assert
            expect(
              () => SongModel.fromMusicXml(xml, fallbackTitle: 'Essai'),
              throwsUnsupported(
                'Les longues et les maximes ne sont pas prises en charge.',
              ),
            );
          });
        }

        test('lit le sens de la hampe de chaque portée', () {
          //arrange
          final xml = scoreWith([
            note('E', 4, duration: 8, extra: '<stem>down</stem>') +
                backup(8) +
                note(
                  'C',
                  3,
                  duration: 8,
                  staff: 2,
                  voice: 5,
                  extra: '<stem>up</stem>',
                ),
          ]);

          //act
          final sut = SongModel.fromMusicXml(xml, fallbackTitle: 'Essai');

          //assert
          expect(
            sut.events.single.trebleNotation!.stemDirection,
            StemDirection.down,
          );
          expect(
            sut.events.single.bassNotation!.stemDirection,
            StemDirection.up,
          );
        });

        test('lit la place de chaque note dans les barres de ligature', () {
          //arrange
          final xml = scoreWith([
            note(
                  'C',
                  4,
                  duration: 1,
                  extra:
                      '<beam number="1">begin</beam><beam number="2">forward hook</beam>',
                ) +
                note(
                  'D',
                  4,
                  duration: 1,
                  extra: '<beam number="1">end</beam>',
                ) +
                note('E', 4, duration: 6),
          ]);

          //act
          final sut = SongModel.fromMusicXml(xml, fallbackTitle: 'Essai');

          //assert
          expect(sut.events[0].trebleNotation!.beams, [
            BeamMark.begin,
            BeamMark.forwardHook,
          ]);
          expect(sut.events[1].trebleNotation!.beams, [BeamMark.end]);
          expect(sut.events[2].trebleNotation!.beams, isEmpty);
        });
      });

      group('silences', () {
        test('garde chaque silence sur sa portée, avec sa figure', () {
          //arrange
          final xml = scoreWith([
            rest(extra: '<type>quarter</type>') +
                note('D', 4, duration: 6) +
                backup(8) +
                note('C', 3, duration: 4, staff: 2, voice: 5) +
                rest(duration: 3, staff: 2, voice: 5, extra: '<dot/>') +
                rest(duration: 1, staff: 2, voice: 5),
          ]);

          //act
          final sut = SongModel.fromMusicXml(xml, fallbackTitle: 'Essai');

          //assert
          expect(sut.rests, const [
            SongRest(
              measureNumber: 1,
              onsetDivisions: 0,
              isBass: false,
              value: NoteValue(NoteType.quarter),
            ),
            SongRest(
              measureNumber: 1,
              onsetDivisions: 4,
              isBass: true,
              value: NoteValue(NoteType.quarter, dotCount: 1),
            ),
            SongRest(
              measureNumber: 1,
              onsetDivisions: 7,
              isBass: true,
              value: NoteValue(NoteType.eighth),
            ),
          ]);
        });

        test('reconnaît un silence de mesure entière', () {
          //arrange
          final xml = scoreWith([
            note('C', 4, duration: 8) +
                backup(8) +
                rest(duration: 8, staff: 2, voice: 5, wholeMeasure: true),
          ]);

          //act
          final sut = SongModel.fromMusicXml(xml, fallbackTitle: 'Essai');

          //assert
          expect(sut.rests.single.isWholeMeasure, isTrue);
          expect(sut.rests.single.isBass, isTrue);
        });
      });

      group('titre', () {
        test('prend le titre de l\'œuvre', () {
          //arrange
          final xml = scoreTitled(
            '<work><work-title>Song of Storms</work-title></work>'
            '<movement-title>Mouvement</movement-title>',
          );

          //act
          final sut = SongModel.fromMusicXml(xml, fallbackTitle: 'Essai');

          //assert
          expect(sut.title, 'Song of Storms');
        });

        test('prend le titre du mouvement à défaut', () {
          //arrange
          final xml = scoreTitled('<movement-title>Mouvement</movement-title>');

          //act
          final sut = SongModel.fromMusicXml(xml, fallbackTitle: 'Essai');

          //assert
          expect(sut.title, 'Mouvement');
        });

        test('prend le titre de secours sans titre dans la partition', () {
          //arrange
          final xml = scoreWith([note('C', 4, duration: 8)]);

          //act
          final sut = SongModel.fromMusicXml(xml, fallbackTitle: 'Essai');

          //assert
          expect(sut.title, 'Essai');
        });
      });

      test(
        'lit l\'Ode à la joie : titre, 16 mesures, 62 événements, 5 silences, la main gauche seule en mesure 12',
        () {
          //arrange
          final xml = File(
            'test/fixtures/songs/ode_to_joy.musicxml',
          ).readAsStringSync();

          //act
          final sut = SongModel.fromMusicXml(xml, fallbackTitle: 'Sans titre');

          //assert
          expect(sut.title, 'Ode à la joie');
          expect(sut.rests, hasLength(5));
          expect(sut.rests.where((rest) => rest.isWholeMeasure), hasLength(3));
          expect(sut.divisionsPerQuarter, 2);
          expect(sut.beatsPerMeasure, 4);
          expect(sut.beatUnit, 4);
          expect(sut.measureCount, 16);
          expect(sut.measures.map((measure) => measure.startDivisions), [
            for (var index = 0; index < 16; index++) index * 8,
          ]);
          expect(
            sut.measures.map((measure) => measure.durationDivisions),
            everyElement(8),
          );
          expect(sut.events, hasLength(62));
          expect(
            sut.events.first.notes,
            const TwoStaffEvent(trebleSteps: [2], bassSteps: [-7, -3]),
          );
          final leftHandOnlyEvents = sut.events.where(
            (event) => event.notes.trebleSteps.isEmpty,
          );
          expect(leftHandOnlyEvents.single.measureNumber, 12);
          expect(
            leftHandOnlyEvents.single.notes,
            const TwoStaffEvent(trebleSteps: [], bassSteps: [-3]),
          );
        },
      );
    });
  });
}
