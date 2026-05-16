import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Émet le nom du premier équipement MIDI connecté, ou null si aucun.
/// Se connecte automatiquement aux appareils disponibles et se met à jour
/// à chaque changement de configuration MIDI.
final midiConnectionProvider = StreamProvider<String?>((ref) async* {
  final midi = MidiCommand();

  Future<String?> connectAndGetName() async {
    final devices = await midi.devices ?? [];
    for (final device in devices) {
      if (!device.connected) {
        await midi.connectToDevice(device);
      }
    }
    final updated = await midi.devices ?? [];
    for (final device in updated) {
      if (device.connected) return device.name;
    }
    return null;
  }

  yield await connectAndGetName();

  await for (final _ in midi.onMidiSetupChanged ?? const Stream.empty()) {
    yield await connectAndGetName();
  }
});
