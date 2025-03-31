import 'package:flutter/material.dart';
import '/constants/app_colors.dart';

class ChatScreen extends StatefulWidget {
  final String providerName;
  final String providerId;

  const ChatScreen({
    super.key,
    required this.providerName,
    required this.providerId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final List<_Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadDummyMessages();
  }

  void _loadDummyMessages() {
    _messages.addAll([
      _Message(
        text: 'Hello, how can I help you today?',
        isFromMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      _Message(
        text: 'I would like to schedule an appointment',
        isFromMe: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.providerName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _MessageBubble(message: message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: AppColors.primary,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Message(
        text: text,
        isFromMe: true,
        timestamp: DateTime.now(),
      ));
    });

    _messageController.clear();
  }
}

class _Message {
  final String text;
  final bool isFromMe;
  final DateTime timestamp;

  _Message({
    required this.text,
    required this.isFromMe,
    required this.timestamp,
  });
}

class _MessageBubble extends StatelessWidget {
  final _Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isFromMe
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: message.isFromMe
              ? AppColors.primary
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isFromMe ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}