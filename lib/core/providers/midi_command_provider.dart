import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Accès unique au plugin MIDI, partagé par la connexion et la Source d'entrée.
final midiCommandProvider = Provider<MidiCommand>((ref) => MidiCommand());
