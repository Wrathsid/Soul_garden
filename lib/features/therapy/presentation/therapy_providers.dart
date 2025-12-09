import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../xp/data/xp_repository.dart';
import '../data/ai_service.dart';
import '../data/chat_repository.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.createdAt,
  });
}

final therapyServiceProvider = Provider((ref) => SolAiService());

class ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final bool hasStartedSession;

  const ChatState({
    this.messages = const [],
    this.isTyping = false,
    this.hasStartedSession = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    bool? hasStartedSession,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      hasStartedSession: hasStartedSession ?? this.hasStartedSession,
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(
    ref.watch(therapyServiceProvider),
    ref.watch(chatRepositoryProvider),
    ref,
  );
});

// Legacy providers for backward compatibility
final chatMessagesProvider = Provider<List<ChatMessage>>((ref) => ref.watch(chatProvider).messages);
final chatLoadingProvider = Provider<bool>((ref) => ref.watch(chatProvider).isTyping);

class ChatNotifier extends StateNotifier<ChatState> {
  final SolAiService _service;
  final ChatRepository _chatRepo;
  final Ref _ref;
  bool _hasAwardedSessionXp = false;

  ChatNotifier(this._service, this._chatRepo, this._ref) : super(const ChatState()) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    // Load persisted messages from today's session
    final persistedMessages = await _chatRepo.loadRecentMessages();
    
    if (persistedMessages.isEmpty) {
      // Start with welcome message
      state = state.copyWith(messages: [
        ChatMessage(
          id: 'welcome',
          text: "Hello. I'm Sol. How is your inner garden growing today? 🌿",
          isUser: false,
          createdAt: DateTime.now(),
        ),
      ]);
    } else {
      // Convert persisted messages to ChatMessage
      final messages = persistedMessages.map((p) => ChatMessage(
        id: p.id,
        text: p.content,
        isUser: p.role == 'user',
        createdAt: p.createdAt,
      )).toList();
      
      state = state.copyWith(
        messages: messages,
        hasStartedSession: true,
      );
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
      hasStartedSession: true,
    );

    // Persist user message
    await _chatRepo.saveMessage(role: 'user', content: text);

    try {
      final responseText = await _service.sendMessage(text);
      final aiMsg = ChatMessage(
        id: DateTime.now().add(const Duration(milliseconds: 100)).millisecondsSinceEpoch.toString(),
        text: responseText,
        isUser: false,
        createdAt: DateTime.now(),
      );
      
      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isTyping: false,
      );

      // Persist AI response
      await _chatRepo.saveMessage(role: 'assistant', content: responseText);

      // Award XP for first message in session (once per session)
      if (!_hasAwardedSessionXp) {
        _hasAwardedSessionXp = true;
        _ref.invalidate(xpProvider);
      }
    } catch (e) {
      final errorMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: "I'm having a bit of trouble hearing you. Could you say that again?",
        isUser: false,
        createdAt: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isTyping: false,
      );
    }
  }

  void startNewSession() {
    state = state.copyWith(
      hasStartedSession: true,
    );
  }

  Future<void> clearHistory() async {
    await _chatRepo.clearHistory();
    state = ChatState(messages: [
      ChatMessage(
        id: 'welcome',
        text: "Hello. I'm Sol. How is your inner garden growing today? 🌿",
        isUser: false,
        createdAt: DateTime.now(),
      ),
    ]);
  }
}
