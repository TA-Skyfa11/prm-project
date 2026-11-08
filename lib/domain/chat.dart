class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.sentAt,
    this.isMe = false,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime sentAt;
  final bool isMe;

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map, String currentUserId) => ChatMessage(
        id: id,
        senderId: map['senderId'] as String? ?? '',
        senderName: map['senderName'] as String? ?? 'Người dùng',
        text: map['text'] as String? ?? '',
        sentAt: map['sentAt'] != null ? DateTime.tryParse(map['sentAt'] as String) ?? DateTime.now() : DateTime.now(),
        isMe: (map['senderId'] as String? ?? '') == currentUserId,
      );

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'sentAt': sentAt.toIso8601String(),
      };
}

class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.otherPartyId,
    required this.otherPartyName,
    required this.otherPartyAvatar,
    required this.lastMessageText,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.listingTitle,
    this.participantIds = const [],
    this.lastSenderId,
    this.otherPartyPhone = '0988888999',
  });

  final String id;
  final String otherPartyId;
  final String otherPartyName;
  final String otherPartyAvatar;
  final String lastMessageText;
  final String lastMessageTime;
  final int unreadCount;
  final String? listingTitle;
  final List<String> participantIds;
  final String? lastSenderId;
  final String otherPartyPhone;

  ChatRoom copyWith({
    String? otherPartyId,
    String? otherPartyName,
    String? otherPartyAvatar,
    String? lastMessageText,
    String? lastMessageTime,
    int? unreadCount,
    String? listingTitle,
    List<String>? participantIds,
    String? lastSenderId,
    String? otherPartyPhone,
  }) =>
      ChatRoom(
        id: id,
        otherPartyId: otherPartyId ?? this.otherPartyId,
        otherPartyName: otherPartyName ?? this.otherPartyName,
        otherPartyAvatar: otherPartyAvatar ?? this.otherPartyAvatar,
        lastMessageText: lastMessageText ?? this.lastMessageText,
        lastMessageTime: lastMessageTime ?? this.lastMessageTime,
        unreadCount: unreadCount ?? this.unreadCount,
        listingTitle: listingTitle ?? this.listingTitle,
        participantIds: participantIds ?? this.participantIds,
        lastSenderId: lastSenderId ?? this.lastSenderId,
        otherPartyPhone: otherPartyPhone ?? this.otherPartyPhone,
      );

  static final List<ChatRoom> demo = [
    const ChatRoom(
      id: 'room_001',
      otherPartyId: 'owner_001',
      otherPartyName: 'Bác Hoàng Văn Minh (Chủ trọ)',
      otherPartyAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
      lastMessageText: 'Phòng vẫn còn nhé, tầng 1 có ổ cắm sạc xe máy điện riêng có đồng hồ đo điện. Cháu rảnh qua xem phòng nhé!',
      lastMessageTime: '10:45',
      unreadCount: 0,
      listingTitle: 'Phòng khép kín ban công Cầu Giấy',
      participantIds: ['user_finder_01', 'current_user_finder', 'owner_001'],
      lastSenderId: 'owner_001',
      otherPartyPhone: '0982123456',
    ),
    const ChatRoom(
      id: 'room_002',
      otherPartyId: 'owner_002',
      otherPartyName: 'Chị Trần Thanh Hà (Chủ trọ)',
      otherPartyAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
      lastMessageText: 'Hẹn bạn 9h sáng mai qua xem phòng Trúc Bạch nha.',
      lastMessageTime: 'Hôm qua',
      unreadCount: 0,
      listingTitle: 'Studio view hồ Trúc Bạch',
      participantIds: ['user_finder_01', 'current_user_finder', 'owner_002'],
      lastSenderId: 'owner_002',
      otherPartyPhone: '0977222333',
    ),
    const ChatRoom(
      id: 'room_003',
      otherPartyId: 'user_finder_02',
      otherPartyName: 'Nguyễn Văn Tuấn (Khách tìm trọ)',
      otherPartyAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      lastMessageText: 'Chào bác Minh, em muốn hỏi phòng trọ 2.5tr Cầu Giấy có cho nuôi mèo nhỏ không ạ?',
      lastMessageTime: '15 phút trước',
      unreadCount: 1,
      listingTitle: 'Phòng khép kín ban công Cầu Giấy',
      participantIds: ['owner_001', 'user_finder_02'],
      lastSenderId: 'user_finder_02',
      otherPartyPhone: '0912345678',
    ),
    const ChatRoom(
      id: 'room_004',
      otherPartyId: 'user_finder_03',
      otherPartyName: 'Lê Thuỳ Dung (Sinh viên ĐHQG)',
      otherPartyAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
      lastMessageText: 'Bác ơi, chiều mai tầm 17h30 em cùng bạn qua xem phòng và cọc giữ chỗ được không ạ?',
      lastMessageTime: '30 phút trước',
      unreadCount: 1,
      listingTitle: 'Phòng khép kín ban công Cầu Giấy',
      participantIds: ['owner_001', 'user_finder_03'],
      lastSenderId: 'user_finder_03',
      otherPartyPhone: '0966778899',
    ),
  ];
}
