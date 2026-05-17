import 'package:flutter/material.dart';

abstract class SettingsSectionData {
  const SettingsSectionData();

  String get title;
  List<Widget> get children;
}
