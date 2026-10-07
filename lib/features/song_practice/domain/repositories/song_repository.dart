import 'package:dartz/dartz.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/song_practice/domain/entities/bundled_song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';

/// Accès aux morceaux à travailler.
///
/// Contrat : [listSongs] renvoie les morceaux livrés avec l'app, triés par
/// titre ; [loadSong] renvoie le morceau lu, ou un [Failure] —
/// [UnsupportedSongFailure] (avec sa raison) si la partition contient un
/// élément pas encore pris en charge, [SongFileFailure] si le fichier est
/// illisible.
///
/// ```dart
/// final songs = await repository.listSongs();
/// final result = await repository.loadSong(bundledSong);
/// result.fold((failure) => ..., (song) => ...);
/// ```
///
/// Voir aussi : [SongRepositoryImpl]
abstract class SongRepository {
  /// Morceaux livrés, chacun sous le titre de sa partition.
  Future<Either<Failure, List<BundledSong>>> listSongs();

  /// Morceau correspondant à [bundledSong].
  Future<Either<Failure, Song>> loadSong(BundledSong bundledSong);
}
