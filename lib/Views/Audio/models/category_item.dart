// models/category_item.dart
class CategoryItem {
  final String catID;
  final String catName;
  final String catImage;

  CategoryItem({
    required this.catID,
    required this.catName,
    required this.catImage,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      catID: json['catID'] as String,
      catName: json['catName'] as String,
      catImage: json['catImage'] as String,
    );
  }
}
