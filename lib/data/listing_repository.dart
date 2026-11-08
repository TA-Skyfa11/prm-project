import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/listing.dart';

class ListingRepository {
  static final ListingRepository _instance = ListingRepository._internal();
  factory ListingRepository() => _instance;

  final List<Listing> _inMemoryListings = List.from(Listing.demo);
  final Set<String> _favoriteIds = {'post_cau_giay_301'};
  late final StreamController<List<Listing>> _listingsController;
  late final StreamController<Set<String>> _favoritesController;

  ListingRepository._internal() {
    _listingsController = StreamController<List<Listing>>.broadcast(
      onListen: () => _listingsController.add(List.unmodifiable(_inMemoryListings)),
    );
    _favoritesController = StreamController<Set<String>>.broadcast(
      onListen: () => _favoritesController.add(Set.unmodifiable(_favoriteIds)),
    );
  }

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

  Stream<Set<String>> watchFavorites() {
    return _favoritesController.stream;
  }

  bool isFavorite(String id) => _favoriteIds.contains(id);

  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    _favoritesController.add(Set.unmodifiable(_favoriteIds));
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

  void moderateListing(String listingId, String approvalStatus) {
    final index = _inMemoryListings.indexWhere((l) => l.id == listingId);
    if (index != -1) {
      _inMemoryListings[index] = _inMemoryListings[index].copyWith(approvalStatus: approvalStatus);
      _listingsController.add(List.unmodifiable(_inMemoryListings));
    }
  }

  List<Listing> get currentListings => List.unmodifiable(_inMemoryListings);
}
