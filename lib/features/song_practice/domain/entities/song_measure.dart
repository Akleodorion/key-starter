import 'package:equatable/equatable.dart';

/// Une mesure d'un morceau : son numéro, son début (depuis le début du
/// morceau) et sa durée, en divisions de noire.
class SongMeasure extends Equatable {
  final int number;
  final int startDivisions;
  final int durationDivisions;

  const SongMeasure({
    required this.number,
    required this.startDivisions,
    required this.durationDivisions,
  });

  @override
  List<Object?> get props => [number, startDivisions, durationDivisions];
}
