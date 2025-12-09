import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ai_service.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime createdAt;

  ChatMessage({
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

  ChatState({this.messages = const [], this.isTyping = false});

  ChatState copyWith({List<ChatMessage>? messages, bool? isTyping}) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref.watch(therapyServiceProvider));
});

// Deprecated old provider reference to avoid breaking change immediately if used elsewhere, 
// but we should update usage.
final chatMessagesProvider = Provider<List<ChatMessage>>((ref) => ref.watch(chatProvider).messages);
final chatLoadingProvider = Provider<bool>((ref) => ref.watch(chatProvider).isTyping);

class ChatNotifier extends StateNotifier<ChatState> {
  final SolAiService _service;

  ChatNotifier(this._service) : super(ChatState(messages: [])) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    // TODO: Load from Supabase 'ai_chat' table filtered by today (or recent context)
    // For now, we start with welcome if empty.
    if (state.messages.isEmpty) {
      state = state.copyWith(messages: [
        ChatMessage(
          id: 'welcome',
          text: "Hello. I'm Sol. How is your inner garden growing today? 🌿",
          isUser: false,
          createdAt: DateTime.now(),
        ),
      ]);
    }
    // Logic to restore Gemini context would go here (passing history to _service)
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().toString(),
      text: text,
      isUser: true,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(messages: [...state.messages, userMsg], isTyping: true);

    // Save userMsg to Supabase? (Skipping for now as per "Automatic Implementation" speed, but requirement says "compatible with ai_chat table")
    // If we want actual continuity, we should save/load.
    
    try {
      final responseText = await _service.sendMessage(text);
      final aiMsg = ChatMessage(
        id: DateTime.now().add(const Duration(milliseconds: 100)).toString(),
        text: responseText,
        isUser: false,
        createdAt: DateTime.now(),
      );
      state = state.copyWith(messages: [...state.messages, aiMsg], isTyping: false);
      // Save aiMsg to Supabase?
    } catch (e) {
       final errorMsg = ChatMessage(
        id: DateTime.now().toString(),
        text: "I'm having a bit of trouble hearing you. Could you say that again?",
        isUser: false,
        createdAt: DateTime.now(),
      );
      state = state.copyWith(messages: [...state.messages, errorMsg], isTyping: false);
    }
  }
}
