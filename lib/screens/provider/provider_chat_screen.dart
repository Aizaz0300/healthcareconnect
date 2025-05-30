import 'package:flutter/material.dart';
import '/constants/app_colors.dart';
import '/models/message.dart';
import '/services/chat_service.dart';
import 'package:appwrite/appwrite.dart';

class ProviderChatScreen extends StatefulWidget {
  final String chatId;
  final String patientName;
  final String patientId;  // Add this
  final String currentUserId;

  const ProviderChatScreen({
    super.key,
    required this.chatId,
    required this.patientName,
    required this.patientId,  // Add this
    required this.currentUserId,
  });

  @override
  State<ProviderChatScreen> createState() => _ProviderChatScreenState();
}

class _ProviderChatScreenState extends State<ProviderChatScreen> with WidgetsBindingObserver {
  final _messageController = TextEditingController();
  final List<Message> _messages = [];
  late final ChatService _chatService;
  RealtimeSubscription? _subscription;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _chatService = ChatService();
    _initializeChat();
    _markMessagesAsRead();  // Add this
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.close();
    _messageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _markMessagesAsRead();
    }
  }

  Future<void> _initializeChat() async {
    try {
      await _loadMessages();
      _subscribeToMessages();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load messages';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _chatService.getMessages(widget.chatId);
      if (mounted) {
        setState(() {
          _messages.addAll(messages.map((doc) => Message.fromDocument(doc)));
          final seen = <String>{};
          _messages.removeWhere((message) {
            final unique = !seen.contains(message.id);
            seen.add(message.id);
            return !unique;
          });
          _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        });
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  void _subscribeToMessages() {
    try {
      _subscription = _chatService.subscribeToMessages(
        widget.chatId,
        (message) {
          if (mounted) {
            setState(() {
              final newMessage = Message.fromDocument(message.payload);
              _messages.insert(0, newMessage);
            });
          }
        },
      );
    } catch (e) {
      debugPrint('Error subscribing to messages: $e');
    }
  }

  Future<void> _markMessagesAsRead() async {
    try {
      await _chatService.markMessagesAsRead(
        widget.chatId,
        widget.currentUserId,
      );
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();

    try {
      await _chatService.sendMessage(
        chatId: widget.chatId,
        senderId: widget.currentUserId,
        receiverId: widget.patientId,  // Use patient ID as receiver
        message: text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.patientName),
            const Text(
              'Patient',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Add patient info viewing functionality here
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _initializeChat,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: _messages.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                reverse: true,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  final message = _messages[index];
                                  return _MessageBubble(
                                    message: message.message,
                                    isFromMe: message.senderId ==
                                        widget.currentUserId,
                                    timestamp: message.timestamp,
                                    isRead: message.isRead,
                                    showReadStatus: message.senderId == widget.currentUserId,
                                  );
                                },
                              ),
                      ),
                      _buildMessageInput(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 80, color: AppColors.primary.withOpacity(0.3)),
            const SizedBox(height: 24),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation with your patient.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 22,
              child: IconButton(
                icon: const Icon(Icons.send, size: 18, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isFromMe;
  final DateTime timestamp;
  final bool isRead;
  final bool showReadStatus;

  const _MessageBubble({
    required this.message,
    required this.isFromMe,
    required this.timestamp,
    required this.isRead,
    required this.showReadStatus,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isFromMe ? AppColors.primary : const Color(0xFFEAEAEA);
    final textColor = isFromMe ? Colors.white : Colors.black87;
    final align = isFromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = isFromMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: bgColor, borderRadius: radius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message,
                style: TextStyle(color: textColor, fontSize: 15),
              ),
              if (showReadStatus) ...[
                const SizedBox(height: 4),
                Icon(
                  isRead ? Icons.done_all : Icons.done,
                  size: 16,
                  color: isRead ? AppColors.primary : Colors.grey,
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
          child: Text(
            _formatTimestamp(timestamp),
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    if (now.difference(timestamp).inHours < 24) {
      return "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
    }
    return "${timestamp.day}/${timestamp.month}";
  }
}
