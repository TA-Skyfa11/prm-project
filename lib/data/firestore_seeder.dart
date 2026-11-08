import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/listing.dart';
import '../domain/user_profile.dart';
import '../domain/appointment.dart';

/// Service to seed and initialize Firestore collections:
/// - users
/// - apartments
/// - listings
/// - appointments
/// - categories
/// - amenities
class FirestoreSeeder {
  static Future<void> seedIfEmpty() async {
    try {
      if (Firebase.apps.isEmpty) return;

      final firestore = FirebaseFirestore.instance;
      final checkListings = await firestore.collection('listings').limit(1).get();

      if (checkListings.docs.isNotEmpty) {
        // Already populated
        return;
      }

      await seedAll(firestore);
    } catch (_) {}
  }

  static Future<void> seedAll([FirebaseFirestore? instance]) async {
    final firestore = instance ?? FirebaseFirestore.instance;
    final batch = firestore.batch();

    // 1. Seed Users Collection
    final users = [
      UserProfile.finderUser,
      UserProfile.ownerUser,
      UserProfile.adminUser,
    ];
    for (final u in users) {
      final ref = firestore.collection('users').doc(u.id);
      batch.set(ref, u.toMap());
    }

    // 2. Seed Apartments Collection
    final apartments = [
      {
        'apartmentId': 'apt_cau_giay_01',
        'ownerId': 'owner_001',
        'name': 'Khu trọ Hoa Sen Cầu Giấy',
        'address': 'Số 26 Ngõ 165 Cầu Giấy',
        'district': 'Cầu Giấy',
        'city': 'Hà Nội',
        'latitude': 21.0345,
        'longitude': 105.7923,
        'totalRooms': 10,
        'generalRules': 'Giờ giấc tự do, khóa vân tay, không hút thuốc hành lang',
      },
      {
        'apartmentId': 'apt_ba_dinh_01',
        'ownerId': 'owner_002',
        'name': 'Căn hộ Dịch vụ Trúc Bạch',
        'address': 'Số 12 Trúc Bạch',
        'district': 'Ba Đình',
        'city': 'Hà Nội',
        'latitude': 21.0498,
        'longitude': 105.8398,
        'totalRooms': 6,
        'generalRules': 'Thang máy thẻ từ, bảo vệ 24/7',
      },
    ];
    for (final a in apartments) {
      final ref = firestore.collection('apartments').doc(a['apartmentId'] as String);
      batch.set(ref, a);
    }

    // 3. Seed Listings Collection (Nhà trọ)
    for (final l in Listing.demo) {
      final ref = firestore.collection('listings').doc(l.id);
      batch.set(ref, l.toMap());
    }

    // 4. Seed Appointments Collection
    for (final aptm in Appointment.demo) {
      final ref = firestore.collection('appointments').doc(aptm.id);
      batch.set(ref, aptm.toMap());
    }

    // 5. Seed Categories Collection
    final categories = [
      {'id': 'cat_room', 'name': 'Phòng trọ', 'description': 'Phòng trọ sinh viên truyền thống 15-25m2'},
      {'id': 'cat_mini_apartment', 'name': 'Căn hộ mini', 'description': 'Studio khép kín full nội thất'},
      {'id': 'cat_house', 'name': 'Nhà nguyên căn', 'description': 'Nhà riêng nhiều tầng cho nhóm bạn'},
      {'id': 'cat_homestay', 'name': 'Ở ghép / Homestay', 'description': 'Ký túc xá cao cấp hoặc ở ghép'},
    ];
    for (final c in categories) {
      final ref = firestore.collection('categories').doc(c['id']!);
      batch.set(ref, c);
    }

    // 6. Seed Amenities Collection
    final amenities = [
      {'id': 'wifi', 'name': 'Wi-Fi tốc độ cao'},
      {'id': 'air_conditioner', 'name': 'Điều hòa 2 chiều'},
      {'id': 'water_heater', 'name': 'Bình nóng lạnh'},
      {'id': 'refrigerator', 'name': 'Tủ lạnh'},
      {'id': 'parking', 'name': 'Chỗ để xe / Sạc xe điện'},
      {'id': 'private_bathroom', 'name': 'Vệ sinh khép kín'},
      {'id': 'balcony', 'name': 'Ban công thoáng mát'},
      {'id': 'security', 'name': 'Khóa vân tay an toàn'},
    ];
    for (final am in amenities) {
      final ref = firestore.collection('amenities').doc(am['id']!);
      batch.set(ref, am);
    }

    await batch.commit();
  }
}
