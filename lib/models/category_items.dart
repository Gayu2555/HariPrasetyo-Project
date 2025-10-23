class CategoryItems {
  final String image;
  final String category;

  const CategoryItems({required this.image, required this.category});

  CategoryItems copyWith({String? image, String? category}) {
    return CategoryItems(
      image: image ?? this.image,
      category: category ?? this.category,
    );
  }

  @override
  String toString() => 'CategoryItems(image: $image, category: $category)';
}
