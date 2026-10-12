import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/features/chord_chart/data/datasources/chord_chart_asset_datasource.dart';

/// [AssetBundle] qui sert le texte fourni pour chaque chemin.
class _InMemoryAssetBundle extends CachingAssetBundle {
  final Map<String, String> textByPath;

  _InMemoryAssetBundle(this.textByPath);

  @override
  Future<ByteData> load(String key) async {
    final text = textByPath[key];
    if (text == null) throw StateError('Asset absent : $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(text)));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChordChartAssetDataSourceImpl', () {
    group('listChordChartAssetPaths', () {
      test(
        'garde les .txt des grilles livrées et des grilles locales',
        () async {
          //arrange
          final sut = ChordChartAssetDataSourceImpl(
            listAllAssetPaths: () async => [
              'assets/fonts/Bravura.otf',
              'assets/songs/ode_to_joy.mxl',
              'assets/grids/c_g_am_f.txt',
              'assets/grids/local/.gitkeep',
              'assets/grids/local/let_it_be.txt',
            ],
          );

          //act
          final paths = await sut.listChordChartAssetPaths();

          //assert
          expect(paths, [
            'assets/grids/c_g_am_f.txt',
            'assets/grids/local/let_it_be.txt',
          ]);
        },
      );

      test(
        'trouve la grille de démonstration dans les assets de l\'app',
        () async {
          //arrange
          final sut = ChordChartAssetDataSourceImpl();

          //act
          final paths = await sut.listChordChartAssetPaths();

          //assert
          expect(paths, contains('assets/grids/c_g_am_f.txt'));
        },
      );
    });

    group('loadChordChartText', () {
      test('renvoie le texte du fichier', () async {
        //arrange
        final sut = ChordChartAssetDataSourceImpl(
          bundle: _InMemoryAssetBundle({
            'assets/grids/essai.txt': 'titre: Essai\nmesure: 4\n|C |\n',
          }),
        );

        //act
        final text = await sut.loadChordChartText('assets/grids/essai.txt');

        //assert
        expect(text, 'titre: Essai\nmesure: 4\n|C |\n');
      });

      test(
        'lève ChordChartFileException quand le fichier est absent',
        () async {
          //arrange
          final sut = ChordChartAssetDataSourceImpl(
            bundle: _InMemoryAssetBundle({}),
          );

          //act
          //assert
          await expectLater(
            sut.loadChordChartText('assets/grids/absente.txt'),
            throwsA(isA<ChordChartFileException>()),
          );
        },
      );
    });
  });
}
