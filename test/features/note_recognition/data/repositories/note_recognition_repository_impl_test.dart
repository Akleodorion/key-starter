import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/note_recognition/data/datasources/midi_datasource.dart';
import 'package:key_starter/features/note_recognition/data/repositories/note_recognition_repository_impl.dart';
import 'package:key_starter/features/note_recognition/domain/entities/note.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'note_recognition_repository_impl_test.mocks.dart';

@GenerateMocks([MidiDataSource])
void main() {
  late MockMidiDataSource mockDataSource;
  late NoteRecognitionRepositoryImpl sut;

  setUp(() {
    mockDataSource = MockMidiDataSource();
    sut = NoteRecognitionRepositoryImpl(dataSource: mockDataSource);
  });

  group('NoteRecognitionRepositoryImpl', () {
    group('recognizeNote', () {
      test('retourne Right(Note) quand le datasource convertit avec succès', () {
        //arrange
        const midiNumber = 60;
        const note = Note(midiNumber: 60, name: 'C', octave: 4);
        when(mockDataSource.noteFromMidiNumber(midiNumber)).thenReturn(note);

        //act
        final result = sut.recognizeNote(midiNumber);

        //assert
        expect(result, const Right(note));
        verify(mockDataSource.noteFromMidiNumber(midiNumber));
        verifyNoMoreInteractions(mockDataSource);
      });

      test('retourne Left(InvalidMidiNoteFailure) quand le datasource lève MidiException', () {
        //arrange
        const midiNumber = 200;
        when(mockDataSource.noteFromMidiNumber(midiNumber))
            .thenThrow(MidiException(midiNumber));

        //act
        final result = sut.recognizeNote(midiNumber);

        //assert
        expect(result, Left(InvalidMidiNoteFailure(midiNumber)));
        verify(mockDataSource.noteFromMidiNumber(midiNumber));
        verifyNoMoreInteractions(mockDataSource);
      });
    });
  });
}
