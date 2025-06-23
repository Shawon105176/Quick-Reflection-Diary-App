import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../utils/safe_provider_base.dart';

class AIMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? emotion;

  AIMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.emotion,
  });
}

class AIJournalProvider extends SafeChangeNotifier {
  final List<AIMessage> _messages = [];
  bool _isTyping = false;

  List<AIMessage> get messages => _messages;
  bool get isTyping => _isTyping;

  // Simulated AI responses for demo (in production, use actual AI API)
  final List<Map<String, dynamic>> _aiResponses = [
    {
      'triggers': ['hard day', 'difficult', 'tough', 'bad day'],
      'responses': [
        "I'm sorry to hear you had a hard day. Sometimes life can feel overwhelming. What made today particularly challenging for you?",
        "That sounds really tough. I'm here to listen. Would you like to share what's been weighing on your mind?",
        "Difficult days can teach us a lot about ourselves. What do you think was the hardest part of today?",
      ],
    },
    {
      'triggers': ['happy', 'good day', 'great', 'amazing', 'wonderful'],
      'responses': [
        "That's wonderful to hear! I love when you're feeling positive. What made today so special?",
        "Your happiness is contagious! Tell me more about what brought you joy today.",
        "It sounds like today was a good day for you. What moments stood out the most?",
      ],
    },
    {
      'triggers': ['anxious', 'worried', 'nervous', 'scared'],
      'responses': [
        "Anxiety can feel really overwhelming. Remember that it's okay to feel this way. What's been on your mind lately?",
        "I hear that you're feeling anxious. Sometimes talking about our worries can help lighten the load. Want to share?",
        "Feeling nervous is completely normal. You're brave for acknowledging these feelings. What's causing you the most worry?",
      ],
    },
    {
      'triggers': ['tired', 'exhausted', 'drained', 'sleepy'],
      'responses': [
        "It sounds like you need some rest. Sometimes our bodies and minds need time to recharge. How have you been sleeping?",
        "Feeling drained can be your mind's way of saying you need a break. What's been keeping you busy lately?",
        "Exhaustion is real, and it's important to listen to your body. Have you been taking care of yourself?",
      ],
    },
    {
      'triggers': ['lonely', 'alone', 'isolated', 'disconnected'],
      'responses': [
        "Loneliness can be really hard to bear. You're not truly alone though - I'm here with you. What's making you feel this way?",
        "Feeling disconnected from others is something many people experience. Would you like to talk about what's contributing to these feelings?",
        "I'm sorry you're feeling lonely. Sometimes reaching out, even to me, is a brave first step. What would help you feel more connected?",
      ],
    },
  ];

  void addUserMessage(String content) {
    _messages.add(
      AIMessage(content: content, isUser: true, timestamp: DateTime.now()),
    );
    notifyListeners();

    _generateAIResponse(content);
  }

  Future<void> _generateAIResponse(String userMessage) async {
    _isTyping = true;
    notifyListeners();

    // Simulate AI thinking time
    await Future.delayed(const Duration(seconds: 2));

    String aiResponse = _findBestResponse(userMessage.toLowerCase());

    _messages.add(
      AIMessage(content: aiResponse, isUser: false, timestamp: DateTime.now()),
    );

    _isTyping = false;
    notifyListeners();
  }

  String _findBestResponse(String userMessage) {
    // Find matching response based on keywords
    for (var responseSet in _aiResponses) {
      List<String> triggers = List<String>.from(responseSet['triggers']);

      for (String trigger in triggers) {
        if (userMessage.contains(trigger)) {
          List<String> responses = List<String>.from(responseSet['responses']);
          return responses[Random().nextInt(responses.length)];
        }
      }
    }

    // Default empathetic responses
    List<String> defaultResponses = [
      "Thank you for sharing that with me. How are you feeling about it right now?",
      "I appreciate you opening up. Would you like to explore that feeling a bit more?",
      "That's interesting. What thoughts come to mind when you think about this?",
      "I'm here to listen. Is there anything specific you'd like to talk about regarding this?",
      "How has this been affecting your daily life?",
      "What would you say has been the most challenging part about this situation?",
    ];

    return defaultResponses[Random().nextInt(defaultResponses.length)];
  }

  void clearConversation() {
    _messages.clear();
    notifyListeners();
  }
}

class AIJournalCompanionScreen extends StatefulWidget {
  const AIJournalCompanionScreen({super.key});

  @override
  State<AIJournalCompanionScreen> createState() =>
      _AIJournalCompanionScreenState();
}

class _AIJournalCompanionScreenState extends State<AIJournalCompanionScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _fadeController;
  late AnimationController _typingController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();

    // Send welcome message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AIJournalProvider>().addUserMessage("Hi");
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _typingController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      context.read<AIJournalProvider>().addUserMessage(
        _messageController.text.trim(),
      );
      _messageController.clear();

      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.purple.shade300, Colors.blue.shade400],
                ),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Companion',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Consumer<AIJournalProvider>(
                  builder: (context, provider, child) {
                    return Text(
                      provider.isTyping ? 'Typing...' : 'Here to listen',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Clear Conversation'),
                      content: const Text(
                        'Are you sure you want to clear this conversation?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<AIJournalProvider>()
                                .clearConversation();
                            Navigator.pop(context);
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
              );
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Welcome Message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.purple.shade50, Colors.blue.shade50],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.pink.shade300,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Your AI Journal Companion',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'I\'m here to listen and help you explore your thoughts and feelings. Share whatever is on your mind.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Chat Messages
            Expanded(
              child: Consumer<AIJournalProvider>(
                builder: (context, provider, child) {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        provider.messages.length + (provider.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.messages.length &&
                          provider.isTyping) {
                        return _buildTypingIndicator();
                      }

                      final message = provider.messages[index];
                      return _buildMessageBubble(message);
                    },
                  );
                },
              ),
            ),

            // Message Input
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(AIMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.purple.shade300, Colors.blue.shade400],
                ),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    message.isUser
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft:
                      message.isUser
                          ? const Radius.circular(20)
                          : const Radius.circular(4),
                  bottomRight:
                      message.isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color:
                          message.isUser
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: Icon(
                Icons.person,
                color: Theme.of(context).primaryColor,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.purple.shade300, Colors.blue.shade400],
              ),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _typingController,
      builder: (context, child) {
        final progress = (_typingController.value * 3 - index).clamp(0.0, 1.0);
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.withOpacity(0.3 + (0.7 * progress)),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Share what\'s on your mind...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
