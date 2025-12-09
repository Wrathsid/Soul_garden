class AppConstants {
  static const String appName = 'SoulGarden';
  
  // Supabase Tables
  static const String tableProfiles = 'profiles';
  static const String tableMoodEntries = 'mood_entries';
  static const String tableJournalEntries = 'journal_entries';
  static const String tableRitualsCompleted = 'rituals_completed';
  static const String tableAiChat = 'ai_chat';
  static const String tableShopItems = 'shop_items';
  static const String tableUserInventory = 'user_inventory';

  // XP Values
  static const int xpMoodCheckIn = 10;
  static const int xpRitual = 15;
  static const int xpTherapy = 20;
  static const int xpStreakBonus = 5;

  // Asset Paths (Placeholders - ensure these exist or handle missing)
  static const String riveBreathing = 'assets/rive/breathing.riv';
  static const String defaultAvatar = 'assets/images/cat_default.png';
}
