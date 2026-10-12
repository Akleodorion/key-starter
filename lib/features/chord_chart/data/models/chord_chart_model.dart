import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart_bar.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart_cell.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_quality.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_symbol.dart';

/// Grille lue depuis son fichier texte.
class ChordChartModel extends ChordChart {
  static const _supportedBeatsPerBar = 4;
  static const _rootPitchClasses = {
    'C': 0,
    'D': 2,
    'E': 4,
    'F': 5,
    'G': 7,
    'A': 9,
    'B': 11,
  };
  static final _chordPattern = RegExp(r'^([A-G])(m?)$');

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
    return ChordSymbol(
      rootPitchClass: _rootPitchClasses[match.group(1)]!,
      quality: match.group(2)!.isEmpty
          ? ChordQuality.major
          : ChordQuality.minor,
    );
  }
}
