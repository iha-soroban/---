import 'dart:math';
import '../models/training_settings.dart';

/// フラッシュ暗算の問題(数字の列)を生成するロジック
class ProblemGenerator {
  static final Random _random = Random();

  /// 設定に基づいて数字のリストと正解の合計を生成する。
  /// digitMode に含まれる桁数の中からランダムに1つを選んで各口の数字を生成する。
  /// 足し算のみモードの場合はすべて正の数。
  /// 混合モードの場合は2問目以降にランダムで負の数(引き算)を含める。
  /// ただし、途中で合計がマイナスにならないよう調整する。
  static ({List<int> numbers, int answer}) generate(
    TrainingSettings settings,
  ) {
    final List<int> availableDigits = settings.digitMode.digits;

    final List<int> numbers = [];
    int runningTotal = 0;

    for (int i = 0; i < settings.flashCount; i++) {
      final int digitCount =
          availableDigits[_random.nextInt(availableDigits.length)];
      final int minValue = pow(10, digitCount - 1).toInt();
      final int maxValue = pow(10, digitCount).toInt() - 1;

      int value;
      bool doSubtract;

      // 直前の口と同じ数字(絶対値)が連続して出ないように、
      // 範囲が許す限り再抽選する(無限ループ防止のため最大試行回数を設定)。
      int attempts = 0;
      const int maxAttempts = 20;
      final int? previousAbsValue = numbers.isNotEmpty ? numbers.last.abs() : null;

      do {
        value = minValue + _random.nextInt(maxValue - minValue + 1);

        final bool canSubtract = settings.operationMode == OperationMode.mixed &&
            i > 0 && // 最初の数字は必ず正の数(合計の起点)
            runningTotal - value >= 0;

        // 混合モードでは50%の確率で引き算にする(可能な場合)
        doSubtract = canSubtract && _random.nextBool();

        attempts++;
      } while (previousAbsValue != null &&
          value == previousAbsValue &&
          maxValue > minValue && // 選択肢が複数ある場合のみ再抽選
          attempts < maxAttempts);

      if (doSubtract) {
        value = -value;
      }

      numbers.add(value);
      runningTotal += value;
    }

    return (numbers: numbers, answer: runningTotal);
  }
}
