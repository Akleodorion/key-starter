import 'package:equatable/equatable.dart';

/// Une plage continue de mesures travaillée d'un seul tenant, de
/// [firstMeasureNumber] à [lastMeasureNumber] incluses. Le morceau entier
/// est la section qui va de la première à la dernière mesure.
class SongSection extends Equatable {
  final int firstMeasureNumber;
  final int lastMeasureNumber;

  const SongSection({
    required this.firstMeasureNumber,
    required this.lastMeasureNumber,
  });

  bool contains(int measureNumber) =>
      measureNumber >= firstMeasureNumber && measureNumber <= lastMeasureNumber;

  @override
  List<Object?> get props => [firstMeasureNumber, lastMeasureNumber];
}
