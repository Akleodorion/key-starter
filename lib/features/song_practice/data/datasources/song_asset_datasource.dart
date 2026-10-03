import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:key_starter/core/errors/exceptions.dart';
import 'package:xml/xml.dart';

/// Lit les partitions MusicXML des morceaux livrés dans les assets de l'app.
///
/// Contrat : [listSongAssetPaths] renvoie le chemin de chaque `.mxl` livré ;
/// [loadMusicXml] renvoie le texte d'une partition, ou lève
/// [SongFileException] si le fichier est absent ou illisible.
///
/// ```dart
/// final paths = await dataSource.listSongAssetPaths();
/// final xml = await dataSource.loadMusicXml(paths.first);
/// ```
///
/// Voir aussi : [SongAssetDataSourceImpl]
abstract class SongAssetDataSource {
  /// Chemins des `.mxl` de `assets/songs/`, dossier `local/` compris.
  Future<List<String>> listSongAssetPaths();

  /// Texte MusicXML du fichier `.mxl` situé à [assetPath].
  Future<String> loadMusicXml(String assetPath);
}

/// Implémentation de [SongAssetDataSource] qui lit le manifeste des assets
/// et décompresse un `.mxl`.
class SongAssetDataSourceImpl implements SongAssetDataSource {
  static const _songsFolder = 'assets/songs/';

  final AssetBundle bundle;
  final Future<List<String>> Function() listAllAssetPaths;

  SongAssetDataSourceImpl({
    AssetBundle? bundle,
    Future<List<String>> Function()? listAllAssetPaths,
  }) : bundle = bundle ?? rootBundle,
       listAllAssetPaths =
           listAllAssetPaths ??
           (() async => (await AssetManifest.loadFromAssetBundle(
             bundle ?? rootBundle,
           )).listAssets());

  @override
  Future<List<String>> listSongAssetPaths() async => [
    for (final path in await listAllAssetPaths())
      if (path.startsWith(_songsFolder) && path.endsWith('.mxl')) path,
  ];

  @override
  Future<String> loadMusicXml(String assetPath) async {
    try {
      final bytes = await bundle.load(assetPath);
      final archive = ZipDecoder().decodeBytes(bytes.buffer.asUint8List());
      final container = XmlDocument.parse(
        utf8.decode(archive.findFile('META-INF/container.xml')!.content),
      );
      final scorePath = container
          .findAllElements('rootfile')
          .first
          .getAttribute('full-path')!;
      return utf8.decode(archive.findFile(scorePath)!.content);
    } catch (_) {
      throw const SongFileException();
    }
  }
}
