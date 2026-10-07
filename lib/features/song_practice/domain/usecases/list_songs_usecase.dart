import 'package:dartz/dartz.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/song_practice/domain/entities/bundled_song.dart';
import 'package:key_starter/features/song_practice/domain/repositories/song_repository.dart';

/// Liste les morceaux livrés avec l'app, triés par titre.
///
/// Contrat : renvoie la liste ou le [Failure] de [SongRepository.listSongs].
///
/// ```dart
/// final result = await ListSongsUseCase(repository: repository)();
/// ```
///
/// Voir aussi : [SongRepository]
class ListSongsUseCase {
  final SongRepository repository;

  ListSongsUseCase({required this.repository});

  Future<Either<Failure, List<BundledSong>>> call() => repository.listSongs();
}
