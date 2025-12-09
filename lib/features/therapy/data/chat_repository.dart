import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';

import '../../../services/supabase_client.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository());

/// Model for persisted chat messages
class PersistedChatMessage {
  final String id;
  final String userId;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime createdAt;

  PersistedChatMessage({
    required this.id,
    required this.userId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory PersistedChatMessage.fromJson(Map<String, dynamic> json) {
    return PersistedChatMessage(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'role': role,
    'content': content,
    'created_at': createdAt.toIso8601String(),
  };
}

/// Repository for persisting chat messages to Supabase
class ChatRepository {
  /// Saves a chat message to the database
  Future<void> saveMessage({
    required String role,
    required String content,
  }) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    try {
      await SupabaseService.client
          .from(AppConstants.tableAiChat)
          .insert({
        'user_id': userId,
        'role': role,
        'content': content,
      });
    } catch (e) {
      // Silently fail - chat should work even if persistence fails
    }
  }

  /// Loads recent chat messages for context restoration
  /// Returns messages from today's session or last 20 messages
  Future<List<PersistedChatMessage>> loadRecentMessages() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];

    try {
      // Get today's start
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      final data = await SupabaseService.client
          .from(AppConstants.tableAiChat)
          .select()
          .eq('user_id', userId)
          .gte('created_at', todayStart.toIso8601String())
          .order('created_at', ascending: true)
          .limit(50);

      return (data as List)
          .map((e) => PersistedChatMessage.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Clears all chat history for the user
  Future<void> clearHistory() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    try {
      await SupabaseService.client
          .from(AppConstants.tableAiChat)
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      // Silently fail
    }
  }
}
