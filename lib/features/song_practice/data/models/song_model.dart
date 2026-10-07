import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_event.dart';
import 'package:key_starter/features/song_practice/domain/entities/note_value.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_measure.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_rest.dart';
import 'package:key_starter/features/song_practice/domain/entities/staff_notation.dart';
import 'package:xml/xml.dart';

const _stepLetters = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];

const _noteTypesByName = {
  'breve': NoteType.breve,
  'whole': NoteType.whole,
  'half': NoteType.half,
  'quarter': NoteType.quarter,
  'eighth': NoteType.eighth,
  '16th': NoteType.sixteenth,
  '32nd': NoteType.thirtySecond,
  '64th': NoteType.sixtyFourth,
  '128th': NoteType.oneHundredTwentyEighth,
  '256th': NoteType.twoHundredFiftySixth,
  '512th': NoteType.fiveHundredTwelfth,
  '1024th': NoteType.oneThousandTwentyFourth,
};

const _beamMarksByName = {
  'begin': BeamMark.begin,
  'continue': BeamMark.continued,
  'end': BeamMark.end,
  'forward hook': BeamMark.forwardHook,
  'backward hook': BeamMark.backwardHook,
};

class SongModel extends Song {
  const SongModel({
    required super.title,
    required super.measures,
    required super.events,
    super.rests,
    super.divisionsPerQuarter,
    super.beatsPerMeasure,
    super.beatUnit,
  });

  /// Titre écrit dans une partition MusicXML (œuvre, sinon mouvement), ou
  /// null, même si le reste de la partition n'est pas pris en charge.
  static String? titleFromMusicXml(String xml) =>
      _title(XmlDocument.parse(xml));

  /// Lit une partition MusicXML (score-partwise) d'une partie piano à deux
  /// portées. Le titre est celui de l'œuvre, sinon du mouvement, sinon
  /// [fallbackTitle]. Lève [UnsupportedSongException] si elle contient un
  /// élément que l'app ne sait pas encore jouer juste.
  factory SongModel.fromMusicXml(String xml, {required String fallbackTitle}) {
    final document = XmlDocument.parse(xml);
    _rejectUnsupported(document);
    final divisionsPerQuarter = _intOf(
      document.findAllElements('divisions').firstOrNull,
      orElse: 1,
    );
    final measures = document.findAllElements('measure').toList();
    final eventsByOnset = <int, _SongEventBuilder>{};
    final rests = <SongRest>[];
    final songMeasures = <SongMeasure>[];
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
            final isBass = element.getElement('staff')?.innerText == '2';
            final pitch = element.getElement('pitch');
            final restElement = element.getElement('rest');
            if (pitch != null) {
              final onset = measureStart + previousNoteOnset;
              eventsByOnset
                  .putIfAbsent(
                    onset,
                    () => _SongEventBuilder(measureIndex + 1, onset),
                  )
                  .add(
                    isBass: isBass,
                    step: _diatonicStep(pitch),
                    duration: duration,
                    notation: _staffNotation(element, divisionsPerQuarter),
                  );
            } else if (restElement != null) {
              rests.add(
                SongRest(
                  measureNumber: measureIndex + 1,
                  onsetDivisions: measureStart + previousNoteOnset,
                  isBass: isBass,
                  value: restElement.getAttribute('measure') == 'yes'
                      ? null
                      : _noteValue(element, divisionsPerQuarter),
                ),
              );
            }
            if (!isChordNote) cursor += duration;
        }
        if (cursor > longestCursor) longestCursor = cursor;
      }
      songMeasures.add(
        SongMeasure(
          number: measureIndex + 1,
          startDivisions: measureStart,
          durationDivisions: longestCursor,
        ),
      );
      measureStart += longestCursor;
    }

    final onsets = eventsByOnset.keys.toList()..sort();
    final time = document.findAllElements('time').firstOrNull;
    return SongModel(
      title: _title(document) ?? fallbackTitle,
      measures: songMeasures,
      events: [for (final onset in onsets) eventsByOnset[onset]!.build()],
      rests: rests,
      divisionsPerQuarter: divisionsPerQuarter,
      beatsPerMeasure: _intOf(time?.getElement('beats'), orElse: 4),
      beatUnit: _intOf(time?.getElement('beat-type'), orElse: 4),
    );
  }
}

String? _title(XmlDocument document) {
  for (final elementName in ['work-title', 'movement-title']) {
    final title = document
        .findAllElements(elementName)
        .firstOrNull
        ?.innerText
        .trim();
    if (title != null && title.isNotEmpty) return title;
  }
  return null;
}

StaffNotation _staffNotation(XmlElement note, int divisionsPerQuarter) =>
    StaffNotation(
      value: _noteValue(note, divisionsPerQuarter),
      stemDirection: switch (note.getElement('stem')?.innerText) {
        'up' => StemDirection.up,
        'down' => StemDirection.down,
        _ => null,
      },
      beams: [
        for (final beam in note.findElements('beam'))
          ?_beamMarksByName[beam.innerText.trim()],
      ],
    );

/// Valeur écrite d'une note ou d'un silence : sa figure (`<type>`) et ses
/// points, ou, sans `<type>`, la figure dont la durée correspond.
NoteValue _noteValue(XmlElement note, int divisionsPerQuarter) {
  final typeName = note.getElement('type')?.innerText.trim();
  if (typeName == 'long' || typeName == 'maxima') {
    throw const UnsupportedSongException(
      'Les longues et les maximes ne sont pas prises en charge.',
    );
  }
  final noteType = _noteTypesByName[typeName];
  final dotCount = note.findElements('dot').length;
  if (noteType != null) return NoteValue(noteType, dotCount: dotCount);

  final quarters = _duration(note) / divisionsPerQuarter;
  for (final candidateType in NoteType.values) {
    for (var dots = 0; dots <= 3; dots++) {
      final dottedQuarters = candidateType.quarters * (2 - 1 / (1 << dots));
      if ((dottedQuarters - quarters).abs() < 1e-9) {
        return NoteValue(candidateType, dotCount: dots);
      }
    }
  }
  throw const UnsupportedSongException(
    'Une durée de note ne correspond à aucune figure.',
  );
}

class _SongEventBuilder {
  final int measureNumber;
  final int onsetDivisions;
  final List<int> trebleSteps = [];
  final List<int> bassSteps = [];
  int trebleDurationDivisions = 0;
  int bassDurationDivisions = 0;
  StaffNotation? trebleNotation;
  StaffNotation? bassNotation;

  _SongEventBuilder(this.measureNumber, this.onsetDivisions);

  // Les notes d'un accord partagent la notation de la première.
  void add({
    required bool isBass,
    required int step,
    required int duration,
    required StaffNotation notation,
  }) {
    if (isBass) {
      bassSteps.add(step);
      bassDurationDivisions = duration;
      bassNotation ??= notation;
    } else {
      trebleSteps.add(step);
      trebleDurationDivisions = duration;
      trebleNotation ??= notation;
    }
  }

  SongEvent build() => SongEvent(
    measureNumber: measureNumber,
    onsetDivisions: onsetDivisions,
    notes: TwoStaffEvent(trebleSteps: trebleSteps, bassSteps: bassSteps),
    trebleDurationDivisions: trebleDurationDivisions,
    bassDurationDivisions: bassDurationDivisions,
    trebleNotation: trebleNotation,
    bassNotation: bassNotation,
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
  final timeSignatures = {
    for (final time in document.findAllElements('time'))
      '${time.getElement('beats')?.innerText}/'
          '${time.getElement('beat-type')?.innerText}',
  };
  if (timeSignatures.length > 1) {
    throw const UnsupportedSongException(
      'Les changements de chiffrage ne sont pas encore pris en charge.',
    );
  }
  final divisionValues = {
    for (final divisions in document.findAllElements('divisions'))
      divisions.innerText,
  };
  if (divisionValues.length > 1) {
    throw const UnsupportedSongException(
      "Les changements d'unité de durée ne sont pas encore pris en charge.",
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

int _intOf(XmlElement? element, {required int orElse}) =>
    element == null ? orElse : int.parse(element.innerText);

int _duration(XmlElement element) =>
    int.parse(element.getElement('duration')!.innerText);

/// Degré diatonique d'un élément `<pitch>` (step 0 = Do 4).
int _diatonicStep(XmlElement pitch) {
  final letterIndex = _stepLetters.indexOf(pitch.getElement('step')!.innerText);
  final octave = int.parse(pitch.getElement('octave')!.innerText);
  return (octave - 4) * 7 + letterIndex;
}
