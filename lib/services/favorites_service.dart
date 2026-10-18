import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_puzzle.dart';

class FavoritesService extends ChangeNotifier {
  FavoritesService(this._prefs) {
    _load();
  }

  static const _key = 'favorite_puzzles_v1';

  final SharedPreferences _prefs;
  final List<SavedPuzzle> _items = [];

  List<SavedPuzzle> get items => List.unmodifiable(_items);

  static Future<FavoritesService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return FavoritesService(prefs);
  }

  void _load() {
    final raw = _prefs.getStringList(_key) ?? [];
    _items
      ..clear()
      ..addAll(raw.map(SavedPuzzle.decode));
  }

  Future<void> _persist() async {
    await _prefs.setStringList(
      _key,
      _items.map((e) => e.encode()).toList(),
    );
  }

  bool containsId(String id) => _items.any((e) => e.id == id);

  SavedPuzzle? findById(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<void> upsert(SavedPuzzle puzzle) async {
    _items.removeWhere((e) => e.id == puzzle.id);
    _items.insert(0, puzzle);
    // Keep list manageable for elderly users.
    if (_items.length > 20) {
      _items.removeRange(20, _items.length);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
    await _persist();
    notifyListeners();
  }
}
