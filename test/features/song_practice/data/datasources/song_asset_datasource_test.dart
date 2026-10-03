import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/features/song_practice/data/datasources/song_asset_datasource.dart';
import 'package:key_starter/features/song_practice/data/models/song_model.dart';
import 'package:key_starter/features/song_practice/domain/entities/note_value.dart';

/// [AssetBundle] qui sert les octets fournis pour chaque chemin.
class _InMemoryAssetBundle extends CachingAssetBundle {
  final Map<String, List<int>> bytesByPath;

  _InMemoryAssetBundle(this.bytesByPath);

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(bytesByPath[key]!));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

      test('lit le .mxl de l\'Ode à la joie livré dans les assets', () async {
        //arrange
        final sut = SongAssetDataSourceImpl();

        //act
        final xml = await sut.loadMusicXml('assets/songs/ode_to_joy.mxl');

        //assert
        final song = SongModel.fromMusicXml(xml, fallbackTitle: 'Sans titre');
        expect(song.measureCount, 16);
        expect(song.events, hasLength(62));
      });
    });

    group('démonstration Figures de notes', () {
      test(
        'contient toutes les figures, en notes et en silences, et des points',
        () async {
          //arrange
          final sut = SongAssetDataSourceImpl();

          //act
          final xml = await sut.loadMusicXml(
            'assets/songs/figures_de_notes.mxl',
          );

          //assert
          final song = SongModel.fromMusicXml(xml, fallbackTitle: 'Sans titre');
          expect(song.title, 'Figures de notes');
          expect(song.beatsPerMeasure, 4);
          expect(song.beatUnit, 2);
          final noteValues = {
            for (final event in song.events)
              if (event.trebleNotation case final notation?) notation.value,
          };
          final restValues = {for (final rest in song.rests) ?rest.value};
          expect(
            noteValues.map((value) => value.type).toSet(),
            NoteType.values.toSet(),
          );
          expect(
            restValues.map((value) => value.type).toSet(),
            NoteType.values.toSet(),
          );
          expect(noteValues.map((value) => value.dotCount).toSet(), {
            0,
            1,
            2,
            3,
          });
          expect(restValues.map((value) => value.dotCount).toSet(), {0, 1, 2});
        },
      );
    });

    group('listSongAssetPaths', () {
      test(
        'garde les .mxl des morceaux livrés et des morceaux locaux',
        () async {
          //arrange
          final sut = SongAssetDataSourceImpl(
            listAllAssetPaths: () async => [
              'assets/fonts/Bravura.otf',
              'assets/songs/ode_to_joy.mxl',
              'assets/songs/local/.gitkeep',
              'assets/songs/local/song_of_storms.mxl',
            ],
          );

          //act
          final paths = await sut.listSongAssetPaths();

          //assert
          expect(paths, [
            'assets/songs/ode_to_joy.mxl',
            'assets/songs/local/song_of_storms.mxl',
          ]);
        },
      );

      test('trouve l\'Ode à la joie dans les assets de l\'app', () async {
        //arrange
        final sut = SongAssetDataSourceImpl();

        //act
        final paths = await sut.listSongAssetPaths();

        //assert
        expect(paths, contains('assets/songs/ode_to_joy.mxl'));
      });
    });
  });
}
