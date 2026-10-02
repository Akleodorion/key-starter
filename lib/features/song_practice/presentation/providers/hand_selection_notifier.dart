import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/song_practice/presentation/providers/hand_selection.dart';

/// Main(s) choisie(s) sur la page de préparation, gardée(s) le temps de la
/// session.
final handSelectionProvider =
    NotifierProvider<HandSelectionNotifier, HandSelection>(
      HandSelectionNotifier.new,
    );

class HandSelectionNotifier extends Notifier<HandSelection> {
  @override
  HandSelection build() => HandSelection.both;

  void select(HandSelection hands) => state = hands;
}
