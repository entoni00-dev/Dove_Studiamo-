class StudyPlace {
  final String id;
  final String name;
  final String address;
  final String city;
  final String category;
  final String? googlePlaceId;
  final double rating;
  final int reviewsCount;
  final bool hasWifi;
  final bool hasPowerOutlets;
  final bool isQuiet;
  final bool isFree;
  final String imageUrl;
  final String description;
  final List<String> tags;
  final bool isFavorite;

  StudyPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.category,
    this.googlePlaceId,
    required this.rating,
    required this.reviewsCount,
    required this.hasWifi,
    required this.hasPowerOutlets,
    required this.isQuiet,
    required this.isFree,
    required this.imageUrl,
    required this.description,
    required this.tags,
    this.isFavorite = false,
  });
  StudyPlace copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? category,
    String? googlePlaceId,
    double? rating,
    int? reviewsCount,
    bool? hasWifi,
    bool? hasPowerOutlets,
    bool? isQuiet,
    bool? isFree,
    String? imageUrl,
    String? description,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return StudyPlace(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      category: category ?? this.category,
      googlePlaceId: googlePlaceId ?? this.googlePlaceId,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      hasWifi: hasWifi ?? this.hasWifi,
      hasPowerOutlets: hasPowerOutlets ?? this.hasPowerOutlets,
      isQuiet: isQuiet ?? this.isQuiet,
      isFree: isFree ?? this.isFree,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
