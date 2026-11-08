enum UserRole { finder, owner, admin }

class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.role,
    this.isVerifiedHost = false,
  });

  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String avatarUrl;
  final UserRole role;
  final bool isVerifiedHost;

  String get roleDisplay {
    switch (role) {
      case UserRole.admin:
        return 'Quản trị viên (Admin)';
      case UserRole.owner:
        return 'Chủ nhà trọ (House Owner)';
      case UserRole.finder:
        return 'Người tìm trọ (House Finder)';
    }
  }

  UserProfile copyWith({
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    UserRole? role,
    bool? isVerifiedHost,
  }) =>
      UserProfile(
        id: id,
        fullName: fullName ?? this.fullName,
        email: email,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        role: role ?? this.role,
        isVerifiedHost: isVerifiedHost ?? this.isVerifiedHost,
      );

  static const defaultUser = UserProfile(
    id: 'current_user_finder',
    fullName: 'Trần Thị Lan',
    email: 'lan.tran@fpt.edu.vn',
    phoneNumber: '0977888999',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
    role: UserRole.finder,
    isVerifiedHost: false,
  );
}
