/// 出題形式
enum OperationMode {
  additionOnly, // 足し算のみ
  mixed, // 足し算・引き算混合
}

/// フラッシュ暗算のトレーニング設定
class TrainingSettings {
  final int digitCount; // 桁数 (1~3)
  final int flashCount; // 表示個数 (3~10)
  final double flashSpeedMs; // 1個あたりの表示時間(ミリ秒) 200~1500
  final OperationMode operationMode; // 出題形式

  const TrainingSettings({
    this.digitCount = 1,
    this.flashCount = 5,
    this.flashSpeedMs = 800,
    this.operationMode = OperationMode.additionOnly,
  });

  TrainingSettings copyWith({
    int? digitCount,
    int? flashCount,
    double? flashSpeedMs,
    OperationMode? operationMode,
  }) {
    return TrainingSettings(
      digitCount: digitCount ?? this.digitCount,
      flashCount: flashCount ?? this.flashCount,
      flashSpeedMs: flashSpeedMs ?? this.flashSpeedMs,
      operationMode: operationMode ?? this.operationMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'digitCount': digitCount,
      'flashCount': flashCount,
      'flashSpeedMs': flashSpeedMs,
      'operationMode': operationMode.index,
    };
  }

  factory TrainingSettings.fromMap(Map<String, dynamic> map) {
    return TrainingSettings(
      digitCount: map['digitCount'] as int? ?? 1,
      flashCount: map['flashCount'] as int? ?? 5,
      flashSpeedMs: (map['flashSpeedMs'] as num?)?.toDouble() ?? 800,
      operationMode:
          OperationMode.values[map['operationMode'] as int? ?? 0],
    );
  }

  String get speedLabel {
    if (flashSpeedMs >= 1200) return 'ゆっくり';
    if (flashSpeedMs >= 700) return 'ふつう';
    if (flashSpeedMs >= 400) return 'はやい';
    return '最速';
  }
}
