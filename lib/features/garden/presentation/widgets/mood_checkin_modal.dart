import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/success_toast.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/mood_entry_model.dart';
import '../../data/garden_repository.dart';
import '../garden_providers.dart';

class MoodCheckInModal extends ConsumerStatefulWidget {
  const MoodCheckInModal({super.key});

  @override
  ConsumerState<MoodCheckInModal> createState() => _MoodCheckInModalState();
}

class _MoodCheckInModalState extends ConsumerState<MoodCheckInModal> {
  int _selectedMood = 3;
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;

  final List<String> _moodEmojis = ['😢', '😕', '😐', '🙂', '🤩'];
  final List<String> _moodLabels = ['Very Sad', 'Sad', 'Neutral', 'Happy', 'Amazing'];

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    
    final entry = MoodEntry(
      id: DateTime.now().toIso8601String(), // Temporary ID, Supabase generates real one
      userId: '', // Repository handles this
      moodScore: _selectedMood + 1, // 1-based index (1-5)
      note: _noteController.text,
      flowerType: 'default',
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(gardenRepositoryProvider).addMoodEntry(entry);
      // Refresh the garden
      ref.invalidate(gardenProvider);
      if (mounted) {
        context.pop();
        // Show warm success toast
        SuccessToast.show(
          context, 
          'Bloom added to your garden! +5 XP 🌸',
          icon: Icons.local_florist,
        );
      }
    } catch (e) {
      // Show error
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error: $e')),
         );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'How are you feeling?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final isSelected = _selectedMood == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.secondaryAccent.withAlpha(50) : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isSelected ? Border.all(color: AppTheme.secondaryAccent, width: 2) : null,
                  ),
                  child: Text(
                    _moodEmojis[index],
                    style: TextStyle(fontSize: isSelected ? 32 : 24),
                  ),
                ),
              );
            }),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _moodLabels[_selectedMood],
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.secondaryAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              hintText: "What's on your mind? (Optional)",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Plant Mood 🌱',
            onPressed: _submit,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
