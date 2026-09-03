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
              _buildSliderCard(
                context: context,
                label: '桁数',
                valueLabel: '${settings.digitCount}桁',
                value: settings.digitCount.toDouble(),
                min: 1,
                max: 3,
                divisions: 2,
                onChanged: (v) {
                  appState.updateSettings(
                    settings.copyWith(digitCount: v.round()),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildSliderCard(
                context: context,
                label: '表示個数',
                valueLabel: '${settings.flashCount}個',
                value: settings.flashCount.toDouble(),
                min: 3,
                max: 10,
                divisions: 7,
                onChanged: (v) {
                  appState.updateSettings(
                    settings.copyWith(flashCount: v.round()),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildSliderCard(
                context: context,
                label: '表示スピード',
                valueLabel: settings.speedLabel,
                value: settings.flashSpeedMs,
                min: 200,
                max: 1500,
                divisions: 13,
                onChanged: (v) {
                  appState.updateSettings(
                    settings.copyWith(flashSpeedMs: v),
                  );
                },
                reverseTrackHint: true,
              ),
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

  Widget _buildSliderCard({
    required BuildContext context,
    required String label,
    required String valueLabel,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    bool reverseTrackHint = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  valueLabel,
                  style: const TextStyle(
                    color: AppTheme.primaryYellow,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
