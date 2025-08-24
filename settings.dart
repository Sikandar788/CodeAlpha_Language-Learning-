import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> languages = ['Spanish', 'French', 'German', 'English'];

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<AppProvider>(context);
    int dailyTarget = prov.dailyTarget;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          DropdownButtonFormField<String>(
            value: prov.selectedLanguage,
            items: languages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
            onChanged: (v) async {
              if (v == null) return;
              await prov.changeLanguage(v);
            },
            decoration: const InputDecoration(labelText: 'Select language'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: prov.selectedCategory,
            items: const ['Vocabulary', 'Phrases', 'Grammar'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) {
              if (v == null) return;
              prov.changeCategory(v);
            },
            decoration: const InputDecoration(labelText: 'Default category'),
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Daily target (words)'),
            DropdownButton<int>(
              value: dailyTarget,
              items: [5, 10, 15, 20].map((n) => DropdownMenuItem(value: n, child: Text('$n'))).toList(),
              onChanged: (v) {
                if (v == null) return;
                prov.changeDailyTarget(v);
                setState(() {});
              },
            )
          ]),
        ]),
      ),
    );
  }
}
