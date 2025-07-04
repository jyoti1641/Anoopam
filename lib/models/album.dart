class Album {
  final int id;
  final String name;
  final String thumbnailUrl; // For displaying album cover

  Album({required this.id, required this.name, required this.thumbnailUrl});

  // Factory constructor to create an Album from a JSON map (for API integration)
  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      name: json['title'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }

  // // Method to convert Album to a JSON map (if you need to send data to API)
  // Map<String, dynamic> toJson() {
  //   return {'id': id, 'name': name, 'thumbnailUrl': thumbnailUrl};
  // }
}
