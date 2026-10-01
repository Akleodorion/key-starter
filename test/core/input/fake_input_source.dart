import 'dart:async';

import 'package:key_starter/core/input/input_event.dart';
import 'package:key_starter/core/input/input_source.dart';

/// [InputSource] pilotée par les tests : on y pousse des événements et on lit
/// les cibles que l'exercice a déclarées.
class FakeInputSource implements InputSource {
  final _controller = StreamController<InputEvent>.broadcast(sync: true);
  final List<Set<int>> listenedTargets = [];
  bool isListening = false;

  @override
  Stream<InputEvent> get events => _controller.stream;

  @override
  void listenFor(Set<int> candidateMidiNumbers) {
    listenedTargets.add(candidateMidiNumbers);
    isListening = true;
  }

  @override
  void stopListening() => isListening = false;

  void play(int midiNumber, {DateTime? attackTime}) => _controller.add(
    NotePlayed(midiNumber, attackTime: attackTime ?? DateTime.now()),
  );

  void release(int midiNumber) => _controller.add(NoteReleased(midiNumber));
}
