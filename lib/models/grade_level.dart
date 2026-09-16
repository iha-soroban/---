import 'training_settings.dart';

/// 級位・段位のカテゴリ(級 or 段)
enum GradeCategory { kyu, dan }

/// そろばん検定風「級位・段位トレーニング」の1レベル分の仕様。
///
/// 各レベルは固定の桁数・口数・出題時間を持ち、出題は加算のみ。
/// 1レベルにつき15問出題し、10問以上正解で合格となる。
class GradeLevel {
  final String label; // 例: "10級", "初段"
  final GradeCategory category;
  final int digitCount; // 出題する数字の桁数(1〜3)
  final int flashCount; // 1問あたりの口数
  final double totalDurationSeconds; // 1問あたりの出題時間(秒)

  const GradeLevel({
    required this.label,
    required this.category,
    required this.digitCount,
    required this.flashCount,
    required this.totalDurationSeconds,
  });

  /// このレベルの設定を反映した TrainingSettings を作成する。
  /// 桁数・口数・出題時間・出題形式(加算のみ)はレベル固有の値で上書きし、
  /// 出題位置・フォント・サウンドなどの表示系設定は現在のユーザー設定を引き継ぐ。
  TrainingSettings buildSettings(TrainingSettings base) {
    final DigitMode digitMode = switch (digitCount) {
      1 => DigitMode.d1,
      2 => DigitMode.d2,
      _ => DigitMode.d3,
    };
    return base.copyWith(
      digitMode: digitMode,
      flashCount: flashCount,
      totalDurationSeconds: totalDurationSeconds,
      operationMode: OperationMode.additionOnly,
    );
  }

  /// 短い仕様表記(例: "1桁 ・ 4口 ・ 4秒")
  String get specLabel => '$digitCount桁 ・ $flashCount口 ・ $_durationText秒';

  String get _durationText {
    String s = totalDurationSeconds.toStringAsFixed(2);
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
    return s;
  }

  /// 1レベルあたりの出題数
  static const int questionsPerLevel = 15;

  /// 合格に必要な正解数
  static const int passScore = 10;

  /// 級位(10級〜1級)
  static const List<GradeLevel> kyuLevels = [
    GradeLevel(
      label: '10級',
      category: GradeCategory.kyu,
      digitCount: 1,
      flashCount: 4,
      totalDurationSeconds: 4,
    ),
    GradeLevel(
      label: '9級',
      category: GradeCategory.kyu,
      digitCount: 1,
      flashCount: 5,
      totalDurationSeconds: 5,
    ),
    GradeLevel(
      label: '8級',
      category: GradeCategory.kyu,
      digitCount: 1,
      flashCount: 6,
      totalDurationSeconds: 6,
    ),
    GradeLevel(
      label: '7級',
      category: GradeCategory.kyu,
      digitCount: 2,
      flashCount: 3,
      totalDurationSeconds: 3,
    ),
    GradeLevel(
      label: '6級',
      category: GradeCategory.kyu,
      digitCount: 2,
      flashCount: 3,
      totalDurationSeconds: 3,
    ),
    GradeLevel(
      label: '5級',
      category: GradeCategory.kyu,
      digitCount: 2,
      flashCount: 4,
      totalDurationSeconds: 4,
    ),
    GradeLevel(
      label: '4級',
      category: GradeCategory.kyu,
      digitCount: 2,
      flashCount: 5,
      totalDurationSeconds: 5,
    ),
    GradeLevel(
      label: '3級',
      category: GradeCategory.kyu,
      digitCount: 2,
      flashCount: 6,
      totalDurationSeconds: 5,
    ),
    GradeLevel(
      label: '2級',
      category: GradeCategory.kyu,
      digitCount: 2,
      flashCount: 8,
      totalDurationSeconds: 7,
    ),
    GradeLevel(
      label: '1級',
      category: GradeCategory.kyu,
      digitCount: 2,
      flashCount: 10,
      totalDurationSeconds: 8,
    ),
  ];

  /// 段位(初段〜十段)
  static const List<GradeLevel> danLevels = [
    GradeLevel(
      label: '初段',
      category: GradeCategory.dan,
      digitCount: 3,
      flashCount: 4,
      totalDurationSeconds: 4,
    ),
    GradeLevel(
      label: '弐段',
      category: GradeCategory.dan,
      digitCount: 3,
      flashCount: 5,
      totalDurationSeconds: 4,
    ),
    GradeLevel(
      label: '参段',
      category: GradeCategory.dan,
      digitCount: 3,
      flashCount: 6,
      totalDurationSeconds: 4,
    ),
    GradeLevel(
      label: '四段',
      category: GradeCategory.dan,
      digitCount: 3,
      flashCount: 7,
      totalDurationSeconds: 4,
    ),
    GradeLevel(
      label: '五段',
      category: GradeCategory.dan,
      digitCount: 3,
      flashCount: 8,
      totalDurationSeconds: 4,
    ),
    GradeLevel(
      label: '六段',
      category: GradeCategory.dan,
      digitCount: 3,
      flashCount: 9,
      totalDurationSeconds: 4,
    ),
    GradeLevel(
      label: '七段',
      category: GradeCategory.dan,
      digitCount: 3,
      flashCount: 10,
      totalDurationSeconds: 4,
    ),
    GradeLevel(
      label: '八段',
      category: GradeCategory.dan,
      digitCount: 3,
      flashCount: 12,
      totalDurationSeconds: 4,
    ),
    GradeLevel(
      label: '九段',
      category: GradeCategory.dan,
      digitCount: 3,
      flashCount: 15,
      totalDurationSeconds: 4,
    ),
    GradeLevel(
      label: '十段',
      category: GradeCategory.dan,
      digitCount: 3,
      flashCount: 15,
      totalDurationSeconds: 3,
    ),
  ];

  /// 全レベル(級位 → 段位 の順)
  static const List<GradeLevel> all = [...kyuLevels, ...danLevels];
}
