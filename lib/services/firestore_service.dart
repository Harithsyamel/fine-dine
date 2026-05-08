// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_package.dart';
import '../models/reservation.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── MENU PACKAGES ──────────────────────────────────────────────────────────

  Stream<List<MenuPackage>> packagesStream({String? category}) {
    Query query = _db
        .collection('packages')
        .where('isAvailable', isEqualTo: true)
        .orderBy('orderCount', descending: true);

    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snap) => snap.docs
        .map((d) => MenuPackage.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList());
  }

  // All packages including unavailable (for admin)
  Stream<List<MenuPackage>> allPackagesStream() {
    return _db
        .collection('packages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                MenuPackage.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Future<MenuPackage?> getPackageById(String id) async {
    final doc = await _db.collection('packages').doc(id).get();
    if (!doc.exists) return null;
    return MenuPackage.fromMap(doc.data()!, id);
  }

  Future<String> addPackage(MenuPackage pkg) async {
    final ref = await _db.collection('packages').add(pkg.toMap());
    return ref.id;
  }

  Future<void> updatePackage(MenuPackage pkg) async {
    await _db.collection('packages').doc(pkg.id).update(pkg.toMap());
  }

  Future<void> deletePackage(String id) async {
    await _db.collection('packages').doc(id).delete();
  }

  // Most ordered packages (top 5)
  Future<List<MenuPackage>> getMostOrdered() async {
    final snap = await _db
        .collection('packages')
        .where('isAvailable', isEqualTo: true)
        .orderBy('orderCount', descending: true)
        .limit(5)
        .get();
    return snap.docs
        .map((d) => MenuPackage.fromMap(d.data(), d.id))
        .toList();
  }

  // Search packages by name
  Future<List<MenuPackage>> searchPackages(String query) async {
    final snap = await _db
        .collection('packages')
        .where('isAvailable', isEqualTo: true)
        .get();
    final q = query.toLowerCase();
    return snap.docs
        .map((d) => MenuPackage.fromMap(d.data(), d.id))
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q))
        .toList();
  }

  // ─── RESERVATIONS ────────────────────────────────────────────────────────────

  Future<String> createReservation(Reservation res) async {
    final ref = await _db.collection('reservations').add(res.toMap());
    // Increment package order count
    await _db.collection('packages').doc(res.packageId).update({
      'orderCount': FieldValue.increment(1),
    });
    return ref.id;
  }

  // User's reservations
  Stream<List<Reservation>> userReservationsStream(String userId) {
    return _db
        .collection('reservations')
        .where('userId', isEqualTo: userId)
        .orderBy('eventDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                Reservation.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  // All reservations (admin)
  Stream<List<Reservation>> allReservationsStream() {
    return _db
        .collection('reservations')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                Reservation.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Future<void> updateReservation(Reservation res) async {
    await _db.collection('reservations').doc(res.id).update({
      'numGuests': res.numGuests,
      'eventDate': res.eventDate,
      'eventTime': res.eventTime,
      'additionalPreferences': res.additionalPreferences,
      'customizations': res.customizations.map((c) => c.toMap()).toList(),
      'totalPrice': res.totalPrice,
      'packageId': res.packageId,
      'packageName': res.packageName,
      'packageImageUrl': res.packageImageUrl,
      'pricePerGuest': res.pricePerGuest,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelReservation(String id) async {
    await _db.collection('reservations').doc(id).update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rateReservation(String id, double rating) async {
    await _db.collection('reservations').doc(id).update({'rating': rating});
  }

  // ─── USERS (admin) ───────────────────────────────────────────────────────────

  Stream<List<UserModel>> usersStream() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'user')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  Future<void> updateUserByAdmin(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }
}
