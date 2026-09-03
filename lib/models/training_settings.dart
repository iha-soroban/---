/// 出題形式
enum OperationMode {
  additionOnly, // 足し算のみ
  mixed, // 足し算・引き算混合
}

/// フラッシュ暗算のトレーニング設定
class TrainingSettings {
  final int digitCount; // 桁数 (1~5)
  final int flashCount; // 表示口数 (3~10)
  final double totalDurationSeconds; // 全体の表示時間(秒) 2~20
  final OperationMode operationMode; // 出題形式

  const TrainingSettings({
    this.digitCount = 1,
    this.flashCount = 5,
    this.totalDurationSeconds = 4,
    this.operationMode = OperationMode.additionOnly,
  });

  /// 1口あたりの表示時間(ミリ秒)。全体時間を口数で割って算出。
  double get flashSpeedMs => (totalDurationSeconds * 1000) / flashCount;

  TrainingSettings copyWith({
    int? digitCount,
    int? flashCount,
    double? totalDurationSeconds,
    OperationMode? operationMode,
  }) {
    return TrainingSettings(
      digitCount: digitCount ?? this.digitCount,
      flashCount: flashCount ?? this.flashCount,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      operationMode: operationMode ?? this.operationMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'digitCount': digitCount,
      'flashCount': flashCount,
      'totalDurationSeconds': totalDurationSeconds,
      'operationMode': operationMode.index,
    };
  }

  factory TrainingSettings.fromMap(Map<String, dynamic> map) {
    return TrainingSettings(
      digitCount: map['digitCount'] as int? ?? 1,
      flashCount: map['flashCount'] as int? ?? 5,
      totalDurationSeconds:
          (map['totalDurationSeconds'] as num?)?.toDouble() ?? 4,
      operationMode:
          OperationMode.values[map['operationMode'] as int? ?? 0],
    );
  }

  String get durationLabel {
    // 0.5秒単位で表示。整数なら小数点なしで表示。
    if (totalDurationSeconds == totalDurationSeconds.roundToDouble()) {
      return '${totalDurationSeconds.round()}秒';
    }
    return '${totalDurationSeconds.toStringAsFixed(1)}秒';
  }
}
