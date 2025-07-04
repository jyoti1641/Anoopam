class Photo {
  final int id;
  final int albumId;
  final String imageUrl;
  final String country;
  final String state;
  final DateTime lastUpdated;

  Photo({
    required this.id,
    required this.albumId,
    required this.imageUrl,
    required this.country,
    required this.state,
    required this.lastUpdated,
  });

  // Factory constructor to create a Photo from a JSON map (for API integration)
  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      albumId: json['postId'],
      imageUrl: json['imageUrl'],
      country: json['country'],
      state: json['state'],
      lastUpdated: DateTime.parse(
        json['lastUpdatedTimestamp'].split('/').reversed.join('-'),
      ),
    );
  }

  // // Method to convert Photo to a JSON map
  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'albumId': albumId,
  //     'imageUrl': imageUrl,
  //     'caption': caption,
  //     'country': country,
  //     'state': state,
  //     'lastUpdated': lastUpdated.toIso8601String(),
  //   };
  // }
}
