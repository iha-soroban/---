/// 1回分のトレーニング結果(履歴保存用)
class TrainingResult {
  final DateTime playedAt;
  final String digitModeLabel; // 桁数パターンの短い表示ラベル(例: "3ケタ")
  final int flashCount;
  final double flashSpeedMs;
  final String operationModeLabel;
  final int correctAnswer;
  final int? userAnswer;
  final bool isCorrect;
  final int answerTimeMs; // 回答にかかった時間

  TrainingResult({
    required this.playedAt,
    required this.digitModeLabel,
    required this.flashCount,
    required this.flashSpeedMs,
    required this.operationModeLabel,
    required this.correctAnswer,
    required this.userAnswer,
    required this.isCorrect,
    required this.answerTimeMs,
  });

  Map<String, dynamic> toMap() {
    return {
      'playedAt': playedAt.toIso8601String(),
      'digitModeLabel': digitModeLabel,
      'flashCount': flashCount,
      'flashSpeedMs': flashSpeedMs,
      'operationModeLabel': operationModeLabel,
      'correctAnswer': correctAnswer,
      'userAnswer': userAnswer,
      'isCorrect': isCorrect,
      'answerTimeMs': answerTimeMs,
    };
  }

  factory TrainingResult.fromMap(Map<String, dynamic> map) {
    return TrainingResult(
      playedAt: DateTime.parse(map['playedAt'] as String),
      digitModeLabel: map['digitModeLabel'] as String? ??
          '${map['digitCount'] as int? ?? 1}ケタ', // 旧データ互換
      flashCount: map['flashCount'] as int? ?? 5,
      flashSpeedMs: (map['flashSpeedMs'] as num?)?.toDouble() ?? 800,
      operationModeLabel: map['operationModeLabel'] as String? ?? '',
      correctAnswer: map['correctAnswer'] as int? ?? 0,
      userAnswer: map['userAnswer'] as int?,
      isCorrect: map['isCorrect'] as bool? ?? false,
      answerTimeMs: map['answerTimeMs'] as int? ?? 0,
    );
  }
}
