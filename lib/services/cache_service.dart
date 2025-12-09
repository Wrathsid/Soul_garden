import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

/// Service for caching data locally for offline support
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  SharedPreferences? _prefs;

  /// Initialize the cache service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    log('CacheService initialized', name: 'CacheService');
  }

  // ==================== Garden Cache ====================

  /// Cache mood entries for offline access
  Future<void> cacheMoodEntries(List<Map<String, dynamic>> entries) async {
    await _prefs?.setString('cached_mood_entries', jsonEncode(entries));
    await _prefs?.setInt('mood_entries_cached_at', DateTime.now().millisecondsSinceEpoch);
  }

  /// Get cached mood entries
  List<Map<String, dynamic>> getCachedMoodEntries() {
    final json = _prefs?.getString('cached_mood_entries');
    if (json == null) return [];
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(json));
    } catch (e) {
      return [];
    }
  }

  /// Check if mood cache is fresh (less than 1 hour old)
  bool isMoodCacheFresh() {
    final cachedAt = _prefs?.getInt('mood_entries_cached_at');
    if (cachedAt == null) return false;
    final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
    return age < 3600000; // 1 hour in milliseconds
  }

  // ==================== Chat Cache ====================

  /// Cache chat messages for offline viewing
  Future<void> cacheChatMessages(List<Map<String, dynamic>> messages) async {
    await _prefs?.setString('cached_chat_messages', jsonEncode(messages));
  }

  /// Get cached chat messages
  List<Map<String, dynamic>> getCachedChatMessages() {
    final json = _prefs?.getString('cached_chat_messages');
    if (json == null) return [];
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(json));
    } catch (e) {
      return [];
    }
  }

  // ==================== Pending Actions Queue ====================

  /// Add an action to the pending queue (for sync when online)
  Future<void> queuePendingAction(Map<String, dynamic> action) async {
    final queue = getPendingActions();
    queue.add({
      ...action,
      'queued_at': DateTime.now().toIso8601String(),
    });
    await _prefs?.setString('pending_actions', jsonEncode(queue));
    log('Action queued: ${action['type']}', name: 'CacheService');
  }

  /// Get all pending actions
  List<Map<String, dynamic>> getPendingActions() {
    final json = _prefs?.getString('pending_actions');
    if (json == null) return [];
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(json));
    } catch (e) {
      return [];
    }
  }

  /// Clear pending actions after sync
  Future<void> clearPendingActions() async {
    await _prefs?.remove('pending_actions');
    log('Pending actions cleared', name: 'CacheService');
  }

  /// Remove specific action from queue
  Future<void> removePendingAction(int index) async {
    final queue = getPendingActions();
    if (index >= 0 && index < queue.length) {
      queue.removeAt(index);
      await _prefs?.setString('pending_actions', jsonEncode(queue));
    }
  }

  // ==================== User Preferences ====================

  /// Save notification preferences
  Future<void> setNotificationEnabled(bool enabled) async {
    await _prefs?.setBool('notifications_enabled', enabled);
  }

  bool getNotificationEnabled() {
    return _prefs?.getBool('notifications_enabled') ?? true;
  }

  /// Save reminder time
  Future<void> setReminderTime(int hour, int minute) async {
    await _prefs?.setInt('reminder_hour', hour);
    await _prefs?.setInt('reminder_minute', minute);
  }

  (int, int) getReminderTime() {
    final hour = _prefs?.getInt('reminder_hour') ?? 20; // Default 8 PM
    final minute = _prefs?.getInt('reminder_minute') ?? 0;
    return (hour, minute);
  }

  // ==================== XP Cache ====================

  /// Cache XP value for display when offline
  Future<void> cacheXp(int xp) async {
    await _prefs?.setInt('cached_xp', xp);
  }

  int getCachedXp() {
    return _prefs?.getInt('cached_xp') ?? 0;
  }

  // ==================== Streak Cache ====================

  /// Cache streak data
  Future<void> cacheStreak(int currentStreak, bool completedToday) async {
    await _prefs?.setInt('cached_streak', currentStreak);
    await _prefs?.setBool('cached_completed_today', completedToday);
    await _prefs?.setString('streak_cached_date', DateTime.now().toIso8601String().split('T')[0]);
  }

  (int, bool) getCachedStreak() {
    final streak = _prefs?.getInt('cached_streak') ?? 0;
    final completedToday = _prefs?.getBool('cached_completed_today') ?? false;
    
    // Check if cached today
    final cachedDate = _prefs?.getString('streak_cached_date');
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (cachedDate != today) {
      return (streak, false); // New day, not completed yet
    }
    
    return (streak, completedToday);
  }

  // ==================== Utility ====================

  /// Clear all cached data
  Future<void> clearAllCache() async {
    await _prefs?.clear();
    log('All cache cleared', name: 'CacheService');
  }

  /// Get total cache size (approximate)
  int getApproximateCacheSize() {
    int size = 0;
    for (final key in _prefs?.getKeys() ?? <String>{}) {
      final value = _prefs?.get(key);
      if (value is String) {
        size += value.length;
      }
    }
    return size;
  }
}
