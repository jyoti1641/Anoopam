// lib/models/sahebji_occasion.dart
class SahebjiOccasion {
  final int id;
  final String name;

  SahebjiOccasion({
    required this.id,
    required this.name,
  });

  factory SahebjiOccasion.fromJson(Map<String, dynamic> json) {
    return SahebjiOccasion(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
