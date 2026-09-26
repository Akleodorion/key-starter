import 'package:equatable/equatable.dart';

/// Écart moyen au temps d'un exercice rythmique : négatif en avance, positif
/// en retard, null quand aucune note n'a été jouée juste.
class TimingOffset extends Equatable {
  final int? averageMs;

  const TimingOffset({required this.averageMs});

  @override
  List<Object?> get props => [averageMs];
}
