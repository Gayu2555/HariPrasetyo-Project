export 'category_items.dart';
export 'food.dart';
export 'icon.dart';
export 'saved_recipes.dart';

// Di file models.dart
class IconModel {
  final dynamic icon; // Bisa String (asset path) atau IconData
  final String text;

  IconModel({required this.icon, required this.text});
}
