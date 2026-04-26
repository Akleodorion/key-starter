import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/features/note_recognition/data/datasources/midi_datasource.dart';
import 'package:key_starter/features/note_recognition/domain/entities/note.dart';

void main() {
  late MidiDataSourceImpl sut;

  setUp(() {
    sut = MidiDataSourceImpl();
  });

  group('MidiDataSourceImpl', () {
    group('noteFromMidiNumber', () {
      test('retourne C4 pour le MIDI 60 (Do central)', () {
        //arrange
        const midiNumber = 60;

        //act
        final result = sut.noteFromMidiNumber(midiNumber);

        //assert
        expect(result, const Note(midiNumber: 60, name: 'C', octave: 4));
      });

      test('retourne A4 pour le MIDI 69 (La du diapason)', () {
        //arrange
        const midiNumber = 69;

        //act
        final result = sut.noteFromMidiNumber(midiNumber);

        //assert
        expect(result, const Note(midiNumber: 69, name: 'A', octave: 4));
      });

      test('retourne C-1 pour le MIDI 0 (note minimale)', () {
        //arrange
        const midiNumber = 0;

        //act
        final result = sut.noteFromMidiNumber(midiNumber);

        //assert
        expect(result, const Note(midiNumber: 0, name: 'C', octave: -1));
      });

      test('retourne G9 pour le MIDI 127 (note maximale)', () {
        //arrange
        const midiNumber = 127;

        //act
        final result = sut.noteFromMidiNumber(midiNumber);

        //assert
        expect(result, const Note(midiNumber: 127, name: 'G', octave: 9));
      });

      test('retourne correctement une note dièse', () {
        //arrange
        const midiNumber = 61; // C#4

        //act
        final result = sut.noteFromMidiNumber(midiNumber);

        //assert
        expect(result, const Note(midiNumber: 61, name: 'C#', octave: 4));
      });

      test('lève MidiException pour un numéro supérieur à 127', () {
        //arrange
        const midiNumber = 128;

        //act & assert
        expect(
          () => sut.noteFromMidiNumber(midiNumber),
          throwsA(isA<MidiException>()),
        );
      });

      test('lève MidiException pour un numéro négatif', () {
        //arrange
        const midiNumber = -1;

        //act & assert
        expect(
          () => sut.noteFromMidiNumber(midiNumber),
          throwsA(isA<MidiException>()),
        );
      });
    });
  });
}
