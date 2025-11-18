import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/provider/provider.dart';
import 'package:recipe_app/widgets/widgets.dart';

class RecipeDetailScreen extends StatefulWidget {
  final dynamic recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _recipeDetails;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Validasi recipe sebelum load details
    if (widget.recipe == null) {
      setState(() {
        _errorMessage =
            'Data resep tidak valid. Tipe: ${widget.recipe.runtimeType}';
        _isLoading = false;
      });
    } else {
      _loadRecipeDetails();
    }
  }

  // Helper method untuk safely get recipe ID sebagai int
  int _getRecipeId() {
    return widget.recipe?.recipeId ?? 0;
  }

  Future<void> _loadRecipeDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load detail resep dari API
      final recipesProvider =
          Provider.of<ListOfRecipes>(context, listen: false);

      final recipeId = _getRecipeId();

      if (recipeId == 0) {
        throw Exception('Recipe ID tidak ditemukan');
      }

      final details = await recipesProvider.getRecipeDetails(recipeId);

      if (mounted) {
        setState(() {
          _recipeDetails = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildRecipeContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xfffe0000)),
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(UniconsLine.exclamation_triangle,
                size: 64, color: Color(0xfffe0000)),
            const SizedBox(height: 24),
            const Text(
              'Gagal memuat resep',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadRecipeDetails,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeContent() {
    final savedProvider = Provider.of<SavedProvider>(context);
    final recipeId = _getRecipeId();
    final isSaved = savedProvider.getSaved.containsKey(recipeId.toString());

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(isSaved, savedProvider),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecipeHeader(),
              _buildRecipeInfo(),
              _buildDescription(),
              _buildIngredients(),
              _buildSteps(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(bool isSaved, SavedProvider savedProvider) {
    final recipeImage = widget.recipe?.fullImageUrl ?? '';

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios_new, color: Color(0xfffe0000)),
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
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                isSaved ? UniconsLine.bookmark : UniconsLine.bookmark,
                color: isSaved ? const Color(0xfffe0000) : Colors.grey[400],
              ),
              onPressed: () {
                savedProvider.addAndRemoveFromSaved(
                  _getRecipeId().toString(),
                  widget.recipe?.recipeCategory ?? '',
                  widget.recipe?.cookTime ?? 0,
                  widget.recipe?.prepTime ?? 0,
                  widget.recipe?.fullImageUrl ?? '',
                  widget.recipe?.recipeName ?? '',
                );
              },
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            recipeImage.isNotEmpty
                ? ReusableNetworkImage(imageUrl: recipeImage)
                : Container(
                    color: Colors.grey[300],
                    child:
                        const Icon(Icons.image, size: 100, color: Colors.grey),
                  ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeHeader() {
    final recipeName = widget.recipe?.recipeName ?? 'Nama Resep Tidak Tersedia';
    final recipeCategory = widget.recipe?.recipeCategory ?? 'Kategori';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipeName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip(
                icon: UniconsLine.utensils,
                label: recipeCategory,
                color: const Color(0xfffe0000),
              ),
              _buildChip(
                icon: UniconsLine.chart_bar,
                label: _recipeDetails?['difficulty']?.toString() ?? 'Medium',
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
      {required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeInfo() {
    final servings =
        _recipeDetails?['servings'] ?? widget.recipe?.recipeServing ?? 4;
    final prepTime = widget.recipe?.prepTime ?? 0;
    final cookTime = widget.recipe?.cookTime ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(UniconsLine.user, '$servings', 'Porsi'),
          _buildDivider(),
          _buildInfoItem(
              UniconsLine.clock, '${prepTime.toInt()}', 'Prep (min)'),
          _buildDivider(),
          _buildInfoItem(
              UniconsLine.fire, '${cookTime.toInt()}', 'Masak (min)'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xfffe0000), size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.grey[300],
    );
  }

  Widget _buildDescription() {
    final description = _recipeDetails?['description']?.toString() ??
        widget.recipe?.recipeMethod ??
        '';

    if (description.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deskripsi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.grey[700],
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredients() {
    final ingredients = _recipeDetails?['ingredients'] as List<dynamic>? ?? [];

    if (ingredients.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xfffe0000).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  UniconsLine.shopping_cart,
                  color: Color(0xfffe0000),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Bahan-Bahan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: List.generate(ingredients.length, (index) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: index < ingredients.length - 1
                          ? BorderSide(color: Colors.grey[200]!)
                          : BorderSide.none,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xfffe0000),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          ingredients[index].toString(),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                            height: 1.4,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSteps() {
    final steps = _recipeDetails?['steps'] as List<dynamic>? ?? [];

    if (steps.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xfffe0000).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  UniconsLine.list_ul,
                  color: Color(0xfffe0000),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Langkah-Langkah',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (index) {
            final step =
                steps[index] is Map ? steps[index] as Map<String, dynamic> : {};
            final description = step['description']?.toString() ?? '';
            final imageUrl = step['image']?.toString();
            final stepNumber = index + 1;

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xfffe0000),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$stepNumber',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Langkah $stepNumber',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.6,
                                  color: Colors.grey[700],
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (imageUrl != null && imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: ReusableNetworkImage(imageUrl: imageUrl),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
