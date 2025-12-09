import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../secrets.dart';

class SupabaseService {
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: AppSecrets.supabaseUrl,
        anonKey: AppSecrets.supabaseAnonKey,
      );
    } catch (e) {
      // Graceful degradation or logging
      log('CRITICAL: Supabase initialization failed: $e', name: 'SupabaseService');
      // We don't rethrow to avoid crashing the whole app on startup, 
      // but features depending on it will fail gracefully (or should).
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
  
  static User? get currentUser => client.auth.currentUser;
}
