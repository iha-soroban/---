import 'package:flutter/material.dart';
import '../models/training_settings.dart';
import '../models/training_result.dart';
import 'storage_service.dart';

/// アプリ全体の状態管理(Provider)
class AppState extends ChangeNotifier {
  TrainingSettings _settings = const TrainingSettings();
  List<TrainingResult> _history = [];

  TrainingSettings get settings => _settings;
  List<TrainingResult> get history => _history;

  Future<void> init() async {
    _settings = StorageService.loadSettings();
    _history = StorageService.loadResults();
    notifyListeners();
  }

  Future<void> updateSettings(TrainingSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    await StorageService.saveSettings(newSettings);
  }

  Future<void> addResult(TrainingResult result) async {
    _history.insert(0, result);
    notifyListeners();
    await StorageService.addResult(result);
  }

  Future<void> clearHistory() async {
    _history = [];
    notifyListeners();
    await StorageService.clearResults();
  }

  // ---------------- 統計情報 ----------------
  int get totalCount => _history.length;

  int get correctCount => _history.where((r) => r.isCorrect).length;

  double get accuracyRate {
    if (totalCount == 0) return 0;
    return correctCount / totalCount * 100;
  }

  double get averageAnswerTimeSec {
    if (_history.isEmpty) return 0;
    final total = _history.fold<int>(0, (sum, r) => sum + r.answerTimeMs);
    return total / _history.length / 1000;
  }

  int get currentStreak {
    int streak = 0;
    for (final r in _history) {
      if (r.isCorrect) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int get bestStreak {
    int best = 0;
    int current = 0;
    // historyは新しい順なので逆順(古い順)で走査
    for (final r in _history.reversed) {
      if (r.isCorrect) {
        current++;
        if (current > best) best = current;
      } else {
        current = 0;
      }
    }
    return best;
  }
}
