import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class CardEntry extends Equatable {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color tintColor;
  final Color darkTintColor;

  const CardEntry({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.tintColor,
    required this.darkTintColor,
  });

  @override
  List<Object?> get props => [icon, title, description, color, tintColor, darkTintColor];
}
