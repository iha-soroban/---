import 'package:flutter/material.dart';
import '../models/grade_level.dart';
import '../theme/app_theme.dart';
import 'grade_training_screen.dart';

/// 級位・段位トレーニングのメニュー選択画面。
/// 左列に級位(10級〜1級)、右列に段位(初段〜十段)を並べ、
/// できるだけ1画面で全メニューが見えるようにコンパクトに表示する。
class GradeSelectScreen extends StatelessWidget {
  const GradeSelectScreen({super.key});

  // 級位・段位それぞれのテーマカラー(視認性重視の色分け)
  static const Color kyuColor = Color(0xFF4CD964); // 緑
  static const Color danColor = Color(0xFF29D1E8); // 水色

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppTheme.textSecondary, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('級位・段位トレーニング'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    const Text(
                      '15問中10問正解で合格(足し算のみ)',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _GradeColumn(
                            title: '級位',
                            color: kyuColor,
                            levels: GradeLevel.kyuLevels,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _GradeColumn(
                            title: '段位',
                            color: danColor,
                            levels: GradeLevel.danLevels,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GradeColumn extends StatelessWidget {
  final String title;
  final Color color;
  final List<GradeLevel> levels;

  const _GradeColumn({
    required this.title,
    required this.color,
    required this.levels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 1),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 6),
        ...levels.map((level) => _GradeRow(level: level, color: color)),
      ],
    );
  }
}

class _GradeRow extends StatelessWidget {
  final GradeLevel level;
  final Color color;

  const _GradeRow({required this.level, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GradeTrainingScreen(level: level),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.7)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      level.label,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      level.specLabel,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10.5,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
