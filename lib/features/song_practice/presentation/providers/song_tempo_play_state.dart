import 'package:equatable/equatable.dart';
import 'package:key_starter/core/utils/two_staff_judgement.dart';

sealed class SongTempoPlayState extends Equatable {
  const SongTempoPlayState();
}

/// La section se joue au tempo : la barre avance sur l'horloge du notifier.
class SongTempoPlayRunning extends SongTempoPlayState {
  final int errorCount;

  /// Verdict de chaque événement déjà jugé, par indice dans le morceau.
  final Map<int, TwoStaffVerdict> judgedVerdicts;

  const SongTempoPlayRunning({
    required this.errorCount,
    this.judgedVerdicts = const {},
  });

  SongTempoPlayRunning copyWith({
    int? errorCount,
    Map<int, TwoStaffVerdict>? judgedVerdicts,
  }) => SongTempoPlayRunning(
    errorCount: errorCount ?? this.errorCount,
    judgedVerdicts: judgedVerdicts ?? this.judgedVerdicts,
  );

  @override
  List<Object?> get props => [errorCount, judgedVerdicts];
}

/// La barre est arrivée au bout de la section : elle va reprendre du
/// décompte avec les mêmes réglages.
class SongTempoPlayRetrying extends SongTempoPlayState {
  final int errorCount;

  const SongTempoPlayRetrying({required this.errorCount});

  @override
  List<Object?> get props => [errorCount];
}
