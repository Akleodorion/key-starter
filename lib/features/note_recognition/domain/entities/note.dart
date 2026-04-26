import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final int midiNumber;
  final String name;
  final int octave;

  const Note({
    required this.midiNumber,
    required this.name,
    required this.octave,
  });

  @override
  List<Object?> get props => [midiNumber, name, octave];
}
