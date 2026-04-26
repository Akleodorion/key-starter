import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();
}

class InvalidMidiNoteFailure extends Failure {
  final int midiNumber;

  const InvalidMidiNoteFailure(this.midiNumber);

  @override
  List<Object?> get props => [midiNumber];
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
