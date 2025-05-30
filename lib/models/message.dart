import 'package:appwrite/models.dart';

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });

  factory Message.fromDocument(dynamic doc) {
    final data = doc is Document ? doc.data : doc;
    final id = doc is Document ? doc.$id : doc['\$id'];
    
    return Message(
      id: id,
      chatId: data['chat_id'],
      senderId: data['sender_id'],
      receiverId: data['receiver_id'],
      message: data['message'],
      timestamp: DateTime.parse(data['timestamp']),
      isRead: data['read'] ?? false,
    );
  }
}
