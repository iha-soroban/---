import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/grade_session_result.dart';
import '../theme/app_theme.dart';

/// 級位・段位トレーニングの成績・履歴画面。
/// 各セット(15問)ごとの「何問中何問正解」「合格/不合格」を表示する。
class GradeHistoryScreen extends StatelessWidget {
  const GradeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final history = appState.gradeHistory;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppTheme.background,
          pinned: true,
          centerTitle: true,
          title: const Text('成績・履歴'),
          actions: [
            if (history.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppTheme.textSecondary),
                onPressed: () => _confirmClear(context, appState),
              ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildOverallStats(context, appState),
              const SizedBox(height: 24),
              const Text(
                'プレイ履歴',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
            ]),
          ),
        ),
        if (history.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'まだ履歴がありません\n級位・段位トレーニングを始めましょう!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildHistoryTile(history[index]),
                childCount: history.length,
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  void _confirmClear(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('履歴を削除', style: TextStyle(color: Colors.white)),
        content: const Text(
          '全ての履歴を削除しますか?この操作は取り消せません。',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              appState.clearGradeHistory();
              Navigator.of(ctx).pop();
            },
            child: const Text(
              '削除する',
              style: TextStyle(color: AppTheme.accentRed),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStats(BuildContext context, AppState appState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _statBox('合格率', '${appState.gradePassRate.toStringAsFixed(0)}%'),
            _statBox('合格回数',
                '${appState.gradePassedSessions} / ${appState.gradeTotalSessions}'),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.primaryYellow,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(GradeSessionResult result) {
    final dateStr =
        '${result.playedAt.month}/${result.playedAt.day} ${result.playedAt.hour.toString().padLeft(2, '0')}:${result.playedAt.minute.toString().padLeft(2, '0')}';

    final categoryColor = result.category == 'kyu'
        ? const Color(0xFF4CD964)
        : const Color(0xFF29D1E8);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          Icon(
            result.passed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            color: result.passed ? AppTheme.accentGreen : AppTheme.accentRed,
            size: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      result.levelLabel,
                      style: TextStyle(
                        color: categoryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${result.correctCount} / ${result.totalQuestions}問正解',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (result.passed ? AppTheme.accentGreen : AppTheme.accentRed)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: result.passed
                    ? AppTheme.accentGreen
                    : AppTheme.accentRed,
              ),
            ),
            child: Text(
              result.passed ? '合格' : '不合格',
              style: TextStyle(
                color: result.passed
                    ? AppTheme.accentGreen
                    : AppTheme.accentRed,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
