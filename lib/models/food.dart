class Recipe {
  final int recipeId;
  final String recipeCategory;
  final String recipeName;
  final String recipeImage;
  final double prepTime;
  final double cookTime;
  final double recipeReview;
  final int recipeServing;
  final List recipeIngredients;
  final String recipeMethod;
  final bool isPopular;

  Recipe({
    required this.recipeId,
    required this.recipeCategory,
    required this.recipeName,
    required this.recipeImage,
    required this.prepTime,
    required this.cookTime,
    required this.recipeServing,
    required this.recipeIngredients,
    required this.recipeMethod,
    required this.recipeReview,
    required this.isPopular,
  });

  // Factory constructor untuk membuat Recipe dari JSON
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      recipeId: json['recipeId'] ?? json['id'] ?? 0,
      recipeCategory: json['recipeCategory'] ?? '',
      recipeName: json['recipeName'] ?? '',
      recipeImage: json['recipeImage'] ?? '',
      prepTime: (json['prepTime'] ?? 0).toDouble(),
      cookTime: (json['cookTime'] ?? 0).toDouble(),
      recipeServing: json['recipeServing'] ?? 0,
      recipeIngredients: List<String>.from(json['recipeIngredients'] ?? []),
      recipeMethod: json['recipeMethod'] ?? '',
      recipeReview: json['recipeReview'] ?? 0,
      isPopular: json['isPopular'] ?? false,
    );
  }

  // Method untuk convert Recipe ke JSON
  Map<String, dynamic> toJson() {
    return {
      'recipeId': recipeId,
      'recipeCategory': recipeCategory,
      'recipeName': recipeName,
      'recipeImage': recipeImage,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'recipeServing': recipeServing,
      'recipeIngredients': recipeIngredients,
      'recipeMethod': recipeMethod,
      'recipeReview': recipeReview,
      'isPopular': isPopular,
    };
  }
}
