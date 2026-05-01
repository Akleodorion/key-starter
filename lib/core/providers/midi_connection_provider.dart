import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool> _connectAndCheck(MidiCommand midi) async {
  final devices = await midi.devices ?? [];
  for (final device in devices) {
    if (!device.connected) {
      await midi.connectToDevice(device);
    }
  }
  final updated = await midi.devices;
  return updated?.any((d) => d.connected) ?? false;
}

final midiConnectedProvider = StreamProvider<bool>((ref) async* {
  final midi = MidiCommand();

  yield await _connectAndCheck(midi);

  final setupStream = midi.onMidiSetupChanged;
  if (setupStream == null) return;

  await for (final _ in setupStream) {
    yield await _connectAndCheck(midi);
  }
});
