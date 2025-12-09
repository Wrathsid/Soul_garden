import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants.dart';
import '../../../services/supabase_client.dart';
import 'profile_model.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepository());

class ProfileRepository {
  Future<UserProfile?> fetchProfile() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return null;

    try {
      final data = await SupabaseService.client
          .from(AppConstants.tableProfiles)
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (data == null) {
        // Return dummy profile if not found, or handle creation
        return UserProfile(id: userId, xp: 0, displayName: 'Gardener');
      }
      return UserProfile.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, int>> fetchStats() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return {'entries': 0, 'rituals': 0, 'messages': 0};

    // Use count queries
    final entriesCount = await SupabaseService.client
        .from(AppConstants.tableMoodEntries)
        .count(CountOption.exact)
        .eq('user_id', userId);

    final ritualsCount = await SupabaseService.client
        .from(AppConstants.tableRitualsCompleted)
        .count(CountOption.exact)
        .eq('user_id', userId);
    
    // Determining chat message count (messages from User or Total? usually User)
    // Assuming ai_chat table has user_id and is_user column (or similar)
    // If ai_chat stores JSON history per session, this is harder. 
    // If ai_chat stores individual messages:
    /*
    final messageCount = await SupabaseService.client
        .from(AppConstants.tableAiChat)
        .count(CountOption.exact)
        .eq('user_id', userId)
        .eq('is_user', true);
    */
    // For now returning mock for messages or 0 if table structure uncertain
    return {
      'entries': entriesCount,
      'rituals': ritualsCount,
      'messages': 0, // Placeholder
    };
  }
}
