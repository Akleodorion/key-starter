/// Lettre d'une note, de Do à Si, avec sa classe de note naturelle
/// (0 = Do … 11 = Si).
enum NoteLetter {
  c(0),
  d(2),
  e(4),
  f(5),
  g(7),
  a(9),
  b(11);

  final int naturalPitchClass;

  const NoteLetter(this.naturalPitchClass);
}
