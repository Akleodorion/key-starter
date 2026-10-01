import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/input/input_event.dart';
import 'package:key_starter/core/input/input_source_kind.dart';
import 'package:key_starter/core/input/input_source_router.dart';

import 'fake_input_source.dart';

void main() {
  const c4 = 60;
  const d4 = 62;

  late FakeInputSource midi;
  late FakeInputSource microphone;
  late InputSourceRouter sut;
  late List<InputEvent> events;

  setUp(() {
    midi = FakeInputSource();
    microphone = FakeInputSource();
    sut = InputSourceRouter(midi: midi, microphone: microphone);
    events = [];
    sut.events.listen(events.add);
  });

  tearDown(() => sut.dispose());

  group('InputSourceRouter', () {
    group('events', () {
      test('ne relaie que la source active', () {
        //arrange
        sut.activate(InputSourceKind.microphone);

        //act
        midi.play(c4);
        microphone.play(d4);

        //assert
        expect(events.map((event) => event.midiNumber), [d4]);
      });

      test('ne relaie rien sans source active', () {
        //arrange
        sut.activate(InputSourceKind.none);

        //act
        midi.play(c4);
        microphone.play(d4);

        //assert
        expect(events, isEmpty);
      });
    });

    group('listenFor', () {
      test('déclare la cible à la source active seulement', () {
        //arrange
        sut.activate(InputSourceKind.microphone);

        //act
        sut.listenFor({c4});

        //assert
        expect(microphone.listenedTargets, [
          {c4},
        ]);
        expect(midi.listenedTargets, isEmpty);
      });
    });

    group('activate', () {
      test('réarme la nouvelle source avec la cible en cours', () {
        //arrange
        sut.activate(InputSourceKind.midi);
        sut.listenFor({c4});

        //act
        sut.activate(InputSourceKind.microphone);

        //assert
        expect(microphone.listenedTargets, [
          {c4},
        ]);
        expect(microphone.isListening, isTrue);
      });

      test('arrête l\'écoute de l\'ancienne source', () {
        //arrange
        sut.activate(InputSourceKind.microphone);
        sut.listenFor({c4});

        //act
        sut.activate(InputSourceKind.midi);

        //assert
        expect(microphone.isListening, isFalse);
      });

      test('ne réarme rien quand l\'exercice a cessé d\'écouter', () {
        //arrange
        sut.activate(InputSourceKind.midi);
        sut.listenFor({c4});
        sut.stopListening();

        //act
        sut.activate(InputSourceKind.microphone);

        //assert
        expect(microphone.listenedTargets, isEmpty);
      });
    });
  });
}
