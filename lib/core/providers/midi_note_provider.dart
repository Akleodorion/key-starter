import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits the MIDI number of every note-on event received from connected devices.
/// A note-on packet is 3 bytes: [0x9n, noteNumber, velocity] with velocity > 0.
final midiNoteOnProvider = StreamProvider<int>((ref) {
  final stream = MidiCommand().onMidiDataReceived;
  if (stream == null) return const Stream.empty();

  return stream
      .where((packet) =>
          packet.data.length >= 3 &&
          (packet.data[0] & 0xF0) == 0x90 &&
          packet.data[2] > 0)
      .map((packet) => packet.data[1]);
});
