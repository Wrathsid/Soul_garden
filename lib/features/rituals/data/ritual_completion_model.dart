class RitualCompletion {
  final String id;
  final String userId;
  final String ritualType; // 'breathe', 'journal', 'dream', 'stillness', 'affirmations'
  final DateTime completedAt;

  RitualCompletion({
    required this.id,
    required this.userId,
    required this.ritualType,
    required this.completedAt,
  });

  factory RitualCompletion.fromJson(Map<String, dynamic> json) {
    return RitualCompletion(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      ritualType: json['ritual_type'] as String? ?? '',
      completedAt: DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'ritual_type': ritualType,
      'created_at': completedAt.toIso8601String(),
    };
  }
}
