import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db_helper.dart';
import 'models.dart';

class AppProvider extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  List<Vocab> _allVocabs = [];
  String _selectedLanguage = 'Spanish';
  String _selectedCategory = 'Vocabulary';
  int _dailyTarget = 10;
  Map<String, int> _dailyProgress = {}; // date -> count practiced

  List<Vocab> get allVocabs => _allVocabs;
  String get selectedLanguage => _selectedLanguage;
  String get selectedCategory => _selectedCategory;
  int get dailyTarget => _dailyTarget;

  Future<void> init() async {
    await _loadPrefs();
    await _loadVocabs();
    if (_allVocabs.isEmpty) {
      await _seedDefaults();
      await _loadVocabs();
    }
    // configure tts default
    await _tts.setPitch(1.0);
    notifyListeners();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    _selectedLanguage = p.getString('lang') ?? 'Spanish';
    _selectedCategory = p.getString('cat') ?? 'Vocabulary';
    _dailyTarget = p.getInt('target') ?? 10;
    // load today's progress (if any)
    final todayKey = _todayKey();
    _dailyProgress[todayKey] = p.getInt('progress_$todayKey') ?? 0;
  }

  Future<void> _savePref(String key, dynamic value) async {
    final p = await SharedPreferences.getInstance();
    if (value is String) await p.setString(key, value);
    if (value is int) await p.setInt(key, value);
  }

  String _todayKey() => DateTime.now().toIso8601String().split('T').first;

  Future<void> _loadVocabs() async {
    _allVocabs = await DBHelper.fetchVocabs(language: _selectedLanguage, category: null);
    notifyListeners();
  }

  Future<void> changeLanguage(String lang) async {
    _selectedLanguage = lang;
    await _savePref('lang', lang);
    await _loadVocabs();
  }

  Future<void> changeCategory(String cat) async {
    _selectedCategory = cat;
    await _savePref('cat', cat);
    notifyListeners();
  }

  Future<void> changeDailyTarget(int value) async {
    _dailyTarget = value;
    await _savePref('target', value);
    notifyListeners();
  }

  Future<void> addVocab(Vocab v) async {
    await DBHelper.insertVocab(v);
    await _loadVocabs();
  }

  Future<void> speak(String text) async {
    // set language code based on selectedLanguage (simple mapping)
    final langCode = _langCodeFromLanguage(_selectedLanguage);
    try {
      await _tts.setLanguage(langCode);
    } catch (_) {}
    await _tts.speak(text);
  }

  String _langCodeFromLanguage(String lang) {
    switch (lang.toLowerCase()) {
      case 'spanish':
        return 'es-ES';
      case 'french':
        return 'fr-FR';
      case 'german':
        return 'de-DE';
      default:
        return 'en-US';
    }
  }

  // mark practiced
  Future<void> markPracticed() async {
    final key = _todayKey();
    _dailyProgress[key] = (_dailyProgress[key] ?? 0) + 1;
    final p = await SharedPreferences.getInstance();
    await p.setInt('progress_$key', _dailyProgress[key]!);
    notifyListeners();
  }

  int todaysCount() {
    final key = _todayKey();
    return _dailyProgress[key] ?? 0;
  }

  double progressPercent() {
    if (_dailyTarget == 0) return 0;
    return (todaysCount() / _dailyTarget).clamp(0.0, 1.0);
  }

  // helper: fetch vocabs filtered by category
  List<Vocab> vocabsForCurrentSelection() {
    return _allVocabs.where((v) => v.category == _selectedCategory && v.language == _selectedLanguage).toList();
  }

  // simple seeding
  Future<void> _seedDefaults() async {
    final seeds = [
      Vocab(text: 'Hola', translation: 'Hello', example: 'Hola, ¿cómo estás?', category: 'Vocabulary', language: 'Spanish'),
      Vocab(text: 'Gracias', translation: 'Thank you', example: 'Gracias por tu ayuda.', category: 'Vocabulary', language: 'Spanish'),
      Vocab(text: 'Buenos días', translation: 'Good morning', example: '¡Buenos días, señor!', category: 'Phrases', language: 'Spanish'),
      Vocab(text: '¿Dónde está el baño?', translation: 'Where is the bathroom?', example: '', category: 'Phrases', language: 'Spanish'),
      Vocab(text: 'Subjunctive (brief)', translation: 'Used for wishes, doubts', example: 'Es importante que vengas.', category: 'Grammar', language: 'Spanish'),
      // you can add more seeds or languages here
    ];
    for (final s in seeds) {
      await DBHelper.insertVocab(s);
    }
  }
}
