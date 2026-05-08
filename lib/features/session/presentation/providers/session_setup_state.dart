import 'package:equatable/equatable.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';

sealed class SessionSetupState extends Equatable {
  const SessionSetupState();
}

class SessionSetupInitial extends SessionSetupState {
  const SessionSetupInitial();
  @override
  List<Object?> get props => [];
}

class SessionSetupLoading extends SessionSetupState {
  const SessionSetupLoading();
  @override
  List<Object?> get props => [];
}

class SessionSetupLoaded extends SessionSetupState {
  final ClefMode clef;
  final int minStep;
  final int maxStep;
  final int totalNotes;
  final NoteLanguage? noteLanguage;

  const SessionSetupLoaded({
    required this.clef,
    required this.minStep,
    required this.maxStep,
    required this.totalNotes,
    this.noteLanguage,
  });

  SessionSetupLoaded copyWith({
    ClefMode? clef,
    int? minStep,
    int? maxStep,
    int? totalNotes,
    NoteLanguage? Function()? noteLanguage,
  }) => SessionSetupLoaded(
    clef: clef ?? this.clef,
    minStep: minStep ?? this.minStep,
    maxStep: maxStep ?? this.maxStep,
    totalNotes: totalNotes ?? this.totalNotes,
    noteLanguage: noteLanguage != null ? noteLanguage() : this.noteLanguage,
  );

  @override
  List<Object?> get props => [clef, minStep, maxStep, totalNotes, noteLanguage];
}

class SessionSetupError extends SessionSetupState {
  final String message;
  const SessionSetupError(this.message);
  @override
  List<Object?> get props => [message];
}

class SessionSetupCreated extends SessionSetupState {
  final Session session;
  const SessionSetupCreated(this.session);
  @override
  List<Object?> get props => [session];
}
