import 'package:flutter/foundation.dart';
import 'package:recipe_app/models/food.dart';
import 'package:recipe_app/services/recipe_api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:recipe_app/services/auth_storage.dart';

class ListOfRecipes with ChangeNotifier {
  final RecipeApiService _apiService = RecipeApiService();

  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _error;

  List<Recipe> get getRecipes => _recipes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRecipes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final recipes = await _apiService.getAllRecipes();
      _recipes = recipes;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _recipes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔍 CARI RESEP BERDASARKAN KATEGORI
  List<Recipe> findByCategory(String categoryName) {
    if (categoryName == 'All' || categoryName.isEmpty) {
      return _recipes;
    }
    return _recipes
        .where((recipe) =>
            recipe.recipeCategory.toLowerCase() == categoryName.toLowerCase())
        .toList();
  }

  // ⭐ AMBIL RESEP POPULER
  List<Recipe> get popularRecipes =>
      _recipes.where((recipe) => recipe.isPopular == true).toList();

  // 🔍 CARI RESEP BERDASARKAN ID
  Recipe findById(int id) {
    return _recipes.firstWhere(
      (recipe) => recipe.recipeId == id,
      orElse: () => throw Exception('Recipe not found'),
    );
  }

  // 🔍 PENCARIAN RESEP
  Future<List<Recipe>> searchRecipe(String searchText) async {
    if (searchText.trim().isEmpty) {
      return _recipes;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final recipes = await _apiService.searchRecipes(searchText);
      _error = null;
      return recipes;
    } catch (e) {
      _error = 'Gagal mencari resep: $e';
      return _recipes
          .where((recipe) => recipe.recipeName
              .toLowerCase()
              .contains(searchText.toLowerCase()))
          .toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔄 REFRESH DATA
  Future<void> refresh() async {
    await loadRecipes();
  }

  // 📖 GET DETAIL RESEP LENGKAP DENGAN LANGKAH DAN FOTO
  Future<Map<String, dynamic>> getRecipeDetails(int recipeId) async {
    const String baseUrl = 'https://api.gayuyunma.my.id';

    try {
      final token = await AuthStorage.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/recipes/$recipeId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('=== GET RECIPE DETAILS ===');
      debugPrint('URL: $baseUrl/recipes/$recipeId');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Parse dan format data sesuai kebutuhan
        return {
          'id': data['id'] ?? recipeId,
          'title': data['title'] ?? '',
          'description': data['description'] ?? '',
          'category': data['category'] ?? '',
          'difficulty': data['difficulty'] ?? 'Sedang',
          'servings': data['servings'] ?? 4,
          'prepTime': data['prepTime'] ?? 0,
          'cookTime': data['cookTime'] ?? 0,
          'mainImage': data['mainImage'] ?? '',
          'ingredients':
              (data['ingredients'] as List<dynamic>?)?.map((ingredient) {
                    // Handle jika ingredients berupa string atau object
                    if (ingredient is String) {
                      return ingredient;
                    } else if (ingredient is Map) {
                      return ingredient['name'] ??
                          ingredient['ingredient'] ??
                          ingredient.toString();
                    }
                    return ingredient.toString();
                  }).toList() ??
                  [],
          'steps': (data['steps'] as List<dynamic>?)?.map((step) {
                return {
                  'order': step['order'] ?? 0,
                  'description': step['description'] ?? step['step'] ?? '',
                  'image': step['image'] ?? step['stepImage'], // bisa null
                };
              }).toList() ??
              [],
          'author': data['author'] ?? {},
          'createdAt': data['createdAt'],
          'updatedAt': data['updatedAt'],
        };
      } else if (response.statusCode == 404) {
        throw Exception('Resep tidak ditemukan');
      } else if (response.statusCode == 401) {
        throw Exception('Sesi berakhir. Silakan login kembali');
      } else {
        throw Exception('Gagal memuat detail resep: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in getRecipeDetails: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
