import 'dart:math';

import 'package:key_starter/core/input/audio/piano_audio_analyzer.dart';

const syntheticSampleRate = 44100;

/// Sons de test imitant un piano au micro (partiels inharmoniques,
/// décroissance, bruit de pièce). Garde-fou algorithmique : la validation réelle
/// a été faite en direct sur le synthé.
class SyntheticPiano {
  final Random _random;

  SyntheticPiano({int seed = 42}) : _random = Random(seed);

  /// Une note (ou plusieurs) d'une seconde, crête d'environ [peak].
  List<double> note(List<int> midiNumbers, {double peak = 0.3}) {
    const durationSamples = syntheticSampleRate;
    const harmonicProfile = [
      1.0,
      0.8,
      0.45,
      0.35,
      0.2,
      0.15,
      0.1,
      0.08,
      0.05,
      0.04,
    ];
    final samples = List<double>.filled(durationSamples, 0);
    for (final midiNumber in midiNumbers) {
      final fundamental = midiToFrequency(midiNumber);
      for (var harmonic = 1; harmonic <= harmonicProfile.length; harmonic++) {
        final frequency =
            harmonic * fundamental * sqrt(1 + 0.0004 * harmonic * harmonic);
        if (frequency > syntheticSampleRate / 2) break;
        final amplitude =
            harmonicProfile[harmonic - 1] * (0.7 + 0.6 * _random.nextDouble());
        final phase = _random.nextDouble() * 2 * pi;
        final decay = 1.5 + harmonic * 0.4;
        for (var index = 0; index < durationSamples; index++) {
          final time = index / syntheticSampleRate;
          samples[index] +=
              amplitude *
              exp(-decay * time) *
              sin(2 * pi * frequency * time + phase);
        }
      }
    }
    final currentPeak = samples.fold(
      0.0,
      (maxValue, sample) => max(maxValue, sample.abs()),
    );
    return [for (final sample in samples) sample * peak / currentPeak];
  }

  /// Bruit de pièce : surtout grave (ventilation, rumeur), un peu de souffle.
  List<double> roomNoise(int length, {double level = 0.003}) {
    var lowPassed = 0.0;
    return List.generate(length, (_) {
      lowPassed = 0.98 * lowPassed + 0.02 * (_random.nextDouble() * 2 - 1);
      return level * (12 * lowPassed + 0.25 * (_random.nextDouble() * 2 - 1));
    });
  }

  /// Une seconde de pièce calme, le son joué par-dessus le bruit, puis une
  /// demi-seconde de calme.
  List<double> inRoom(List<double> played) {
    final noiseUnderPlayed = roomNoise(played.length);
    return [
      ...roomNoise(syntheticSampleRate),
      for (var index = 0; index < played.length; index++)
        played[index] + noiseUnderPlayed[index],
      ...roomNoise(syntheticSampleRate ~/ 2),
    ];
  }
}
