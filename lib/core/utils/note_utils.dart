import 'package:key_starter/core/enums/note_language.dart';

const List<String> noteNamesEn = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
const List<String> noteNamesFr = ['Do', 'Ré', 'Mi', 'Fa', 'Sol', 'La', 'Si'];

/// Demi-tons de chaque degré diatonique dans une octave (Do=0).
const List<int> diatonicSemitones = [0, 2, 4, 5, 7, 9, 11];

/// Retourne le nom lisible d'une note à partir de son degré diatonique.
///
/// [step] est relatif à Do 4 (step 0 = Do 4, step 7 = Do 5, step -7 = Do 3, …).
String noteLabel(int step, NoteLanguage lang) {
  final noteIndex = ((step % 7) + 7) % 7;
  final octave = 4 + (step - noteIndex) ~/ 7;
  final names = lang == NoteLanguage.fr ? noteNamesFr : noteNamesEn;
  return '${names[noteIndex]} $octave';
}

/// Converts a diatonic step to its MIDI number (step 0 = C4 = MIDI 60).
int midiFromDiatonicStep(int step) {
  final noteIndex = ((step % 7) + 7) % 7;
  final octave = 4 + (step - noteIndex) ~/ 7;
  return (octave + 1) * 12 + diatonicSemitones[noteIndex];
}

/// Converts a MIDI number to a diatonic step, or null if the note is chromatic.
/// step 0 = C4 = MIDI 60.
int? diatonicStepFromMidi(int midiNumber) {
  final semitone = midiNumber % 12;
  final octave = midiNumber ~/ 12 - 1;
  final noteIndex = diatonicSemitones.indexOf(semitone);
  if (noteIndex == -1) return null;
  return (octave - 4) * 7 + noteIndex;
}
