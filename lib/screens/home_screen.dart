import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

// --- IMPORT FILE KAMU ---
import 'package:recipe_app/provider/provider.dart';
import 'package:recipe_app/screens/screens.dart';
import 'package:recipe_app/utils/utils.dart';
import 'package:recipe_app/widgets/widgets.dart';
import 'package:recipe_app/models/models.dart';

// ===============================================================
// 1. HOMESCREEN UTAMA (Mengatur Navigasi)
// ===============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const SearchScreen(),
    const SavedScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        elevation: 8,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// 2. SEARCH SCREEN WRAPPER
// ===============================================================
class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const RecipesScreen(),
          settings: const RouteSettings(arguments: 'All'),
        );
      },
    );
  }
}

// ===============================================================
// 3. KONTEN UTAMA TAB "HOME"
// ===============================================================
class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HomeLogoText(),
                  const SizedBox(height: 20.0),
                  const HomeHeaderRow(),
                  const SizedBox(height: 30.0),
                  const SearchField(),
                  const SizedBox(height: 35.0),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: HomeGrid()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Recipes',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecipesScreen(),
                          settings: const RouteSettings(arguments: 'Popular'),
                        ),
                      );
                    },
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20.0)),
          SliverToBoxAdapter(
            child: Selector<ListOfRecipes, List<Recipe>>(
              selector: (_, provider) => provider.popularRecipes,
              shouldRebuild: (previous, next) => previous != next,
              builder: (context, popularRecipes, child) {
                return HomePopularCarousel(popularRecipes: popularRecipes);
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30.0)),
        ],
      ),
    );
  }
}

// ===============================================================
// 4. WIDGET KOMPONEN
// ===============================================================

class HomeHeaderRow extends StatelessWidget {
  const HomeHeaderRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning 👋',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 5.0),
              Text(
                'Devina',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 28.0,
                    ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const ProfileImage(
            height: 55.0,
            image:
                'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1740&q=80',
          ),
        ),
      ],
    );
  }
}

class HomeGrid extends StatelessWidget {
  const HomeGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110.0,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemCount: iconList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return InkWell(
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
              width: 100.0,
              margin: const EdgeInsets.only(right: 15.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(iconList[index].icon, height: 45.0),
                  const SizedBox(height: 8.0),
                  Text(
                    iconList[index].text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.0,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CategoryScreen(categoryName: items[index].category),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ===============================================================
// 5. CAROUSEL WIDGET UNTUK POPULAR RECIPES
// ===============================================================

class HomePopularCarousel extends StatefulWidget {
  final List<Recipe> popularRecipes;
  const HomePopularCarousel({Key? key, required this.popularRecipes})
      : super(key: key);

  @override
  State<HomePopularCarousel> createState() => _HomePopularCarouselState();
}

class _HomePopularCarouselState extends State<HomePopularCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85, initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 380.0,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.popularRecipes.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
                  }
                  return Center(
                    child: SizedBox(
                      height: Curves.easeOut.transform(value) * 380.0,
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20.0),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecipeScreen(),
                          settings: RouteSettings(
                            arguments: widget.popularRecipes[index],
                          ),
                        ),
                      );
                    },
                    child: HomeStack(
                      image: widget.popularRecipes[index].recipeImage,
                      text: widget.popularRecipes[index].recipeName,
                      prepTime: widget.popularRecipes[index].prepTime,
                      cookTime: widget.popularRecipes[index].cookTime,
                      recipeReview: widget.popularRecipes[index].recipeReview,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.popularRecipes.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              height: 8.0,
              width: _currentPage == index ? 24.0 : 8.0,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ===============================================================
// 6. CARD WIDGET UNTUK RECIPE
// ===============================================================

class HomeStack extends StatelessWidget {
  final String image;
  final String text;
  final double prepTime;
  final double cookTime;
  final double recipeReview;

  const HomeStack({
    Key? key,
    required this.image,
    required this.text,
    required this.prepTime,
    required this.cookTime,
    required this.recipeReview,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Stack(
          children: [
            ReusableNetworkImage(imageUrl: image, height: 380.0, width: 250.0),
            Container(
              height: 380.0,
              width: 250.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 15.0,
              right: 15.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 6.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      UniconsLine.star,
                      size: 16.0,
                      color: Color(0xFFFFB800),
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      recipeReview.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            UniconsLine.clock,
                            size: 16.0,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            '${(prepTime + cookTime).toInt()} mins',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
