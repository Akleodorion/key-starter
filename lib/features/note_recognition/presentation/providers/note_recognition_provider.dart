import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_recognition_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_recognition_state.dart';

final noteRecognitionProvider =
    NotifierProvider<NoteRecognitionNotifier, NoteRecognitionState>(
  NoteRecognitionNotifier.new,
);
