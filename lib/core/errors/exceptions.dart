class MidiException implements Exception {
  final int midiNumber;
  const MidiException(this.midiNumber);
}

class SharedPreferencesException implements Exception {
  const SharedPreferencesException();
}
