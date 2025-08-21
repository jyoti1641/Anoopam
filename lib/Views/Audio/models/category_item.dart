// models/category_item.dart
class CategoryItem {
  final int id;
  final String title;
  final String cover_image;

  CategoryItem({
    required this.id,
    required this.title,
    required this.cover_image,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'],
      title: json['title'] as String,
      cover_image: json['cover_image'] as String,
    );
  }
}
