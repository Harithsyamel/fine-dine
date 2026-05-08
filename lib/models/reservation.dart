// lib/models/reservation.dart
enum ReservationStatus { upcoming, completed, cancelled }

class ServiceCustomization {
  final String name;
  final double price;

  ServiceCustomization({required this.name, required this.price});

  factory ServiceCustomization.fromMap(Map<String, dynamic> map) {
    return ServiceCustomization(
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'price': price};
}

class Reservation {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String packageId;
  final String packageName;
  final String packageImageUrl;
  final double pricePerGuest;
  final int numGuests;
  final DateTime eventDate;
  final String eventTime;
  final String? additionalPreferences;
  final List<ServiceCustomization> customizations;
  final double totalPrice;
  final ReservationStatus status;
  final double? rating;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Reservation({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.packageId,
    required this.packageName,
    required this.packageImageUrl,
    required this.pricePerGuest,
    required this.numGuests,
    required this.eventDate,
    required this.eventTime,
    this.additionalPreferences,
    this.customizations = const [],
    required this.totalPrice,
    this.status = ReservationStatus.upcoming,
    this.rating,
    required this.createdAt,
    this.updatedAt,
  });

  double get basePrice => pricePerGuest * numGuests;
  double get customizationTotal =>
      customizations.fold(0.0, (sum, c) => sum + c.price);

  factory Reservation.fromMap(Map<String, dynamic> map, String id) {
    ReservationStatus status;
    switch (map['status']) {
      case 'completed':
        status = ReservationStatus.completed;
        break;
      case 'cancelled':
        status = ReservationStatus.cancelled;
        break;
      default:
        status = ReservationStatus.upcoming;
    }

    return Reservation(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userPhone: map['userPhone'] ?? '',
      packageId: map['packageId'] ?? '',
      packageName: map['packageName'] ?? '',
      packageImageUrl: map['packageImageUrl'] ?? '',
      pricePerGuest: (map['pricePerGuest'] ?? 0.0).toDouble(),
      numGuests: map['numGuests'] ?? 1,
      eventDate: (map['eventDate'] as dynamic).toDate(),
      eventTime: map['eventTime'] ?? '',
      additionalPreferences: map['additionalPreferences'],
      customizations: (map['customizations'] as List<dynamic>? ?? [])
          .map((c) => ServiceCustomization.fromMap(c as Map<String, dynamic>))
          .toList(),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      status: status,
      rating: map['rating']?.toDouble(),
      createdAt: (map['createdAt'] as dynamic).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    String statusStr;
    switch (status) {
      case ReservationStatus.completed:
        statusStr = 'completed';
        break;
      case ReservationStatus.cancelled:
        statusStr = 'cancelled';
        break;
      default:
        statusStr = 'upcoming';
    }

    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'packageId': packageId,
      'packageName': packageName,
      'packageImageUrl': packageImageUrl,
      'pricePerGuest': pricePerGuest,
      'numGuests': numGuests,
      'eventDate': eventDate,
      'eventTime': eventTime,
      'additionalPreferences': additionalPreferences,
      'customizations': customizations.map((c) => c.toMap()).toList(),
      'totalPrice': totalPrice,
      'status': statusStr,
      'rating': rating,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Reservation copyWith({
    int? numGuests,
    DateTime? eventDate,
    String? eventTime,
    String? additionalPreferences,
    List<ServiceCustomization>? customizations,
    double? totalPrice,
    ReservationStatus? status,
    double? rating,
    DateTime? updatedAt,
    String? packageId,
    String? packageName,
    String? packageImageUrl,
    double? pricePerGuest,
  }) {
    return Reservation(
      id: id,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      packageId: packageId ?? this.packageId,
      packageName: packageName ?? this.packageName,
      packageImageUrl: packageImageUrl ?? this.packageImageUrl,
      pricePerGuest: pricePerGuest ?? this.pricePerGuest,
      numGuests: numGuests ?? this.numGuests,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      additionalPreferences:
          additionalPreferences ?? this.additionalPreferences,
      customizations: customizations ?? this.customizations,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
