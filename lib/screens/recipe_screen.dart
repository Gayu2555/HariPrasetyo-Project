import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/models/models.dart';
import 'package:recipe_app/provider/provider.dart';
import 'package:unicons/unicons.dart';

class RecipeScreen extends StatelessWidget {
  const RecipeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recipe = ModalRoute.of(context)!.settings.arguments as Recipe;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 350.0,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
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
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(UniconsLine.share, color: Colors.black87),
                    onPressed: () {},
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Consumer<SavedProvider>(
                  builder: (context, savedProvider, child) {
                    final isSaved = savedProvider.getSaved.containsKey(
                      recipe.recipeId.toString(),
                    );

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          isSaved ? UniconsLine.bookmark : UniconsLine.bookmark,
                          color: isSaved
                              ? Theme.of(context).primaryColor
                              : Colors.black87,
                        ),
                        onPressed: () {
                          savedProvider.addAndRemoveFromSaved(
                            recipe.recipeId.toString(),
                            recipe.recipeCategory,
                            recipe.cookTime,
                            recipe.prepTime,
                            recipe.recipeImage,
                            recipe.recipeName,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: recipe.recipeImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RecipeAbout(recipe: recipe),
                      const SizedBox(height: 24.0),
                      RecipeStats(recipe: recipe),
                      const SizedBox(height: 24.0),
                      RecipeIngredient(recipe: recipe),
                      const SizedBox(height: 24.0),
                      RecipeMethod(recipe: recipe),
                      const SizedBox(height: 40.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeAbout extends StatelessWidget {
  final Recipe recipe;
  const RecipeAbout({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recipe.recipeName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 28.0,
              ),
        ),
        const SizedBox(height: 12.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            recipe.recipeCategory,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

class RecipeStats extends StatelessWidget {
  final Recipe recipe;
  const RecipeStats({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            icon: UniconsLine.clock,
            value: '${recipe.prepTime.toStringAsFixed(0)}m',
            label: 'Prep',
            color: const Color(0xFF6C63FF),
          ),
          Container(height: 50.0, width: 1, color: Colors.grey[300]),
          _buildStatItem(
            context,
            icon: UniconsLine.fire,
            value: '${recipe.cookTime.toStringAsFixed(0)}m',
            label: 'Cook',
            color: const Color(0xFFFF6B6B),
          ),
          Container(height: 50.0, width: 1, color: Colors.grey[300]),
          _buildStatItem(
            context,
            icon: UniconsLine.users_alt,
            value: '${recipe.recipeServing}',
            label: 'Servings',
            color: const Color(0xFF4ECDC4),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24.0),
        ),
        const SizedBox(height: 8.0),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 2.0),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}

class RecipeIngredient extends StatelessWidget {
  final Recipe recipe;
  const RecipeIngredient({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  UniconsLine.restaurant,
                  color: Color(0xFF4ECDC4),
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Text(
                'Ingredients',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          ...recipe.recipeIngredients.map((ingredient) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2.0),
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ECDC4).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      UniconsLine.check,
                      size: 16.0,
                      color: Color(0xFF4ECDC4),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      ingredient,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class RecipeMethod extends StatelessWidget {
  final Recipe recipe;
  const RecipeMethod({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  UniconsLine.book_open,
                  color: Color(0xFFFF6B6B),
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Text(
                'Cooking Method',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              recipe.recipeMethod,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: Colors.grey[800],
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
