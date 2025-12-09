class XPTransaction {
  final String description;
  final int amount;
  final DateTime date;
  final String source; // 'mood', 'ritual', 'therapy', 'purchase'

  XPTransaction({
    required this.description,
    required this.amount,
    required this.date,
    required this.source,
  });
}
