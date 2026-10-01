/// Capture du son du micro, en échantillons mono normalisés entre -1 et 1.
///
/// Contrat :
/// - [start] ouvre le micro et renvoie le flux d'échantillons, dans l'ordre ;
/// - [stop] ferme le micro ; un nouveau [start] peut suivre.
///
/// ```dart
/// class SilentAudioCapture implements AudioCapture {
///   @override
///   int get sampleRate => 44100;
///   @override
///   Future<Stream<List<double>>> start() async => const Stream.empty();
///   @override
///   Future<void> stop() async {}
/// }
/// ```
///
/// Voir aussi : [RecordAudioCapture].
abstract class AudioCapture {
  /// Nombre d'échantillons par seconde du flux.
  int get sampleRate;

  /// Ouvre le micro et renvoie le flux d'échantillons.
  Future<Stream<List<double>>> start();

  /// Ferme le micro.
  Future<void> stop();
}
