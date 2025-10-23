import 'package:flutter/material.dart';
import 'package:recipe_app/models/models.dart';

// PASTIKAN model class seperti ini:
class IconModel {
  final String icon; // Tetap pakai String untuk asset path
  final String text;

  IconModel({required this.icon, required this.text});
}

// List icons TANPA isIconData:
List<IconModel> iconList = [
  IconModel(icon: 'assets/coffee.png', text: 'Breakfast'),
  IconModel(icon: 'assets/lunch-box.png', text: 'Lunch'),
  IconModel(icon: 'assets/dish.png', text: 'Dinner'),
  IconModel(icon: 'assets/fruits.png', text: 'Snack'),
  IconModel(icon: 'assets/cake.png', text: 'Desert'),
  IconModel(icon: 'assets/beverage.png', text: 'Beverage'),
];
