import 'dart:math';
import 'dart:typed_data';

import 'package:fftea/fftea.dart';

/// Fréquence tempérée (La 440) d'un numéro MIDI.
double midiToFrequency(num midiNumber) =>
    440.0 * pow(2, (midiNumber - 69) / 12).toDouble();

/// Inharmonicité B mesurée sur un piano réel : ~1,3e-4 du grave au Do3, puis
/// monte d'environ ×2,5 par octave jusqu'à ~1e-2 vers Do7 ; légère remontée
/// dans l'extrême grave.
double pianoInharmonicity(int midiNumber) {
  final exponent = midiNumber < 30
      ? -3.9 + (30 - midiNumber) * 0.03
      : midiNumber <= 48
      ? -3.9
      : min(-1.9, -3.9 + (midiNumber - 48) * 0.041);
  return pow(10, exponent).toDouble();
}

/// Rapports de fréquence ×2, ×3, ×4, ×5 → écart en demi-tons (octave,
/// douzième, double octave, 17e majeure). Une note k fois plus aiguë a toutes
/// ses harmoniques en commun avec la plus grave : c'est la source des
/// confusions dans le grave (D2 pris pour A3 = 3 × D2).
const _harmonicRelations = {2: 12, 3: 19, 4: 24, 5: 28};

/// Verdict d'une vérification guidée (voir CONTEXT.md).
class TargetVerdict {
  final bool matches;

  /// Salience de chaque note cible, relative au meilleur candidat du spectre.
  final Map<int, double> presenceByNote;

  const TargetVerdict({required this.matches, required this.presenceByNote});

  static const silent = TargetVerdict(matches: false, presenceByNote: {});
}

/// Analyse spectrale d'une trame de son de piano ou de synthé, par somme
/// harmonique (inspirée de Klapuri 2006) avec un modèle d'inharmonicité.
///
/// Ne sert qu'à la vérification guidée : on lui demande si une note connue
/// est jouée, jamais de deviner ce qui est joué.
class PianoAudioAnalyzer {
  /// Au-delà, on considère que la note plus grave (octave, douzième…) a été jouée.
  static const _lowerOctaveLimit = 0.1;

  /// En dessous, la cible n'est qu'un « fantôme » d'une note plus aiguë.
  static const _ghostLimit = 0.1;

  /// Taille de la trame courte de mesure de justesse (≈ 93 ms).
  static const _shortFrameSize = 4096;

  /// Au-delà, on ignore les partiels (aigus : on en garde assez jusqu'à 10 kHz).
  static const _maxPartialHz = 12000.0;

  /// Marge de soustraction du bruit (> 1 : on retire un peu plus que la moyenne).
  static const _noiseOverSubtraction = 1.5;

  final int sampleRate;
  final int frameSize;
  final int minMidi;
  final int maxMidi;
  final int harmonicCount;

  /// Spectre moyen du bruit de fond, retiré de chaque analyse (null = rien appris).
  Float64List? _noiseProfile;

  /// Inharmonicité ajustée sur le son joué, pour l'extrême grave (voir
  /// [_fitBassInharmonicity]) ; sinon on prend la courbe [pianoInharmonicity].
  final Map<int, double> _fittedInharmonicity = {};

  late final FFT _fft = FFT(frameSize);
  late final Float64List _window = Window.hanning(frameSize);
  late final double _binHz = sampleRate / frameSize;
  late final FFT _shortFft = FFT(_shortFrameSize);
  late final Float64List _shortWindow = Window.hanning(_shortFrameSize);

  PianoAudioAnalyzer({
    this.sampleRate = 44100,
    this.frameSize = 8192,
    this.minMidi = 21,
    this.maxMidi = 108,
    this.harmonicCount = 8,
  });

  /// Apprend le spectre du bruit de fond (moyenne glissante) : à appeler
  /// uniquement sur des trames où rien d'intentionnel ne joue.
  void learnNoise(List<double> frame) {
    final spectrum = _rawSpectrum(frame);
    final current = _noiseProfile;
    if (current == null) {
      _noiseProfile = spectrum;
      return;
    }
    for (var bin = 0; bin < spectrum.length; bin++) {
      current[bin] = 0.9 * current[bin] + 0.1 * spectrum[bin];
    }
  }

  /// Vérifie une hypothèse connue au lieu de transcrire à l'aveugle :
  /// 1. chaque note cible doit être présente (salience ≥ [minPresence] × max) ;
  /// 2. après avoir retiré la cible du spectre, aucune autre note ne doit
  ///    dépasser [maxExtraRatio] × la salience de la cible (note en trop) ;
  /// 3. ni une note plus grave liée (octave, douzième…), ni un fantôme d'une
  ///    note plus aiguë ne doivent mieux expliquer le son.
  TargetVerdict verifyTarget(
    List<double> frame,
    List<int> target, {
    double minPresence = 0.15,
    double maxExtraRatio = 0.3,
  }) {
    final spectrum = _spectrum(frame);
    if (spectrum == null) return TargetVerdict.silent;
    _fitBassInharmonicity(spectrum);

    var maxSalience = 0.0;
    for (var midi = minMidi; midi <= maxMidi; midi++) {
      if (_isHarmonicEchoOf(midi, target)) continue;
      maxSalience = max(
        maxSalience,
        _salience(_harmonicAmplitudes(spectrum, midi)),
      );
    }
    final presence = <int, double>{};
    var weakestTargetSalience = double.infinity;
    for (final note in target) {
      final salience = _salience(_harmonicAmplitudes(spectrum, note));
      presence[note] = maxSalience == 0 ? 0 : salience / maxSalience;
      weakestTargetSalience = min(weakestTargetSalience, salience);
    }

    final spectrumBeforeCancel = Float64List.fromList(spectrum);
    for (final note in target) {
      _cancel(spectrum, note);
    }
    var extraSalience = 0.0;
    for (var midi = minMidi; midi <= maxMidi; midi++) {
      // Notes AU-DESSUS d'une cible dans un rapport harmonique (octave,
      // douzième…) = résidus d'harmoniques, on les ignore. Une note EN
      // DESSOUS reste une vraie note en trop (C4 joué pour C5).
      if (_isHarmonicEchoOf(midi, target)) continue;
      if (target.contains(midi)) continue;
      extraSalience = max(
        extraSalience,
        _salience(_harmonicAmplitudes(spectrum, midi)),
      );
    }
    final extraRatio = weakestTargetSalience == 0
        ? double.infinity
        : extraSalience / weakestTargetSalience;

    // Dans le grave, la fondamentale est faible : jouer l'octave du dessous
    // passe les tests ci-dessus (sa 2e harmonique = la cible). On regarde
    // donc directement s'il y a de l'énergie à la fréquence de l'octave basse,
    // et à l'inverse si la cible n'est qu'un écho d'une note plus aiguë.
    final hasLowerRelated = target.any((note) {
      final lower = _lowerRelatedNote(spectrumBeforeCancel, note);
      return lower != null && !target.contains(lower);
    });
    final isGhost = target.any(
      (note) => _isGhostOfHigherNote(spectrumBeforeCancel, note),
    );
    final allPresent =
        !hasLowerRelated &&
        !isGhost &&
        presence.values.every((value) => value >= minPresence);
    return TargetVerdict(
      matches: allPresent && extraRatio <= maxExtraRatio,
      presenceByNote: presence,
    );
  }

  /// Note la plus saillante de la trame, octave corrigée (null si silence).
  int? dominantNote(List<double> frame) {
    final spectrum = _spectrum(frame);
    if (spectrum == null) return null;
    _fitBassInharmonicity(spectrum);
    var bestMidi = -1;
    var bestSalience = 0.0;
    for (var midi = minMidi; midi <= maxMidi; midi++) {
      final salience = _salience(_harmonicAmplitudes(spectrum, midi));
      if (salience > bestSalience) {
        bestSalience = salience;
        bestMidi = midi;
      }
    }
    return bestMidi < 0 ? null : _correctOctave(spectrum, bestMidi);
  }

  /// Part de l'énergie du spectre portée par les harmoniques de [note], dans
  /// la bande de la note. Une note tenue concentre son énergie sur ses
  /// harmoniques ; un claquement de langue, un souffle ou un choc l'étalent.
  double harmonicity(List<double> frame, int note) {
    final spectrum = _spectrum(frame);
    if (spectrum == null) return 0;
    final harmonicBins = <int>{};
    for (var harmonic = 1; harmonic <= _harmonicsFor(note); harmonic++) {
      final frequency = _partialFrequency(note, harmonic);
      if (frequency > _maxPartialHz) break;
      final (low, high) = _binRange(frequency);
      for (var bin = low - 1; bin <= high + 1; bin++) {
        harmonicBins.add(bin);
      }
    }
    final fundamental = midiToFrequency(note);
    final bandLow = 0.7 * fundamental;
    final bandHigh = min(_maxPartialHz, max(1300.0, 8.5 * fundamental));
    var harmonicEnergy = 0.0;
    var totalEnergy = 0.0;
    for (var bin = 1; bin < spectrum.length; bin++) {
      final frequency = bin * _binHz;
      if (frequency < bandLow || frequency > bandHigh) continue;
      final energy = spectrum[bin] * spectrum[bin];
      totalEnergy += energy;
      if (harmonicBins.contains(bin)) harmonicEnergy += energy;
    }
    return totalEnergy == 0 ? 0 : harmonicEnergy / totalEnergy;
  }

  /// Écart en cents entre la hauteur réellement jouée et la note tempérée
  /// [note], estimé sur les 4 premiers harmoniques utiles (interpolation
  /// parabolique des pics), sur les 93 dernières ms : assez court pour « voir »
  /// osciller un vibrato de voix. null si introuvable.
  double? centsOffset(List<double> frame, int note) {
    final shortFrame = frame.sublist(frame.length - _shortFrameSize);
    final windowed = Float64List(_shortFrameSize);
    for (var index = 0; index < _shortFrameSize; index++) {
      windowed[index] = shortFrame[index] * _shortWindow[index];
    }
    final spectrum = _shortFft
        .realFft(windowed)
        .discardConjugates()
        .magnitudes();
    final binHz = sampleRate / _shortFrameSize;
    var weightedCents = 0.0;
    var totalWeight = 0.0;
    var usedHarmonics = 0;
    for (var harmonic = 1; harmonic <= 24 && usedHarmonics < 4; harmonic++) {
      final expected = _partialFrequency(note, harmonic);
      // Trame courte = bins de 10,8 Hz : trop grossier sous 150 Hz, on mesure
      // les notes graves sur leurs harmoniques plus hautes.
      if (expected < 150) continue;
      if (expected > 5000) break;
      usedHarmonics++;
      final halfWidthHz = max(binHz, expected * 0.0145);
      final low = max(1, ((expected - halfWidthHz) / binHz).floor());
      final high = min(
        spectrum.length - 2,
        ((expected + halfWidthHz) / binHz).ceil(),
      );
      var peakBin = low;
      for (var bin = low; bin <= high; bin++) {
        if (spectrum[bin] > spectrum[peakBin]) peakBin = bin;
      }
      final left = spectrum[peakBin - 1];
      final center = spectrum[peakBin];
      final right = spectrum[peakBin + 1];
      if (center <= left || center <= right) continue;
      final shift = 0.5 * (left - right) / (left - 2 * center + right);
      final measured = (peakBin + shift) * binHz;
      weightedCents += center * 1200 * log(measured / expected) / ln2;
      totalWeight += center;
    }
    return totalWeight == 0 ? null : weightedCents / totalWeight;
  }

  /// Spectre d'amplitude fenêtré, bruit de fond retiré, ou null si silence.
  Float64List? _spectrum(List<double> frame) {
    var sumSquares = 0.0;
    for (final sample in frame) {
      sumSquares += sample * sample;
    }
    if (sumSquares == 0) return null;
    final spectrum = _rawSpectrum(frame);
    final noise = _noiseProfile;
    if (noise != null) {
      for (var bin = 0; bin < spectrum.length; bin++) {
        spectrum[bin] = max(
          0,
          spectrum[bin] - _noiseOverSubtraction * noise[bin],
        );
      }
    }
    return spectrum;
  }

  Float64List _rawSpectrum(List<double> frame) {
    assert(frame.length == frameSize);
    final windowed = Float64List(frameSize);
    for (var index = 0; index < frameSize; index++) {
      windowed[index] = frame[index] * _window[index];
    }
    return Float64List.fromList(
      _fft.realFft(windowed).discardConjugates().magnitudes(),
    );
  }

  double _partialFrequency(int midiNumber, int harmonic) {
    final coefficient =
        _fittedInharmonicity[midiNumber] ?? pianoInharmonicity(midiNumber);
    return harmonic *
        midiToFrequency(midiNumber) *
        sqrt(1 + coefficient * harmonic * harmonic);
  }

  /// Sous Do2, une erreur sur l'inharmonicité décale les harmoniques hautes
  /// d'un demi-ton (A0 lu A#0). Elle varie d'un piano / synthé à l'autre : on
  /// l'ajuste donc sur le son joué, en gardant celle qui aligne le mieux les pics.
  void _fitBassInharmonicity(Float64List spectrum) {
    _fittedInharmonicity.clear();
    for (var midi = minMidi; midi < 36; midi++) {
      final base = pianoInharmonicity(midi);
      var bestCoefficient = base;
      var bestScore = -1.0;
      for (final factor in const [0.25, 0.5, 1.0, 2.0, 4.0, 8.0]) {
        _fittedInharmonicity[midi] = base * factor;
        final score = _harmonicAmplitudes(
          spectrum,
          midi,
        ).fold(0.0, (sum, value) => sum + value);
        if (score > bestScore) {
          bestScore = score;
          bestCoefficient = base * factor;
        }
      }
      _fittedInharmonicity[midi] = bestCoefficient;
    }
  }

  /// Nombre d'harmoniques utiles : 8 au médium, jusqu'à 40 dans l'extrême
  /// grave (fondamentale quasi absente).
  int _harmonicsFor(int midiNumber) =>
      (1200 / midiToFrequency(midiNumber)).floor().clamp(harmonicCount, 40);

  /// Plage de bins où chercher un partiel : ± un quart de demi-ton, au moins
  /// 1 bin, élargie dans l'aigu où les pianos sont accordés « étirés ».
  (int, int) _binRange(double frequency) {
    final stretchCents = (12 * log(frequency / 880) / ln2 * 1.5).clamp(
      0.0,
      40.0,
    );
    final halfWidthFraction = pow(2, (25 + stretchCents) / 1200).toDouble() - 1;
    final halfWidthHz = max(_binHz, frequency * halfWidthFraction);
    final low = max(1, ((frequency - halfWidthHz) / _binHz).floor());
    final high = min(
      frameSize ~/ 2,
      ((frequency + halfWidthHz) / _binHz).ceil(),
    );
    return (low, high);
  }

  double _peakAround(Float64List spectrum, double frequency) {
    final (low, high) = _binRange(frequency);
    var peak = 0.0;
    for (var bin = low; bin <= high; bin++) {
      if (spectrum[bin] > peak) peak = spectrum[bin];
    }
    return peak;
  }

  List<double> _harmonicAmplitudes(Float64List spectrum, int midiNumber) {
    final amplitudes = <double>[];
    final count = _harmonicsFor(midiNumber);
    for (var harmonic = 1; harmonic <= count; harmonic++) {
      final frequency = _partialFrequency(midiNumber, harmonic);
      if (frequency > _maxPartialHz) break;
      amplitudes.add(_peakAround(spectrum, frequency));
    }
    return amplitudes;
  }

  /// Sous-harmonique fantôme : si c'est l'octave du dessus qui joue, ce
  /// candidat n'a d'énergie que sur ses harmoniques PAIRES. Une vraie note a
  /// aussi des harmoniques impaires, même dans le grave.
  double _salience(List<double> amplitudes) {
    if (amplitudes.isEmpty) return 0;
    var oddEnergy = 0.0;
    var evenEnergy = 0.0;
    for (var index = 0; index < min(8, amplitudes.length); index++) {
      if (index.isEven) {
        oddEnergy += amplitudes[index];
      } else {
        evenEnergy += amplitudes[index];
      }
    }
    if (oddEnergy < 0.2 * evenEnergy) return 0;
    var salience = 0.0;
    for (var index = 0; index < amplitudes.length; index++) {
      salience += amplitudes[index] / (index + 1);
    }
    return salience;
  }

  /// Retire du spectre la contribution de la note trouvée. On lisse les
  /// amplitudes harmoniques : un partiel qui dépasse l'enveloppe lissée
  /// appartient probablement aussi à une autre note, on en laisse l'excédent.
  void _cancel(Float64List spectrum, int midiNumber) {
    final amplitudes = _harmonicAmplitudes(spectrum, midiNumber);
    for (var index = 0; index < amplitudes.length; index++) {
      final previous = index > 0 ? amplitudes[index - 1] : amplitudes[index];
      final next = index < amplitudes.length - 1
          ? amplitudes[index + 1]
          : amplitudes[index];
      final smoothed = (previous + amplitudes[index] + next) / 3;
      final removed = min(amplitudes[index], smoothed);
      final (low, high) = _binRange(_partialFrequency(midiNumber, index + 1));
      for (var bin = low - 1; bin <= high + 1; bin++) {
        if (bin < 1 || bin >= spectrum.length) continue;
        spectrum[bin] = max(0, spectrum[bin] - removed);
      }
    }
  }

  /// Niveau de référence de [note] : moyenne de ses 4 premières harmoniques
  /// SIGNIFICATIVES (≥ 10 % de la plus forte). Les harmoniques quasi nulles
  /// des aigus feraient passer une simple résonance de cordes pour une note.
  double _referenceTargetPeak(Float64List spectrum, int note) {
    final peaks = <double>[];
    for (var harmonic = 1; harmonic <= 4; harmonic++) {
      final frequency = _partialFrequency(note, harmonic);
      if (frequency > _maxPartialHz) break;
      peaks.add(_peakAround(spectrum, frequency));
    }
    if (peaks.isEmpty) return 0;
    final strongest = peaks.reduce(max);
    final significant = peaks.where((peak) => peak >= 0.1 * strongest).toList();
    if (significant.isEmpty) return 0;
    return significant.reduce((sum, peak) => sum + peak) / significant.length;
  }

  /// Énergie des harmoniques PROPRES de [lower] (celles que la note [factor]
  /// fois plus aiguë [note] n'explique pas), relative aux harmoniques de
  /// [note]. Élevé = c'est bien [lower] qui joue, pas [note].
  double _lowerNoteRatio(
    Float64List spectrum,
    int note,
    int lower,
    int factor,
  ) {
    final reference = _referenceTargetPeak(spectrum, note);
    if (reference == 0) return 0;
    var own = 0.0;
    var count = 0;
    for (var harmonic = 1; count < 4 && harmonic <= 3 * factor; harmonic++) {
      if (harmonic % factor == 0) continue;
      final frequency = _partialFrequency(lower, harmonic);
      if (frequency > _maxPartialHz) break;
      own += _peakAround(spectrum, frequency);
      count++;
    }
    return count == 0 ? 0 : own / count / reference;
  }

  /// La note jouée est-elle en réalité une note plus grave dont [note] n'est
  /// qu'une harmonique ? Renvoie cette note plus grave, ou null.
  int? _lowerRelatedNote(Float64List spectrum, int note) {
    int? best;
    var bestRatio = _lowerOctaveLimit;
    _harmonicRelations.forEach((factor, semitones) {
      final lower = note - semitones;
      if (lower < minMidi) return;
      final ratio = _lowerNoteRatio(spectrum, note, lower, factor);
      if (ratio > bestRatio) {
        bestRatio = ratio;
        best = lower;
      }
    });
    return best;
  }

  /// [note] n'est-elle qu'un fantôme d'une note plus aiguë ? Ses harmoniques
  /// propres (non multiples de k) doivent porter de l'énergie.
  bool _isGhostOfHigherNote(Float64List spectrum, int note) {
    for (final factor in _harmonicRelations.keys) {
      if (note + _harmonicRelations[factor]! > maxMidi) continue;
      var own = 0.0;
      var ownCount = 0;
      var shared = 0.0;
      var sharedCount = 0;
      for (var harmonic = 1; harmonic <= max(2 * factor, 8); harmonic++) {
        final frequency = _partialFrequency(note, harmonic);
        if (frequency > _maxPartialHz) break;
        final peak = _peakAround(spectrum, frequency);
        if (harmonic % factor == 0) {
          shared += peak;
          sharedCount++;
        } else {
          own += peak;
          ownCount++;
        }
      }
      if (sharedCount == 0 || ownCount == 0 || shared == 0) continue;
      if (own / ownCount < _ghostLimit * (shared / sharedCount)) return true;
    }
    return false;
  }

  /// Corrige les erreurs « note trop aiguë » (octave, douzième…) : on descend
  /// tant qu'une note plus grave explique mieux le spectre.
  int _correctOctave(Float64List spectrum, int note) {
    var corrected = note;
    for (var step = 0; step < 4; step++) {
      final lower = _lowerRelatedNote(spectrum, corrected);
      if (lower == null) break;
      corrected = lower;
    }
    return corrected;
  }

  /// Notes dont la fréquence est un multiple entier de celle d'une cible :
  /// leurs « saliences » ne sont que des échos de la cible.
  bool _isHarmonicEchoOf(int midi, List<int> target) => target.any(
    (note) =>
        midi > note && const [12, 19, 24, 28, 31, 34, 36].contains(midi - note),
  );
}
