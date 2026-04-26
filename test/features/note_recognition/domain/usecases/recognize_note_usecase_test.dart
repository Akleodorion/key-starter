import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/note_recognition/domain/entities/note.dart';
import 'package:key_starter/features/note_recognition/domain/repositories/note_recognition_repository.dart';
import 'package:key_starter/features/note_recognition/domain/usecases/recognize_note_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'recognize_note_usecase_test.mocks.dart';

@GenerateMocks([NoteRecognitionRepository])
void main() {
  late MockNoteRecognitionRepository mockRepository;
  late RecognizeNoteUseCase sut;

  setUp(() {
    mockRepository = MockNoteRecognitionRepository();
    sut = RecognizeNoteUseCase(repository: mockRepository);
  });

  group('RecognizeNoteUseCase', () {
    group('call', () {
      test('retourne Note depuis le repository pour un numéro MIDI valide', () {
        //arrange
        const midiNumber = 60;
        const note = Note(midiNumber: 60, name: 'C', octave: 4);
        when(mockRepository.recognizeNote(midiNumber))
            .thenReturn(const Right(note));

        //act
        final result = sut(midiNumber);

        //assert
        expect(result, const Right(note));
        verify(mockRepository.recognizeNote(midiNumber));
        verifyNoMoreInteractions(mockRepository);
      });

      test('retourne InvalidMidiNoteFailure pour un numéro MIDI supérieur à 127', () {
        //arrange
        const midiNumber = 200;
        when(mockRepository.recognizeNote(midiNumber))
            .thenReturn(Left(InvalidMidiNoteFailure(midiNumber)));

        //act
        final result = sut(midiNumber);

        //assert
        expect(result, Left(InvalidMidiNoteFailure(midiNumber)));
        verify(mockRepository.recognizeNote(midiNumber));
        verifyNoMoreInteractions(mockRepository);
      });

      test('retourne InvalidMidiNoteFailure pour un numéro MIDI négatif', () {
        //arrange
        const midiNumber = -1;
        when(mockRepository.recognizeNote(midiNumber))
            .thenReturn(Left(InvalidMidiNoteFailure(midiNumber)));

        //act
        final result = sut(midiNumber);

        //assert
        expect(result, Left(InvalidMidiNoteFailure(midiNumber)));
        verify(mockRepository.recognizeNote(midiNumber));
        verifyNoMoreInteractions(mockRepository);
      });
    });
  });
}
