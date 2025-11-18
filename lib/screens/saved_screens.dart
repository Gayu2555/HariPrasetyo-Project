import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/provider/provider.dart';
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
      body: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: savedProvider.getSaved.isEmpty
            ? const EmptyRecipe()
            : const SavedRecipes(),
      ),
    );
  }
}

class SavedRecipes extends StatelessWidget {
  const SavedRecipes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final savedProvider = Provider.of<SavedProvider>(context);
    final savedList = savedProvider.getSaved.values.toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6.0.h),
          Text('Saved', style: Theme.of(context).textTheme.displayLarge),
          SizedBox(height: 4.0.h),
          TabRow(
            tabs: const ['All Recipes', 'Main Course', 'Appetizer', 'Dessert'],
            selectedIndex: 0,
            onTap: (index) {},
          ),
          SizedBox(height: 2.0.h),
          // Gunakan ListView biasa (bukan dengan height tetap)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: savedList.length,
            itemBuilder: (context, index) {
              final recipe = savedList[index];
              return Dismissible(
                key: Key(recipe.recipeId.toString()), // ✅ Unique dan stabil
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  color: Colors.red,
                  padding: const EdgeInsets.only(right: 15.0),
                  child: Icon(
                    UniconsLine.trash,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                onDismissed: (direction) {
                  savedProvider.removeRecipe(recipe.recipeId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${recipe.recipeName} deleted')),
                  );
                },
                child: InkWell(
                  onTap: () {
                    // Opsional: navigasi ke detail resep
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // ✅ Gambar dengan SizedBox + ReusableNetworkImage
                        SizedBox(
                          width: 20.0.h,
                          height: 20.0.h,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12.0),
                              bottomLeft: Radius.circular(12.0),
                            ),
                            child: ReusableNetworkImage(
                              imageUrl: recipe.recipeImage,
                            ),
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
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                                maxLines: 1,
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
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
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
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class EmptyRecipe extends StatelessWidget {
  const EmptyRecipe({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10.h),
          Image.asset(
            'assets/recipebook.gif',
            height: 150,
            width: 150,
          ),
          const SizedBox(height: 16),
          Text(
            'You haven\'t saved any recipes yet',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Want to take a look?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 2.5.h),
          SizedBox(
            width: double.infinity,
            height: 45.0,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 2,
              ),
              child: Text(
                'Explore',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
