import 'package:flutter/foundation.dart';

@immutable
class SavedRecipes {
  final String recipeId;
  final String recipeCategory;
  final String recipeName;
  final String recipeImage;
  final double prepTime;
  final double cookTime;

  const SavedRecipes({
    required this.recipeId,
    required this.recipeCategory,
    required this.recipeName,
    required this.recipeImage,
    required this.prepTime,
    required this.cookTime,
  });

  /// Membuat salinan objek dengan field yang diperbarui.
  SavedRecipes copyWith({
    String? recipeId,
    String? recipeCategory,
    String? recipeName,
    String? recipeImage,
    double? prepTime,
    double? cookTime,
  }) {
    return SavedRecipes(
      recipeId: recipeId ?? this.recipeId,
      recipeCategory: recipeCategory ?? this.recipeCategory,
      recipeName: recipeName ?? this.recipeName,
      recipeImage: recipeImage ?? this.recipeImage,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavedRecipes &&
        other.recipeId == recipeId &&
        other.recipeCategory == recipeCategory &&
        other.recipeName == recipeName &&
        other.recipeImage == recipeImage &&
        other.prepTime == prepTime &&
        other.cookTime == cookTime;
  }

  @override
  int get hashCode {
    return Object.hash(
      recipeId,
      recipeCategory,
      recipeName,
      recipeImage,
      prepTime,
      cookTime,
    );
  }

  @override
  String toString() {
    return 'SavedRecipes('
        'recipeId: $recipeId, '
        'recipeCategory: $recipeCategory, '
        'recipeName: $recipeName, '
        'recipeImage: $recipeImage, '
        'prepTime: $prepTime, '
        'cookTime: $cookTime'
        ')';
  }
}
