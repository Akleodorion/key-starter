import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/input/audio/audio_capture.dart';
import 'package:key_starter/core/input/audio/record_audio_capture.dart';
import 'package:key_starter/core/input/input_source.dart';
import 'package:key_starter/core/input/input_source_kind.dart';
import 'package:key_starter/core/input/input_source_router.dart';
import 'package:key_starter/core/input/microphone_input_source.dart';
import 'package:key_starter/core/input/microphone_permission.dart';
import 'package:key_starter/core/input/midi_input_source.dart';
import 'package:key_starter/core/providers/midi_command_provider.dart';
import 'package:key_starter/core/providers/midi_connection_provider.dart';

final microphonePermissionAccessProvider = Provider<MicrophonePermission>(
  (ref) => SystemMicrophonePermission(),
);

final audioCaptureProvider = Provider<AudioCapture>(
  (ref) => RecordAudioCapture(),
);

/// Le micro est-il autorisé ? Relu à chaque retour dans l'app (l'élève a pu
/// l'autoriser dans les réglages entre-temps).
final microphonePermissionProvider =
    NotifierProvider<MicrophonePermissionNotifier, bool>(
      MicrophonePermissionNotifier.new,
    );

class MicrophonePermissionNotifier extends Notifier<bool> {
  @override
  bool build() {
    final lifecycleListener = AppLifecycleListener(onResume: refresh);
    ref.onDispose(lifecycleListener.dispose);
    refresh();
    return false;
  }

  Future<void> refresh() async {
    final isGranted = await ref
        .read(microphonePermissionAccessProvider)
        .isGranted();
    if (ref.mounted) state = isGranted;
  }

  Future<void> requestOnFirstLaunch() async {
    final isGranted = await ref
        .read(microphonePermissionAccessProvider)
        .requestOnFirstLaunch();
    if (ref.mounted) state = isGranted;
  }

  Future<void> openSettings() =>
      ref.read(microphonePermissionAccessProvider).openSettings();
}

/// La Source d'entrée à utiliser : MIDI dès qu'un clavier est connecté, sinon
/// le micro s'il est autorisé.
final activeInputSourceKindProvider = Provider<InputSourceKind>((ref) {
  final midiDeviceName = ref.watch(midiConnectionProvider).value;
  if (midiDeviceName != null) return InputSourceKind.midi;
  if (ref.watch(microphonePermissionProvider)) {
    return InputSourceKind.microphone;
  }
  return InputSourceKind.none;
});

/// La Source d'entrée active, à laquelle les exercices s'abonnent. Elle reste
/// la même quand la source bascule : c'est elle qui relaie la nouvelle.
final inputSourceProvider = Provider<InputSource>((ref) {
  final microphone = MicrophoneInputSource(
    capture: ref.watch(audioCaptureProvider),
  );
  final router = InputSourceRouter(
    midi: MidiInputSource(
      packets: ref.watch(midiCommandProvider).onMidiDataReceived,
    ),
    microphone: microphone,
  );
  ref.listen(
    activeInputSourceKindProvider,
    (_, kind) => router.activate(kind),
    fireImmediately: true,
  );
  ref.onDispose(() {
    router.dispose();
    microphone.dispose();
  });
  return router;
});
