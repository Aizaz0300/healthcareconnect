import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:healthcare/constants/api_constants.dart';
import 'package:flutter/material.dart';

class ChatService {

  Client client = Client();
  late Databases _databases;
  late Realtime _realtime;
  static const String databaseId = '67e6393a0009ccfe982e';
  static const String chatsCollection = '683376f400382a05c70d';
  static const String messagesCollection = '683384040035b15e4fe1';
  late Databases databases;

  ChatService() {
    _init();
  }

  void _init() {
    client
        .setEndpoint(ApiConstants.endPoint)
        .setProject(ApiConstants.projectId)
        .setSelfSigned(status: true); 

    _databases = Databases(client);
    _realtime = Realtime(client);
  }

  Future<Document> createChat({
    required String userId,
    required String providerId,
    required String providerName,
    required String userName,
  }) async {
    return await _databases.createDocument(
      databaseId: databaseId,
      collectionId: chatsCollection,
      documentId: ID.unique(),
      data: {
        'user_id': userId,
        'provider_id': providerId,
        'provider_name': providerName,
        'user_name': userName,
        'last_message': '',
        'last_message_time': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<Document> getOrCreateChat({
    required String userId,
    required String providerId,
    required String providerName,
    required String userName,
  }) async {
    try {
      // First, try to find an existing chat
      final response = await _databases.listDocuments(
        databaseId: databaseId,
        collectionId: chatsCollection,
        queries: [
          Query.equal('user_id', userId),
          Query.equal('provider_id', providerId),
        ],
      );

      // If chat exists, return it
      if (response.documents.isNotEmpty) {
        return response.documents.first;
      }

      // If no chat exists, create a new one
      return await _databases.createDocument(
        databaseId: databaseId,
        collectionId: chatsCollection,
        documentId: ID.unique(),
        data: {
          'user_id': userId,
          'provider_id': providerId,
          'provider_name': providerName,
          'user_name': userName,
          'last_message': '',
          'last_message_time': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Error in getOrCreateChat: $e');
      rethrow;
    }
  }

  Future<Document> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,  // Add receiverId parameter
    required String message,
  }) async {
    final messageDoc = await _databases.createDocument(
      databaseId: databaseId,
      collectionId: messagesCollection,
      documentId: ID.unique(),
      data: {
        'chat_id': chatId,
        'sender_id': senderId,
        'receiver_id': receiverId,  // Store receiver ID
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'read': false,
      },
    );

    // Update last message and increment unread count for receiver
    await _databases.updateDocument(
      databaseId: databaseId,
      collectionId: chatsCollection,
      documentId: chatId,
      data: {
        'last_message': message,
        'last_message_time': DateTime.now().toIso8601String(),
        'unread_count': await _getUnreadCount(chatId, receiverId) + 1,
        'last_sender_id': senderId,  // Track who sent the last message
      },
    );

    return messageDoc;
  }

  Future<int> _getUnreadCount(String chatId, String receiverId) async {
    final response = await _databases.listDocuments(
      databaseId: databaseId,
      collectionId: messagesCollection,
      queries: [
        Query.equal('chat_id', chatId),
        Query.equal('receiver_id', receiverId),
        Query.equal('read', false),
      ],
    );
    return response.total;
  }

  Future<void> markMessagesAsRead(String chatId, String receiverId) async {
    try {
      final messages = await _databases.listDocuments(
        databaseId: databaseId,
        collectionId: messagesCollection,
        queries: [
          Query.equal('chat_id', chatId),
          Query.equal('receiver_id', receiverId),
          Query.equal('read', false),
        ],
      );

      // Mark all messages as read in parallel
      await Future.wait(
        messages.documents.map((message) => 
          _databases.updateDocument(
            databaseId: databaseId,
            collectionId: messagesCollection,
            documentId: message.$id,
            data: {'read': true},
          )
        ),
      );

      // Reset unread count
      await _databases.updateDocument(
        databaseId: databaseId,
        collectionId: chatsCollection,
        documentId: chatId,
        data: {'unread_count': 0},
      );
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
      rethrow;
    }
  }

  Future<List<Document>> getChatList(String userId) async {
    final response = await _databases.listDocuments(
      databaseId: databaseId,
      collectionId: chatsCollection,
      queries: [
        Query.equal('user_id', userId),
      ],
    );
    return response.documents;
  }

  Future<List<Document>> getProviderChatList(String providerId) async {
    final response = await _databases.listDocuments(
      databaseId: databaseId,
      collectionId: chatsCollection,
      queries: [
        Query.equal('provider_id', providerId),
        Query.orderDesc('last_message_time'),
      ],
    );
    return response.documents;
  }

  Future<List<Document>> getMessages(String chatId) async {
    final response = await _databases.listDocuments(
      databaseId: databaseId,
      collectionId: messagesCollection,
      queries: [
        Query.equal('chat_id', chatId),
        Query.orderDesc('timestamp'),
      ],
    );
    return response.documents;
  }

  RealtimeSubscription subscribeToMessages(
      String chatId, Function(RealtimeMessage) callback) {
    final subscription = _realtime.subscribe(
        ['databases.$databaseId.collections.$messagesCollection.documents']);

    subscription.stream.listen((event) {
      if (event.payload['chat_id'] == chatId) {
        callback(event);
      }
    });

    return subscription;
  }

}
