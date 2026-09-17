/// 級位・段位トレーニング 1セット(15問)分の結果(履歴保存用)
class GradeSessionResult {
  final DateTime playedAt;
  final String levelLabel; // 例: "10級", "初段"
  final String category; // 'kyu' または 'dan'
  final int correctCount;
  final int totalQuestions;
  final bool passed;

  GradeSessionResult({
    required this.playedAt,
    required this.levelLabel,
    required this.category,
    required this.correctCount,
    required this.totalQuestions,
    required this.passed,
  });

  Map<String, dynamic> toMap() {
    return {
      'playedAt': playedAt.toIso8601String(),
      'levelLabel': levelLabel,
      'category': category,
      'correctCount': correctCount,
      'totalQuestions': totalQuestions,
      'passed': passed,
    };
  }

  factory GradeSessionResult.fromMap(Map<String, dynamic> map) {
    return GradeSessionResult(
      playedAt: DateTime.parse(map['playedAt'] as String),
      levelLabel: map['levelLabel'] as String? ?? '',
      category: map['category'] as String? ?? 'kyu',
      correctCount: map['correctCount'] as int? ?? 0,
      totalQuestions: map['totalQuestions'] as int? ?? 15,
      passed: map['passed'] as bool? ?? false,
    );
  }
}
