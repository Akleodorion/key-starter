import 'package:flutter_riverpod/flutter_riverpod.dart';

final showNoteAidProvider =
    NotifierProvider<ShowNoteAidNotifier, bool>(ShowNoteAidNotifier.new);

class ShowNoteAidNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;

  void setValue(bool value) => state = value;
}
