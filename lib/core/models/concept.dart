import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class Concept extends Equatable {
  final String title;
  final String description;
  final Color color;
  final Color tintColor;
  final IconData icon;

  const Concept({
    required this.title,
    required this.description,
    required this.color,
    required this.tintColor,
    required this.icon,
  });

  @override
  List<Object?> get props => [title, description, color, tintColor, icon];
}
