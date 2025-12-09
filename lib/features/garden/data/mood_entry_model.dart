class MoodEntry {
  final String id;
  final String userId;
  final int moodScore; // 1-5
  final String? note;
  final String flowerType;
  final DateTime createdAt;

  MoodEntry({
    required this.id,
    required this.userId,
    required this.moodScore,
    this.note,
    required this.flowerType,
    required this.createdAt,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String? ?? '', // Handle potential nulls
      userId: json['user_id'] as String? ?? '',
      moodScore: json['mood_score'] as int? ?? 3,
      note: json['note'] as String?,
      flowerType: json['flower_type'] as String? ?? 'default',
      createdAt: DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'mood_score': moodScore,
      'note': note,
      'flower_type': flowerType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
