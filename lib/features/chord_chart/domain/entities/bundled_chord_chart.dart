import 'package:equatable/equatable.dart';

/// Une grille livrée avec l'app : son titre affiché et son fichier texte
/// dans les assets.
class BundledChordChart extends Equatable {
  final String title;
  final String assetPath;

  const BundledChordChart({required this.title, required this.assetPath});

  @override
  List<Object?> get props => [title, assetPath];
}
