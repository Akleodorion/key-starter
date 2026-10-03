import 'dart:math';

import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/utils/staff_paint_utils.dart';
import 'package:key_starter/features/song_practice/domain/entities/note_value.dart';
import 'package:key_starter/features/song_practice/domain/entities/staff_notation.dart';
import 'package:key_starter/features/song_practice/presentation/layout/beam_groups.dart';
import 'package:key_starter/features/song_practice/presentation/layout/score_line_note.dart';
import 'package:key_starter/features/song_practice/presentation/layout/score_line_rest.dart';
import 'package:key_starter/features/song_practice/presentation/painting/song_glyphs.dart';

/// Épaisseur d'une hampe, en interlignes.
const _stemThickness = 0.12;

/// Longueur ordinaire d'une hampe depuis la note la plus éloignée, en
/// interlignes.
const _stemLength = 3.5;

/// Écart entre deux barres de ligature (ou deux crochets), en interlignes.
const beamSpacing = 0.75;

/// Épaisseur d'une barre de ligature, en interlignes.
const beamThickness = 0.5;

/// Longueur d'une demi-barre de ligature, en interlignes.
const _beamHookLength = 1.1;

/// Où et comment dessiner la hampe d'un groupe de notes.
class StemPlacement {
  final double x;
  final double fromY;
  final double toY;

  const StemPlacement({
    required this.x,
    required this.fromY,
    required this.toY,
  });
}

/// Dessine [glyph] (police Bravura, 4 interlignes) avec sa ligne de base à
/// [baselineY], centré sur [centerX] ou aligné à gauche sur [leftX].
double paintGlyph(
  Canvas canvas,
  String glyph, {
  double? centerX,
  double? leftX,
  required double baselineY,
  required double lineGap,
  required Color color,
}) {
  final textPainter = _glyphPainter(glyph, lineGap: lineGap, color: color);
  final baseline = textPainter.computeDistanceToActualBaseline(
    TextBaseline.alphabetic,
  );
  final x = leftX ?? centerX! - textPainter.width / 2;
  textPainter.paint(canvas, Offset(x, baselineY - baseline));
  return textPainter.width;
}

/// Largeur de [glyph] dessiné à la taille de [lineGap].
double glyphWidth(String glyph, {required double lineGap}) =>
    _glyphPainter(glyph, lineGap: lineGap, color: Colors.black).width;

TextPainter _glyphPainter(
  String glyph, {
  required double lineGap,
  required Color color,
}) => TextPainter(
  text: TextSpan(
    text: glyph,
    style: TextStyle(
      fontFamily: 'Bravura',
      fontSize: lineGap * 4,
      height: 1,
      color: color,
    ),
  ),
  textDirection: TextDirection.ltr,
)..layout();

/// Sens de hampe par défaut d'un groupe de degrés : vers le bas si la note
/// la plus éloignée du milieu de la portée est au-dessus.
bool defaultStemUp(Iterable<int> steps, ClefMode clef) {
  final middleStep = staffBottomStep[clef]! + 4;
  final maxStep = steps.reduce(max);
  final minStep = steps.reduce(min);
  return (maxStep - middleStep) < (middleStep - minStep);
}

/// Hampe ordinaire d'un groupe de notes dessiné à [noteX] : partie de la
/// note la plus proche de son extrémité, longue de 3,5 interlignes depuis la
/// plus éloignée, allongée pour loger plus de deux crochets ou barres.
StemPlacement defaultStem({
  required double noteX,
  required List<int> steps,
  required NoteType noteType,
  required bool stemUp,
  required ClefMode clef,
  required double staffTop,
  required double lineGap,
}) {
  final headHalfWidth =
      glyphWidth(noteHeadGlyph(noteType), lineGap: lineGap) / 2;
  double yOf(int step) =>
      staffYFor(step, clef: clef, staffTop: staffTop, lineGap: lineGap);
  final length =
      (_stemLength + max(0, noteType.flagCount - 2) * beamSpacing) * lineGap;
  final halfThickness = _stemThickness * lineGap / 2;
  return stemUp
      ? StemPlacement(
          x: noteX + headHalfWidth - halfThickness,
          fromY: yOf(steps.reduce(min)),
          toY: yOf(steps.reduce(max)) - length,
        )
      : StemPlacement(
          x: noteX - headHalfWidth + halfThickness,
          fromY: yOf(steps.reduce(max)),
          toY: yOf(steps.reduce(min)) + length,
        );
}

/// Dessine un groupe de notes de valeur [value] empilées à [noteX] : lignes
/// supplémentaires, têtes, points, et, à partir de la blanche, la hampe
/// [stem] avec ses crochets si [drawFlags].
void paintSongChord(
  Canvas canvas, {
  required double noteX,
  required List<int> steps,
  required NoteValue value,
  required StemPlacement? stem,
  required bool stemUp,
  required bool drawFlags,
  required ClefMode clef,
  required double staffTop,
  required double lineGap,
  required Color color,
}) {
  if (steps.isEmpty) return;
  final headGlyph = noteHeadGlyph(value.type);
  final headWidth = glyphWidth(headGlyph, lineGap: lineGap);
  final bottomStep = staffBottomStep[clef]!;
  double yOf(int step) =>
      staffYFor(step, clef: clef, staffTop: staffTop, lineGap: lineGap);

  final ledgerPaint = Paint()
    ..color = color
    ..strokeWidth = lineGap * 0.12;
  final ledgerHalfWidth = headWidth / 2 + lineGap * 0.4;
  for (var step = bottomStep + 10; step <= steps.reduce(max); step += 2) {
    canvas.drawLine(
      Offset(noteX - ledgerHalfWidth, yOf(step)),
      Offset(noteX + ledgerHalfWidth, yOf(step)),
      ledgerPaint,
    );
  }
  for (var step = bottomStep - 2; step >= steps.reduce(min); step -= 2) {
    canvas.drawLine(
      Offset(noteX - ledgerHalfWidth, yOf(step)),
      Offset(noteX + ledgerHalfWidth, yOf(step)),
      ledgerPaint,
    );
  }

  for (final step in steps) {
    paintGlyph(
      canvas,
      headGlyph,
      centerX: noteX,
      baselineY: yOf(step),
      lineGap: lineGap,
      color: color,
    );
    final isOnLine = (step - bottomStep).isEven;
    _paintDots(
      canvas,
      count: value.dotCount,
      leftX: noteX + headWidth / 2 + lineGap * 0.35,
      y: yOf(step) - (isOnLine ? lineGap / 2 : 0),
      lineGap: lineGap,
      color: color,
    );
  }

  if (stem == null || !value.type.hasStem) return;
  canvas.drawLine(
    Offset(stem.x, stem.fromY),
    Offset(stem.x, stem.toY),
    Paint()
      ..color = color
      ..strokeWidth = _stemThickness * lineGap,
  );
  final flag = drawFlags ? flagGlyph(value.type, stemUp: stemUp) : null;
  if (flag != null) {
    paintGlyph(
      canvas,
      flag,
      leftX: stem.x - _stemThickness * lineGap / 2,
      baselineY: stem.toY,
      lineGap: lineGap,
      color: color,
    );
  }
}

/// Dessine un silence de valeur [value] centré sur [centerX] ; null pour un
/// silence de mesure entière, dessiné comme une pause.
void paintSongRest(
  Canvas canvas, {
  required double centerX,
  required NoteValue? value,
  required double staffTop,
  required double lineGap,
  required Color color,
}) {
  final noteType = value?.type ?? NoteType.whole;
  final baselineLine = restBaselineLine(noteType);
  final width = paintGlyph(
    canvas,
    restGlyph(noteType),
    centerX: centerX,
    baselineY: staffTop + (5 - baselineLine) * lineGap,
    lineGap: lineGap,
    color: color,
  );
  _paintDots(
    canvas,
    count: value?.dotCount ?? 0,
    leftX: centerX + width / 2 + lineGap * 0.35,
    y: staffTop + lineGap * 1.5,
    lineGap: lineGap,
    color: color,
  );
}

void _paintDots(
  Canvas canvas, {
  required int count,
  required double leftX,
  required double y,
  required double lineGap,
  required Color color,
}) {
  for (var dot = 0; dot < count; dot++) {
    paintGlyph(
      canvas,
      augmentationDotGlyph,
      leftX: leftX + dot * lineGap * 0.5,
      baselineY: y,
      lineGap: lineGap,
      color: color,
    );
  }
}

/// Dessine une barre de ligature du niveau [level] entre deux hampes, sur la
/// droite qui passe par ([fromX], [fromY]) et ([toX], [toY]) — l'extrémité
/// des hampes, où se pose la barre du premier niveau. Les niveaux suivants
/// se rapprochent des notes.
void paintBeam(
  Canvas canvas, {
  required double fromX,
  required double fromY,
  required double toX,
  required double toY,
  required int level,
  required bool stemUp,
  required double lineGap,
  required Color color,
}) {
  final towardNotes = stemUp ? 1 : -1;
  final offset = (level - 1) * beamSpacing * lineGap * towardNotes;
  final thickness = beamThickness * lineGap * towardNotes;
  canvas.drawPath(
    Path()
      ..moveTo(fromX, fromY + offset)
      ..lineTo(toX, toY + offset)
      ..lineTo(toX, toY + offset + thickness)
      ..lineTo(fromX, fromY + offset + thickness)
      ..close(),
    Paint()..color = color,
  );
}

/// Longueur horizontale d'une demi-barre de ligature.
double beamHookLength(double lineGap) => _beamHookLength * lineGap;

/// Dessine les figures d'une portée sur une ligne : chaque groupe de notes
/// (avec sa hampe, ses crochets ou ses barres de ligature) et chaque
/// silence. [noteX] convertit une position de la ligne en abscisse ;
/// [colorFor] donne la couleur d'un état ; [restColor] celle des silences.
/// La note à [currentPosition] est grossie de [eventScale] et décalée de
/// [eventShift] autour de [centerY].
void paintStaffFigures(
  Canvas canvas, {
  required List<ScoreLineNote> notes,
  required List<ScoreLineRest> rests,
  required bool isBass,
  required double staffTop,
  required double lineGap,
  required double Function(double position) noteX,
  required Color Function(NoteState state) colorFor,
  required Color restColor,
  required double? currentPosition,
  required double eventScale,
  required double eventShift,
  required double centerY,
}) {
  final clef = isBass ? ClefMode.bass : ClefMode.treble;
  List<int> stepsOf(ScoreLineNote note) =>
      isBass ? note.bassSteps : note.trebleSteps;
  NoteState stateOf(ScoreLineNote note) =>
      isBass ? note.bassState : note.trebleState;
  final notations = [
    for (final note in notes)
      if (stepsOf(note).isEmpty)
        null
      else
        (isBass ? note.bassNotation : note.trebleNotation) ??
            const StaffNotation(value: NoteValue(NoteType.quarter)),
  ];

  final beamedStems = <int, ({StemPlacement stem, bool stemUp})>{};
  final beamLines = <BeamGroup, ({bool stemUp, double Function(double) yAt})>{};
  for (final group in beamGroupsOf(notations)) {
    final members = group.memberIndices;
    final writtenDirection = notations[members.first]!.stemDirection;
    final stemUp = writtenDirection == null
        ? defaultStemUp(members.expand((index) => stepsOf(notes[index])), clef)
        : writtenDirection == StemDirection.up;
    final defaultStems = [
      for (final index in members)
        defaultStem(
          noteX: noteX(notes[index].position),
          steps: stepsOf(notes[index]),
          noteType: notations[index]!.value.type,
          stemUp: stemUp,
          clef: clef,
          staffTop: staffTop,
          lineGap: lineGap,
        ),
    ];
    final first = defaultStems.first;
    final last = defaultStems.last;
    final maximumRise = lineGap / 2;
    final rise = (last.toY - first.toY).clamp(-maximumRise, maximumRise);
    final slope = last.x == first.x ? 0.0 : rise / (last.x - first.x);
    double lineAt(double x) => first.toY + slope * (x - first.x);
    // Décale la barre jusqu'à ce que la hampe la plus courte ait sa longueur
    // ordinaire : aucune hampe n'est alors plus courte.
    final shift = stemUp
        ? defaultStems.map((stem) => lineAt(stem.x) - stem.toY).reduce(max)
        : defaultStems.map((stem) => stem.toY - lineAt(stem.x)).reduce(max);
    double yAt(double x) => lineAt(x) + (stemUp ? -shift : shift);
    beamLines[group] = (stemUp: stemUp, yAt: yAt);
    for (final (member, index) in members.indexed) {
      final stem = defaultStems[member];
      beamedStems[index] = (
        stem: StemPlacement(x: stem.x, fromY: stem.fromY, toY: yAt(stem.x)),
        stemUp: stemUp,
      );
    }
  }

  for (final (index, note) in notes.indexed) {
    final notation = notations[index];
    if (notation == null) continue;
    final x = noteX(note.position);
    final beamed = beamedStems[index];
    final stemUp =
        beamed?.stemUp ??
        (notation.stemDirection == null
            ? defaultStemUp(stepsOf(note), clef)
            : notation.stemDirection == StemDirection.up);
    final isCurrent = note.position == currentPosition;
    canvas.save();
    if (isCurrent) {
      canvas.translate(x + eventShift, centerY);
      canvas.scale(eventScale);
      canvas.translate(-x, -centerY);
    }
    paintSongChord(
      canvas,
      noteX: x,
      steps: stepsOf(note),
      value: notation.value,
      stem:
          beamed?.stem ??
          defaultStem(
            noteX: x,
            steps: stepsOf(note),
            noteType: notation.value.type,
            stemUp: stemUp,
            clef: clef,
            staffTop: staffTop,
            lineGap: lineGap,
          ),
      stemUp: stemUp,
      drawFlags: beamed == null,
      clef: clef,
      staffTop: staffTop,
      lineGap: lineGap,
      color: colorFor(stateOf(note)),
    );
    canvas.restore();
  }

  for (final MapEntry(key: group, value: beamLine) in beamLines.entries) {
    final memberStates = group.memberIndices
        .map((index) => stateOf(notes[index]))
        .toSet();
    final color = colorFor(
      memberStates.length == 1 ? memberStates.single : NoteState.idle,
    );
    double stemXOf(int member) =>
        beamedStems[group.memberIndices[member]]!.stem.x;
    for (final segment in group.segments) {
      final fromX = stemXOf(segment.fromMember);
      final toX = stemXOf(segment.toMember);
      paintBeam(
        canvas,
        fromX: fromX,
        fromY: beamLine.yAt(fromX),
        toX: toX,
        toY: beamLine.yAt(toX),
        level: segment.level,
        stemUp: beamLine.stemUp,
        lineGap: lineGap,
        color: color,
      );
    }
    for (final hook in group.hooks) {
      final stemX = stemXOf(hook.member);
      final endX =
          stemX + beamHookLength(lineGap) * (hook.pointsForward ? 1 : -1);
      paintBeam(
        canvas,
        fromX: stemX,
        fromY: beamLine.yAt(stemX),
        toX: endX,
        toY: beamLine.yAt(endX),
        level: hook.level,
        stemUp: beamLine.stemUp,
        lineGap: lineGap,
        color: color,
      );
    }
  }

  for (final rest in rests) {
    if (rest.isBass != isBass) continue;
    paintSongRest(
      canvas,
      centerX: noteX(rest.position),
      value: rest.value,
      staffTop: staffTop,
      lineGap: lineGap,
      color: restColor,
    );
  }
}
