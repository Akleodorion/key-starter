import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/input/input_source_kind.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/widgets/midi_disconnected_overlay.dart';

/// Cadre d'un exercice réservé au MIDI (accords, tempo) : clavier débranché,
/// l'exercice est mis en pause sous [MidiDisconnectedOverlay], et reprend de
/// lui-même au rebranchement.
class MidiOnlyExerciseFrame extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onPause;
  final VoidCallback? onResume;

  const MidiOnlyExerciseFrame({
    super.key,
    required this.child,
    this.onPause,
    this.onResume,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMidiConnected =
        ref.watch(activeInputSourceKindProvider) == InputSourceKind.midi;
    ref.listen(activeInputSourceKindProvider, (previous, next) {
      final wasConnected = previous == InputSourceKind.midi;
      final isConnected = next == InputSourceKind.midi;
      if (wasConnected && !isConnected) onPause?.call();
      if (!wasConnected && isConnected) onResume?.call();
    });

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (!isMidiConnected)
          const Material(
            type: MaterialType.transparency,
            child: MidiDisconnectedOverlay(),
          ),
      ],
    );
  }
}
