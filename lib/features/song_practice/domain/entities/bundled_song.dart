import 'package:equatable/equatable.dart';

/// Un morceau livré avec l'app : son titre affiché et le fichier `.mxl` de
/// sa partition dans les assets.
class BundledSong extends Equatable {
  final String title;
  final String assetPath;

  const BundledSong({required this.title, required this.assetPath});

  @override
  List<Object?> get props => [title, assetPath];
}

const odeToJoy = BundledSong(
  title: 'Ode à la joie',
  assetPath: 'assets/songs/ode_to_joy.mxl',
);
