import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/features/song_practice/data/datasources/song_asset_datasource.dart';

/// [AssetBundle] qui sert les octets fournis pour chaque chemin.
class _InMemoryAssetBundle extends CachingAssetBundle {
  final Map<String, List<int>> bytesByPath;

  _InMemoryAssetBundle(this.bytesByPath);

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(bytesByPath[key]!));
}

void main() {
  const assetPath = 'assets/songs/essai.mxl';

  group('SongAssetDataSourceImpl', () {
    group('loadMusicXml', () {
      test(
        'renvoie la partition désignée par le container d\'un fichier .mxl',
        () async {
          //arrange
          final archive = Archive()
            ..addFile(
              ArchiveFile.string(
                'META-INF/container.xml',
                '<container><rootfiles>'
                    '<rootfile full-path="score.xml" media-type="application/vnd.recordare.musicxml+xml"/>'
                    '</rootfiles></container>',
              ),
            )
            ..addFile(ArchiveFile.string('score.xml', '<score-partwise/>'));
          final sut = SongAssetDataSourceImpl(
            bundle: _InMemoryAssetBundle({
              assetPath: ZipEncoder().encodeBytes(archive),
            }),
          );

          //act
          final xml = await sut.loadMusicXml(assetPath);

          //assert
          expect(xml, '<score-partwise/>');
        },
      );

      test('lève SongFileException si le fichier n\'est pas un .mxl', () async {
        //arrange
        final sut = SongAssetDataSourceImpl(
          bundle: _InMemoryAssetBundle({
            assetPath: utf8.encode('pas une archive'),
          }),
        );

        //act
        //assert
        await expectLater(
          sut.loadMusicXml(assetPath),
          throwsA(isA<SongFileException>()),
        );
      });
    });
  });
}
