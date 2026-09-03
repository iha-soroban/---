/// 1回分のトレーニング結果(履歴保存用)
class TrainingResult {
  final DateTime playedAt;
  final int digitCount;
  final int flashCount;
  final double flashSpeedMs;
  final String operationModeLabel;
  final int correctAnswer;
  final int? userAnswer;
  final bool isCorrect;
  final int answerTimeMs; // 回答にかかった時間

  TrainingResult({
    required this.playedAt,
    required this.digitCount,
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
      'digitCount': digitCount,
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
      digitCount: map['digitCount'] as int? ?? 1,
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
