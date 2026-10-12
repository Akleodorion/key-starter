import 'package:equatable/equatable.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_symbol.dart';

/// Une case de grille : un accord et sa durée en temps.
class ChordChartCell extends Equatable {
  final ChordSymbol chord;
  final int beats;

  const ChordChartCell({required this.chord, required this.beats});

  @override
  List<Object?> get props => [chord, beats];
}
