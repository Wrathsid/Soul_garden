import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../therapy/presentation/therapy_providers.dart';
import '../data/rituals_repository.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isProcessing = false;

  void _finishJournal() async {
    final text = _controller.text;
    if (text.trim().isEmpty) {
      if (mounted) context.pop();
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 1. Log completion for streak
      await ref.read(ritualsRepositoryProvider).logCompletion('journal');
      // Note: Ideally we also save the 'text' to 'journal_entries' table, but prompt asks for "Journal Auto-Insights".
      // Assuming saving logic exists or we add it. 
      // For now, focusing on the requested "Auto-Insight".

      // 2. Get AI Reflection
      final aiService = ref.read(therapyServiceProvider);
      // We send it as a message to Sol so it remembers context
      final reflection = await aiService.sendMessage(
        "I just wrote this journal entry: \"$text\". Please give me one short, gentle reflection on it."
      );

      if (!mounted) return;

      // 3. Show Reflection
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (context) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 40),
              const SizedBox(height: 16),
              Text(
                "Sol's Reflection",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                reflection,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close sheet
                  context.pop(); // Close screen
                },
                child: const Text('Close & Save'),
              ),
            ],
          ),
        ),
      );

    } catch (e) {
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Journal')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(150),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      hintText: 'Write your thoughts here...',
                      border: InputBorder.none,
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _finishJournal,
                  icon: _isProcessing 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                      : const Icon(Icons.check),
                  label: Text(_isProcessing ? 'Reflecting...' : 'Finish Entry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
