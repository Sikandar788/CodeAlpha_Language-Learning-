import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_provider.dart';
import 'lessons.dart';
import 'flashcards.dart';
import 'quiz.dart';
import 'settings.dart';
import 'widgets.dart';
import 'models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('LinguaSpark'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ProgressCard(
              title: "Today's Progress",
              subtitle: 'Practice daily to build habit',
              percent: prov.progressPercent(),
              count: prov.todaysCount(),
              target: prov.dailyTarget,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _menuTile(context, Icons.school, 'Daily Lessons', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LessonsScreen()))),
                  _menuTile(context, Icons.auto_stories, 'Flashcards', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FlashcardsScreen()))),
                  _menuTile(context, Icons.quiz, 'Quiz', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen()))),
                  _menuTile(context, Icons.add, 'Add Word', () => _showAddDialog(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(BuildContext c, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.teal.shade300, Colors.teal.shade600]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 48, color: Colors.white), const SizedBox(height: 12), Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final textCtrl = TextEditingController();
    final transCtrl = TextEditingController();
    final exampleCtrl = TextEditingController();
    String category = 'Vocabulary';
    final prov = Provider.of<AppProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add new item'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: textCtrl, decoration: const InputDecoration(labelText: 'Text (word / phrase)')),
              TextField(controller: transCtrl, decoration: const InputDecoration(labelText: 'Translation')),
              TextField(controller: exampleCtrl, decoration: const InputDecoration(labelText: 'Example (optional)')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: category,
                items: const ['Vocabulary', 'Phrases', 'Grammar'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => category = v ?? 'Vocabulary',
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final t = textCtrl.text.trim();
              final tr = transCtrl.text.trim();
              if (t.isEmpty || tr.isEmpty) return;
              final v = Vocab(text: t, translation: tr, example: exampleCtrl.text.trim(), category: category, language: prov.selectedLanguage);
              await prov.addVocab(v);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
