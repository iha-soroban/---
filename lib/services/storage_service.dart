import 'package:hive_flutter/hive_flutter.dart';
import '../models/training_settings.dart';
import '../models/training_result.dart';

/// Hiveを使ったローカルデータ永続化サービス
/// - 設定 (settingsBox)
/// - トレーニング履歴 (historyBox)
class StorageService {
  static const String settingsBoxName = 'settingsBox';
  static const String historyBoxName = 'historyBox';

  static Box? _settingsBox;
  static Box? _historyBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox(settingsBoxName);
    _historyBox = await Hive.openBox(historyBoxName);
  }

  // ---------------- 設定 ----------------
  static Future<void> saveSettings(TrainingSettings settings) async {
    await _settingsBox?.put('current', settings.toMap());
  }

  static TrainingSettings loadSettings() {
    final map = _settingsBox?.get('current');
    if (map == null) return const TrainingSettings();
    try {
      return TrainingSettings.fromMap(Map<String, dynamic>.from(map));
    } catch (_) {
      return const TrainingSettings();
    }
  }

  // ---------------- 履歴 ----------------
  static Future<void> addResult(TrainingResult result) async {
    final list = _historyBox?.get('list', defaultValue: <dynamic>[]) as List?;
    final newList = List<dynamic>.from(list ?? []);
    newList.add(result.toMap());
    // 最大200件まで保存
    if (newList.length > 200) {
      newList.removeRange(0, newList.length - 200);
    }
    await _historyBox?.put('list', newList);
  }

  static List<TrainingResult> loadResults() {
    final list = _historyBox?.get('list', defaultValue: <dynamic>[]) as List?;
    if (list == null) return [];
    return list
        .map((e) {
          try {
            return TrainingResult.fromMap(Map<String, dynamic>.from(e));
          } catch (_) {
            return null;
          }
        })
        .whereType<TrainingResult>()
        .toList()
        .reversed
        .toList();
  }

  static Future<void> clearResults() async {
    await _historyBox?.put('list', <dynamic>[]);
  }
}
