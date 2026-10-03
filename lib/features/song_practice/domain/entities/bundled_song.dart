import 'package:equatable/equatable.dart';

/// Un morceau livré avec l'app : son titre affiché (celui de sa partition)
/// et le fichier `.mxl` de sa partition dans les assets.
class BundledSong extends Equatable {
  final String title;
  final String assetPath;

  const BundledSong({required this.title, required this.assetPath});

  @override
  List<Object?> get props => [title, assetPath];
}
