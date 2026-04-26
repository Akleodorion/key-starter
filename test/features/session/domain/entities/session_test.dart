import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/features/note_recognition/domain/entities/note.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';
import 'package:key_starter/features/session/domain/entities/session_result.dart';

void main() {
  final tStartedAt = DateTime(2026, 4, 25, 10, 0);

  const tMinNote = Note(midiNumber: 64, name: 'E', octave: 4);
  const tMaxNote = Note(midiNumber: 77, name: 'F', octave: 5);

  const tResult = SessionResult(
    correctCount: 22,
    totalNotes: 25,
    durationSec: 96,
    bestStreak: 14,
    avgResponseMs: 1240,
  );

  late Session tSession;

  setUp(() {
    tSession = Session(
      id: 'abc-123',
      clef: ClefMode.treble,
      minNote: tMinNote,
      maxNote: tMaxNote,
      totalNotes: 25,
      showNoteName: false,
      language: NoteLanguage.fr,
      startedAt: tStartedAt,
    );
  });

  group('Session', () {
    group('isCompleted', () {
      test('retourne false quand result est null', () {
        //assert
        expect(tSession.isCompleted, isFalse);
      });

      test('retourne true quand result est renseigné', () {
        //arrange
        final completed = tSession.copyWith(result: tResult);

        //assert
        expect(completed.isCompleted, isTrue);
      });
    });

    group('équalité', () {
      test('deux instances avec les mêmes props sont égales', () {
        //arrange
        final other = Session(
          id: 'abc-123',
          clef: ClefMode.treble,
          minNote: tMinNote,
          maxNote: tMaxNote,
          totalNotes: 25,
          showNoteName: false,
          language: NoteLanguage.fr,
          startedAt: tStartedAt,
        );

        //assert
        expect(tSession, equals(other));
      });

      test('deux instances avec des props différentes ne sont pas égales', () {
        //arrange
        final other = Session(
          id: 'xyz-999',
          clef: ClefMode.treble,
          minNote: tMinNote,
          maxNote: tMaxNote,
          totalNotes: 25,
          showNoteName: false,
          language: NoteLanguage.fr,
          startedAt: tStartedAt,
        );

        //assert
        expect(tSession, isNot(equals(other)));
      });
    });

    group('copyWith', () {
      test('sans argument retourne une instance équivalente', () {
        //act
        final result = tSession.copyWith();

        //assert
        expect(result, equals(tSession));
      });

      test('met à jour uniquement le champ spécifié', () {
        //act
        final result = tSession.copyWith(totalNotes: 50);

        //assert
        expect(result.totalNotes, 50);
        expect(result.id, tSession.id);
        expect(result.clef, tSession.clef);
        expect(result.minNote, tSession.minNote);
        expect(result.maxNote, tSession.maxNote);
        expect(result.showNoteName, tSession.showNoteName);
        expect(result.language, tSession.language);
        expect(result.startedAt, tSession.startedAt);
        expect(result.result, tSession.result);
      });

      test('complète la session en ajoutant le résultat', () {
        //act
        final completed = tSession.copyWith(result: tResult);

        //assert
        expect(completed.result, equals(tResult));
        expect(completed.isCompleted, isTrue);
        expect(completed.id, tSession.id);
      });
    });
  });
}
