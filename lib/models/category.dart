class Category {
  final String mainCatID;
  final String catID;
  final String catName;
  final String catImage;
  // Removed date and duration as they are not in the provided API snippet for categories

  Category({
    required this.mainCatID,
    required this.catID,
    required this.catName,
    required this.catImage,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      mainCatID: json['mainCatID'],
      catID: json['catID'],
      catName: json['catName'],
      catImage: json['catImage'],
    );
  }
}
