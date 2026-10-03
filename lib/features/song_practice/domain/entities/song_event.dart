import 'package:equatable/equatable.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/features/song_practice/domain/entities/staff_notation.dart';

/// Un moment d'un morceau : les notes de chaque portée qui commencent à
/// [onsetDivisions] (compté depuis le début du morceau, en divisions de
/// noire), dans la mesure [measureNumber]. Les durées écrites de chaque
/// groupe sont conservées (0 pour une portée qui n'attaque rien), ainsi que
/// leur notation (null pour une portée qui n'attaque rien).
class SongEvent extends Equatable {
  final int measureNumber;
  final int onsetDivisions;
  final TwoStaffEvent notes;
  final int trebleDurationDivisions;
  final int bassDurationDivisions;
  final StaffNotation? trebleNotation;
  final StaffNotation? bassNotation;

  const SongEvent({
    required this.measureNumber,
    required this.onsetDivisions,
    required this.notes,
    this.trebleDurationDivisions = 0,
    this.bassDurationDivisions = 0,
    this.trebleNotation,
    this.bassNotation,
  });

  @override
  List<Object?> get props => [
    measureNumber,
    onsetDivisions,
    notes,
    trebleDurationDivisions,
    bassDurationDivisions,
    trebleNotation,
    bassNotation,
  ];
}
