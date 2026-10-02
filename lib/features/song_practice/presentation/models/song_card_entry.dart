import 'package:flutter/material.dart';
import 'package:key_starter/core/models/card_entry.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/features/song_practice/domain/entities/bundled_song.dart';

/// Carte d'un morceau livré avec l'app sur la page Morceaux.
class SongCardEntry extends CardEntry {
  SongCardEntry(BundledSong bundledSong)
    : super(
        icon: Icons.music_note_rounded,
        title: bundledSong.title,
        description: 'portée double · une ou deux mains',
        color: AppColors.songsFg,
        tintColor: AppColors.songsTint,
        darkTintColor: const Color(0xFF2A1840),
      );
}
