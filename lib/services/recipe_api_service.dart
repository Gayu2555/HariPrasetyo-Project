import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:recipe_app/models/models.dart';

class RecipeApiService {
  static const String baseUrl = 'https://api.gayuyunma.my.id';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<List<Recipe>> getAllRecipes() async {
    return _fetchRecipes();
  }

  Future<List<Recipe>> getRecipesByCategory(String category) async {
    return _fetchRecipes(category: category);
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    return _fetchRecipes(search: query);
  }

  Future<List<Recipe>> getPopularRecipes() async {
    return _fetchRecipes(popular: true);
  }

  Future<List<Recipe>> _fetchRecipes({
    String? category,
    String? search,
    bool? popular,
    int page = 1,
    int limit = 100,
  }) async {
    final uri = Uri(
      scheme: 'https',
      host: 'api.gayuyunma.my.id',
      path: 'recipes',
      queryParameters: {
        if (category != null) 'category': category,
        if (search != null) 'search': search,
        if (popular == true) 'popular': 'true',
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    try {
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        // ✅ Perbaikan utama: parse 'data' dari response
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> data = responseBody['data'] ?? [];
        return data
            .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Recipe> getRecipeById(int id) async {
    final uri = Uri.parse('$baseUrl/recipes/$id');
    try {
      final response = await http.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        return Recipe.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load recipe: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching recipe: $e');
    }
  }
}
