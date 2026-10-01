import 'dart:async';

import 'package:key_starter/core/input/audio/audio_capture.dart';
import 'package:key_starter/core/input/audio/target_note_listener.dart';
import 'package:key_starter/core/input/input_event.dart';
import 'package:key_starter/core/input/input_source.dart';

/// Implémentation de [InputSource] au micro, par vérification guidée : elle
/// n'émet une note que si elle reconnaît l'une des cibles déclarées, ou
/// entend nettement une autre note.
///
/// Le micro n'a pas de Note Off : chaque [NotePlayed] est aussitôt suivi d'un
/// [NoteReleased], et l'écoute s'arrête jusqu'au prochain [listenFor] — une
/// réponse au micro est toujours une nouvelle attaque.
class MicrophoneInputSource implements InputSource {
  final AudioCapture _capture;
  final TargetNoteListener _listener;
  final DateTime Function() _now;
  final _controller = StreamController<InputEvent>.broadcast();
  StreamSubscription<List<double>>? _samplesSubscription;
  bool _isCapturing = false;

  MicrophoneInputSource({
    required AudioCapture capture,
    TargetNoteListener? listener,
    DateTime Function()? now,
  }) : _capture = capture,
       _listener = listener ?? TargetNoteListener(sampleRate: capture.sampleRate),
       _now = now ?? DateTime.now;

  @override
  Stream<InputEvent> get events => _controller.stream;

  @override
  void listenFor(Set<int> candidateMidiNumbers) {
    _listener.listenFor(candidateMidiNumbers);
    if (!_isCapturing) _startCapture();
  }

  @override
  void stopListening() {
    _listener.pause();
    if (_isCapturing) _stopCapture();
  }

  Future<void> dispose() async {
    stopListening();
    await _controller.close();
  }

  Future<void> _startCapture() async {
    _isCapturing = true;
    try {
      final samples = await _capture.start();
      if (!_isCapturing) {
        await _capture.stop();
        return;
      }
      _samplesSubscription = samples.listen(_onSamples);
    } catch (_) {
      // Micro indisponible (permission retirée, occupé) : rien n'est entendu.
      _isCapturing = false;
    }
  }

  Future<void> _stopCapture() async {
    _isCapturing = false;
    await _samplesSubscription?.cancel();
    _samplesSubscription = null;
    try {
      await _capture.stop();
    } catch (_) {
      // Déjà fermé.
    }
  }

  void _onSamples(List<double> samples) {
    final result = _listener.pushSamples(samples);
    if (result == null) return;
    final heardNote = result.heardNote;
    _controller
      ..add(NotePlayed(heardNote, attackTime: _now().subtract(result.sinceAttack)))
      ..add(NoteReleased(heardNote));
  }
}
