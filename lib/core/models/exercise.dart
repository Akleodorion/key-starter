import 'package:key_starter/core/models/card_entry.dart';

abstract class Exercise extends CardEntry {
  const Exercise({
    required super.icon,
    required super.title,
    required super.description,
    required super.color,
    required super.tintColor,
    required super.darkTintColor,
  });
}
