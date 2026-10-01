import 'dart:typed_data';

import 'package:key_starter/core/input/audio/audio_capture.dart';
import 'package:record/record.dart';

/// Implémentation de [AudioCapture] avec le package `record`, en PCM 16 bits.
class RecordAudioCapture implements AudioCapture {
  /// Créé au premier démarrage : sa construction ouvre déjà le plugin natif.
  AudioRecorder? _recorder;

  @override
  int get sampleRate => 44100;

  @override
  Future<Stream<List<double>>> start() async {
    final recorder = _recorder ??= AudioRecorder();
    final bytes = await recorder.startStream(
      RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: sampleRate,
        numChannels: 1,
        // Le traitement « voix » du téléphone abîme les harmoniques du
        // piano : le filtrage du bruit est fait par le seuil d'écoute.
        autoGain: false,
        echoCancel: false,
        noiseSuppress: false,
      ),
    );
    return bytes.map(_samplesFromPcm16);
  }

  @override
  Future<void> stop() async {
    await _recorder?.stop();
  }

  List<double> _samplesFromPcm16(Uint8List bytes) {
    final data = ByteData.sublistView(bytes);
    return List<double>.generate(
      bytes.length ~/ 2,
      (index) => data.getInt16(index * 2, Endian.little) / 32768,
    );
  }
}
