enum UserRole { finder, owner, admin, guest }

class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.role,
    this.isVerifiedHost = false,
    this.status = 'active',
  });

  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String avatarUrl;
  final UserRole role;
  final bool isVerifiedHost;
  final String status; // "active", "banned"

  String get roleDisplay {
    switch (role) {
      case UserRole.admin:
        return 'Quản trị viên (Admin)';
      case UserRole.owner:
        return 'Chủ nhà trọ (House Owner)';
      case UserRole.finder:
        return 'Người tìm trọ (House Finder)';
      case UserRole.guest:
        return 'Khách vãng lai (Guest)';
    }
  }

  factory UserProfile.fromMap(String id, Map<String, dynamic> map) {
    UserRole r = UserRole.finder;
    final roleStr = (map['role'] as String? ?? 'finder').toLowerCase();
    if (roleStr == 'owner') {
      r = UserRole.owner;
    } else if (roleStr == 'admin') {
      r = UserRole.admin;
    } else if (roleStr == 'guest') {
      r = UserRole.guest;
    }

    return UserProfile(
      id: id,
      fullName: map['fullName'] as String? ?? 'Người dùng',
      email: map['email'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String? ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
      role: r,
      isVerifiedHost: map['isVerifiedHost'] as bool? ?? false,
      status: map['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'avatarUrl': avatarUrl,
        'role': role.name,
        'isVerifiedHost': isVerifiedHost,
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      };

  UserProfile copyWith({
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    UserRole? role,
    bool? isVerifiedHost,
    String? status,
  }) =>
      UserProfile(
        id: id,
        fullName: fullName ?? this.fullName,
        email: email,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        role: role ?? this.role,
        isVerifiedHost: isVerifiedHost ?? this.isVerifiedHost,
        status: status ?? this.status,
      );

  // Pre-configured demo accounts for instant testing
  static const finderUser = UserProfile(
    id: 'user_finder_01',
    fullName: 'Trần Thị Lan',
    email: 'finder@housefinder.vn',
    phoneNumber: '0977888999',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
    role: UserRole.finder,
    isVerifiedHost: false,
  );

  static const ownerUser = UserProfile(
    id: 'owner_001',
    fullName: 'Bác Hoàng Văn Minh',
    email: 'owner@housefinder.vn',
    phoneNumber: '0982123456',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
    role: UserRole.owner,
    isVerifiedHost: true,
  );

  static const adminUser = UserProfile(
    id: 'user_admin_01',
    fullName: 'Nguyễn Quản Trị',
    email: 'admin@housefinder.vn',
    phoneNumber: '0901234567',
    avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
    role: UserRole.admin,
    isVerifiedHost: true,
  );

  static const guestUser = UserProfile(
    id: 'user_guest',
    fullName: 'Khách khám phá',
    email: 'guest@housefinder.vn',
    phoneNumber: '',
    avatarUrl: '',
    role: UserRole.guest,
    isVerifiedHost: false,
  );
}
