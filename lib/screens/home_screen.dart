import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/sound_service.dart';
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

/// 「公式フラッシュ暗算」風の直感的な設定画面
/// - 桁数: リストから選択(①〜⑫のパターン)
/// - 口数・出題時間: 直接数値入力
/// - 出題位置・フォント: ボタン選択
class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  late TextEditingController _flashCountController;
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<AppState>().settings;
    _flashCountController =
        TextEditingController(text: '${settings.flashCount}');
    _durationController =
        TextEditingController(text: settings.totalDurationSeconds.toString());
  }

  @override
  void dispose() {
    _flashCountController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _applyFlashCount(AppState appState, TrainingSettings settings) {
    final parsed = int.tryParse(_flashCountController.text.trim());
    if (parsed == null) return;
    final clamped = parsed.clamp(1, 20);
    appState.updateSettings(settings.copyWith(flashCount: clamped));
    if (clamped != parsed) {
      _flashCountController.text = '$clamped';
    }
  }

  void _applyDuration(AppState appState, TrainingSettings settings) {
    final parsed = double.tryParse(_durationController.text.trim());
    if (parsed == null) return;
    final clamped = parsed.clamp(0.1, 60.0);
    appState.updateSettings(settings.copyWith(totalDurationSeconds: clamped));
    if (clamped != parsed) {
      _durationController.text = '$clamped';
    }
  }

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
                '伊波そろばん教室',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildStatsSummary(context, appState),
              const SizedBox(height: 16),
              _buildCurrentSettingsSummary(settings),
              const SizedBox(height: 20),

              // ---- 桁数(リスト選択) & 右側パラメータ ----
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 480;
                  final digitList = _DigitModeList(
                    settings: settings,
                    onSelect: (mode) => appState.updateSettings(
                      settings.copyWith(digitMode: mode),
                    ),
                  );
                  final rightColumn = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOperationModeSelector(context, appState, settings),
                      const SizedBox(height: 16),
                      _buildNumberInputCard(
                        label: '口数(何口出題するか)',
                        unit: '口',
                        helperText: '1〜20口の範囲で指定できます',
                        controller: _flashCountController,
                        onSubmit: () => _applyFlashCount(appState, settings),
                        isInteger: true,
                      ),
                      const SizedBox(height: 16),
                      _buildNumberInputCard(
                        label: '出題時間(全部で何秒で出すか)',
                        unit: '秒',
                        helperText: '0.01秒刻みで指定できます',
                        controller: _durationController,
                        onSubmit: () => _applyDuration(appState, settings),
                        isInteger: false,
                      ),
                      const SizedBox(height: 16),
                      _buildSectionLabel('出題位置'),
                      const SizedBox(height: 8),
                      _buildTwoWayToggle(
                        leftLabel: DisplayAlignment.center.label,
                        rightLabel: DisplayAlignment.right.label,
                        selectedLeft:
                            settings.alignment == DisplayAlignment.center,
                        onSelectLeft: () => appState.updateSettings(
                          settings.copyWith(
                              alignment: DisplayAlignment.center),
                        ),
                        onSelectRight: () => appState.updateSettings(
                          settings.copyWith(alignment: DisplayAlignment.right),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionLabel('フォント'),
                      const SizedBox(height: 8),
                      _buildTwoWayToggle(
                        leftLabel: DisplayFont.sorofont.label,
                        rightLabel: DisplayFont.mincho.label,
                        selectedLeft: settings.font == DisplayFont.sorofont,
                        onSelectLeft: () => appState.updateSettings(
                          settings.copyWith(font: DisplayFont.sorofont),
                        ),
                        onSelectRight: () => appState.updateSettings(
                          settings.copyWith(font: DisplayFont.mincho),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionLabel('サウンド(数字が出る時の「ピッ」音)'),
                      const SizedBox(height: 8),
                      _buildTwoWayToggle(
                        leftLabel: 'ON',
                        rightLabel: 'OFF',
                        selectedLeft: settings.soundEnabled,
                        onSelectLeft: () => appState.updateSettings(
                          settings.copyWith(soundEnabled: true),
                        ),
                        onSelectRight: () => appState.updateSettings(
                          settings.copyWith(soundEnabled: false),
                        ),
                      ),
                    ],
                  );

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('桁数(何ケタの数を出題するか)'),
                        const SizedBox(height: 8),
                        digitList,
                        const SizedBox(height: 20),
                        rightColumn,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel('桁数(何ケタの数を出題するか)'),
                            const SizedBox(height: 8),
                            digitList,
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(flex: 5, child: rightColumn),
                    ],
                  );
                },
              ),

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: () {
                    // 未確定の数値入力を反映してから開始する
                    _applyFlashCount(appState, appState.settings);
                    _applyDuration(appState, appState.settings);
                    // 【重要】ブラウザの自動再生ポリシー対策:
                    // ボタン押下という明確なユーザー操作の中で音声再生を
                    // 一度実行し、AudioContext をアンロックしておく。
                    // これを行わないと、後続のタイマー(カウントダウン等)
                    // 経由の再生がブラウザにブロックされ、無音になる。
                    SoundService.instance.unlockWithUserGesture();
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
                      Text('出題へ', style: TextStyle(fontSize: 20)),
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

  /// 現在の設定を「何ケタ・何口・何秒」の形で常に一目でわかるように表示するカード
  Widget _buildCurrentSettingsSummary(TrainingSettings settings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryYellow.withValues(alpha: 0.5)),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: [
          _summaryChip(settings.digitMode.shortLabel),
          _summaryDot(),
          _summaryChip('${settings.flashCount}口'),
          _summaryDot(),
          _summaryChip(settings.durationLabel),
          _summaryDot(),
          _summaryChip(
            settings.operationMode == OperationMode.additionOnly
                ? '足し算のみ'
                : '足し算・引き算',
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.primaryYellow,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _summaryDot() {
    return const Text(
      '・',
      style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
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

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildOperationModeSelector(
    BuildContext context,
    AppState appState,
    TrainingSettings settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('出題形式'),
        const SizedBox(height: 8),
        _buildTwoWayToggle(
          leftLabel: '足し算のみ',
          rightLabel: '足し算・引き算',
          selectedLeft:
              settings.operationMode == OperationMode.additionOnly,
          onSelectLeft: () => appState.updateSettings(
            settings.copyWith(operationMode: OperationMode.additionOnly),
          ),
          onSelectRight: () => appState.updateSettings(
            settings.copyWith(operationMode: OperationMode.mixed),
          ),
        ),
      ],
    );
  }

  /// 2択のトグルボタン(出題位置・フォント・出題形式などで使う共通UI)
  Widget _buildTwoWayToggle({
    required String leftLabel,
    required String rightLabel,
    required bool selectedLeft,
    required VoidCallback onSelectLeft,
    required VoidCallback onSelectRight,
  }) {
    return Row(
      children: [
        Expanded(
          child: _toggleChip(
            label: leftLabel,
            selected: selectedLeft,
            onTap: onSelectLeft,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _toggleChip(
            label: rightLabel,
            selected: !selectedLeft,
            onTap: onSelectRight,
          ),
        ),
      ],
    );
  }

  Widget _toggleChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
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
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// 口数・出題時間などの直接数値入力カード
  /// 入力欄の中に「口」「秒」などの単位を直接表示することで、
  /// 数字だけを見ても何を意味する値かが一目でわかるようにする。
  Widget _buildNumberInputCard({
    required String label,
    required String unit,
    required String helperText,
    required TextEditingController controller,
    required VoidCallback onSubmit,
    required bool isInteger,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel(label),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(
                decimal: !isInteger,
              ),
              inputFormatters: isInteger
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*'),
                      ),
                    ],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.primaryYellow,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceLight,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                // 単位(口・秒など)を入力欄の右側に直接表示
                suffixText: unit,
                suffixStyle: const TextStyle(
                  color: AppTheme.primaryYellow,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => onSubmit(),
              onTapOutside: (_) => onSubmit(),
              onEditingComplete: onSubmit,
            ),
            const SizedBox(height: 6),
            Text(
              helperText,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 桁数パターン(①〜⑫)を選択するリストウィジェット
class _DigitModeList extends StatelessWidget {
  final TrainingSettings settings;
  final ValueChanged<DigitMode> onSelect;

  const _DigitModeList({required this.settings, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: DigitMode.values.map((mode) {
          final selected = mode == settings.digitMode;
          return InkWell(
            onTap: () => onSelect(mode),
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.primaryYellow
                    : Colors.transparent,
                border: const Border(
                  bottom: BorderSide(color: Color(0xFF2A2A2A), width: 1),
                ),
              ),
              child: Text(
                mode.label,
                style: TextStyle(
                  color: selected ? Colors.black : AppTheme.textPrimary,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
