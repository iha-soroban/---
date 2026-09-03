import 'dart:math';
import '../models/training_settings.dart';

/// フラッシュ暗算の問題(数字の列)を生成するロジック
class ProblemGenerator {
  static final Random _random = Random();

  /// 設定に基づいて数字のリストと正解の合計を生成する。
  /// 足し算のみモードの場合はすべて正の数。
  /// 混合モードの場合は2問目以降にランダムで負の数(引き算)を含める。
  /// ただし、途中で合計がマイナスにならないよう調整する。
  static ({List<int> numbers, int answer}) generate(
    TrainingSettings settings,
  ) {
    final int minValue = pow(10, settings.digitCount - 1).toInt();
    final int maxValue = pow(10, settings.digitCount).toInt() - 1;

    final List<int> numbers = [];
    int runningTotal = 0;

    for (int i = 0; i < settings.flashCount; i++) {
      int value = minValue + _random.nextInt(maxValue - minValue + 1);

      bool canSubtract = settings.operationMode == OperationMode.mixed &&
          i > 0 && // 最初の数字は必ず正の数(合計の起点)
          runningTotal - value >= 0;

      // 混合モードでは50%の確率で引き算にする(可能な場合)
      bool doSubtract = canSubtract && _random.nextBool();

      if (doSubtract) {
        value = -value;
      }

      numbers.add(value);
      runningTotal += value;
    }

    return (numbers: numbers, answer: runningTotal);
  }
}
