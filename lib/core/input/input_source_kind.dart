/// Source d'entrée active (voir CONTEXT.md), choisie automatiquement.
enum InputSourceKind {
  /// Un clavier MIDI est connecté : la référence de précision.
  midi,

  /// Pas de clavier, mais le micro est autorisé : repli par vérification guidée.
  microphone,

  /// Ni clavier ni micro : rien ne peut être entendu.
  none,
}
