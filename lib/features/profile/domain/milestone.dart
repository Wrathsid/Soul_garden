import 'package:flutter/material.dart';

class Milestone {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final IconData? icon;
  final int rewardXp;
  final DateTime? completedDate;

  const Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    this.icon,
    required this.rewardXp,
    this.completedDate,
  });
}
