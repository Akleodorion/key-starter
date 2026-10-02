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
      test('renvoie le morceau lu, sous le titre du catalogue', () async {
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
  });
}
