import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/listing.dart';
import 'auth_repository.dart';

class ListingRepository {
  static final ListingRepository _instance = ListingRepository._internal();
  factory ListingRepository() => _instance;

  final List<Listing> _inMemoryListings = List.from(Listing.demo);
  final Map<String, Set<String>> _favoritesByUser = {
    'user_finder_01': {'post_cau_giay_301'},
    'current_user_finder': {'post_cau_giay_301'},
  };

  late final StreamController<List<Listing>> _listingsController;
  late final StreamController<void> _favoritesChangedController;

  ListingRepository._internal() {
    _listingsController = StreamController<List<Listing>>.broadcast(
      onListen: () => _listingsController.add(List.unmodifiable(_inMemoryListings)),
    );
    _favoritesChangedController = StreamController<void>.broadcast();
  }

  String? get _activeUserId => AuthRepository().currentUser?.id;

  Stream<List<Listing>> watchListings() {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance
            .collection('listings')
            .where('approvalStatus', isEqualTo: 'approved')
            .snapshots()
            .map((snapshot) {
          if (snapshot.docs.isEmpty) return _inMemoryListings;
          return snapshot.docs.map((doc) => Listing.fromMap(doc.id, doc.data())).toList();
        }).handleError((_) => _inMemoryListings);
      }
    } catch (_) {}
    return _listingsController.stream;
  }

  Set<String> getFavorites([String? userId]) {
    final uid = userId ?? _activeUserId;
    if (uid == null) return const {};
    return Set.unmodifiable(_favoritesByUser[uid] ?? const {});
  }

  Stream<Set<String>> watchFavorites({String? userId}) async* {
    final uid = userId ?? _activeUserId;
    yield Set<String>.unmodifiable(_favoritesByUser[uid] ?? <String>{});
    yield* _favoritesChangedController.stream.map((_) {
      final curUid = userId ?? _activeUserId;
      return Set<String>.unmodifiable(_favoritesByUser[curUid] ?? <String>{});
    });
  }

  bool isFavorite(String id, {String? userId}) {
    final uid = userId ?? _activeUserId;
    if (uid == null) return false;
    return _favoritesByUser[uid]?.contains(id) ?? false;
  }

  void toggleFavorite(String id, {String? userId}) {
    final uid = userId ?? _activeUserId;
    if (uid == null) return;
    final set = _favoritesByUser.putIfAbsent(uid, () => <String>{});
    if (set.contains(id)) {
      set.remove(id);
    } else {
      set.add(id);
    }
    _favoritesChangedController.add(null);
  }

  void addListing(Listing listing) {
    _inMemoryListings.insert(0, listing);
    _listingsController.add(List.unmodifiable(_inMemoryListings));
    try {
      if (Firebase.apps.isNotEmpty) {
        FirebaseFirestore.instance.collection('listings').doc(listing.id).set(listing.toMap());
      }
    } catch (_) {}
  }

  void updateRoomStatus(String listingId, String roomStatus) {
    final index = _inMemoryListings.indexWhere((l) => l.id == listingId);
    if (index != -1) {
      _inMemoryListings[index] = _inMemoryListings[index].copyWith(roomStatus: roomStatus);
      _listingsController.add(List.unmodifiable(_inMemoryListings));
    }
    try {
      if (Firebase.apps.isNotEmpty) {
        FirebaseFirestore.instance.collection('listings').doc(listingId).update({'roomStatus': roomStatus});
      }
    } catch (_) {}
  }

  void moderateListing(String listingId, String approvalStatus, {bool isAudited = true}) {
    final index = _inMemoryListings.indexWhere((l) => l.id == listingId);
    if (index != -1) {
      _inMemoryListings[index] = _inMemoryListings[index].copyWith(
        approvalStatus: approvalStatus,
        isAudited: isAudited,
      );
      _listingsController.add(List.unmodifiable(_inMemoryListings));
    }
  }

  List<Listing> get currentListings => List.unmodifiable(_inMemoryListings);
}
