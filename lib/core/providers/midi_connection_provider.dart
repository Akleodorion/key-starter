import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/providers/midi_command_provider.dart';

/// Émet le nom du premier équipement MIDI connecté, ou null si aucun.
/// Se connecte automatiquement aux appareils disponibles et se met à jour
/// à chaque changement de configuration MIDI. Sans plugin MIDI disponible,
/// aucun clavier n'est considéré comme connecté.
final midiConnectionProvider = StreamProvider<String?>(
  (ref) => _connectedDeviceNames(ref.watch(midiCommandProvider)),
);

Stream<String?> _connectedDeviceNames(MidiCommand midi) async* {
  Future<String?> connectAndGetFirstName() async {
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

  Future<String?> connectAndGetName() async {
    try {
      return await connectAndGetFirstName();
    } catch (_) {
      return null; // plugin MIDI indisponible : aucun clavier
    }
  }

  yield await connectAndGetName();

  await for (final _ in midi.onMidiSetupChanged ?? const Stream.empty()) {
    yield await connectAndGetName();
  }
}
