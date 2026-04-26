import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/note_recognition/domain/entities/note.dart';
import 'package:key_starter/features/note_recognition/domain/usecases/recognize_note_usecase.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_recognition_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_recognition_provider.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_recognition_state.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'note_recognition_notifier_test.mocks.dart';

@GenerateMocks([RecognizeNoteUseCase])
void main() {
  late MockRecognizeNoteUseCase mockUseCase;
  late ProviderContainer container;

  setUp(() {
    mockUseCase = MockRecognizeNoteUseCase();
    container = ProviderContainer(
      overrides: [
        recognizeNoteUseCaseProvider.overrideWithValue(mockUseCase),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('NoteRecognitionNotifier', () {
    test('état initial est NoteRecognitionInitial', () {
      //assert
      expect(
        container.read(noteRecognitionProvider),
        isA<NoteRecognitionInitial>(),
      );
    });

    group('onMidiNoteReceived', () {
      test('passe à NoteRecognitionLoaded quand le use case réussit', () {
        //arrange
        const midiNumber = 60;
        const note = Note(midiNumber: 60, name: 'C', octave: 4);
        when(mockUseCase(midiNumber)).thenReturn(const Right(note));

        //act
        container
            .read(noteRecognitionProvider.notifier)
            .onMidiNoteReceived(midiNumber);

        //assert
        expect(
          container.read(noteRecognitionProvider),
          const NoteRecognitionLoaded(note: note),
        );
      });

      test('passe à NoteRecognitionError quand le use case retourne une Failure', () {
        //arrange
        const midiNumber = 200;
        when(mockUseCase(midiNumber))
            .thenReturn(Left(InvalidMidiNoteFailure(midiNumber)));

        //act
        container
            .read(noteRecognitionProvider.notifier)
            .onMidiNoteReceived(midiNumber);

        //assert
        expect(
          container.read(noteRecognitionProvider),
          NoteRecognitionError(failure: InvalidMidiNoteFailure(midiNumber)),
        );
      });
    });
  });
}
