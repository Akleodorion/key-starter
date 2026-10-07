import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/widgets/note_range_section.dart';

/// Sol 4 → Sol 5 : les libellés de note les plus larges.
class FakeNoteRangeSection extends NoteRangeSection {
  FakeNoteRangeSection({super.key});

  final List<String> calls = [];

  @override
  ClefMode clef(WidgetRef ref) => ClefMode.treble;

  @override
  int minNoteStep(WidgetRef ref) => 4;

  @override
  int maxNoteStep(WidgetRef ref) => 11;

  @override
  void decrementMinNote(WidgetRef ref) => calls.add('decrementMinNote');

  @override
  void incrementMinNote(WidgetRef ref) => calls.add('incrementMinNote');

  @override
  void decrementMaxNote(WidgetRef ref) => calls.add('decrementMaxNote');

  @override
  void incrementMaxNote(WidgetRef ref) => calls.add('incrementMaxNote');
}
