import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/note_recognition/domain/entities/note.dart';
import 'package:key_starter/features/session/domain/repositories/session_repository.dart';
import 'package:key_starter/features/session/domain/usecases/create_session_usecase.dart';
import 'package:key_starter/features/session/domain/usecases/get_last_session_params_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_last_session_params_usecase_test.mocks.dart';

@GenerateMocks([SessionRepository])
void main() {
  late MockSessionRepository mockRepository;
  late GetLastSessionParamsUseCase sut;

  const tParams = CreateSessionParams(
    clef: ClefMode.treble,
    minNote: Note(midiNumber: 64, name: 'E', octave: 4),
    maxNote: Note(midiNumber: 77, name: 'F', octave: 5),
    totalNotes: 25,
    showNoteName: false,
    language: NoteLanguage.fr,
  );

  setUp(() {
    mockRepository = MockSessionRepository();
    sut = GetLastSessionParamsUseCase(repository: mockRepository);
  });

  group('GetLastSessionParamsUseCase', () {
    group('call', () {
      test('retourne Right(params) quand des params existent', () async {
        //arrange
        when(mockRepository.getLastSessionParams())
            .thenAnswer((_) async => const Right(tParams));

        //act
        final result = await sut();

        //assert
        expect(result, const Right(tParams));
        verify(mockRepository.getLastSessionParams());
        verifyNoMoreInteractions(mockRepository);
      });

      test('retourne Right(null) au premier lancement', () async {
        //arrange
        when(mockRepository.getLastSessionParams())
            .thenAnswer((_) async => const Right(null));

        //act
        final result = await sut();

        //assert
        expect(result, const Right(null));
        verify(mockRepository.getLastSessionParams());
        verifyNoMoreInteractions(mockRepository);
      });

      test('retourne CacheFailure en cas d\'erreur de lecture', () async {
        //arrange
        when(mockRepository.getLastSessionParams())
            .thenAnswer((_) async => const Left(CacheFailure()));

        //act
        final result = await sut();

        //assert
        expect(result, const Left(CacheFailure()));
        verify(mockRepository.getLastSessionParams());
        verifyNoMoreInteractions(mockRepository);
      });
    });
  });
}
