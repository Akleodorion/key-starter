import 'package:dartz/dartz.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/song_practice/domain/entities/bundled_song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';

/// Accès aux morceaux à travailler.
///
/// Contrat : [loadSong] renvoie le morceau lu, ou un [Failure] —
/// [UnsupportedSongFailure] (avec sa raison) si la partition contient un
/// élément pas encore pris en charge, [SongFileFailure] si le fichier est
/// illisible.
///
/// ```dart
/// final result = await repository.loadSong(odeToJoy);
/// result.fold((failure) => ..., (song) => ...);
/// ```
///
/// Voir aussi : [SongRepositoryImpl]
abstract class SongRepository {
  /// Morceau correspondant à [bundledSong].
  Future<Either<Failure, Song>> loadSong(BundledSong bundledSong);
}
