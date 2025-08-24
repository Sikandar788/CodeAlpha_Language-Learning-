import 'dart:math'; // This can actually be removed if _rand is unused
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> _questions = [];
  int _qIndex = 0;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _buildQuestions();
  }

  void _buildQuestions() {
    final prov = Provider.of<AppProvider>(context, listen: false);
    final pool = prov.allVocabs
        .where((v) =>
            v.language == prov.selectedLanguage &&
            v.category == prov.selectedCategory)
        .toList();
    pool.shuffle();
    final n = min(8, pool.length);
    _questions = List.generate(n, (i) {
      final correct = pool[i];
      final others = pool.where((p) => p != correct).toList()..shuffle();
      final options = [correct.translation];
      for (int j = 0; j < 3 && j < others.length; j++) {
        options.add(others[j].translation);
      }
      options.shuffle();
      return {
        'word': correct.text,
        'answer': correct.translation,
        'options': options
      };
    });
  }

  void _answer(String selected) {
    if (selected == _questions[_qIndex]['answer']) _score++;
    setState(() {
      _qIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(
          child: Text('Not enough items to build a quiz.'),
        ),
      );
    }

    if (_qIndex >= _questions.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Results')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Score: $_score / ${_questions.length}',
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    }

    final q = _questions[_qIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Text(
              'Q${_qIndex + 1} / ${_questions.length}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text(
              q['word'],
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...List.generate(q['options'].length, (i) {
              final opt = q['options'][i];
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  onPressed: () => _answer(opt),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(opt),
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
