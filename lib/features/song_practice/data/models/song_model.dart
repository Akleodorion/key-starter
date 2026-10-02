import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_event.dart';
import 'package:xml/xml.dart';

const _stepLetters = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];

class SongModel extends Song {
  const SongModel({
    required super.title,
    required super.measureCount,
    required super.events,
  });

  /// Lit une partition MusicXML (score-partwise) d'une partie piano à deux
  /// portées. Lève [UnsupportedSongException] si elle contient un élément
  /// que l'app ne sait pas encore jouer juste.
  factory SongModel.fromMusicXml(String xml, {required String title}) {
    final document = XmlDocument.parse(xml);
    _rejectUnsupported(document);
    final measures = document.findAllElements('measure').toList();
    final eventsByOnset = <int, _SongEventBuilder>{};
    var measureStart = 0;

    for (var measureIndex = 0; measureIndex < measures.length; measureIndex++) {
      var cursor = 0;
      var longestCursor = 0;
      var previousNoteOnset = 0;
      for (final element in measures[measureIndex].childElements) {
        switch (element.name.local) {
          case 'backup':
            cursor -= _duration(element);
          case 'forward':
            cursor += _duration(element);
          case 'note':
            final duration = _duration(element);
            final isChordNote = element.getElement('chord') != null;
            if (!isChordNote) previousNoteOnset = cursor;
            final pitch = element.getElement('pitch');
            if (pitch != null) {
              final onset = measureStart + previousNoteOnset;
              eventsByOnset
                  .putIfAbsent(
                    onset,
                    () => _SongEventBuilder(measureIndex + 1, onset),
                  )
                  .add(
                    isBass: element.getElement('staff')?.innerText == '2',
                    step: _diatonicStep(pitch),
                    duration: duration,
                  );
            }
            if (!isChordNote) cursor += duration;
        }
        if (cursor > longestCursor) longestCursor = cursor;
      }
      measureStart += longestCursor;
    }

    final onsets = eventsByOnset.keys.toList()..sort();
    return SongModel(
      title: title,
      measureCount: measures.length,
      events: [for (final onset in onsets) eventsByOnset[onset]!.build()],
    );
  }
}

class _SongEventBuilder {
  final int measureNumber;
  final int onsetDivisions;
  final List<int> trebleSteps = [];
  final List<int> bassSteps = [];
  int trebleDurationDivisions = 0;
  int bassDurationDivisions = 0;

  _SongEventBuilder(this.measureNumber, this.onsetDivisions);

  void add({required bool isBass, required int step, required int duration}) {
    if (isBass) {
      bassSteps.add(step);
      bassDurationDivisions = duration;
    } else {
      trebleSteps.add(step);
      trebleDurationDivisions = duration;
    }
  }

  SongEvent build() => SongEvent(
    measureNumber: measureNumber,
    onsetDivisions: onsetDivisions,
    notes: TwoStaffEvent(trebleSteps: trebleSteps, bassSteps: bassSteps),
    trebleDurationDivisions: trebleDurationDivisions,
    bassDurationDivisions: bassDurationDivisions,
  );
}

void _rejectUnsupported(XmlDocument document) {
  if (document.findAllElements('part').length != 1) {
    throw const UnsupportedSongException(
      'Le morceau doit contenir une seule partie de piano.',
    );
  }
  final hasTooManyStaves = document
      .findAllElements('staves')
      .any((staves) => int.parse(staves.innerText) > 2);
  if (hasTooManyStaves) {
    throw const UnsupportedSongException(
      'Le morceau doit tenir sur deux portées au plus.',
    );
  }
  const unsupportedNoteElements = {
    'tie': 'Les notes liées ne sont pas encore prises en charge.',
    'time-modification': 'Les triolets ne sont pas encore pris en charge.',
    'grace': "Les notes d'ornement ne sont pas encore prises en charge.",
  };
  for (final MapEntry(key: elementName, value: reason)
      in unsupportedNoteElements.entries) {
    if (document.findAllElements(elementName).isNotEmpty) {
      throw UnsupportedSongException(reason);
    }
  }
  final voicesByStaff = <String, Set<String>>{};
  for (final noteElement in document.findAllElements('note')) {
    final staff = noteElement.getElement('staff')?.innerText ?? '1';
    final voice = noteElement.getElement('voice')?.innerText ?? '1';
    voicesByStaff.putIfAbsent(staff, () => {}).add(voice);
  }
  if (voicesByStaff.values.any((voices) => voices.length > 1)) {
    throw const UnsupportedSongException(
      "Une seule voix par portée est prise en charge pour l'instant.",
    );
  }
  final hasAccidental = document
      .findAllElements('alter')
      .any((alter) => double.parse(alter.innerText) != 0);
  if (hasAccidental) {
    throw const UnsupportedSongException(
      'Les altérations (♯, ♭) ne sont pas encore prises en charge.',
    );
  }
  final hasKeySignature = document
      .findAllElements('fifths')
      .any((fifths) => int.parse(fifths.innerText) != 0);
  if (hasKeySignature) {
    throw const UnsupportedSongException(
      "Seule la tonalité de Do majeur est prise en charge pour l'instant.",
    );
  }
}

int _duration(XmlElement element) =>
    int.parse(element.getElement('duration')!.innerText);

/// Degré diatonique d'un élément `<pitch>` (step 0 = Do 4).
int _diatonicStep(XmlElement pitch) {
  final letterIndex = _stepLetters.indexOf(pitch.getElement('step')!.innerText);
  final octave = int.parse(pitch.getElement('octave')!.innerText);
  return (octave - 4) * 7 + letterIndex;
}
