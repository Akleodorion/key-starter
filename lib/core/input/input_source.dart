import 'package:key_starter/core/input/input_event.dart';

/// Source d'entrée (voir CONTEXT.md) : d'où l'app reçoit ce que l'élève joue.
///
/// Contrat :
/// - [events] émet les notes jouées et relâchées, dans l'ordre de réception ;
/// - [listenFor] déclare les notes que l'exercice attend en ce moment. Une
///   source peut s'en servir pour vérifier la réponse (vérification guidée) ou
///   l'ignorer si elle reçoit déjà des notes exactes ;
/// - [stopListening] indique que l'exercice n'attend plus rien (il est quitté).
///
/// Les exercices gardent leurs propres règles de verdict : une source ne dit
/// jamais si une réponse est juste, elle rapporte ce qui a été joué.
///
/// ```dart
/// class KeyboardInputSource implements InputSource {
///   final _controller = StreamController<InputEvent>.broadcast();
///   @override
///   Stream<InputEvent> get events => _controller.stream;
///   @override
///   void listenFor(Set<int> candidateMidiNumbers) {}
///   @override
///   void stopListening() {}
///   void press(int midiNumber) => _controller.add(
///     NotePlayed(midiNumber, attackTime: DateTime.now()),
///   );
/// }
/// ```
///
/// Voir aussi : [MidiInputSource], [MicrophoneInputSource].
abstract class InputSource {
  /// Les notes jouées et relâchées.
  Stream<InputEvent> get events;

  /// Déclare les numéros MIDI acceptés comme bonne réponse pour l'étape en cours.
  void listenFor(Set<int> candidateMidiNumbers);

  /// L'exercice n'attend plus de note.
  void stopListening();
}
