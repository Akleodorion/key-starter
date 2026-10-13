import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart_bar.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart_cell.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_quality.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_symbol.dart';

/// Grille lue depuis son fichier texte.
class ChordChartModel extends ChordChart {
  static const _supportedBeatsPerBar = {3, 4};
  static const _rootPitchClasses = {
    'C': 0,
    'D': 2,
    'E': 4,
    'F': 5,
    'G': 7,
    'A': 9,
    'B': 11,
  };
  static const _holdSymbol = '.';
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
    final barTexts = <String>[];
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
        barTexts.addAll(_splitBarLine(line));
      } else {
        throw UnsupportedChordChartException('Ligne illisible : « $line ».');
      }
    }
    if (beatsPerBar == null) {
      throw const UnsupportedChordChartException(
        'La grille doit indiquer sa mesure (« mesure: 4 »).',
      );
    }
    if (barTexts.isEmpty) {
      throw const UnsupportedChordChartException(
        'La grille ne contient aucune mesure.',
      );
    }
    return ChordChartModel(
      title: title ?? fallbackTitle,
      beatsPerBar: beatsPerBar,
      bars: [for (final bar in barTexts) _readBar(bar, beatsPerBar)],
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
    final beatsPerBar = int.tryParse(value);
    if (beatsPerBar == null || !_supportedBeatsPerBar.contains(beatsPerBar)) {
      throw UnsupportedChordChartException(
        'Seules les mesures à 3 ou 4 temps sont prises en charge '
        '(« mesure: $value »).',
      );
    }
    return beatsPerBar;
  }

  /// Texte de chaque mesure de la ligne `|C |G |Am |F |`.
  static List<String> _splitBarLine(String line) => [
    for (final bar in line.split('|').map((bar) => bar.trim()))
      if (bar.isNotEmpty) bar,
  ];

  /// 1 accord = toute la mesure ; 2 accords = moitié-moitié ; sinon un jeton
  /// par temps, `.` prolongeant l'accord précédent.
  static ChordChartBar _readBar(String bar, int beatsPerBar) {
    final symbols = bar.split(RegExp(r'\s+'));
    if (symbols.first == _holdSymbol) {
      throw UnsupportedChordChartException(
        'Une mesure ne peut pas commencer par « . » : il prolonge '
        'l\'accord précédent de la même mesure (« |$bar| »).',
      );
    }
    if (symbols.length == 1) {
      return ChordChartBar(
        cells: [
          ChordChartCell(chord: _readChord(symbols.single), beats: beatsPerBar),
        ],
      );
    }
    if (symbols.length == 2 && !symbols.contains(_holdSymbol)) {
      if (beatsPerBar.isOdd) {
        final [first, second] = symbols;
        throw UnsupportedChordChartException(
          'Deux accords ne se partagent pas une mesure à $beatsPerBar temps : '
          '« |$first . $second| » ou « |$first $second .| » '
          'au lieu de « |$bar| ».',
        );
      }
      return ChordChartBar(
        cells: [
          for (final symbol in symbols)
            ChordChartCell(chord: _readChord(symbol), beats: beatsPerBar ~/ 2),
        ],
      );
    }
    if (symbols.length != beatsPerBar) {
      throw UnsupportedChordChartException(
        'La mesure « |$bar| » compte ${symbols.length} temps '
        'au lieu de $beatsPerBar : un accord ou un « . » par temps, '
        'le « . » prolongeant l\'accord précédent.',
      );
    }
    final cells = <ChordChartCell>[];
    for (final symbol in symbols) {
      if (symbol == _holdSymbol) {
        final previous = cells.removeLast();
        cells.add(
          ChordChartCell(chord: previous.chord, beats: previous.beats + 1),
        );
      } else {
        cells.add(ChordChartCell(chord: _readChord(symbol), beats: 1));
      }
    }
    return ChordChartBar(cells: cells);
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
