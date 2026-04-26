import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/features/note_recognition/domain/entities/note.dart';

abstract interface class MidiDataSource {
  Note noteFromMidiNumber(int midiNumber);
}

class MidiDataSourceImpl implements MidiDataSource {
  static const _noteNames = [
    'C', 'C#', 'D', 'D#', 'E', 'F',
    'F#', 'G', 'G#', 'A', 'A#', 'B',
  ];

  @override
  Note noteFromMidiNumber(int midiNumber) {
    if (midiNumber < 0 || midiNumber > 127) {
      throw MidiException(midiNumber);
    }
    return Note(
      midiNumber: midiNumber,
      name: _noteNames[midiNumber % 12],
      octave: midiNumber ~/ 12 - 1,
    );
  }
}
