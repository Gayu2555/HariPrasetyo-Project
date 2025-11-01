import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/provider/provider.dart';
import 'package:recipe_app/screens/screens.dart';
import 'package:recipe_app/widgets/widgets.dart';
import 'package:unicons/unicons.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryName;

  const CategoryScreen({
    Key? key,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecipes();
    });
  }

  Future<void> _loadRecipes() async {
    final categoryName = widget.categoryName;
    final recipesProvider = Provider.of<ListOfRecipes>(context, listen: false);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (recipesProvider.getRecipes.isEmpty) {
        await recipesProvider.loadRecipes();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryName = widget.categoryName;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: const Color(0xFFF8F9FA),
              elevation: 0,
              pinned: true,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              expandedHeight: 120.0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20.0, bottom: 16.0),
                title: Text(
                  categoryName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 28.0,
                  ),
                ),
                background: Container(color: const Color(0xFFF8F9FA)),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error loading recipes',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(_error!, textAlign: TextAlign.center),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadRecipes,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else
              CategoryRecipesList(categoryName: categoryName),
          ],
        ),
      ),
    );
  }
}

// Sisanya tetap sama (CategoryRecipesList, _buildInfoChip) — tidak diubah
class CategoryRecipesList extends StatelessWidget {
  final String categoryName;
  const CategoryRecipesList({Key? key, required this.categoryName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ListOfRecipes>(
      builder: (context, recipesProvider, child) {
        final recipeList = recipesProvider.findByCategory(categoryName);
        final savedProvider = Provider.of<SavedProvider>(context);

        if (recipeList.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No recipes found',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(20.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final recipe = recipeList[index];
                final isSaved = savedProvider.getSaved
                    .containsKey(recipe.recipeId.toString());

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20.0),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeScreen(), // tanpa const
                        settings: RouteSettings(arguments: recipe),
                      ),
                    ),
                    child: Container(
                      height: 140.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              bottomLeft: Radius.circular(20.0),
                            ),
                            child: ReusableNetworkImage(
                              height: 140.0,
                              width: 120.0,
                              imageUrl: recipe.recipeImage,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    recipe.recipeName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12.0),
                                  Row(
                                    children: [
                                      _buildInfoChip(
                                        context,
                                        icon: UniconsLine.clock,
                                        text:
                                            '${recipe.prepTime.toStringAsFixed(0)}m',
                                        color: const Color(0xFF6C63FF),
                                      ),
                                      const SizedBox(width: 8.0),
                                      _buildInfoChip(
                                        context,
                                        icon: UniconsLine.fire,
                                        text:
                                            '${recipe.cookTime.toStringAsFixed(0)}m',
                                        color: const Color(0xFFFF6B6B),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSaved
                                    ? Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1)
                                    : Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  UniconsLine.bookmark,
                                  color: isSaved
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[400],
                                  size: 24.0,
                                ),
                                onPressed: () {
                                  context
                                      .read<SavedProvider>()
                                      .addAndRemoveFromSaved(
                                        recipe.recipeId.toString(),
                                        recipe.recipeCategory,
                                        recipe.cookTime,
                                        recipe.prepTime,
                                        recipe.recipeImage,
                                        recipe.recipeName,
                                      );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: recipeList.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(BuildContext context,
      {required IconData icon, required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.0, color: color),
          const SizedBox(width: 4.0),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }
}
