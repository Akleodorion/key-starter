import 'package:dartz/dartz.dart';
import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/song_practice/data/datasources/song_asset_datasource.dart';
import 'package:key_starter/features/song_practice/data/models/song_model.dart';
import 'package:key_starter/features/song_practice/domain/entities/bundled_song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/repositories/song_repository.dart';
import 'package:xml/xml.dart';

/// Implémentation de [SongRepository] qui lit les partitions des assets.
class SongRepositoryImpl implements SongRepository {
  final SongAssetDataSource dataSource;

  SongRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<BundledSong>>> listSongs() async {
    final songs = [
      for (final assetPath in await dataSource.listSongAssetPaths())
        BundledSong(
          title: await _titleOf(assetPath) ?? _titleFromFileName(assetPath),
          assetPath: assetPath,
        ),
    ]..sort((first, second) => first.title.compareTo(second.title));
    return Right(songs);
  }

  @override
  Future<Either<Failure, Song>> loadSong(BundledSong bundledSong) async {
    try {
      final xml = await dataSource.loadMusicXml(bundledSong.assetPath);
      return Right(
        SongModel.fromMusicXml(xml, fallbackTitle: bundledSong.title),
      );
    } on UnsupportedSongException catch (exception) {
      return Left(UnsupportedSongFailure(exception.reason));
    } on SongFileException {
      return const Left(SongFileFailure());
    } on XmlException {
      return const Left(SongFileFailure());
    }
  }

  Future<String?> _titleOf(String assetPath) async {
    try {
      return SongModel.titleFromMusicXml(
        await dataSource.loadMusicXml(assetPath),
      );
    } on SongFileException {
      return null;
    } on XmlException {
      return null;
    }
  }

  /// `assets/songs/sans_titre.mxl` → « Sans titre ».
  String _titleFromFileName(String assetPath) {
    final words = assetPath
        .split('/')
        .last
        .replaceAll(RegExp(r'\.mxl$'), '')
        .replaceAll('_', ' ');
    return words.isEmpty ? words : words[0].toUpperCase() + words.substring(1);
  }
}
