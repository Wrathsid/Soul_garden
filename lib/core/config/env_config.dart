/// Environment configuration
/// 
/// In production, these values should come from --dart-define flags:
/// flutter run --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=xxx --dart-define=GEMINI_API_KEY=xxx
/// 
/// For development, fallback values from secrets.dart are used.
class EnvConfig {
  /// Get Supabase URL from environment or fallback
  static String get supabaseUrl {
    const envValue = String.fromEnvironment('SUPABASE_URL');
    if (envValue.isNotEmpty) return envValue;
    
    // Fallback to secrets.dart (development only)
    return _FallbackSecrets.supabaseUrl;
  }

  /// Get Supabase Anon Key from environment or fallback
  static String get supabaseAnonKey {
    const envValue = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (envValue.isNotEmpty) return envValue;
    
    return _FallbackSecrets.supabaseAnonKey;
  }

  /// Get Gemini API Key from environment or fallback
  static String get geminiApiKey {
    const envValue = String.fromEnvironment('GEMINI_API_KEY');
    if (envValue.isNotEmpty) return envValue;
    
    return _FallbackSecrets.geminiApiKey;
  }

  /// Check if running in production mode (all env vars defined)
  static bool get isProduction {
    const url = String.fromEnvironment('SUPABASE_URL');
    const key = String.fromEnvironment('SUPABASE_ANON_KEY');
    return url.isNotEmpty && key.isNotEmpty;
  }
}

/// Fallback secrets for development only
/// WARNING: These will be removed in production builds
class _FallbackSecrets {
  static const String geminiApiKey = 'AIzaSyAVg4btC9vBYd1JnhogE9DvHJR_DSEEXJA';
  static const String supabaseUrl = 'https://vqzvhvgugswmvfvzaeic.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZxenZodmd1Z3N3bXZmdnphZWljIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzODI5MTYsImV4cCI6MjA3OTk1ODkxNn0.piVXfuYqSyFZriHXdSROs4A3Cm62skeAvq66pv-xe0s';
}
