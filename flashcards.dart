import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_provider.dart';
import 'models.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  int _index = 0;
  bool _showBack = false;

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);
    final list = prov.allVocabs.where((v) => v.language == prov.selectedLanguage && v.category == prov.selectedCategory).toList();

    if (list.isEmpty) {
      return Scaffold(appBar: AppBar(title: const Text('Flashcards')), body: const Center(child: Text('No items in this category. Add some!')));
    }

    final card = list[_index % list.length];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (s) => prov.changeCategory(s),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'Vocabulary', child: Text('Vocabulary')),
              PopupMenuItem(value: 'Phrases', child: Text('Phrases')),
              PopupMenuItem(value: 'Grammar', child: Text('Grammar')),
            ],
            icon: const Icon(Icons.filter_list),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showBack = !_showBack),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))]),
                alignment: Alignment.center,
                child: _showBack ? _back(card) : _front(card),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(icon: const Icon(Icons.volume_up), onPressed: () => prov.speak(card.text)),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                prov.markPracticed();
                setState(() {
                  _index++;
                  _showBack = false;
                });
              },
              child: const Text('I practiced this'),
            ),
          ])
        ]),
      ),
    );
  }

  Widget _front(Vocab v) => Padding(padding: const EdgeInsets.all(24.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(v.text, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(v.category, style: const TextStyle(color: Colors.grey))]));

  Widget _back(Vocab v) => Padding(padding: const EdgeInsets.all(20.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(v.translation, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600)), const SizedBox(height: 12), Text(v.example, style: const TextStyle(color: Colors.grey))]));
}
