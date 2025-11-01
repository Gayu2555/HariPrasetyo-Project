import 'package:flutter/material.dart';
import 'package:recipe_app/models/models.dart';
import 'package:recipe_app/services/recipe_api_service.dart';

class ListOfRecipes with ChangeNotifier {
  final RecipeApiService _apiService = RecipeApiService();

  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _error;

  List<Recipe> get getRecipes => _recipes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all recipes from API
  Future<void> loadRecipes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recipes = await _apiService.getAllRecipes();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _recipes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Find recipe by ID
  Recipe findById(int id) {
    return _recipes.firstWhere(
      (recipe) => recipe.recipeId == id,
      orElse: () => throw Exception('Recipe not found'),
    );
  }

  // Find recipes by category (from cached data)
  List<Recipe> findByCategory(String categoryName) {
    return _recipes
        .where((element) => element.recipeCategory.toLowerCase().contains(
              categoryName.toLowerCase(),
            ))
        .toList();
  }

  // Load recipes by category from API
  Future<List<Recipe>> loadRecipesByCategory(String categoryName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final recipes = await _apiService.getRecipesByCategory(categoryName);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return recipes;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Get popular recipes (from cached data)
  List<Recipe> get popularRecipes {
    return _recipes.where((element) => element.isPopular).toList();
  }

  // Load popular recipes from API
  Future<List<Recipe>> loadPopularRecipes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final recipes = await _apiService.getPopularRecipes();
      _error = null;
      _isLoading = false;
      notifyListeners();
      return recipes;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Search recipes
  Future<List<Recipe>> searchRecipe(String searchText) async {
    if (searchText.isEmpty) {
      return _recipes;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final recipes = await _apiService.searchRecipes(searchText);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return recipes;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();

      // Fallback to local search if API fails
      return _recipes
          .where((element) => element.recipeName.toLowerCase().contains(
                searchText.toLowerCase(),
              ))
          .toList();
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadRecipes();
  }
}
