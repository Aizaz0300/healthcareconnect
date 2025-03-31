import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:groq/groq.dart';
import '/constants/app_colors.dart';

class SmartCareConnect extends StatefulWidget {
  const SmartCareConnect({super.key});

  @override
  State<SmartCareConnect> createState() => _SmartCareConnectState();
}

class _SmartCareConnectState extends State<SmartCareConnect> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final _groq = Groq(
    apiKey: "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",
    model: "llama-3.3-70b-versatile",
  );

  @override
  void initState() {
    super.initState();
    _groq.startChat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart Care Connect',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'AI-Powered Health Assistant',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildWelcomeCard(),
          Expanded(
            child: _messages.isEmpty
                ? _buildSuggestedQuestions()
                : _buildChatList(),
          ),
          if (_isLoading) _buildLoadingIndicator(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  // Add new UI components and helper methods
  Widget _buildWelcomeCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.8), AppColors.gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              child: Icon(Icons.health_and_safety, color: AppColors.primary),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello! 👋',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'I\'m your AI health assistant. How can I help you today?',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    final suggestions = [
      'What are common symptoms of the flu?',
      'How can I improve my sleep quality?',
      'Tips for maintaining a healthy diet',
      'Exercises for back pain relief',
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Suggested Questions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((question) {
            return InkWell(
              onTap: () {
                _textController.text = question;
                _handleSubmitted(question);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(
                  question,
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) => _messages[index],
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 16),
          Text('Processing your request...'),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Ask me anything about health...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: () => _handleSubmitted(_textController.text),
            backgroundColor: AppColors.primary,
            elevation: 0,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _messages.add(ChatMessage(text: text, isUserMessage: true));
      _isLoading = true;
      _textController.clear();
    });

    _scrollToBottom();

    try {
      // Format the prompt to get better structured responses
      final prompt = '''Please provide a well-structured response using markdown formatting:
      # for main headings
      ## for subheadings
      - for bullet points
      **text** for emphasis
      
      Question: $text''';

      final response = await _groq.sendMessage(prompt);
      
      setState(() {
        _messages.add(ChatMessage(
          text: response.choices.first.message.content,
          isUserMessage: false,
        ));
        _isLoading = false;
      });
      
      _scrollToBottom();
    } catch (error) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Sorry, I encountered an error. Please try again.',
          isUserMessage: false,
          isError: true,
        ));
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Smart Care Connect'),
        content: const Text(
          'Smart Care Connect is an AI-powered health assistant. While it provides helpful information, '
          'it should not replace professional medical advice. Always consult with healthcare professionals '
          'for medical concerns.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUserMessage;
  final bool isError;

  const ChatMessage({
    super.key,
    required this.text,
    this.isUserMessage = false,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUserMessage
              ? AppColors.primary
              : isError
                  ? Colors.red[50]
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isUserMessage ? const Radius.circular(0) : null,
            bottomLeft: !isUserMessage ? const Radius.circular(0) : null,
          ),
        ),
        child: isUserMessage
            ? Text(
                text,
                style: const TextStyle(color: Colors.white),
              )
            : MarkdownBody(
                data: text,
                styleSheet: MarkdownStyleSheet(
                  h1: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  h2: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                  strong: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  listBullet: const TextStyle(color: AppColors.primary),
                ),
              ),
      ),
    );
  }
}