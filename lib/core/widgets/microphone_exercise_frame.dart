import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/input/input_source_kind.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/utils/feedback_utils.dart';
import 'package:key_starter/core/widgets/no_input_source_banner.dart';

/// Cadre d'un exercice jouable au MIDI comme au micro : prévient d'une bascule
/// de source par un toast, et affiche [NoInputSourceBanner] tant qu'aucune
/// source n'est disponible.
class MicrophoneExerciseFrame extends ConsumerStatefulWidget {
  static const switchedToMidiMessage = 'Clavier MIDI connecté.';
  static const switchedToMicrophoneMessage = 'Passage au micro.';

  final Widget child;

  const MicrophoneExerciseFrame({super.key, required this.child});

  @override
  ConsumerState<MicrophoneExerciseFrame> createState() =>
      _MicrophoneExerciseFrameState();
}

class _MicrophoneExerciseFrameState
    extends ConsumerState<MicrophoneExerciseFrame> {
  ScaffoldMessengerState? _messenger;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateBanner(ref.read(activeInputSourceKindProvider));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.maybeOf(context);
  }

  @override
  void dispose() {
    final messenger = _messenger;
    if (messenger != null && messenger.mounted) {
      messenger.removeCurrentMaterialBanner();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(activeInputSourceKindProvider, (previous, next) {
      if (previous == next) return;
      _updateBanner(next);
      final message = switch (next) {
        InputSourceKind.midi => MicrophoneExerciseFrame.switchedToMidiMessage,
        InputSourceKind.microphone =>
          MicrophoneExerciseFrame.switchedToMicrophoneMessage,
        InputSourceKind.none => null,
      };
      if (message != null) showToast(context, message);
    });
    return widget.child;
  }

  void _updateBanner(InputSourceKind kind) {
    final messenger = _messenger;
    if (messenger == null) return;
    messenger.hideCurrentMaterialBanner();
    if (kind != InputSourceKind.none) return;
    messenger.showMaterialBanner(
      const MaterialBanner(
        content: NoInputSourceBanner(),
        actions: [SizedBox.shrink()],
        padding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
      ),
    );
  }
}
