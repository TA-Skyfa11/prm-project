import 'dart:async';
import '../domain/chat.dart';

class ChatRepository {
  static final ChatRepository _instance = ChatRepository._internal();
  factory ChatRepository() => _instance;

  final Map<String, List<ChatMessage>> _messagesByRoom = {
    'room_001': [
      ChatMessage(
        id: 'm1',
        senderId: 'owner_001',
        senderName: 'Bác Minh',
        text: 'Chào cháu, cháu đang quan tâm phòng trọ Cầu Giấy đúng không?',
        sentAt: DateTime.now().subtract(const Duration(hours: 3)),
        isMe: false,
      ),
      ChatMessage(
        id: 'm2',
        senderId: 'current_user_finder',
        senderName: 'Trần Thị Lan',
        text: 'Dạ vâng bác, phòng tầng 3 còn trống không ạ? Xe điện có chỗ sạc riêng không bác?',
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
        isMe: true,
      ),
      ChatMessage(
        id: 'm3',
        senderId: 'owner_001',
        senderName: 'Bác Minh',
        text: 'Phòng vẫn còn nhé, tầng 1 có ổ cắm sạc xe máy điện riêng có đồng hồ đo điện. Cháu rảnh qua xem phòng nhé!',
        sentAt: DateTime.now().subtract(const Duration(hours: 1)),
        isMe: false,
      ),
    ],
  };

  late final StreamController<List<ChatMessage>> _messagesController;

  ChatRepository._internal() {
    _messagesController = StreamController<List<ChatMessage>>.broadcast();
  }

  Stream<List<ChatMessage>> watchMessages(String roomId) {
    final list = _messagesByRoom[roomId] ?? [];
    return Stream.value(List.unmodifiable(list));
  }

  void sendMessage(String roomId, String text, {required String senderId, required String senderName}) {
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
  }

  static const List<String> quickTemplates = [
    'Phòng này hiện tại còn trống không ạ?',
    'Tiền điện nước và dịch vụ tính thế nào ạ?',
    'Có chỗ sạc xe máy điện an toàn không ạ?',
    'Em có thể qua xem phòng vào chiều mai được không?',
    'Giá thuê có thương lượng thêm không ạ?',
  ];
}
