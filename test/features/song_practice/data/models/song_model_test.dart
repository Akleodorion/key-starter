import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/features/song_practice/data/models/song_model.dart';

/// Partition MusicXML minimale d'une partie piano à deux portées, en Do
/// majeur et 4/4 (unité : la croche), dont les mesures sont [measures].
String scoreWith(List<String> measures, {String attributes = ''}) {
  final measureElements = [
    for (var index = 0; index < measures.length; index++)
      '<measure number="${index + 1}">'
          '${index == 0 ? '<attributes><divisions>2</divisions><key><fifths>0</fifths></key>'
                    '<time><beats>4</beats><beat-type>4</beat-type></time><staves>2</staves>$attributes</attributes>' : ''}'
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

String rest({int duration = 2, int staff = 1, int voice = 1}) =>
    '<note><rest/><duration>$duration</duration><voice>$voice</voice><staff>$staff</staff></note>';

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
          final sut = SongModel.fromMusicXml(xml, title: 'Essai');

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
          final sut = SongModel.fromMusicXml(xml, title: 'Essai');

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
        final sut = SongModel.fromMusicXml(xml, title: 'Essai');

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
          final sut = SongModel.fromMusicXml(xml, title: 'Essai');

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
        final sut = SongModel.fromMusicXml(xml, title: 'Essai');

        //assert
        expect(sut.measureCount, 2);
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
          () => SongModel.fromMusicXml(xml, title: 'Essai'),
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
          () => SongModel.fromMusicXml(xml, title: 'Essai'),
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
          () => SongModel.fromMusicXml(xml, title: 'Essai'),
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
          () => SongModel.fromMusicXml(xml, title: 'Essai'),
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
          () => SongModel.fromMusicXml(xml, title: 'Essai'),
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
          () => SongModel.fromMusicXml(xml, title: 'Essai'),
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
          () => SongModel.fromMusicXml(xml, title: 'Essai'),
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
          () => SongModel.fromMusicXml(xml, title: 'Essai'),
          throwsUnsupported(
            'Une seule voix par portée est prise en charge pour l\'instant.',
          ),
        );
      });

      test(
        'lit l\'Ode à la joie : 16 mesures, 62 événements, la main gauche seule en mesure 12',
        () {
          //arrange
          final xml = File(
            'test/fixtures/songs/ode_to_joy.musicxml',
          ).readAsStringSync();

          //act
          final sut = SongModel.fromMusicXml(xml, title: 'Ode à la joie');

          //assert
          expect(sut.measureCount, 16);
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
