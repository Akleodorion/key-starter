import 'dart:math';

import 'package:key_starter/core/enums/note_state.dart';

/// Durée de l'effet sur une note de portée qui vient d'être jugée.
const noteFeedbackDuration = Duration(milliseconds: 400);

/// Délai avant la note suivante dans les exercices sans tempo ; l'effet y
/// est joué sur cette même durée pour ne pas être coupé.
const noteAdvanceDelay = Duration(milliseconds: 150);

const _swellScaleGain = 0.3;
const _shakeAmplitude = 12.0;
const _shakeOscillations = 3;

/// Échelle de la note à [progress] (0 à 1) de l'effet : une note juste gonfle
/// jusqu'à ×1,3 puis revient, les autres gardent leur taille.
double noteFeedbackScale(NoteState noteState, double progress) {
  if (noteState != NoteState.correct) return 1;
  return 1 + sin(progress * pi) * _swellScaleGain;
}

/// Décalage horizontal de la note à [progress] (0 à 1) de l'effet : une note
/// fausse tremble de moins en moins, les autres restent en place.
double noteFeedbackShift(NoteState noteState, double progress) {
  if (noteState != NoteState.wrong || progress == 1) return 0;
  return sin(progress * pi * 2 * _shakeOscillations) *
      _shakeAmplitude *
      (1 - progress);
}
