import 'package:equatable/equatable.dart';

/// Un événement deux portées : le groupe de notes écrit en clé de sol (main
/// droite) et celui écrit en clé de fa (main gauche), à jouer ensemble.
/// Chaque groupe contient de 0 à n degrés diatoniques (step 0 = Do 4).
class TwoStaffEvent extends Equatable {
  final List<int> trebleSteps;
  final List<int> bassSteps;

  const TwoStaffEvent({required this.trebleSteps, required this.bassSteps});

  @override
  List<Object?> get props => [trebleSteps, bassSteps];
}
