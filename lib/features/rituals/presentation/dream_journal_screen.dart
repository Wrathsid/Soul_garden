import 'package:flutter/material.dart';

class DreamJournalScreen extends StatefulWidget {
  const DreamJournalScreen({super.key});

  @override
  State<DreamJournalScreen> createState() => _DreamJournalScreenState();
}

class _DreamJournalScreenState extends State<DreamJournalScreen> {
  final TextEditingController _dreamController = TextEditingController();
  String? _selectedMood;

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '😌', 'label': 'Peaceful'},
    {'emoji': '😰', 'label': 'Anxious'},
    {'emoji': '😔', 'label': 'Sad'},
    {'emoji': '😨', 'label': 'Scared'},
    {'emoji': '🤔', 'label': 'Confused'},
  ];

  @override
  void dispose() {
    _dreamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Journal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Record Your Dream',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Capture the details while they\'re still fresh',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Dream mood selection
            Text(
              'How did your dream feel?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _moods.map((mood) {
                final isSelected = _selectedMood == mood['label'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = mood['label']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFF5483B3).withAlpha(51)
                          : const Color(0xFF052659),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected 
                            ? const Color(0xFF5483B3)
                            : const Color(0xFF7DA0CA).withAlpha(77),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(mood['emoji'], style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          mood['label'],
                          style: TextStyle(
                            color: isSelected 
                                ? const Color(0xFFC1E8FF)
                                : const Color(0xFF7DA0CA),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Dream description
            Text(
              'Describe your dream',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dreamController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'I was in a place where...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                filled: true,
                fillColor: const Color(0xFF052659),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: const Color(0xFF7DA0CA).withAlpha(77)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: const Color(0xFF7DA0CA).withAlpha(77)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF5483B3), width: 2),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveDream,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5483B3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save Dream',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveDream() {
    if (_dreamController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your dream')),
      );
      return;
    }
    // TODO: Save to database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dream saved! 🌙')),
    );
    Navigator.of(context).pop();
  }
}
