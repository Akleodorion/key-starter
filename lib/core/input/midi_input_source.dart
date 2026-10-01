import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:key_starter/core/input/input_event.dart';
import 'package:key_starter/core/input/input_source.dart';

/// Implémentation de [InputSource] pour un clavier MIDI : les notes reçues sont
/// exactes, les cibles déclarées par [listenFor] sont donc ignorées.
class MidiInputSource implements InputSource {
  final Stream<MidiPacket> _packets;
  final DateTime Function() _now;

  MidiInputSource({
    required Stream<MidiPacket>? packets,
    DateTime Function()? now,
  }) : _packets = packets ?? const Stream.empty(),
       _now = now ?? DateTime.now;

  @override
  Stream<InputEvent> get events => _packets.expand(_eventsFromPacket);

  @override
  void listenFor(Set<int> candidateMidiNumbers) {}

  @override
  void stopListening() {}

  /// Un message de note fait 3 octets : [statut, numéro, vélocité]. Un Note On
  /// de vélocité 0 est un Note Off.
  Iterable<InputEvent> _eventsFromPacket(MidiPacket packet) sync* {
    final data = packet.data;
    if (data.length < 3) return;

    final status = data[0] & 0xF0;
    final midiNumber = data[1];
    final velocity = data[2];

    if (status == 0x90 && velocity > 0) {
      yield NotePlayed(midiNumber, attackTime: _now());
    } else if (status == 0x80 || status == 0x90) {
      yield NoteReleased(midiNumber);
    }
  }
}
