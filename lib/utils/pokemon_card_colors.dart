import 'package:flutter/material.dart';

const List<Color> basePokemonCardColors = [
  Color(0xFFFFCC00),
  Color(0xFFFF6B2E),
  Color(0xFF3BA7FF),
  Color(0xFF4BC47E),
  Color(0xFFB057E6),
  Color(0xFFFF9BD4),
  Color(0xFF9AA0A6),
  Color(0xFFCC8858),
  Color(0xFF52C7B8),
  Color(0xFF2E3A67),
];

Color cardColorForName(String name) {
  final safeHash = name.hashCode & 0x7fffffff;
  return basePokemonCardColors[safeHash % basePokemonCardColors.length];
}
