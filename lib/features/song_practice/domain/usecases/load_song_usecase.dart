import 'package:dartz/dartz.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/song_practice/domain/entities/bundled_song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/repositories/song_repository.dart';

/// Charge un morceau livré avec l'app, prêt à être joué.
///
/// Contrat : renvoie le [Song] ou le [Failure] de [SongRepository.loadSong].
///
/// ```dart
/// final result = await LoadSongUseCase(repository: repository)(bundledSong);
/// ```
///
/// Voir aussi : [SongRepository]
class LoadSongUseCase {
  final SongRepository repository;

  LoadSongUseCase({required this.repository});

  Future<Either<Failure, Song>> call(BundledSong bundledSong) =>
      repository.loadSong(bundledSong);
}
