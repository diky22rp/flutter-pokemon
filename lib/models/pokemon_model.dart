import 'package:flutter/material.dart';

class PokemonModel {
  const PokemonModel({
    required this.name,
    required this.number,
    required this.types,
    required this.cardColor,
    required this.imageUrl,
    required this.description,
    required this.heightMeters,
    required this.weightKg,
    required this.category,
    required this.abilities,
  });

  final String name;
  final int number;
  final List<String> types;
  final Color cardColor;
  final String imageUrl;
  final String description;
  final double heightMeters;
  final double weightKg;
  final String category;
  final List<String> abilities;

  String get formattedNumber => '#${number.toString().padLeft(3, '0')}';

  String get formattedHeight => '${heightMeters.toStringAsFixed(1)} m';

  String get formattedWeight => '${weightKg.toStringAsFixed(1)} kg';

  String get joinedAbilities => abilities.join(', ');
}
