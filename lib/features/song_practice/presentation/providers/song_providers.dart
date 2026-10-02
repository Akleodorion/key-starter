import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/song_practice/domain/entities/bundled_song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/usecases/load_song_usecase.dart';
import 'package:key_starter/injection_container.dart';

final loadSongUseCaseProvider = Provider<LoadSongUseCase>(
  (ref) => sl<LoadSongUseCase>(),
);

/// Le morceau chargé depuis sa partition, ou la raison de l'échec.
final songProvider = FutureProvider.autoDispose
    .family<Either<Failure, Song>, BundledSong>(
      (ref, bundledSong) => ref.read(loadSongUseCaseProvider)(bundledSong),
    );
