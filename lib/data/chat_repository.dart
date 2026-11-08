import 'dart:async';
import '../domain/chat.dart';

class ChatRepository {
  static final ChatRepository _instance = ChatRepository._internal();
  factory ChatRepository() => _instance;

  final List<ChatRoom> _rooms = List.from(ChatRoom.demo);

  final Map<String, List<ChatMessage>> _messagesByRoom = {
    'room_001': [
      ChatMessage(
        id: 'm1',
        senderId: 'owner_001',
        senderName: 'Bác Hoàng Văn Minh',
        text: 'Chào cháu, cháu đang quan tâm phòng trọ Cầu Giấy đúng không?',
        sentAt: DateTime.now().subtract(const Duration(hours: 3)),
        isMe: false,
      ),
      ChatMessage(
        id: 'm2',
        senderId: 'user_finder_01',
        senderName: 'Trần Thị Lan',
        text: 'Dạ vâng bác, phòng tầng 3 còn trống không ạ? Xe điện có chỗ sạc riêng không bác?',
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
        isMe: true,
      ),
      ChatMessage(
        id: 'm3',
        senderId: 'owner_001',
        senderName: 'Bác Hoàng Văn Minh',
        text: 'Phòng vẫn còn nhé, tầng 1 có ổ cắm sạc xe máy điện riêng có đồng hồ đo điện. Cháu rảnh qua xem phòng nhé!',
        sentAt: DateTime.now().subtract(const Duration(hours: 1)),
        isMe: false,
      ),
    ],
    'room_002': [
      ChatMessage(
        id: 'm2_1',
        senderId: 'owner_002',
        senderName: 'Chị Trần Thanh Hà',
        text: 'Chào bạn, studio view hồ Trúc Bạch full đồ nội thất đang sẵn sàng đón bạn vào ở nhé.',
        sentAt: DateTime.now().subtract(const Duration(days: 1)),
        isMe: false,
      ),
      ChatMessage(
        id: 'm2_2',
        senderId: 'owner_002',
        senderName: 'Chị Trần Thanh Hà',
        text: 'Hẹn bạn 9h sáng mai qua xem phòng Trúc Bạch nha.',
        sentAt: DateTime.now().subtract(const Duration(hours: 18)),
        isMe: false,
      ),
    ],
    'room_003': [
      ChatMessage(
        id: 'm3_1',
        senderId: 'user_finder_02',
        senderName: 'Nguyễn Văn Tuấn',
        text: 'Chào bác Minh, em muốn hỏi phòng trọ 2.5tr Cầu Giấy có cho nuôi mèo nhỏ không ạ?',
        sentAt: DateTime.now().subtract(const Duration(minutes: 15)),
        isMe: false,
      ),
    ],
    'room_004': [
      ChatMessage(
        id: 'm4_1',
        senderId: 'user_finder_03',
        senderName: 'Lê Thuỳ Dung',
        text: 'Bác ơi, chiều mai tầm 17h30 em cùng bạn qua xem phòng và cọc giữ chỗ được không ạ?',
        sentAt: DateTime.now().subtract(const Duration(minutes: 30)),
        isMe: false,
      ),
    ],
  };

  late final StreamController<List<ChatMessage>> _messagesController;
  late final StreamController<List<ChatRoom>> _roomsController;

  ChatRepository._internal() {
    _messagesController = StreamController<List<ChatMessage>>.broadcast();
    _roomsController = StreamController<List<ChatRoom>>.broadcast();
  }

  List<ChatRoom> getRoomsForUser(String userId) {
    return _rooms.where((r) => r.participantIds.contains(userId)).toList();
  }

  Stream<List<ChatRoom>> watchRoomsForUser(String userId) async* {
    yield getRoomsForUser(userId);
    yield* _roomsController.stream.map((_) => getRoomsForUser(userId));
  }

  ChatRoom getOrCreateRoom({
    required String currentUserId,
    required String currentUserName,
    required String otherPartyId,
    required String otherPartyName,
    required String otherPartyAvatar,
    String? listingTitle,
  }) {
    final existingIndex = _rooms.indexWhere((r) =>
        r.participantIds.contains(currentUserId) && r.participantIds.contains(otherPartyId));
    if (existingIndex != -1) {
      return _rooms[existingIndex];
    }

    final newRoom = ChatRoom(
      id: 'room_${currentUserId}_${otherPartyId}_${DateTime.now().millisecondsSinceEpoch}',
      otherPartyId: otherPartyId,
      otherPartyName: otherPartyName,
      otherPartyAvatar: otherPartyAvatar.isNotEmpty
          ? otherPartyAvatar
          : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
      lastMessageText: 'Bắt đầu cuộc trò chuyện',
      lastMessageTime: 'Vừa xong',
      unreadCount: 0,
      listingTitle: listingTitle,
      participantIds: [currentUserId, otherPartyId],
    );
    _rooms.insert(0, newRoom);
    _roomsController.add(List.unmodifiable(_rooms));
    return newRoom;
  }

  List<ChatMessage> getMessages(String roomId) {
    return List.unmodifiable(_messagesByRoom[roomId] ?? []);
  }

  Stream<List<ChatMessage>> watchMessages(String roomId) async* {
    yield getMessages(roomId);
    yield* _messagesController.stream.map((_) => getMessages(roomId));
  }

  List<ChatRoom> getPendingInquiriesForOwner(String ownerId) {
    return _rooms
        .where((r) => r.participantIds.contains(ownerId) && r.lastSenderId != ownerId)
        .toList();
  }

  void sendMessage(
    String roomId,
    String text, {
    required String senderId,
    required String senderName,
    bool autoReply = true,
  }) {
    final list = _messagesByRoom.putIfAbsent(roomId, () => []);
    final newMsg = ChatMessage(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName,
      text: text,
      sentAt: DateTime.now(),
      isMe: true,
    );
    list.add(newMsg);
    _messagesController.add(List.unmodifiable(list));

    final roomIdx = _rooms.indexWhere((r) => r.id == roomId);
    if (roomIdx != -1) {
      _rooms[roomIdx] = _rooms[roomIdx].copyWith(
        lastMessageText: text,
        lastMessageTime: 'Vừa xong',
        lastSenderId: senderId,
      );
      _roomsController.add(List.unmodifiable(_rooms));
    }

    // Auto-reply simulation from host
    if (autoReply) {
      final room = roomIdx != -1 ? _rooms[roomIdx] : null;
      if (room != null && senderId != room.otherPartyId) {
        Timer(const Duration(milliseconds: 800), () {
          final replyText = _generateSmartReply(text);
          final replyMsg = ChatMessage(
            id: 'm_${DateTime.now().millisecondsSinceEpoch}_reply',
            senderId: room.otherPartyId,
            senderName: room.otherPartyName,
            text: replyText,
            sentAt: DateTime.now(),
            isMe: false,
          );
          list.add(replyMsg);
          _messagesController.add(List.unmodifiable(list));

          final currentIdx = _rooms.indexWhere((r) => r.id == roomId);
          if (currentIdx != -1) {
            _rooms[currentIdx] = _rooms[currentIdx].copyWith(
              lastMessageText: replyText,
              lastMessageTime: 'Vừa xong',
              lastSenderId: room.otherPartyId,
            );
            _roomsController.add(List.unmodifiable(_rooms));
          }
        });
      }
    }
  }

  String _generateSmartReply(String query) {
    final lower = query.toLowerCase();
    if (lower.contains('trống') || lower.contains('còn phòng')) {
      return 'Dạ chào bạn! Phòng hiện vẫn còn trống nhé. Bạn có muốn ghé qua xem phòng trực tiếp không ạ?';
    } else if (lower.contains('xem') || lower.contains('hẹn') || lower.contains('qua')) {
      return 'Được bạn nhé! Bạn có thể ấn nút "Đặt lịch hẹn" trên app để chọn giờ cụ thể, mình sẽ giữ lịch đón bạn.';
    } else if (lower.contains('điện') || lower.contains('nước') || lower.contains('giá')) {
      return 'Điện 3.800đ/kWh, nước 30.000đ/khối, internet 100.000đ/phòng ạ. Có công tơ riêng từng phòng nhé bạn!';
    } else if (lower.contains('sạc') || lower.contains('xe máy') || lower.contains('xe điện') || lower.contains('chỗ để xe')) {
      return 'Tầng 1 có ổ sạc xe máy điện thông minh có aptomat riêng, an toàn và có camera giám sát 24/7 bạn nhé.';
    } else if (lower.contains('thương lượng') || lower.contains('bớt') || lower.contains('cọc')) {
      return 'Nếu bạn ký hợp đồng thuê lâu dài từ 6 tháng hoặc 1 năm, mình có thể hỗ trợ bớt chút lộc đầu tháng nhé!';
    }
    return 'Chào bạn! Cảm ơn bạn đã quan tâm. Mình đã nhận được tin nhắn và sẽ hỗ trợ giải đáp mọi thắc mắc của bạn ngay nhé!';
  }

  static const List<String> quickTemplates = [
    'Phòng này hiện tại còn trống không ạ?',
    'Tiền điện nước và dịch vụ tính thế nào ạ?',
    'Có chỗ sạc xe máy điện an toàn không ạ?',
    'Em có thể qua xem phòng vào chiều mai được không?',
    'Giá thuê có thương lượng thêm không ạ?',
  ];

  static const List<String> hostQuickTemplates = [
    'Chào bạn! Phòng hiện vẫn còn trống nhé.',
    'Bạn có thể qua xem phòng lúc 17h30 chiều nay được không?',
    'Phòng trọ cho phép nuôi thú cưng nhỏ nhưng cần giữ vệ sinh chung nhé.',
    'Bạn có thể ấn "Đặt lịch hẹn" trên app để mình xếp lịch đón bạn nhé.',
    'Giá thuê đã bao gồm tiền rác và vệ sinh, điện nước có công tơ riêng nhé.',
  ];
}
