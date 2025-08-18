// models/category_item.dart
class CategoryItem {
  final String id;
  final String title;
  final String cover_image;

  CategoryItem({
    required this.id,
    required this.title,
    required this.cover_image,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] as String,
      title: json['title'] as String,
      cover_image: json['cover_image'] as String,
    );
  }
}
