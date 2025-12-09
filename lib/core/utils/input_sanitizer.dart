/// Utility for sanitizing user inputs before sending to AI
class InputSanitizer {
  /// List of patterns that could indicate prompt injection attempts
  static final List<RegExp> _suspiciousPatterns = [
    RegExp(r'ignore\s+(previous|all|above)\s+instructions?', caseSensitive: false),
    RegExp(r'forget\s+(everything|all|your\s+instructions?)', caseSensitive: false),
    RegExp(r'you\s+are\s+now\s+', caseSensitive: false),
    RegExp(r'act\s+as\s+if', caseSensitive: false),
    RegExp(r'pretend\s+(to\s+be|you\s+are)', caseSensitive: false),
    RegExp(r'system\s*:\s*', caseSensitive: false),
    RegExp(r'<\s*system\s*>', caseSensitive: false),
    RegExp(r'\[\s*INST\s*\]', caseSensitive: false),
    RegExp(r'jailbreak', caseSensitive: false),
    RegExp(r'DAN\s+mode', caseSensitive: false),
  ];

  /// Dangerous content patterns
  static final List<RegExp> _dangerousPatterns = [
    RegExp(r'how\s+to\s+(kill|harm|hurt)\s+(myself|yourself|someone)', caseSensitive: false),
    RegExp(r'suicide\s+method', caseSensitive: false),
    RegExp(r'ways\s+to\s+die', caseSensitive: false),
  ];

  /// Sanitize user input for AI consumption
  /// Returns the sanitized text and a safety flag
  static SanitizationResult sanitize(String input) {
    if (input.isEmpty) {
      return SanitizationResult(
        sanitizedText: input,
        flags: const [],
      );
    }

    final flags = <SanitizationFlag>[];
    var sanitized = input.trim();

    // Check for prompt injection attempts
    for (final pattern in _suspiciousPatterns) {
      if (pattern.hasMatch(sanitized)) {
        flags.add(SanitizationFlag.potentialInjection);
        // Don't block, but log and potentially modify
        sanitized = sanitized.replaceAll(pattern, '[filtered]');
        break;
      }
    }

    // Check for dangerous content (urgent mental health concerns)
    for (final pattern in _dangerousPatterns) {
      if (pattern.hasMatch(input)) {
        flags.add(SanitizationFlag.urgentConcern);
        break;
      }
    }

    // Limit length to prevent abuse
    if (sanitized.length > 2000) {
      sanitized = sanitized.substring(0, 2000);
      flags.add(SanitizationFlag.truncated);
    }

    // Remove excessive whitespace
    sanitized = sanitized.replaceAll(RegExp(r'\s{3,}'), '  ');

    return SanitizationResult(
      sanitizedText: sanitized,
      flags: flags,
    );
  }

  /// Check if input contains urgent mental health concerns
  static bool containsUrgentConcerns(String input) {
    for (final pattern in _dangerousPatterns) {
      if (pattern.hasMatch(input)) return true;
    }
    return false;
  }

  /// Get a supportive response for urgent concerns
  static String getUrgentSupportResponse() {
    return '''
I sense that you might be going through something really difficult right now. 

Your feelings are valid, and you deserve support. Please know that you're not alone.

If you're having thoughts of harming yourself, please reach out to someone who can help:
• National Suicide Prevention Lifeline: 988 (US)
• Crisis Text Line: Text HOME to 741741
• International Association for Suicide Prevention: https://www.iasp.info/resources/Crisis_Centres/

Would you like to talk about what's on your mind? I'm here to listen. 💚
''';
  }
}

/// Result of input sanitization
class SanitizationResult {
  final String sanitizedText;
  final List<SanitizationFlag> flags;

  const SanitizationResult({
    required this.sanitizedText,
    required this.flags,
  });

  bool get isClean => flags.isEmpty;
  bool get hasUrgentConcerns => flags.contains(SanitizationFlag.urgentConcern);
  bool get hasPotentialInjection => flags.contains(SanitizationFlag.potentialInjection);
}

enum SanitizationFlag {
  potentialInjection,
  urgentConcern,
  truncated,
}
