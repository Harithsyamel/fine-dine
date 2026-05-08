// lib/models/menu_package.dart
class MenuPackage {
  final String id;
  final String name;
  final String description;
  final double pricePerGuest;
  final List<String> imageUrls;
  final List<String> includes; // items included in package
  final String category;    // e.g. 'Western', 'Asian', 'Fusion'
  final int minGuests;
  final int maxGuests;
  final bool isAvailable;
  final int orderCount;     // for "Most Ordered" feature
  final DateTime createdAt;

  MenuPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerGuest,
    required this.imageUrls,
    required this.includes,
    this.category = 'All',
    this.minGuests = 10,
    this.maxGuests = 200,
    this.isAvailable = true,
    this.orderCount = 0,
    required this.createdAt,
  });

  factory MenuPackage.fromMap(Map<String, dynamic> map, String id) {
    return MenuPackage(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      pricePerGuest: (map['pricePerGuest'] ?? 0.0).toDouble(),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      includes: List<String>.from(map['includes'] ?? []),
      category: map['category'] ?? 'All',
      minGuests: map['minGuests'] ?? 10,
      maxGuests: map['maxGuests'] ?? 200,
      isAvailable: map['isAvailable'] ?? true,
      orderCount: map['orderCount'] ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'pricePerGuest': pricePerGuest,
      'imageUrls': imageUrls,
      'includes': includes,
      'category': category,
      'minGuests': minGuests,
      'maxGuests': maxGuests,
      'isAvailable': isAvailable,
      'orderCount': orderCount,
      'createdAt': createdAt,
    };
  }

  MenuPackage copyWith({
    String? name,
    String? description,
    double? pricePerGuest,
    List<String>? imageUrls,
    List<String>? includes,
    String? category,
    int? minGuests,
    int? maxGuests,
    bool? isAvailable,
    int? orderCount,
  }) {
    return MenuPackage(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      pricePerGuest: pricePerGuest ?? this.pricePerGuest,
      imageUrls: imageUrls ?? this.imageUrls,
      includes: includes ?? this.includes,
      category: category ?? this.category,
      minGuests: minGuests ?? this.minGuests,
      maxGuests: maxGuests ?? this.maxGuests,
      isAvailable: isAvailable ?? this.isAvailable,
      orderCount: orderCount ?? this.orderCount,
      createdAt: createdAt,
    );
  }
}
