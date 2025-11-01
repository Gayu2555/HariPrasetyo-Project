import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:recipe_app/models/models.dart';

class RecipeApiService {
  static const String baseUrl = 'https://api.gayuyunma.my.id';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // GET /recipes — bisa pakai query: category, search, page, limit
  Future<List<Recipe>> getAllRecipes() async {
    return _fetchRecipes();
  }

  // Gunakan query `category`
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    return _fetchRecipes(category: category);
  }

  // Gunakan query `search`
  Future<List<Recipe>> searchRecipes(String query) async {
    return _fetchRecipes(search: query);
  }

  // Untuk "popular", kamu bisa:
  // - Tambahkan field `isPopular` di database, lalu filter via query
  // - Atau ambil semua resep lalu urutkan di client (tidak disarankan)
  // Sementara, kita asumsikan ada query `popular=true`
  Future<List<Recipe>> getPopularRecipes() async {
    return _fetchRecipes(popular: true);
  }

  // Helper method
  Future<List<Recipe>> _fetchRecipes({
    String? category,
    String? search,
    bool? popular,
    int page = 1,
    int limit = 100, // ambil semua sekalian
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
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get by ID — ini aman, karena endpoint /recipes/:id ada
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
