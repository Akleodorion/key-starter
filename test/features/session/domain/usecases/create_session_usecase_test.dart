import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/note_recognition/domain/entities/note.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';
import 'package:key_starter/features/session/domain/repositories/session_repository.dart';
import 'package:key_starter/features/session/domain/usecases/create_session_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'create_session_usecase_test.mocks.dart';

@GenerateMocks([SessionRepository])
void main() {
  late MockSessionRepository mockRepository;
  late CreateSessionUseCase sut;

  const tParams = CreateSessionParams(
    clef: ClefMode.treble,
    minNote: Note(midiNumber: 64, name: 'E', octave: 4),
    maxNote: Note(midiNumber: 77, name: 'F', octave: 5),
    totalNotes: 25,
    showNoteName: false,
    language: NoteLanguage.fr,
  );

  final tSession = Session(
    id: 'abc-123',
    clef: ClefMode.treble,
    minNote: const Note(midiNumber: 64, name: 'E', octave: 4),
    maxNote: const Note(midiNumber: 77, name: 'F', octave: 5),
    totalNotes: 25,
    showNoteName: false,
    language: NoteLanguage.fr,
    startedAt: DateTime(2026, 4, 25, 10, 0),
  );

  setUp(() {
    mockRepository = MockSessionRepository();
    sut = CreateSessionUseCase(repository: mockRepository);
  });

  group('CreateSessionUseCase', () {
    group('call', () {
      test('retourne Session depuis le repository pour des params valides', () async {
        //arrange
        when(mockRepository.createSession(tParams)).thenAnswer((_) async {
          final Either<Failure, Session> r = Right(tSession);
          return r;
        });

        //act
        final result = await sut(tParams);

        //assert
        expect(result, Right<Failure, Session>(tSession));
        verify(mockRepository.createSession(tParams));
        verifyNoMoreInteractions(mockRepository);
      });

      test('retourne InvalidSessionParamsFailure pour des params invalides', () async {
        //arrange
        when(mockRepository.createSession(tParams)).thenAnswer((_) async {
          const Either<Failure, Session> r = Left(InvalidSessionParamsFailure());
          return r;
        });

        //act
        final result = await sut(tParams);

        //assert
        expect(result, const Left<Failure, Session>(InvalidSessionParamsFailure()));
        verify(mockRepository.createSession(tParams));
        verifyNoMoreInteractions(mockRepository);
      });
    });
  });
}
