import 'package:flutter_riverpod/flutter_riverpod.dart';

final simpleNoteBlackKeysProvider =
    NotifierProvider<SimpleNoteBlackKeysNotifier, bool>(
      SimpleNoteBlackKeysNotifier.new,
    );

/// Inclusion des touches noires dans le tirage de l'exercice Notes simples.
class SimpleNoteBlackKeysNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setValue(bool value) => state = value;
}
