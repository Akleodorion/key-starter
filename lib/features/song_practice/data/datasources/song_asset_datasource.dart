import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:key_starter/core/errors/exceptions.dart';
import 'package:xml/xml.dart';

/// Lit la partition MusicXML d'un morceau livré dans les assets de l'app.
///
/// Contrat : [loadMusicXml] renvoie le texte de la partition, ou lève
/// [SongFileException] si le fichier est absent ou illisible.
///
/// ```dart
/// final xml = await dataSource.loadMusicXml('assets/songs/ode_to_joy.mxl');
/// ```
///
/// Voir aussi : [SongAssetDataSourceImpl]
abstract class SongAssetDataSource {
  /// Texte MusicXML du fichier `.mxl` situé à [assetPath].
  Future<String> loadMusicXml(String assetPath);
}

/// Implémentation de [SongAssetDataSource] qui décompresse un `.mxl`.
class SongAssetDataSourceImpl implements SongAssetDataSource {
  final AssetBundle bundle;

  SongAssetDataSourceImpl({AssetBundle? bundle})
    : bundle = bundle ?? rootBundle;

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
