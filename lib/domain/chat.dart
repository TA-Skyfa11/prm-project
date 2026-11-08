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
  });

  final String id;
  final String otherPartyId;
  final String otherPartyName;
  final String otherPartyAvatar;
  final String lastMessageText;
  final String lastMessageTime;
  final int unreadCount;
  final String? listingTitle;

  static final List<ChatRoom> demo = [
    const ChatRoom(
      id: 'room_001',
      otherPartyId: 'owner_001',
      otherPartyName: 'Bác Hoàng Văn Minh (Chủ trọ)',
      otherPartyAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
      lastMessageText: 'Chào bạn, phòng ở tầng 3 ban công vẫn còn nhé!',
      lastMessageTime: '10:45',
      unreadCount: 1,
      listingTitle: 'Phòng khép kín ban công Cầu Giấy',
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
    ),
  ];
}
