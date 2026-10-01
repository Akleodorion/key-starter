import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_inversion_choice.dart';

final chordInversionChoiceProvider =
    NotifierProvider<ChordInversionChoiceNotifier, ChordInversionChoice>(
      ChordInversionChoiceNotifier.new,
    );

/// Renversements choisis avant de lancer Renversements simples : le 1er seul
/// par défaut, l'élève élargit lui-même.
class ChordInversionChoiceNotifier extends Notifier<ChordInversionChoice> {
  @override
  ChordInversionChoice build() => ChordInversionChoice.first;

  void setValue(ChordInversionChoice value) => state = value;
}
