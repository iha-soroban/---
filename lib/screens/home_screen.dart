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
              _buildStatsSummary(context, appState),
              const SizedBox(height: 24),
              const Text(
                '出題形式',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildOperationModeSelector(context, appState, settings),
              const SizedBox(height: 24),
              _buildChipSelectorCard(
                label: '桁数',
                options: const [1, 2, 3],
                optionLabel: (v) => '$v桁',
                selectedValue: settings.digitCount,
                onSelect: (v) => appState.updateSettings(
                  settings.copyWith(digitCount: v),
                ),
              ),
              const SizedBox(height: 16),
              _buildChipSelectorCard(
                label: '表示個数',
                options: const [3, 4, 5, 6, 7, 8, 9, 10],
                optionLabel: (v) => '$v個',
                selectedValue: settings.flashCount,
                onSelect: (v) => appState.updateSettings(
                  settings.copyWith(flashCount: v),
                ),
              ),
              const SizedBox(height: 16),
              _buildSpeedStepperCard(context, appState, settings),
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
            _statItem('連続正解', '${appState.currentStreak}'),
            _verticalDivider(),
            _statItem('総回数', '${appState.totalCount}'),
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
    required String label,
    required List<int> options,
    required String Function(int) optionLabel,
    required int selectedValue,
    required ValueChanged<int> onSelect,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
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
                          color:
                              selected ? Colors.black : AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 表示スピードは +/- ボタンのステッパー式で調整(タップ操作のみで確実に動く)
  Widget _buildSpeedStepperCard(
    BuildContext context,
    AppState appState,
    TrainingSettings settings,
  ) {
    const double step = 100;
    const double minSpeed = 200;
    const double maxSpeed = 1500;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '表示スピード',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _speedButton(
                  icon: Icons.remove,
                  enabled: settings.flashSpeedMs > minSpeed,
                  onTap: () {
                    final newVal =
                        (settings.flashSpeedMs - step).clamp(minSpeed, maxSpeed);
                    appState.updateSettings(
                      settings.copyWith(flashSpeedMs: newVal),
                    );
                  },
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        settings.speedLabel,
                        style: const TextStyle(
                          color: AppTheme.primaryYellow,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${settings.flashSpeedMs.round()} ms / 個',
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
                  enabled: settings.flashSpeedMs < maxSpeed,
                  onTap: () {
                    final newVal =
                        (settings.flashSpeedMs + step).clamp(minSpeed, maxSpeed);
                    appState.updateSettings(
                      settings.copyWith(flashSpeedMs: newVal),
                    );
                  },
                ),
              ],
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
