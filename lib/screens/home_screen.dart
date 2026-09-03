import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/training_settings.dart';
import '../theme/app_theme.dart';
import 'training_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _navIndex == 0 ? const _HomeContent() : const HistoryScreen(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.flash_on),
            label: 'トレーニング',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '成績・履歴',
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final settings = appState.settings;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppTheme.background,
          pinned: true,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.flash_on, color: AppTheme.primaryYellow),
              const SizedBox(width: 6),
              Text(
                'FLASH CALC',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const _SectionTitle('今の成績'),
              const SizedBox(height: 10),
              _buildStatsSummary(context, appState),
              const SizedBox(height: 28),
              const _SectionTitle('出題形式'),
              const SizedBox(height: 10),
              _buildOperationModeSelector(context, appState, settings),
              const SizedBox(height: 24),
              const _SectionTitle('桁数(1問あたりの数字の桁数)'),
              const SizedBox(height: 10),
              _buildChipSelectorCard(
                options: const [1, 2, 3, 4, 5],
                optionLabel: (v) => '$vケタ',
                selectedValue: settings.digitCount,
                onSelect: (v) => appState.updateSettings(
                  settings.copyWith(digitCount: v),
                ),
              ),
              const SizedBox(height: 24),
              const _SectionTitle('口数(表示する数字の個数)'),
              const SizedBox(height: 10),
              _buildChipSelectorCard(
                options: const [3, 4, 5, 6, 7, 8, 9, 10],
                optionLabel: (v) => '$v口',
                selectedValue: settings.flashCount,
                onSelect: (v) => appState.updateSettings(
                  settings.copyWith(flashCount: v),
                ),
              ),
              const SizedBox(height: 24),
              const _SectionTitle('表示スピード(全体の表示時間)'),
              const SizedBox(height: 10),
              _buildDurationStepperCard(context, appState, settings),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TrainingScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, size: 28),
                      SizedBox(width: 8),
                      Text('スタート', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSummary(BuildContext context, AppState appState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            _statItem('正解率', '${appState.accuracyRate.toStringAsFixed(0)}%'),
            _verticalDivider(),
            _statItem('連続正解', '${appState.currentStreak}回'),
            _verticalDivider(),
            _statItem('総回数', '${appState.totalCount}回'),
          ],
        ),
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 40,
      color: const Color(0xFF333333),
    );
  }

  Widget _statItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.primaryYellow,
              fontSize: 22,
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

  Widget _buildOperationModeSelector(
    BuildContext context,
    AppState appState,
    TrainingSettings settings,
  ) {
    return Row(
      children: [
        Expanded(
          child: _modeChip(
            context: context,
            label: '足し算のみ',
            selected: settings.operationMode == OperationMode.additionOnly,
            onTap: () => appState.updateSettings(
              settings.copyWith(operationMode: OperationMode.additionOnly),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _modeChip(
            context: context,
            label: '足し算・引き算',
            selected: settings.operationMode == OperationMode.mixed,
            onTap: () => appState.updateSettings(
              settings.copyWith(operationMode: OperationMode.mixed),
            ),
          ),
        ),
      ],
    );
  }

  Widget _modeChip({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryYellow : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppTheme.primaryYellow
                : const Color(0xFF333333),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  /// タップだけで選択できるチップ選択式カード(桁数・表示個数用)
  /// スクロール画面内でもドラッグ操作と競合しないよう、Sliderの代わりに採用。
  Widget _buildChipSelectorCard({
    required List<int> options,
    required String Function(int) optionLabel,
    required int selectedValue,
    required ValueChanged<int> onSelect,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((opt) {
            final selected = opt == selectedValue;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 52,
                height: 44,
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.primaryYellow
                      : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected
                        ? AppTheme.primaryYellow
                        : const Color(0xFF3A3A3A),
                  ),
                ),
                child: Center(
                  child: Text(
                    optionLabel(opt),
                    style: TextStyle(
                      color: selected ? Colors.black : AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 表示スピードは全体の表示時間(秒)を +/- ボタンで調整(0.5秒刻み)
  Widget _buildDurationStepperCard(
    BuildContext context,
    AppState appState,
    TrainingSettings settings,
  ) {
    const double step = 0.5;
    const double minDuration = 2;
    const double maxDuration = 20;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _speedButton(
              icon: Icons.remove,
              enabled: settings.totalDurationSeconds > minDuration,
              onTap: () {
                final newVal = (settings.totalDurationSeconds - step)
                    .clamp(minDuration, maxDuration);
                appState.updateSettings(
                  settings.copyWith(totalDurationSeconds: newVal),
                );
              },
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    settings.durationLabel,
                    style: const TextStyle(
                      color: AppTheme.primaryYellow,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1口あたり ${settings.flashSpeedMs.round()} ms',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _speedButton(
              icon: Icons.add,
              enabled: settings.totalDurationSeconds < maxDuration,
              onTap: () {
                final newVal = (settings.totalDurationSeconds + step)
                    .clamp(minDuration, maxDuration);
                appState.updateSettings(
                  settings.copyWith(totalDurationSeconds: newVal),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _speedButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled
                ? const Color(0xFF3A3A3A)
                : const Color(0xFF2A2A2A),
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? AppTheme.primaryYellow : AppTheme.textSecondary,
        ),
      ),
    );
  }
}

/// 各設定セクションの見出しラベル
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
