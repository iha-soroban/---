/// 出題形式(足し算のみ/足し算・引き算混合)
enum OperationMode {
  additionOnly,
  mixed,
}

/// 桁数パターン(そろばん検定風の12パターン)
/// 単一桁数だけでなく「◯桁と◯桁」のような混合桁数にも対応。
enum DigitMode {
  d1, // 1桁
  d1_2, // 1桁と2桁
  d2, // 2桁
  d1_2_3, // 1桁と2桁と3桁
  d2_3, // 2桁と3桁
  d3, // 3桁
  d2_3_4, // 2桁と3桁と4桁
  d3_4, // 3桁と4桁
  d4, // 4桁
  d3_4_5, // 3桁と4桁と5桁
  d4_5, // 4桁と5桁
  d5, // 5桁
}

extension DigitModeInfo on DigitMode {
  /// この桁数モードで出現しうる桁数のリスト
  List<int> get digits {
    switch (this) {
      case DigitMode.d1:
        return [1];
      case DigitMode.d1_2:
        return [1, 2];
      case DigitMode.d2:
        return [2];
      case DigitMode.d1_2_3:
        return [1, 2, 3];
      case DigitMode.d2_3:
        return [2, 3];
      case DigitMode.d3:
        return [3];
      case DigitMode.d2_3_4:
        return [2, 3, 4];
      case DigitMode.d3_4:
        return [3, 4];
      case DigitMode.d4:
        return [4];
      case DigitMode.d3_4_5:
        return [3, 4, 5];
      case DigitMode.d4_5:
        return [4, 5];
      case DigitMode.d5:
        return [5];
    }
  }

  /// 番号付きの表示ラベル(①1ケタ など)
  String get label {
    const labels = {
      DigitMode.d1: '①  1ケタ',
      DigitMode.d1_2: '②  1ケタと2ケタ',
      DigitMode.d2: '③  2ケタ',
      DigitMode.d1_2_3: '④  1ケタと2ケタと3ケタ',
      DigitMode.d2_3: '⑤  2ケタと3ケタ',
      DigitMode.d3: '⑥  3ケタ',
      DigitMode.d2_3_4: '⑦  2ケタと3ケタと4ケタ',
      DigitMode.d3_4: '⑧  3ケタと4ケタ',
      DigitMode.d4: '⑨  4ケタ',
      DigitMode.d3_4_5: '⑩  3ケタと4ケタと5ケタ',
      DigitMode.d4_5: '⑪  4ケタと5ケタ',
      DigitMode.d5: '⑫  5ケタ',
    };
    return labels[this]!;
  }

  /// 短い表記(結果画面などで使う)
  String get shortLabel {
    return digits.map((d) => '$dケタ').join('と');
  }
}

/// 数字の表示位置
enum DisplayAlignment { center, right }

extension DisplayAlignmentInfo on DisplayAlignment {
  String get label =>
      this == DisplayAlignment.center ? '中央揃え' : '右揃え';
}

/// 数字表示に使うフォント
enum DisplayFont { sorofont, mincho }

extension DisplayFontInfo on DisplayFont {
  String get label => this == DisplayFont.sorofont ? 'そろばん' : '明朝';

  /// 対応するFontFamily名。明朝はシステムのserif系フォントにフォールバック。
  String? get fontFamily =>
      this == DisplayFont.sorofont ? 'Sorofont' : 'serif';
}

/// フラッシュ暗算のトレーニング設定
class TrainingSettings {
  final DigitMode digitMode; // 桁数パターン
  final int flashCount; // 表示口数 (1~20)
  final double totalDurationSeconds; // 出題時間(全体・秒) 0.01秒刻み
  final DisplayAlignment alignment; // 出題位置
  final DisplayFont font; // フォント
  final OperationMode operationMode; // 出題形式

  const TrainingSettings({
    this.digitMode = DigitMode.d1,
    this.flashCount = 5,
    this.totalDurationSeconds = 4,
    this.alignment = DisplayAlignment.center,
    this.font = DisplayFont.sorofont,
    this.operationMode = OperationMode.additionOnly,
  });

  /// 1口あたりの表示時間(ミリ秒)。全体時間を口数で割って算出。
  double get flashSpeedMs =>
      flashCount > 0 ? (totalDurationSeconds * 1000) / flashCount : 0;

  TrainingSettings copyWith({
    DigitMode? digitMode,
    int? flashCount,
    double? totalDurationSeconds,
    DisplayAlignment? alignment,
    DisplayFont? font,
    OperationMode? operationMode,
  }) {
    return TrainingSettings(
      digitMode: digitMode ?? this.digitMode,
      flashCount: flashCount ?? this.flashCount,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      alignment: alignment ?? this.alignment,
      font: font ?? this.font,
      operationMode: operationMode ?? this.operationMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'digitMode': digitMode.index,
      'flashCount': flashCount,
      'totalDurationSeconds': totalDurationSeconds,
      'alignment': alignment.index,
      'font': font.index,
      'operationMode': operationMode.index,
    };
  }

  factory TrainingSettings.fromMap(Map<String, dynamic> map) {
    return TrainingSettings(
      digitMode: DigitMode.values[map['digitMode'] as int? ?? 0],
      flashCount: map['flashCount'] as int? ?? 5,
      totalDurationSeconds:
          (map['totalDurationSeconds'] as num?)?.toDouble() ?? 4,
      alignment:
          DisplayAlignment.values[map['alignment'] as int? ?? 0],
      font: DisplayFont.values[map['font'] as int? ?? 0],
      operationMode:
          OperationMode.values[map['operationMode'] as int? ?? 0],
    );
  }

  String get durationLabel {
    // 0.01秒単位まで表示。末尾の余分な0は削る。
    String s = totalDurationSeconds.toStringAsFixed(2);
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
    return '$s秒';
  }
}
