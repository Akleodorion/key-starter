import 'dart:typed_data';

import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/input/input_event.dart';
import 'package:key_starter/core/input/midi_input_source.dart';

void main() {
  final receivedAt = DateTime(2026, 10, 1, 12);
  final device = MidiDevice('id', 'Synthé', 'native', true);

  MidiPacket packet(List<int> bytes) =>
      MidiPacket(Uint8List.fromList(bytes), 0, device);

  Future<List<InputEvent>> eventsFrom(List<MidiPacket> packets) {
    final sut = MidiInputSource(
      packets: Stream.fromIterable(packets),
      now: () => receivedAt,
    );
    return sut.events.toList();
  }

  group('MidiInputSource', () {
    group('events', () {
      test('émet NotePlayed pour un Note On de vélocité non nulle', () async {
        //arrange
        final packets = [
          packet([0x90, 60, 100]),
        ];

        //act
        final events = await eventsFrom(packets);

        //assert
        expect(events, [NotePlayed(60, attackTime: receivedAt)]);
      });

      test('émet NoteReleased pour un Note Off', () async {
        //arrange
        final packets = [
          packet([0x80, 60, 64]),
        ];

        //act
        final events = await eventsFrom(packets);

        //assert
        expect(events, [const NoteReleased(60)]);
      });

      test('émet NoteReleased pour un Note On de vélocité 0', () async {
        //arrange
        final packets = [
          packet([0x90, 62, 0]),
        ];

        //act
        final events = await eventsFrom(packets);

        //assert
        expect(events, [const NoteReleased(62)]);
      });

      test('accepte les notes de tous les canaux MIDI', () async {
        //arrange
        final packets = [
          packet([0x93, 64, 90]),
          packet([0x8F, 64, 0]),
        ];

        //act
        final events = await eventsFrom(packets);

        //assert
        expect(events, [
          NotePlayed(64, attackTime: receivedAt),
          const NoteReleased(64),
        ]);
      });

      test(
        'ignore les paquets trop courts et les messages autres que des notes',
        () async {
          //arrange
          final packets = [
            packet([0x90, 60]),
            packet([0xB0, 64, 127]),
            packet([0xF8]),
          ];

          //act
          final events = await eventsFrom(packets);

          //assert
          expect(events, isEmpty);
        },
      );

      test('ne plante pas sans flux MIDI disponible', () async {
        //arrange
        final sut = MidiInputSource(packets: null);

        //act
        final events = await sut.events.toList();

        //assert
        expect(events, isEmpty);
      });
    });
  });
}
