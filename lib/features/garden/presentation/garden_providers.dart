import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/garden_repository.dart';
import '../data/mood_entry_model.dart';

final gardenProvider = FutureProvider<List<MoodEntry>>((ref) async {
  final repo = ref.watch(gardenRepositoryProvider);
  return repo.fetchMoodEntries();
});
