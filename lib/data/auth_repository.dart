import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/user_profile.dart';

class AuthRepository {
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;

  UserProfile? _currentUser;
  late final StreamController<UserProfile?> _authController;

  final List<UserProfile> _allUsers = [
    UserProfile.finderUser,
    UserProfile.ownerUser,
    UserProfile.adminUser,
    UserProfile(
      id: 'app_host_001',
      fullName: 'Nguyễn Văn Hùng',
      email: 'hung.host@gmail.com',
      phoneNumber: '0983112233',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
      role: UserRole.owner,
      isVerifiedHost: false,
      cccdNumber: '038096001234',
      cccdFrontImage: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600',
      cccdBackImage: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600',
      hostApprovalStatus: 'pending',
      hostApplicationSource: 'Đăng ký tài khoản Chủ trọ mới',
      appliedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    UserProfile(
      id: 'app_host_002',
      fullName: 'Lê Thị Mai',
      email: 'mai.finder@gmail.com',
      phoneNumber: '0977223344',
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300',
      role: UserRole.finder,
      isVerifiedHost: false,
      cccdNumber: '001198005678',
      cccdFrontImage: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600',
      cccdBackImage: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600',
      hostApprovalStatus: 'pending',
      hostApplicationSource: 'Nâng cấp từ Người tìm trọ',
      appliedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  AuthRepository._internal() {
    _authController = StreamController<UserProfile?>.broadcast(
      onListen: () => _authController.add(_currentUser),
    );
  }

  Stream<UserProfile?> watchAuthState() => _authController.stream;
  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && _currentUser!.role != UserRole.guest;
  List<UserProfile> get allUsers => List.unmodifiable(_allUsers);
  List<UserProfile> get hostApplications =>
      _allUsers.where((u) => u.hostApprovalStatus != 'none').toList();

  Future<UserProfile> loginWithEmail(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();

    // Check predefined shortcuts first for instant access
    if (cleanEmail == UserProfile.finderUser.email || cleanEmail == 'finder') {
      return setAuthenticatedUser(UserProfile.finderUser);
    }
    if (cleanEmail == UserProfile.ownerUser.email || cleanEmail == 'owner') {
      return setAuthenticatedUser(UserProfile.ownerUser);
    }
    if (cleanEmail == UserProfile.adminUser.email || cleanEmail == 'admin') {
      return setAuthenticatedUser(UserProfile.adminUser);
    }

    // Check registered users in memory
    final localMatches = _allUsers.where((u) => u.email.toLowerCase() == cleanEmail);
    if (localMatches.isNotEmpty) {
      return setAuthenticatedUser(localMatches.first);
    }

    // Try Firebase Auth if live
    try {
      if (Firebase.apps.isNotEmpty) {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        final uid = credential.user?.uid;
        if (uid != null) {
          final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
          if (doc.exists && doc.data() != null) {
            final profile = UserProfile.fromMap(uid, doc.data()!);
            _allUsers.removeWhere((u) => u.id == profile.id || u.email == profile.email);
            _allUsers.add(profile);
            return setAuthenticatedUser(profile);
          }
        }
      }
    } catch (_) {
      // Graceful fallback for mock or demo testing
    }

    // Default authenticated finder profile for custom test email
    final profile = UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      fullName: cleanEmail.split('@').first,
      email: cleanEmail,
      phoneNumber: '0988888888',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
      role: UserRole.finder,
      isVerifiedHost: false,
    );
    _allUsers.add(profile);
    return setAuthenticatedUser(profile);
  }

  Future<UserProfile> register({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required UserRole role,
    String cccdNumber = '',
    String cccdFrontImage = '',
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final isOwnerRole = role == UserRole.owner;

    try {
      if (Firebase.apps.isNotEmpty) {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        final uid = credential.user?.uid ?? 'usr_${DateTime.now().millisecondsSinceEpoch}';

        final newProfile = UserProfile(
          id: uid,
          fullName: fullName,
          email: cleanEmail,
          phoneNumber: phoneNumber,
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
          role: role,
          isVerifiedHost: false,
          cccdNumber: cccdNumber,
          cccdFrontImage: cccdFrontImage,
          hostApprovalStatus: isOwnerRole ? 'pending' : 'none',
          hostApplicationSource: isOwnerRole ? 'Đăng ký tài khoản mới' : '',
          appliedAt: isOwnerRole ? DateTime.now() : null,
        );

        await FirebaseFirestore.instance.collection('users').doc(uid).set(newProfile.toMap());
        _allUsers.removeWhere((u) => u.email.toLowerCase() == cleanEmail);
        _allUsers.add(newProfile);
        return setAuthenticatedUser(newProfile);
      }
    } catch (_) {
      // Fallback
    }

    final newProfile = UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      email: cleanEmail,
      phoneNumber: phoneNumber,
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
      role: role,
      isVerifiedHost: false,
      cccdNumber: cccdNumber,
      cccdFrontImage: cccdFrontImage,
      hostApprovalStatus: isOwnerRole ? 'pending' : 'none',
      hostApplicationSource: isOwnerRole ? 'Đăng ký tài khoản mới' : '',
      appliedAt: isOwnerRole ? DateTime.now() : null,
    );
    _allUsers.removeWhere((u) => u.email.toLowerCase() == cleanEmail);
    _allUsers.add(newProfile);
    return setAuthenticatedUser(newProfile);
  }

  void submitHostUpgrade({
    required String userId,
    required String cccdNumber,
    String cccdFrontImage = '',
    String cccdBackImage = '',
  }) {
    final idx = _allUsers.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      _allUsers[idx] = _allUsers[idx].copyWith(
        cccdNumber: cccdNumber,
        cccdFrontImage: cccdFrontImage,
        cccdBackImage: cccdBackImage,
        hostApprovalStatus: 'pending',
        hostApplicationSource: 'Nâng cấp từ Người tìm trọ',
        appliedAt: DateTime.now(),
      );
      if (_currentUser?.id == userId) {
        setAuthenticatedUser(_allUsers[idx]);
      }
    }
  }

  void approveHostApplication(String userId) {
    final idx = _allUsers.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      _allUsers[idx] = _allUsers[idx].copyWith(
        role: UserRole.owner,
        isVerifiedHost: true,
        hostApprovalStatus: 'approved',
        hostRejectionReason: null,
      );
      if (_currentUser?.id == userId) {
        setAuthenticatedUser(_allUsers[idx]);
      }
    }
  }

  void rejectHostApplication(String userId, {String? reason}) {
    final idx = _allUsers.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      _allUsers[idx] = _allUsers[idx].copyWith(
        isVerifiedHost: false,
        hostApprovalStatus: 'rejected',
        hostRejectionReason: reason ?? 'Hồ sơ chưa đạt yêu cầu xác minh CCCD.',
      );
      if (_currentUser?.id == userId) {
        setAuthenticatedUser(_allUsers[idx]);
      }
    }
  }

  UserProfile loginAsGuest() {
    return setAuthenticatedUser(UserProfile.guestUser);
  }

  UserProfile setAuthenticatedUser(UserProfile profile) {
    _currentUser = profile;
    _authController.add(_currentUser);
    return profile;
  }

  Future<void> logout() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        await FirebaseAuth.instance.signOut();
      }
    } catch (_) {}
    _currentUser = null;
    _authController.add(null);
  }
}
