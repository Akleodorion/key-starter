import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();
}

class InvalidSessionParamsFailure extends Failure {
  const InvalidSessionParamsFailure();

  @override
  List<Object?> get props => [];
}

class SessionAlreadyCompletedFailure extends Failure {
  const SessionAlreadyCompletedFailure();

  @override
  List<Object?> get props => [];
}

class CacheFailure extends Failure {
  const CacheFailure();

  @override
  List<Object?> get props => [];
}

/// La partition contient un élément pas encore pris en charge ; [reason] est
/// affichable à l'utilisateur.
class UnsupportedSongFailure extends Failure {
  final String reason;

  const UnsupportedSongFailure(this.reason);

  @override
  List<Object?> get props => [reason];
}

class SongFileFailure extends Failure {
  const SongFileFailure();

  @override
  List<Object?> get props => [];
}
