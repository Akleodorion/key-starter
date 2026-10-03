import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/song_practice/data/datasources/song_asset_datasource.dart';
import 'package:key_starter/features/song_practice/data/repositories/song_repository_impl.dart';
import 'package:key_starter/features/song_practice/domain/entities/bundled_song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'song_repository_impl_test.mocks.dart';

@GenerateMocks([SongAssetDataSource])
void main() {
  late MockSongAssetDataSource dataSource;
  late SongRepositoryImpl sut;
  const bundledSong = BundledSong(
    title: 'Ode à la joie',
    assetPath: 'assets/songs/ode_to_joy.mxl',
  );

  setUp(() {
    dataSource = MockSongAssetDataSource();
    sut = SongRepositoryImpl(dataSource: dataSource);
  });

  group('SongRepositoryImpl', () {
    group('loadSong', () {
      test('renvoie le morceau lu, sous le titre de sa partition', () async {
        //arrange
        when(dataSource.loadMusicXml(bundledSong.assetPath)).thenAnswer(
          (_) async => File(
            'test/fixtures/songs/ode_to_joy.musicxml',
          ).readAsStringSync(),
        );

        //act
        final result = await sut.loadSong(bundledSong);

        //assert
        final song = result.getOrElse(() => throw StateError('échec'));
        expect(song, isA<Song>());
        expect(song.title, 'Ode à la joie');
        expect(song.events, hasLength(62));
      });

      test(
        'renvoie la raison du refus d\'une partition non prise en charge',
        () async {
          //arrange
          when(dataSource.loadMusicXml(bundledSong.assetPath)).thenAnswer(
            (_) async =>
                '<score-partwise><part id="P1"/><part id="P2"/></score-partwise>',
          );

          //act
          final result = await sut.loadSong(bundledSong);

          //assert
          expect(
            result,
            const Left<Failure, Song>(
              UnsupportedSongFailure(
                'Le morceau doit contenir une seule partie de piano.',
              ),
            ),
          );
        },
      );

      test('renvoie SongFileFailure si le fichier est illisible', () async {
        //arrange
        when(
          dataSource.loadMusicXml(bundledSong.assetPath),
        ).thenThrow(const SongFileException());

        //act
        final result = await sut.loadSong(bundledSong);

        //assert
        expect(result, const Left<Failure, Song>(SongFileFailure()));
      });
    });

    group('listSongs', () {
      String scoreTitled(String title) =>
          '<score-partwise><work><work-title>$title</work-title></work>'
          '<part-list/><part id="P1"/></score-partwise>';

      test(
        'liste chaque morceau sous le titre de sa partition, par ordre alphabétique',
        () async {
          //arrange
          when(dataSource.listSongAssetPaths()).thenAnswer(
            (_) async => [
              'assets/songs/ode_to_joy.mxl',
              'assets/songs/local/song_of_storms.mxl',
            ],
          );
          when(
            dataSource.loadMusicXml('assets/songs/ode_to_joy.mxl'),
          ).thenAnswer((_) async => scoreTitled('Ode à la joie'));
          when(
            dataSource.loadMusicXml('assets/songs/local/song_of_storms.mxl'),
          ).thenAnswer((_) async => scoreTitled('Song of Storms'));

          //act
          final result = await sut.listSongs();

          //assert
          expect(result.getOrElse(() => throw StateError('échec')), const [
            BundledSong(
              title: 'Ode à la joie',
              assetPath: 'assets/songs/ode_to_joy.mxl',
            ),
            BundledSong(
              title: 'Song of Storms',
              assetPath: 'assets/songs/local/song_of_storms.mxl',
            ),
          ]);
        },
      );

      test(
        'prend le nom du fichier quand la partition n\'a pas de titre ou est illisible',
        () async {
          //arrange
          when(dataSource.listSongAssetPaths()).thenAnswer(
            (_) async => [
              'assets/songs/sans_titre.mxl',
              'assets/songs/abime.mxl',
            ],
          );
          when(
            dataSource.loadMusicXml('assets/songs/sans_titre.mxl'),
          ).thenAnswer((_) async => '<score-partwise/>');
          when(
            dataSource.loadMusicXml('assets/songs/abime.mxl'),
          ).thenThrow(const SongFileException());

          //act
          final result = await sut.listSongs();

          //assert
          expect(
            result
                .getOrElse(() => throw StateError('échec'))
                .map((song) => song.title),
            ['Abime', 'Sans titre'],
          );
        },
      );
    });
  });
}
