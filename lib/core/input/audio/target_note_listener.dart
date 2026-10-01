import 'dart:math';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:key_starter/core/input/audio/piano_audio_analyzer.dart';

/// Issue d'un essai tranché par [TargetNoteListener].
class NoteAttemptResult extends Equatable {
  /// Note réellement entendue : l'un des candidats si l'essai est juste.
  final int heardNote;
  final bool isCorrect;

  /// Temps écoulé entre l'attaque et le verdict, pour dater l'attaque.
  final Duration sinceAttack;

  const NoteAttemptResult({
    required this.heardNote,
    required this.isCorrect,
    required this.sinceAttack,
  });

  @override
  List<Object?> get props => [heardNote, isCorrect, sinceAttack];
}

/// Vérification guidée au micro (voir CONTEXT.md) : écoute si l'une des notes
/// candidates est jouée — une seule en général, toutes les octaves d'une même
/// note quand l'octave est libre.
///
/// Ne réagit qu'au son intentionnel :
/// - le seuil d'écoute est le plus haut de -55 dB et du bruit de fond mesuré
///   en continu, dans la bande de chaque candidat ;
/// - un essai ne démarre que sur une attaque nette (le volume grimpe d'un coup) ;
/// - un son sans hauteur claire (choc, voix, bruit) est ignoré, jamais compté faux.
///
/// Le premier candidat qui tranche décide ; l'écoute s'arrête ensuite jusqu'au
/// prochain [listenFor].
class TargetNoteListener {
  static const hopSize = 2048; // ≈ 46 ms

  /// Seuil d'écoute fixe (-55 dBFS) : en dessous, jamais une note.
  static final minimumGate = pow(10, -55 / 20).toDouble();

  /// Sous Do2, deux notes voisines ne sont séparées que de 2 à 4 Hz : on
  /// analyse une trame 2× plus longue (≈ 370 ms, un peu plus de délai).
  static const _longFrameBelowMidi = 36;

  final int sampleRate;
  final PianoAudioAnalyzer _standardAnalyzer;
  final PianoAudioAnalyzer _bassAnalyzer;

  late final Float64List _ring = Float64List(_bassAnalyzer.frameSize);
  int _writeIndex = 0;
  int _pendingSamples = 0;
  final List<_CandidateTracker> _trackers = [];

  TargetNoteListener({this.sampleRate = 44100})
    : _standardAnalyzer = PianoAudioAnalyzer(sampleRate: sampleRate),
      _bassAnalyzer = PianoAudioAnalyzer(
        sampleRate: sampleRate,
        frameSize: 16384,
      );

  /// Arme l'écoute sur de nouvelles notes candidates ; l'essai démarrera à la
  /// prochaine attaque. Le bruit de fond déjà appris est conservé.
  void listenFor(Set<int> candidateMidiNumbers) {
    _trackers
      ..clear()
      ..addAll([
        for (final midiNumber in candidateMidiNumbers)
          _CandidateTracker(
            target: midiNumber,
            analyzer: midiNumber < _longFrameBelowMidi
                ? _bassAnalyzer
                : _standardAnalyzer,
            sampleRate: sampleRate,
          ),
      ]);
  }

  void pause() => _trackers.clear();

  /// Ajoute des échantillons ; renvoie un résultat quand un essai est tranché.
  NoteAttemptResult? pushSamples(List<double> samples) {
    NoteAttemptResult? result;
    for (final sample in samples) {
      _ring[_writeIndex] = sample;
      _writeIndex = (_writeIndex + 1) % _ring.length;
      for (final tracker in _trackers) {
        tracker.accumulate(sample);
      }
      if (++_pendingSamples == hopSize) {
        _pendingSamples = 0;
        result ??= _onHop();
      }
    }
    return result;
  }

  NoteAttemptResult? _onHop() {
    List<double> frameOf(PianoAudioAnalyzer analyzer) =>
        _currentFrame(analyzer.frameSize);

    NoteAttemptResult? result;
    for (final tracker in _trackers) {
      result ??= tracker.onHop(frameOf);
    }
    // Le bruit de fond ne s'apprend que si rien d'intentionnel ne se passe
    // dans la bande d'aucun candidat.
    if (_trackers.isNotEmpty && _trackers.every((tracker) => tracker.isQuiet)) {
      _standardAnalyzer.learnNoise(frameOf(_standardAnalyzer));
      _bassAnalyzer.learnNoise(frameOf(_bassAnalyzer));
    }
    for (final tracker in _trackers) {
      tracker.endHop();
    }
    if (result != null) _trackers.clear();
    return result;
  }

  /// Les [size] derniers échantillons, dans l'ordre.
  List<double> _currentFrame(int size) {
    final frame = Float64List(size);
    final start = (_writeIndex - size) % _ring.length;
    for (var index = 0; index < size; index++) {
      frame[index] = _ring[(start + index) % _ring.length];
    }
    return frame;
  }
}

/// État d'écoute d'un candidat : sa bande de fréquences, son bruit de fond,
/// et l'essai en cours depuis la dernière attaque.
class _CandidateTracker {
  static const _listeningHops = 15; // ≈ 700 ms après l'attaque

  /// Jusqu'à ce saut (≈ 184 ms), le son doit garder une part de son niveau
  /// d'attaque. Un claquement de langue retombe en quelques dizaines de ms.
  static const _sustainCheckUntilHop = 4;

  /// Sauts d'adaptation au bruit de la nouvelle bande après un changement de cible.
  static const _warmupHops = 6;

  static const _requiredStableHops = 3; // ≈ 140 ms de hauteur stable

  /// Rapport entre le seuil d'écoute et le bruit de fond.
  static const _gateFactor = 8.0;

  /// Le son doit garder au moins cette fraction de son niveau d'attaque.
  static const _sustainRatio = 0.07;

  /// Part minimale de l'énergie portée par les harmoniques de la note.
  static const _minHarmonicity = 0.5;

  /// Anti-parole : la hauteur doit tomber sur la note tempérée (± cents)…
  static const _maxCentsOffset = 25.0;

  /// … et ne pas bouger d'une analyse à l'autre (une voix glisse sans cesse).
  static const _maxCentsDrift = 8.0;

  /// Anti-parole : après l'attaque, le volume ne doit pas remonter au-delà de
  /// ce facteur (une note décroît ou tient ; la parole remonte à chaque syllabe).
  static const _maxReRise = 2.5;

  final int target;
  final PianoAudioAnalyzer analyzer;
  final int sampleRate;

  /// Filtre passe-bande calé sur la cible : le volume, l'attaque et le bruit
  /// de fond sont mesurés dans la bande où la note a son énergie.
  final _Biquad _highPass = _Biquad();
  final _Biquad _lowPass = _Biquad();
  double _hopSumSquares = 0;

  double _noiseFloor = 0.002;
  final List<double> _previousHopRms = [0, 0];
  int _warmupRemaining = _warmupHops;
  double _hopRms = 0;
  bool _isQuiet = false;

  int? _attemptHop;
  double _attackPeak = 0;
  double _minimumSinceAttack = double.infinity;
  final List<double> _matchCents = [];
  final Map<int, List<double>> _heardCents = {};

  _CandidateTracker({
    required this.target,
    required this.analyzer,
    required this.sampleRate,
  }) {
    final fundamental = midiToFrequency(target);
    _highPass.configure(sampleRate, 0.7 * fundamental, highPass: true);
    // Grave : l'énergie est dans les harmoniques (fondamentale quasi absente),
    // on garde au moins jusqu'à 1,5 kHz.
    _lowPass.configure(
      sampleRate,
      min(12000.0, max(1500.0, 8 * fundamental)),
      highPass: false,
    );
  }

  double get _gate =>
      max(TargetNoteListener.minimumGate, _noiseFloor * _gateFactor);

  /// On ne juge qu'une trame d'analyse entièrement postérieure à l'attaque :
  /// le transitoire de l'attaque, ou un claquement, ne pèse pas dans la décision.
  int get _firstDecisionHop => analyzer.frameSize ~/ TargetNoteListener.hopSize;

  /// Rien d'intentionnel dans la bande au dernier saut : le bruit de fond
  /// peut s'apprendre.
  bool get isQuiet => _isQuiet;

  void accumulate(double sample) {
    final banded = _lowPass.process(_highPass.process(sample));
    _hopSumSquares += banded * banded;
  }

  NoteAttemptResult? onHop(List<double> Function(PianoAudioAnalyzer) frameOf) {
    _hopRms = sqrt(_hopSumSquares / TargetNoteListener.hopSize);
    _hopSumSquares = 0;
    final hopRms = _hopRms;
    final reference = _previousHopRms.reduce(max);
    _isQuiet = false;

    // Bruit de fond : suit vite vers le bas, lentement vers le haut, et
    // uniquement quand rien d'intentionnel ne se passe.
    if (_warmupRemaining > 0) {
      _warmupRemaining--;
      _noiseFloor = _warmupRemaining == _warmupHops - 1
          ? hopRms
          : 0.5 * _noiseFloor + 0.5 * hopRms;
      return null;
    }
    _isQuiet = _attemptHop == null && hopRms < _gate && hopRms <= 2 * reference;
    if (_attemptHop == null && hopRms < _gate) {
      _noiseFloor = hopRms < _noiseFloor
          ? 0.7 * _noiseFloor + 0.3 * hopRms
          : 0.98 * _noiseFloor + 0.02 * hopRms;
    }

    if (_attemptHop == null) {
      final isOnset = hopRms > _gate && hopRms > 3 * reference;
      if (isOnset) {
        _attemptHop = 0;
        _attackPeak = hopRms;
      }
      return null;
    }

    final hop = _attemptHop = _attemptHop! + 1;
    if (hop <= 2) _attackPeak = max(_attackPeak, hopRms);
    if (hop <= _sustainCheckUntilHop &&
        (hopRms < _sustainRatio * _attackPeak || hopRms < 1.3 * _noiseFloor)) {
      return _ignore(); // son trop bref
    }
    if (hop > 2) {
      // Une syllabe repart du quasi-silence ; les cordes d'une note aiguë
      // « battent » (creux marqués mais loin du silence) : on ne juge la
      // remontée que si le son est d'abord tombé sous 25 % de son attaque.
      if (hopRms > _maxReRise * max(_minimumSinceAttack, 0.25 * _attackPeak)) {
        return _ignore(); // volume qui remonte : parole
      }
      _minimumSinceAttack = min(_minimumSinceAttack, hopRms);
    }
    if (hop < _firstDecisionHop) return null;

    final frame = frameOf(analyzer);
    final verdict = analyzer.verifyTarget(
      frame,
      [target],
      minPresence: 0.3,
      maxExtraRatio: 0.5,
    );
    final heard = analyzer.dominantNote(frame);
    if (heard != null &&
        analyzer.harmonicity(frame, heard) >= _minHarmonicity) {
      final heardCents = analyzer.centsOffset(frame, heard);
      final (lowestHeard, highestHeard) = _tuningTolerance(heard);
      if (heardCents != null &&
          heardCents >= lowestHeard &&
          heardCents <= highestHeard) {
        _heardCents.putIfAbsent(heard, () => []).add(heardCents);
      }
    }

    final targetCents = analyzer.centsOffset(frame, target);
    final (lowestCents, highestCents) = _tuningTolerance(target);
    final targetMatches =
        verdict.matches &&
        analyzer.harmonicity(frame, target) >= _minHarmonicity &&
        targetCents != null &&
        targetCents >= lowestCents &&
        targetCents <= highestCents;
    if (targetMatches) {
      _matchCents.add(targetCents);
      if (_spread(_matchCents) > _maxCentsDrift) _matchCents.removeAt(0);
    } else {
      _matchCents.clear();
    }
    if (_matchCents.length >= _requiredStableHops) {
      return _decide(target, hop, isCorrect: true);
    }
    if (hop < _listeningHops) return null;

    // Fenêtre écoulée sans validation.
    final stableHeard = _heardCents.entries.where(
      (entry) =>
          entry.value.length >= _requiredStableHops &&
          _spread(entry.value) <= _maxCentsDrift * 1.5,
    );
    if (stableHeard.isEmpty) return _ignore(); // pas de hauteur claire
    final mostHeard = stableHeard.reduce(
      (best, entry) => entry.value.length > best.value.length ? entry : best,
    );
    // On a entendu la bonne note sans pouvoir la valider : ce n'est pas une
    // erreur de l'élève, on réécoute plutôt que d'afficher « faux ».
    if (mostHeard.key == target) return _ignore();
    return _decide(mostHeard.key, hop, isCorrect: false);
  }

  void endHop() {
    _previousHopRms
      ..removeAt(0)
      ..add(_hopRms);
  }

  NoteAttemptResult? _ignore() {
    _resetAttempt();
    return null;
  }

  NoteAttemptResult _decide(int heardNote, int hop, {required bool isCorrect}) {
    _resetAttempt();
    return NoteAttemptResult(
      heardNote: heardNote,
      isCorrect: isCorrect,
      sinceAttack: Duration(
        microseconds:
            hop *
            TargetNoteListener.hopSize *
            Duration.microsecondsPerSecond ~/
            sampleRate,
      ),
    );
  }

  void _resetAttempt() {
    _attemptHop = null;
    _attackPeak = 0;
    _minimumSinceAttack = double.infinity;
    _matchCents.clear();
    _heardCents.clear();
  }

  /// Plage de justesse acceptée (cents) pour [midiNumber]. Les pianos, réels
  /// comme numériques, sont accordés « étirés » : l'aigu plus haut, le grave
  /// plus bas que le tempérament strict. Ce contrôle ne sert qu'à écarter la
  /// voix ; les mauvaises notes sont refusées par la vérification de la cible.
  (double, double) _tuningTolerance(int midiNumber) {
    final trebleStretch = (midiNumber - 81).clamp(0, 27) * 1.5; // dès A5
    final bassStretch = (45 - midiNumber).clamp(0, 24) * 1.0; // sous A2
    return (-_maxCentsOffset - bassStretch, _maxCentsOffset + trebleStretch);
  }

  double _spread(List<double> values) =>
      values.reduce(max) - values.reduce(min);
}

/// Filtre biquad du 2e ordre (formules RBJ), Q = 0,707.
class _Biquad {
  double _b0 = 1, _b1 = 0, _b2 = 0, _a1 = 0, _a2 = 0;
  double _x1 = 0, _x2 = 0, _y1 = 0, _y2 = 0;

  void configure(int sampleRate, double cutoffHz, {required bool highPass}) {
    final omega = 2 * pi * cutoffHz / sampleRate;
    final alpha = sin(omega) / (2 * 0.7071);
    final cosine = cos(omega);
    final a0 = 1 + alpha;
    if (highPass) {
      _b0 = (1 + cosine) / 2 / a0;
      _b1 = -(1 + cosine) / a0;
    } else {
      _b0 = (1 - cosine) / 2 / a0;
      _b1 = (1 - cosine) / a0;
    }
    _b2 = _b0;
    _a1 = -2 * cosine / a0;
    _a2 = (1 - alpha) / a0;
  }

  double process(double input) {
    final output = _b0 * input + _b1 * _x1 + _b2 * _x2 - _a1 * _y1 - _a2 * _y2;
    _x2 = _x1;
    _x1 = input;
    _y2 = _y1;
    _y1 = output;
    return output;
  }
}
