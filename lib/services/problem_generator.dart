import 'dart:math';
import '../models/training_settings.dart';

/// フラッシュ暗算の問題(数字の列)を生成するロジック
class ProblemGenerator {
  static final Random _random = Random();

  /// 設定に基づいて数字のリストと正解の合計を生成する。
  ///
  /// - digitMode に複数の桁数が含まれる場合(例:①1ケタと2ケタ)、
  ///   flashCount 全体でできるだけ均等な回数ずつ各桁数が出現するように
  ///   割り当ててからシャッフルする(バランスの偏りを防止)。
  /// - 同じ数字(絶対値)がトレーニング全体を通してなるべく重複しないように、
  ///   既出の数字を記録して再抽選する。
  /// - 足し算のみモードの場合はすべて正の数。
  /// - 混合モードの場合は2問目以降にランダムで負の数(引き算)を含める。
  ///   ただし、途中で合計がマイナスにならないよう調整する。
  static ({List<int> numbers, int answer}) generate(
    TrainingSettings settings,
  ) {
    final List<int> digitPlan = _buildBalancedDigitPlan(
      settings.digitMode.digits,
      settings.flashCount,
    );

    final List<int> numbers = [];
    final Set<int> usedAbsValues = {};
    int runningTotal = 0;

    for (int i = 0; i < settings.flashCount; i++) {
      final int digitCount = digitPlan[i];
      final int minValue = pow(10, digitCount - 1).toInt();
      final int maxValue = pow(10, digitCount).toInt() - 1;
      final int rangeSize = maxValue - minValue + 1;

      int value;
      bool doSubtract;

      // トレーニング全体を通して、同じ数字(絶対値)が重複しないように
      // 範囲が許す限り再抽選する(無限ループ防止のため最大試行回数を設定)。
      int attempts = 0;
      // 選択可能な数値の範囲が狭い(試行回数以下)場合は、範囲サイズを
      // 上限として試行することで、無駄なループを避けつつ極力重複を避ける。
      final int maxAttempts = rangeSize < 30 ? rangeSize * 2 : 30;

      do {
        value = minValue + _random.nextInt(rangeSize);

        final bool canSubtract = settings.operationMode == OperationMode.mixed &&
            i > 0 && // 最初の数字は必ず正の数(合計の起点)
            runningTotal - value >= 0;

        // 混合モードでは50%の確率で引き算にする(可能な場合)
        doSubtract = canSubtract && _random.nextBool();

        attempts++;
      } while (usedAbsValues.contains(value) &&
          rangeSize > 1 && // 選択肢が複数ある場合のみ再抽選
          attempts < maxAttempts);

      if (doSubtract) {
        value = -value;
      }

      usedAbsValues.add(value.abs());
      numbers.add(value);
      runningTotal += value;
    }

    return (numbers: numbers, answer: runningTotal);
  }

  /// availableDigits(例:[1, 2])を flashCount 個の口にできるだけ均等に、
  /// かつ同じ桁数ができるだけ連続しないように並べた桁数リストを作る。
  ///
  /// 例:availableDigits=[1,2], flashCount=5 の場合、
  /// 各桁数の出現回数を {1:3, 2:2} のように均等配分したうえで、
  /// [1,2,1,2,1] のように交互に近い形へ並べ替える
  /// (単純な均等配分+ランダムシャッフルだと [1,1,2,1,2] のように
  /// 同じ桁数が連続してしまうことがあるため、それを防止する)。
  static List<int> _buildBalancedDigitPlan(
    List<int> availableDigits,
    int flashCount,
  ) {
    if (availableDigits.length <= 1) {
      return List<int>.filled(flashCount, availableDigits.first);
    }

    final int digitTypeCount = availableDigits.length;
    final int baseCount = flashCount ~/ digitTypeCount;
    final int remainder = flashCount % digitTypeCount;

    // シャッフルされた桁数の並び順から、余りをどの桁数に配分するか決める
    // (常に先頭の桁数だけが多くなる偏りを避けるため)。
    final List<int> shuffledDigitOrder = List<int>.from(availableDigits)
      ..shuffle(_random);

    final List<MapEntry<int, int>> digitCounts = [];
    for (int i = 0; i < digitTypeCount; i++) {
      final int digit = shuffledDigitOrder[i];
      final int count = baseCount + (i < remainder ? 1 : 0);
      digitCounts.add(MapEntry(digit, count));
    }

    return _reorganizeNoAdjacentDuplicates(digitCounts, flashCount);
  }

  /// 出現回数(頻度)に基づき、同じ値ができるだけ隣接しないように並べる。
  ///
  /// 出現回数が多い桁数から偶数インデックス(0, 2, 4, ...)に詰めていき、
  /// 埋まったら奇数インデックス(1, 3, 5, ...)に詰めていく方式
  /// (「Reorganize String」として知られるアルゴリズム)。
  /// 例:{1:3, 2:2}, 合計5 → [1,2,1,2,1]
  ///
  /// 桁数ごとの出現回数の差が最大1になるよう均等配分している限り、
  /// 同じ桁数が隣り合うことは発生しない。
  static List<int> _reorganizeNoAdjacentDuplicates(
    List<MapEntry<int, int>> digitCounts,
    int total,
  ) {
    // 出現回数が同じ桁数同士の並び順にランダム性を持たせつつ、
    // 出現回数が多い桁数から先に配置する。
    final List<MapEntry<int, int>> sorted =
        List<MapEntry<int, int>>.from(digitCounts)..shuffle(_random);
    sorted.sort((a, b) => b.value.compareTo(a.value));

    final List<int?> result = List<int?>.filled(total, null);
    int index = 0;

    for (final entry in sorted) {
      for (int i = 0; i < entry.value; i++) {
        if (index >= total) {
          // 偶数インデックスが埋まったら奇数インデックスから詰め直す
          index = 1;
        }
        result[index] = entry.key;
        index += 2;
      }
    }

    // 理論上 null は残らないが、念のためフォールバックしておく。
    return result.map((v) => v ?? sorted.first.key).toList();
  }
}
