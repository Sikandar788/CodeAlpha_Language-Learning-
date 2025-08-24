import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_provider.dart';
import 'models.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);
    // show vocabs filtered by current category (or all categories as sections)
    final items = prov.allVocabs.where((v) => v.language == prov.selectedLanguage).toList();

    // group by category
    final Map<String, List<Vocab>> grouped = {};
    for (final v in items) {
      grouped.putIfAbsent(v.category, () => []).add(v);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Lessons')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: grouped.entries.map((entry) {
          return _categorySection(context, entry.key, entry.value);
        }).toList(),
      ),
    );
  }

  Widget _categorySection(BuildContext context, String title, List<Vocab> items) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: items.map((v) => ListTile(
          title: Text(v.text, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(v.translation),
          trailing: IconButton(icon: const Icon(Icons.volume_up), onPressed: () => Provider.of<AppProvider>(context, listen: false).speak(v.text)),
        )).toList(),
      ),
    );
  }
}
