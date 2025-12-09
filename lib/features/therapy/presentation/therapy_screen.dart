import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import 'therapy_providers.dart';
import 'widgets/chat_bubble.dart';

class TherapyScreen extends ConsumerStatefulWidget {
  const TherapyScreen({super.key});

  @override
  ConsumerState<TherapyScreen> createState() => _TherapyScreenState();
}

class _TherapyScreenState extends ConsumerState<TherapyScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isChatActive = false;

  // Mock data - in production would come from providers
  final String _userName = 'Siddharth';
  final int _streakDays = 3;

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSend() {
    final text = _controller.text;
    if (text.isEmpty) return;
    
    ref.read(chatProvider.notifier).sendMessage(text);
    _controller.clear();
    
    // Slight delay to allow list to update before scrolling
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final isLoading = ref.watch(chatLoadingProvider);

    // Auto scroll on new message
    ref.listen(chatMessagesProvider, (previous, next) {
      if (next.length > (previous?.length ?? 0)) {
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    });

    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sol avatar with warm glow
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.warmGold.withAlpha(100),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome, color: AppTheme.warmGold, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Sol',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: (messages.isEmpty && !_isChatActive)
                  ? _buildLandingView()
                  : _buildChatView(messages, isLoading),
            ),
            if (messages.isNotEmpty || _isChatActive)
              _buildInputArea(),
          ],
        ),
    );
  }

  Widget _buildChatView(List messages, bool isLoading) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          // Typing indicator
          return Align(
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sol avatar
                Container(
                  margin: const EdgeInsets.only(right: 8, top: 4),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.warmGold.withAlpha(50),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.warmPeach.withAlpha(60),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome, color: AppTheme.warmGold, size: 16),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withAlpha(13),
                          blurRadius: 4,
                          offset: const Offset(0, 2)),
                    ]
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Sol is reflecting', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                      const SizedBox(width: 4),
                      ...List.generate(3, (i) => 
                         Padding(
                           padding: const EdgeInsets.only(left: 2),
                           child: Container(
                             width: 4, height: 4, 
                             decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)
                           ).animate(onPlay: (c) => c.repeat())
                            .fadeIn(duration: 600.ms, delay: (i*200).ms)
                            .fadeOut(delay: (600 + i*200).ms, duration: 600.ms),
                         )
                      )
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn();
        }
        
        final msg = messages[index];
        // Add Sol avatar for first message
        if (index == 0 && !msg.isUser) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8, top: 4),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.warmGold.withAlpha(50),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.warmPeach.withAlpha(60),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome, color: AppTheme.warmGold, size: 16),
              ),
              Expanded(
                child: ChatBubble(
                  message: msg.text,
                  isUser: msg.isUser,
                ),
              ),
            ],
          );
        }
        return ChatBubble(
          message: msg.text,
          isUser: msg.isUser,
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Talk to Sol...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  style: const TextStyle(color: Colors.black87),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                onPressed: _handleSend,
                mini: true,
                elevation: 0,
                backgroundColor: AppTheme.secondaryAccent,
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Helper micro-copy
          Text(
            'You can vent, reflect, or just talk about your day.',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandingView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          // Sol Logo Area with warm glow
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(128),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppTheme.warmGold.withAlpha(60), blurRadius: 30, spreadRadius: 10),
                BoxShadow(color: AppTheme.warmPeach.withAlpha(40), blurRadius: 50, spreadRadius: 20),
              ]
            ),
            child: const Icon(Icons.auto_awesome, size: 60, color: AppTheme.warmGold),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(begin: const Offset(1,1), end: const Offset(1.1, 1.1), duration: 2.seconds),
          
          const SizedBox(height: 24),
          
          // Personalized greeting with name and streak
          Text(
            'Hi $_userName!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your garden has been growing for $_streakDays days.\nWhat's on your mind today?",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 40),
          
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isChatActive = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 4,
            ),
            child: const Text('Begin Conversation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          
          const SizedBox(height: 50),
          
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Recent Sessions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold, 
                color: Colors.grey[800]
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentSessionItem('Understanding Anxiety', 'Yesterday • 15 min'),
          _buildRecentSessionItem('Gratitude Practice', '2 days ago • 10 min'),
          _buildRecentSessionItem('Weekly Reflection', '5 days ago • 20 min'),
        ],
      ),
    );
  }

  Widget _buildRecentSessionItem(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(179),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(128)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.secondaryAccent.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.history, color: AppTheme.secondaryAccent, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () {
           // Mock navigation
        },
      ),
    );
  }
}
