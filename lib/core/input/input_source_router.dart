import 'dart:async';

import 'package:key_starter/core/input/input_event.dart';
import 'package:key_starter/core/input/input_source.dart';
import 'package:key_starter/core/input/input_source_kind.dart';

/// Implémentation de [InputSource] qui relaie la source active (MIDI ou
/// micro) et bascule de l'une à l'autre à chaud : les exercices gardent un
/// seul abonnement, et la nouvelle source est réarmée avec la cible en cours.
class InputSourceRouter implements InputSource {
  final InputSource _midi;
  final InputSource _microphone;
  final _controller = StreamController<InputEvent>.broadcast(sync: true);
  late final List<StreamSubscription<InputEvent>> _subscriptions;
  InputSourceKind _activeKind = InputSourceKind.none;
  Set<int>? _currentTarget;

  InputSourceRouter({
    required InputSource midi,
    required InputSource microphone,
  }) : _midi = midi,
       _microphone = microphone {
    _subscriptions = [
      _midi.events.listen((event) {
        if (_activeKind == InputSourceKind.midi) _controller.add(event);
      }),
      _microphone.events.listen((event) {
        if (_activeKind == InputSourceKind.microphone) _controller.add(event);
      }),
    ];
  }

  @override
  Stream<InputEvent> get events => _controller.stream;

  @override
  void listenFor(Set<int> candidateMidiNumbers) {
    _currentTarget = candidateMidiNumbers;
    _activeSource?.listenFor(candidateMidiNumbers);
  }

  @override
  void stopListening() {
    _currentTarget = null;
    _activeSource?.stopListening();
  }

  /// Passe à la source [kind] ; la cible en cours lui est redonnée.
  void activate(InputSourceKind kind) {
    if (kind == _activeKind) return;
    _activeSource?.stopListening();
    _activeKind = kind;
    final target = _currentTarget;
    if (target != null) _activeSource?.listenFor(target);
  }

  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _controller.close();
  }

  InputSource? get _activeSource => switch (_activeKind) {
    InputSourceKind.midi => _midi,
    InputSourceKind.microphone => _microphone,
    InputSourceKind.none => null,
  };
}
