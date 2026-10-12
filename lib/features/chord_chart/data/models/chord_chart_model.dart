import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/features/chord_chart/domain/entities/accidental.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart_bar.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart_cell.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_quality.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_symbol.dart';
import 'package:key_starter/features/chord_chart/domain/entities/note_letter.dart';
import 'package:key_starter/features/chord_chart/domain/entities/spelled_note.dart';

/// Grille lue depuis son fichier texte.
class ChordChartModel extends ChordChart {
  static const _supportedBeatsPerBar = 4;
  static const _letters = {
    'C': NoteLetter.c,
    'D': NoteLetter.d,
    'E': NoteLetter.e,
    'F': NoteLetter.f,
    'G': NoteLetter.g,
    'A': NoteLetter.a,
    'B': NoteLetter.b,
  };
  static const _accidentals = {
    '': Accidental.natural,
    '#': Accidental.sharp,
    '♯': Accidental.sharp,
    'b': Accidental.flat,
    '♭': Accidental.flat,
  };
  static const _qualities = {
    '': ChordQuality.major,
    'm': ChordQuality.minor,
    '7': ChordQuality.dominantSeventh,
    'm7': ChordQuality.minorSeventh,
    'maj7': ChordQuality.majorSeventh,
    'sus2': ChordQuality.suspendedSecond,
    'sus4': ChordQuality.suspendedFourth,
  };
  static final _chordPattern = RegExp(
    r'^(?<rootLetter>[A-G])(?<rootAccidental>[#♯b♭]?)'
    r'(?<quality>maj7|m7|m|7|sus2|sus4|)'
    r'(?:\((?<inversion>[12])\))?'
    r'(?:/(?<bassLetter>[A-G])(?<bassAccidental>[#♯b♭]?))?$',
  );

  const ChordChartModel({
    required super.title,
    required super.beatsPerBar,
    required super.bars,
  });

  /// Lit [text] ; [fallbackTitle] sert si le fichier n'a pas de `titre:`.
  /// Lève [UnsupportedChordChartException] avec sa raison pour tout ce que
  /// le lecteur ne sait pas encore lire.
  factory ChordChartModel.fromText(
    String text, {
    required String fallbackTitle,
  }) {
    String? title;
    int? beatsPerBar;
    final barChords = <ChordSymbol>[];
    for (final rawLine in text.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      final titleValue = _headerValue(line, 'titre');
      final beatsValue = _headerValue(line, 'mesure');
      if (titleValue != null) {
        title = titleValue;
      } else if (beatsValue != null) {
        beatsPerBar = _readBeatsPerBar(beatsValue);
      } else if (line.startsWith('|')) {
        barChords.addAll(_readBarLine(line));
      } else {
        throw UnsupportedChordChartException('Ligne illisible : « $line ».');
      }
    }
    if (beatsPerBar == null) {
      throw const UnsupportedChordChartException(
        'La grille doit indiquer sa mesure (« mesure: 4 »).',
      );
    }
    if (barChords.isEmpty) {
      throw const UnsupportedChordChartException(
        'La grille ne contient aucune mesure.',
      );
    }
    return ChordChartModel(
      title: title ?? fallbackTitle,
      beatsPerBar: beatsPerBar,
      bars: [
        for (final chord in barChords)
          ChordChartBar(
            cells: [ChordChartCell(chord: chord, beats: beatsPerBar)],
          ),
      ],
    );
  }

  /// Titre écrit dans [text], ou `null` s'il n'en a pas.
  static String? titleFromText(String text) {
    for (final rawLine in text.split('\n')) {
      final title = _headerValue(rawLine.trim(), 'titre');
      if (title != null) return title;
    }
    return null;
  }

  static String? _headerValue(String line, String name) =>
      RegExp('^$name\\s*:(.*)\$').firstMatch(line)?.group(1)!.trim();

  static int _readBeatsPerBar(String value) {
    if (int.tryParse(value) != _supportedBeatsPerBar) {
      throw UnsupportedChordChartException(
        'Seules les mesures à 4 temps sont prises en charge '
        '(« mesure: $value »).',
      );
    }
    return _supportedBeatsPerBar;
  }

  /// Un accord par mesure de la ligne `|C |G |Am |F |`.
  static List<ChordSymbol> _readBarLine(String line) => [
    for (final bar in line.split('|').map((bar) => bar.trim()))
      if (bar.isNotEmpty) _readBar(bar),
  ];

  static ChordSymbol _readBar(String bar) {
    final symbols = bar.split(RegExp(r'\s+'));
    if (symbols.length > 1) {
      throw UnsupportedChordChartException(
        'Un seul accord par mesure pour l\'instant (« |$bar| »).',
      );
    }
    return _readChord(symbols.single);
  }

  static ChordSymbol _readChord(String symbol) {
    final match = _chordPattern.firstMatch(symbol);
    if (match == null) {
      throw UnsupportedChordChartException('Accord inconnu : $symbol.');
    }
    final inversion = match.namedGroup('inversion');
    final bassLetter = match.namedGroup('bassLetter');
    if (inversion != null && bassLetter != null) {
      throw UnsupportedChordChartException(
        'Un accord ne peut pas être à la fois renversé et à basse imposée '
        '(« $symbol »).',
      );
    }
    return ChordSymbol(
      root: _spelledNote(
        match.namedGroup('rootLetter')!,
        match.namedGroup('rootAccidental')!,
      ),
      quality: _qualities[match.namedGroup('quality')]!,
      inversion: inversion == null ? null : int.parse(inversion),
      bass: bassLetter == null
          ? null
          : _spelledNote(bassLetter, match.namedGroup('bassAccidental')!),
    );
  }

  static SpelledNote _spelledNote(String letter, String accidental) =>
      SpelledNote(_letters[letter]!, _accidentals[accidental]!);
}
