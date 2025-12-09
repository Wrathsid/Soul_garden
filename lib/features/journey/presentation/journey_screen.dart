import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/loading_state.dart';
import '../../garden/data/mood_entry_model.dart';
import '../../garden/presentation/garden_providers.dart';

class JourneyScreen extends ConsumerStatefulWidget {
  const JourneyScreen({super.key});

  @override
  ConsumerState<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends ConsumerState<JourneyScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Happy', 'Calm', 'Anxious', 'Sad'];

  @override
  Widget build(BuildContext context) {
    final gardenAsync = ref.watch(gardenProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // H1 Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'My Journey',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: filters.map((filter) {
                  final isSelected = selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => selectedFilter = filter);
                        }
                      },
                      backgroundColor: Colors.white.withAlpha(128),
                      selectedColor: AppTheme.secondaryAccent,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
            
            Expanded(
              child: gardenAsync.when(
                data: (entries) {
                  // Apply Filter
                  final filteredEntries = entries.where((e) {
                    if (selectedFilter == 'All') return true;
                    // Start simple mapping, can be improved with real mood mapping
                    final mood = _getMoodLabel(e.moodScore);
                    return mood == selectedFilter; 
                  }).toList();

                  if (filteredEntries.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredEntries.length,
                    itemBuilder: (context, index) {
                      final entry = filteredEntries[index];
                      return _buildTimelineItem(context, entry);
                    },
                  );
                },
                loading: () => const LoadingState(),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primarySurface.withAlpha(150),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(30),
            child: const Icon(Icons.eco, size: 60, color: AppTheme.softHighlight),
          ),
          const SizedBox(height: 32),
          Text(
            'Your journey begins with a\nsingle seed. 🌱',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white.withAlpha(230),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Log your first mood to start your timeline.',
             textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withAlpha(179),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, MoodEntry entry) {
    Color tileColor;
    if (entry.moodScore >= 4) {
      tileColor = Colors.green.shade100;
    } else if (entry.moodScore == 3) {
      tileColor = Colors.blue.shade100;
    } else {
      tileColor = Colors.purple.shade100;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 2,
                height: 20,
                color: Colors.grey.shade300,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: tileColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                     BoxShadow(
                       color: tileColor.withAlpha(128),
                       blurRadius: 8,
                       offset: const Offset(0, 2),
                     )
                  ]
                ),
                child: Text(
                  _getEmojiForMood(entry.moodScore),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              Container(
                width: 2,
                height: 80,
                color: Colors.grey.shade300,
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat.yMMMd().add_jm().format(entry.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: tileColor.withAlpha(200),
                          shape: BoxShape.circle,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.note ?? 'No note',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  // Mood tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: tileColor.withAlpha(100),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getMoodTag(entry.moodScore),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getMoodTagColor(entry.moodScore),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getEmojiForMood(int score) {
     if (score == 0) {
       return '-';
     } 
     const emojis = ['😢', '😕', '😐', '🙂', '🤩'];
     if (score < 1) return emojis[0];
     if (score > 5) return emojis[4];
     return emojis[score - 1];
  }

  String _getMoodLabel(int score) {
    if (score >= 4) return 'Happy'; // Covers Happy and Excited
    if (score == 3) return 'Calm'; // Middle ground
    if (score == 2) return 'Anxious';
    if (score <= 1) return 'Sad';
    return 'All';
  }

  String _getMoodTag(int score) {
    if (score >= 5) return 'Feeling amazing ✨';
    if (score == 4) return 'Mostly calm';
    if (score == 3) return 'Balanced day';
    if (score == 2) return 'Tough but consistent';
    return 'A hard day, but you showed up 💪';
  }

  Color _getMoodTagColor(int score) {
    if (score >= 4) return Colors.green.shade700;
    if (score == 3) return Colors.blue.shade700;
    if (score == 2) return Colors.orange.shade700;
    return Colors.purple.shade700;
  }
}
