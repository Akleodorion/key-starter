import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/input/input_source.dart';
import 'package:key_starter/core/input/midi_input_source.dart';
import 'package:key_starter/core/providers/midi_command_provider.dart';

/// La Source d'entrée active, à laquelle les exercices s'abonnent.
final inputSourceProvider = Provider<InputSource>(
  (ref) => MidiInputSource(
    packets: ref.watch(midiCommandProvider).onMidiDataReceived,
  ),
);
