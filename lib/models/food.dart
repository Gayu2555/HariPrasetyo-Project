// lib/models/food.dart
import 'dart:convert';

class Recipe {
  // ⚙️ GUNAKAN DOMAIN ANDA
  static String get baseUrl => 'https://api.gayuyunma.my.id';

  final int recipeId;
  final String recipeCategory;
  final String recipeName;
  final String recipeImage; // Raw image path dari backend
  final double prepTime;
  final double cookTime;
  final double recipeReview;
  final int recipeServing;
  final List<String> recipeIngredients;
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

  // 🖼️ Getter untuk full image URL
  String get fullImageUrl {
    if (recipeImage.isEmpty) return '';

    // Jika sudah full URL (dimulai dengan http), langsung return
    if (recipeImage.startsWith('http://') ||
        recipeImage.startsWith('https://')) {
      return recipeImage;
    }

    // Jika path relatif, concat dengan base URL
    // Backend mengirim: "/uploads/recipes/filename.jpg" atau "filename.jpg"
    if (recipeImage.startsWith('/')) {
      return '$baseUrl$recipeImage';
    }

    return '$baseUrl/uploads/recipes/$recipeImage';
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<String> parseIngredients(dynamic ingredients) {
      if (ingredients == null) return [];
      if (ingredients is! List) return [];

      return (ingredients as List)
          .map((e) {
            if (e is Map<String, dynamic>) {
              return e['name']?.toString() ?? '';
            }
            return '';
          })
          .where((name) => name.isNotEmpty)
          .toList();
    }

    // Akses _count dengan aman
    final count = json['_count'] as Map<String, dynamic>? ?? {};
    final reviews = count['reviews'] as num? ?? 0;
    final favorites = count['favorites'] as num? ?? 0;

    // 🔧 PERBAIKAN: Cek 'mainImage' dulu, fallback ke 'image'
    final imageUrl =
        json['mainImage'] as String? ?? json['image'] as String? ?? '';

    return Recipe(
      recipeId: json['id'] ?? 0,
      recipeCategory: json['category'] ?? '',
      recipeName: json['title'] ?? '',
      recipeImage: imageUrl.trim(), // Simpan raw path
      prepTime: (json['prepTime'] ?? 0).toDouble(),
      cookTime: (json['cookTime'] ?? 0).toDouble(),
      recipeServing: json['servings'] ?? 0,
      recipeIngredients: parseIngredients(json['ingredients']),
      recipeMethod: json['description'] ?? '',
      recipeReview: reviews.toDouble(),
      isPopular: reviews > 0 || favorites > 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': recipeId,
      'category': recipeCategory,
      'title': recipeName,
      'mainImage': recipeImage, // Gunakan mainImage untuk konsistensi
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': recipeServing,
      'description': recipeMethod,
      '_count': {
        'reviews': recipeReview,
        'favorites': 0,
      },
      'isPopular': isPopular,
    };
  }

  Recipe copyWith({
    int? recipeId,
    String? recipeCategory,
    String? recipeName,
    String? recipeImage,
    double? prepTime,
    double? cookTime,
    int? recipeServing,
    List<String>? recipeIngredients,
    String? recipeMethod,
    double? recipeReview,
    bool? isPopular,
  }) {
    return Recipe(
      recipeId: recipeId ?? this.recipeId,
      recipeCategory: recipeCategory ?? this.recipeCategory,
      recipeName: recipeName ?? this.recipeName,
      recipeImage: recipeImage ?? this.recipeImage,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      recipeServing: recipeServing ?? this.recipeServing,
      recipeIngredients: recipeIngredients ?? this.recipeIngredients,
      recipeMethod: recipeMethod ?? this.recipeMethod,
      recipeReview: recipeReview ?? this.recipeReview,
      isPopular: isPopular ?? this.isPopular,
    );
  }

  @override
  String toString() {
    return 'Recipe(id: $recipeId, name: $recipeName, image: $recipeImage, fullUrl: $fullImageUrl)';
  }
}
