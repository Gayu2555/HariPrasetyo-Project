import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/provider/provider.dart';
import 'package:recipe_app/screens/screens.dart';
import 'package:recipe_app/widgets/widgets.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final savedProvider = Provider.of<SavedProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: savedProvider.getSaved.isEmpty
                ? const EmptyRecipe()
                : const SavedRecipes(),
          ),
        ),
      ),
    );
  }
}

class SavedRecipes extends StatefulWidget {
  const SavedRecipes({Key? key}) : super(key: key);

  @override
  State<SavedRecipes> createState() => _SavedRecipesState();
}

class _SavedRecipesState extends State<SavedRecipes> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final savedProvider = Provider.of<SavedProvider>(context);

    // Filter recipes berdasarkan tab yang dipilih
    List<dynamic> filteredRecipes = savedProvider.getSaved.values.toList();
    if (_selectedTabIndex == 1) {
      filteredRecipes = filteredRecipes
          .where((recipe) => recipe.recipeCategory == 'Main Course')
          .toList();
    } else if (_selectedTabIndex == 2) {
      filteredRecipes = filteredRecipes
          .where((recipe) => recipe.recipeCategory == 'Appetizer')
          .toList();
    } else if (_selectedTabIndex == 3) {
      filteredRecipes = filteredRecipes
          .where((recipe) => recipe.recipeCategory == 'Dessert')
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 6.0.h),
        Text(
          'Saved Recipes',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 28.0,
          ),
        ),
        SizedBox(height: 2.0.h),
        Text(
          '${savedProvider.getSaved.length} recipes saved',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
            fontSize: 14.0,
          ),
        ),
        SizedBox(height: 4.0.h),
        TabRow(
          tabs: const ['All Recipes', 'Main Course', 'Appetizer', 'Dessert'],
          selectedIndex: _selectedTabIndex,
          onTap: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
        ),
        SizedBox(height: 2.0.h),
        filteredRecipes.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0.h),
                  child: Column(
                    children: [
                      Icon(
                        UniconsLine.folder_open,
                        size: 60.0,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'No recipes in this category',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(height: 15.0);
                  },
                  itemCount: filteredRecipes.length,
                  itemBuilder: (context, index) {
                    var recipe = filteredRecipes[index];
                    return Dismissible(
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: AlignmentDirectional.centerEnd,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        height: 20.0,
                        padding: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            0.0,
                            0.0,
                            20.0,
                            0.0,
                          ),
                          child: Icon(
                            UniconsLine.trash,
                            color: Colors.white,
                            size: 24.0,
                          ),
                        ),
                      ),
                      key: UniqueKey(),
                      onDismissed: (direction) {
                        setState(() {
                          savedProvider.removeRecipe(recipe.recipeId);
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${recipe.recipeName} deleted'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        );
                      },
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RecipeScreen(),
                              settings: RouteSettings(arguments: recipe),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12.0),
                        child: Container(
                          height: 20.0.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
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
                                  topLeft: Radius.circular(12.0),
                                  bottomLeft: Radius.circular(12.0),
                                ),
                                child: ReusableNetworkImage(
                                  imageUrl: recipe.recipeImage,
                                  height: 20.0.h,
                                  width: 20.0.h,
                                ),
                              ),
                              SizedBox(width: 2.0.h),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe.recipeName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 1.5.h),
                                    Row(
                                      children: [
                                        Icon(
                                          UniconsLine.clock,
                                          size: 16.0,
                                          color: Colors.grey.shade500,
                                        ),
                                        SizedBox(width: 1.5.w),
                                        Text(
                                          '${recipe.prepTime.toStringAsFixed(0)} M Prep',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 1.0.h),
                                    Row(
                                      children: [
                                        Icon(
                                          UniconsLine.fire,
                                          size: 16.0,
                                          color: Colors.grey.shade500,
                                        ),
                                        SizedBox(width: 1.5.w),
                                        Text(
                                          '${recipe.cookTime.toStringAsFixed(0)} M Cook',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16.0,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}

class EmptyRecipe extends StatelessWidget {
  const EmptyRecipe({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/recipebook.gif', height: 200.0),
              SizedBox(height: 3.0.h),
              Text(
                'No Saved Recipes Yet',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.5.h),
              Text(
                'Start saving your favorite recipes and they\'ll appear here',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.0.h),
              InkWell(
                borderRadius: BorderRadius.circular(12.0),
                onTap: () {
                  // Navigasi ke RecipesScreen dengan argument 'All'
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecipesScreen(),
                      settings: const RouteSettings(arguments: 'All'),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        UniconsLine.compass,
                        color: Colors.white,
                        size: 22.0,
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        'Explore Recipes',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
