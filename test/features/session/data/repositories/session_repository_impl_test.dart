import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/note_recognition/domain/entities/note.dart';
import 'package:key_starter/features/session/data/datasources/session_local_datasource.dart';
import 'package:key_starter/features/session/data/repositories/session_repository_impl.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';
import 'package:key_starter/features/session/domain/entities/session_result.dart';
import 'package:key_starter/features/session/domain/usecases/complete_session_usecase.dart';
import 'package:key_starter/features/session/domain/usecases/create_session_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'session_repository_impl_test.mocks.dart';

@GenerateMocks([SessionLocalDataSource])
void main() {
  late MockSessionLocalDataSource mockDataSource;
  late SessionRepositoryImpl sut;

  final tNow = DateTime(2026, 4, 25, 10, 0);
  const tId = 'test-id';

  const tMinNote = Note(midiNumber: 64, name: 'E', octave: 4);
  const tMaxNote = Note(midiNumber: 77, name: 'F', octave: 5);

  const tParams = CreateSessionParams(
    clef: ClefMode.treble,
    minNote: tMinNote,
    maxNote: tMaxNote,
    totalNotes: 25,
    showNoteName: false,
    language: NoteLanguage.fr,
  );

  final tSession = Session(
    id: tId,
    clef: ClefMode.treble,
    minNote: tMinNote,
    maxNote: tMaxNote,
    totalNotes: 25,
    showNoteName: false,
    language: NoteLanguage.fr,
    startedAt: tNow,
  );

  const tResult = SessionResult(
    correctCount: 22,
    totalNotes: 25,
    durationSec: 96,
    bestStreak: 14,
    avgResponseMs: 1240,
  );

  setUp(() {
    mockDataSource = MockSessionLocalDataSource();
    sut = SessionRepositoryImpl(
      dataSource: mockDataSource,
      generateId: () => tId,
      now: () => tNow,
    );
  });

  group('SessionRepositoryImpl', () {
    group('createSession', () {
      test('retourne Session quand les params sont valides', () async {
        //arrange
        when(mockDataSource.saveLastParams(tParams))
            .thenAnswer((_) => Future<void>.value());

        //act
        final result = await sut.createSession(tParams);

        //assert
        expect(result, Right(tSession));
        verify(mockDataSource.saveLastParams(tParams));
      });

      test('retourne InvalidSessionParamsFailure quand totalNotes < 5', () async {
        //arrange
        const invalidParams = CreateSessionParams(
          clef: ClefMode.treble,
          minNote: tMinNote,
          maxNote: tMaxNote,
          totalNotes: 2,
          showNoteName: false,
          language: NoteLanguage.fr,
        );

        //act
        final result = await sut.createSession(invalidParams);

        //assert
        expect(result, const Left(InvalidSessionParamsFailure()));
        verifyNever(mockDataSource.saveLastParams(any));
      });

      test('retourne InvalidSessionParamsFailure quand totalNotes > 100', () async {
        //arrange
        const invalidParams = CreateSessionParams(
          clef: ClefMode.treble,
          minNote: tMinNote,
          maxNote: tMaxNote,
          totalNotes: 200,
          showNoteName: false,
          language: NoteLanguage.fr,
        );

        //act
        final result = await sut.createSession(invalidParams);

        //assert
        expect(result, const Left(InvalidSessionParamsFailure()));
      });

      test('retourne InvalidSessionParamsFailure quand minNote >= maxNote', () async {
        //arrange
        const invalidParams = CreateSessionParams(
          clef: ClefMode.treble,
          minNote: tMaxNote,
          maxNote: tMinNote,
          totalNotes: 25,
          showNoteName: false,
          language: NoteLanguage.fr,
        );

        //act
        final result = await sut.createSession(invalidParams);

        //assert
        expect(result, const Left(InvalidSessionParamsFailure()));
      });

      test('retourne CacheFailure quand le datasource lève SharedPreferencesException', () async {
        //arrange
        when(mockDataSource.saveLastParams(tParams))
            .thenThrow(const SharedPreferencesException());

        //act
        final result = await sut.createSession(tParams);

        //assert
        expect(result, const Left(CacheFailure()));
      });
    });

    group('completeSession', () {
      test('retourne la Session complétée', () {
        //arrange
        final params = CompleteSessionParams(session: tSession, result: tResult);

        //act
        final result = sut.completeSession(params);

        //assert
        expect(result, Right(tSession.copyWith(result: tResult)));
      });

      test('retourne SessionAlreadyCompletedFailure si déjà terminée', () {
        //arrange
        final completed = tSession.copyWith(result: tResult);
        final params = CompleteSessionParams(session: completed, result: tResult);

        //act
        final result = sut.completeSession(params);

        //assert
        expect(result, const Left(SessionAlreadyCompletedFailure()));
      });
    });

    group('getLastSessionParams', () {
      test('retourne Right(params) quand des params existent', () async {
        //arrange
        when(mockDataSource.getLastParams()).thenAnswer((_) async => tParams);

        //act
        final result = await sut.getLastSessionParams();

        //assert
        expect(result, const Right(tParams));
      });

      test('retourne Right(null) quand aucun param n\'est sauvegardé', () async {
        //arrange
        when(mockDataSource.getLastParams()).thenAnswer((_) async => null);

        //act
        final result = await sut.getLastSessionParams();

        //assert
        expect(result, const Right(null));
      });

      test('retourne CacheFailure quand le datasource lève SharedPreferencesException', () async {
        //arrange
        when(mockDataSource.getLastParams())
            .thenThrow(const SharedPreferencesException());

        //act
        final result = await sut.getLastSessionParams();

        //assert
        expect(result, const Left(CacheFailure()));
      });
    });
  });
}
