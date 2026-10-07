import 'package:equatable/equatable.dart';
import 'package:key_starter/features/song_practice/domain/entities/staff_notation.dart';

/// Une barre de ligature d'un niveau (1 = croches, 2 = doubles…) tendue
/// entre deux membres d'un groupe.
class BeamSegment extends Equatable {
  final int level;
  final int fromMember;
  final int toMember;

  const BeamSegment({
    required this.level,
    required this.fromMember,
    required this.toMember,
  });

  @override
  List<Object?> get props => [level, fromMember, toMember];
}

/// Une demi-barre d'un niveau, accrochée à un seul membre et tournée vers
/// la note suivante ou précédente.
class BeamHook extends Equatable {
  final int level;
  final int member;
  final bool pointsForward;

  const BeamHook({
    required this.level,
    required this.member,
    required this.pointsForward,
  });

  @override
  List<Object?> get props => [level, member, pointsForward];
}

/// Des notes d'une même portée reliées par des barres de ligature : leurs
/// indices dans la ligne, puis les barres et demi-barres, repérées par la
/// place de leurs membres dans le groupe.
class BeamGroup extends Equatable {
  final List<int> memberIndices;
  final List<BeamSegment> segments;
  final List<BeamHook> hooks;

  const BeamGroup({
    required this.memberIndices,
    required this.segments,
    required this.hooks,
  });

  @override
  List<Object?> get props => [memberIndices, segments, hooks];
}

/// Groupes de ligature d'une portée sur une ligne, d'après les marques
/// écrites dans la partition ([notations] dans l'ordre de la ligne, null là
/// où la portée n'attaque rien). Un groupe coupé par le début ou la fin de
/// la ligne est refermé sur ce qu'elle en montre.
List<BeamGroup> beamGroupsOf(List<StaffNotation?> notations) {
  final groups = <BeamGroup>[];
  var members = <int>[];

  void closeGroup() {
    if (members.length > 1) groups.add(_beamGroup(members, notations));
    members = [];
  }

  for (final (index, notation) in notations.indexed) {
    if (notation == null) continue;
    final firstLevel = notation.beams.firstOrNull;
    if (firstLevel == null) {
      closeGroup();
      continue;
    }
    if (firstLevel == BeamMark.begin) closeGroup();
    members.add(index);
    if (firstLevel == BeamMark.end) closeGroup();
  }
  closeGroup();
  return groups;
}

BeamGroup _beamGroup(List<int> members, List<StaffNotation?> notations) {
  final segments = <BeamSegment>[];
  final hooks = <BeamHook>[];
  final levelCount = members
      .map((index) => notations[index]!.beams.length)
      .reduce((first, second) => first > second ? first : second);
  for (var level = 1; level <= levelCount; level++) {
    int? segmentStart;
    for (var member = 0; member < members.length; member++) {
      final beams = notations[members[member]]!.beams;
      final mark = beams.length >= level ? beams[level - 1] : null;
      final isLevelOne = level == 1;
      switch (mark) {
        case BeamMark.begin:
          segmentStart = member;
        case BeamMark.continued:
          segmentStart ??= member;
        case BeamMark.end:
          segments.add(
            BeamSegment(
              level: level,
              fromMember: segmentStart ?? 0,
              toMember: member,
            ),
          );
          segmentStart = null;
        case BeamMark.forwardHook:
          hooks.add(
            BeamHook(level: level, member: member, pointsForward: true),
          );
        case BeamMark.backwardHook:
          hooks.add(
            BeamHook(level: level, member: member, pointsForward: false),
          );
        case null:
          if (!isLevelOne && segmentStart != null) {
            segments.add(
              BeamSegment(
                level: level,
                fromMember: segmentStart,
                toMember: member - 1,
              ),
            );
            segmentStart = null;
          }
      }
    }
    if (segmentStart != null && segmentStart < members.length - 1) {
      segments.add(
        BeamSegment(
          level: level,
          fromMember: segmentStart,
          toMember: members.length - 1,
        ),
      );
    }
  }
  segments.sort(
    (first, second) => first.level != second.level
        ? first.level.compareTo(second.level)
        : first.fromMember.compareTo(second.fromMember),
  );
  return BeamGroup(memberIndices: members, segments: segments, hooks: hooks);
}
