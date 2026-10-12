import 'package:flutter/services.dart';
import 'package:key_starter/core/errors/exceptions.dart';

/// Lit les fichiers texte des grilles livrées dans les assets de l'app.
///
/// Contrat : [listChordChartAssetPaths] renvoie le chemin de chaque `.txt`
/// livré ; [loadChordChartText] renvoie le texte d'une grille, ou lève
/// [ChordChartFileException] si le fichier est absent ou illisible.
///
/// ```dart
/// final paths = await dataSource.listChordChartAssetPaths();
/// final text = await dataSource.loadChordChartText(paths.first);
/// ```
///
/// Voir aussi : [ChordChartAssetDataSourceImpl]
abstract class ChordChartAssetDataSource {
  /// Chemins des `.txt` de `assets/grids/`, dossier `local/` compris.
  Future<List<String>> listChordChartAssetPaths();

  /// Texte du fichier situé à [assetPath].
  Future<String> loadChordChartText(String assetPath);
}

/// Implémentation de [ChordChartAssetDataSource] qui lit le manifeste des
/// assets.
class ChordChartAssetDataSourceImpl implements ChordChartAssetDataSource {
  static const _gridsFolder = 'assets/grids/';

  final AssetBundle bundle;
  final Future<List<String>> Function() listAllAssetPaths;

  ChordChartAssetDataSourceImpl({
    AssetBundle? bundle,
    Future<List<String>> Function()? listAllAssetPaths,
  }) : bundle = bundle ?? rootBundle,
       listAllAssetPaths =
           listAllAssetPaths ??
           (() async => (await AssetManifest.loadFromAssetBundle(
             bundle ?? rootBundle,
           )).listAssets());

  @override
  Future<List<String>> listChordChartAssetPaths() async => [
    for (final path in await listAllAssetPaths())
      if (path.startsWith(_gridsFolder) && path.endsWith('.txt')) path,
  ];

  @override
  Future<String> loadChordChartText(String assetPath) async {
    try {
      return await bundle.loadString(assetPath);
    } catch (_) {
      throw const ChordChartFileException();
    }
  }
}
