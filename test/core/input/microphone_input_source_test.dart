import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/input/audio/audio_capture.dart';
import 'package:key_starter/core/input/input_event.dart';
import 'package:key_starter/core/input/microphone_input_source.dart';

import 'audio/synthetic_piano.dart';

/// [AudioCapture] qui rejoue des échantillons fournis par le test.
class FakeAudioCapture implements AudioCapture {
  StreamController<List<double>>? _controller;
  int startCount = 0;
  int stopCount = 0;

  bool get isOpen => _controller != null;

  @override
  int get sampleRate => syntheticSampleRate;

  @override
  Future<Stream<List<double>>> start() async {
    startCount++;
    _controller = StreamController<List<double>>(sync: true);
    return _controller!.stream;
  }

  @override
  Future<void> stop() async {
    stopCount++;
    final controller = _controller;
    _controller = null;
    unawaited(controller?.close());
  }

  /// Envoie le signal par paquets, comme le ferait le micro.
  void feed(List<double> samples) {
    const packetSize = 1024;
    for (var start = 0; start < samples.length; start += packetSize) {
      final end = (start + packetSize).clamp(0, samples.length);
      _controller?.add(samples.sublist(start, end));
    }
  }
}

void main() {
  const c4 = 60;
  const d4 = 62;
  final receivedAt = DateTime(2026, 10, 1, 12);

  late SyntheticPiano piano;
  late FakeAudioCapture capture;
  late MicrophoneInputSource sut;
  late List<InputEvent> events;

  setUp(() {
    piano = SyntheticPiano();
    capture = FakeAudioCapture();
    sut = MicrophoneInputSource(capture: capture, now: () => receivedAt);
    events = [];
    sut.events.listen(events.add);
  });

  tearDown(() => sut.dispose());

  group('MicrophoneInputSource', () {
    group('listenFor', () {
      test('ouvre le micro', () async {
        //arrange

        //act
        sut.listenFor({c4});
        await pumpEventQueue();

        //assert
        expect(capture.isOpen, isTrue);
      });

      test('émet la note cible jouée, suivie de son relâchement', () async {
        //arrange
        sut.listenFor({c4});
        await pumpEventQueue();

        //act
        capture.feed(piano.inRoom(piano.note([c4])));
        await pumpEventQueue();

        //assert
        expect(events, hasLength(2));
        expect(events.first, isA<NotePlayed>());
        expect(events.first.midiNumber, c4);
        expect(events.last, const NoteReleased(c4));
      });

      test('date la note à son attaque, avant sa réception', () async {
        //arrange
        sut.listenFor({c4});
        await pumpEventQueue();

        //act
        capture.feed(piano.inRoom(piano.note([c4])));
        await pumpEventQueue();

        //assert
        final played = events.first as NotePlayed;
        expect(played.attackTime.isBefore(receivedAt), isTrue);
      });

      test('émet l\'autre note nettement entendue', () async {
        //arrange
        sut.listenFor({c4});
        await pumpEventQueue();

        //act
        capture.feed(piano.inRoom(piano.note([d4])));
        await pumpEventQueue();

        //assert
        expect(events.first.midiNumber, d4);
      });

      test('n\'émet qu\'une réponse par cible déclarée', () async {
        //arrange
        sut.listenFor({c4});
        await pumpEventQueue();

        //act
        capture.feed(piano.inRoom(piano.note([c4])));
        capture.feed(piano.inRoom(piano.note([c4])));
        await pumpEventQueue();

        //assert
        expect(events.whereType<NotePlayed>(), hasLength(1));
      });

      test('ne rouvre pas le micro déjà ouvert', () async {
        //arrange
        sut.listenFor({c4});
        await pumpEventQueue();

        //act
        sut.listenFor({d4});
        await pumpEventQueue();

        //assert
        expect(capture.startCount, 1);
      });
    });

    group('stopListening', () {
      test('ferme le micro', () async {
        //arrange
        sut.listenFor({c4});
        await pumpEventQueue();

        //act
        sut.stopListening();
        await pumpEventQueue();

        //assert
        expect(capture.isOpen, isFalse);
      });

      test('ferme le micro même s\'il était encore en ouverture', () async {
        //arrange
        sut.listenFor({c4});

        //act
        sut.stopListening();
        await pumpEventQueue();

        //assert
        expect(capture.isOpen, isFalse);
      });
    });
  });
}
