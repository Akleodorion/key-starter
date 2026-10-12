/// Altération écrite d'une note : son décalage en demi-tons.
enum Accidental {
  natural(0),
  sharp(1),
  flat(-1);

  final int semitoneOffset;

  const Accidental(this.semitoneOffset);
}
