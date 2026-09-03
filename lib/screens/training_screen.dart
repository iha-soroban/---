import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/problem_generator.dart';
import '../services/sound_service.dart';
import '../models/training_settings.dart';
import '../models/training_result.dart';
import '../theme/app_theme.dart';
import '../utils/number_format.dart';

enum _TrainingPhase { countdown, flashing, answering, result }

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  _TrainingPhase _phase = _TrainingPhase.countdown;

  int _countdownValue = 3;
  Timer? _timer;

  List<int> _numbers = [];
  int _correctAnswer = 0;
  int _currentFlashIndex = -1; // -1 = 何も表示していない(数字間の空白)

  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();

  int? _userAnswer;
  bool _isCorrect = false;
  DateTime? _answerStartTime;
  int _answerTimeMs = 0;

  late TrainingSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = context.read<AppState>().settings;
    final problem = ProblemGenerator.generate(_settings);
    _numbers = problem.numbers;
    _correctAnswer = problem.answer;
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  /// フラッシュ表示ごとに短い「ピッ」音を再生する。
  /// 設定でOFFにされている場合は何もしない。
  void _playBeep() {
    if (!_settings.soundEnabled) return;
    SoundService.instance.playBeep();
  }

  void _startCountdown() {
    _countdownValue = 3;
    _timer = Timer.periodic(const Duration(milliseconds: 700), (t) {
      setState(() {
        _countdownValue--;
      });
      if (_countdownValue <= 0) {
        t.cancel();
        _startFlashing();
      }
    });
  }

  int _flashStep = 0; // 次に表示すべき数字のインデックス

  void _startFlashing() {
    _flashStep = 0;
    setState(() {
      _phase = _TrainingPhase.flashing;
      _currentFlashIndex = 0;
    });
    _playBeep(); // 最初の数字が表示された瞬間に「ピッ」

    final int flashOnMs = (_settings.flashSpeedMs * 0.7).round();
    final int flashOffMs = (_settings.flashSpeedMs * 0.3).round();

    _scheduleNextFlash(flashOnMs, flashOffMs);
  }

  void _scheduleNextFlash(int onMs, int offMs) {
    _timer = Timer(Duration(milliseconds: onMs), () {
      if (!mounted) return;
      setState(() {
        _currentFlashIndex = -1; // blank between numbers
      });
      _timer = Timer(Duration(milliseconds: offMs), () {
        if (!mounted) return;
        _flashStep++;
        if (_flashStep >= _numbers.length) {
          _startAnswering();
        } else {
          setState(() {
            _currentFlashIndex = _flashStep;
          });
          _playBeep(); // 次の数字が表示された瞬間に「ピッ」
          _scheduleNextFlash(onMs, offMs);
        }
      });
    });
  }

  void _startAnswering() {
    setState(() {
      _phase = _TrainingPhase.answering;
      _currentFlashIndex = -1;
    });
    _answerStartTime = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _answerFocusNode.requestFocus();
    });
  }

  void _submitAnswer() {
    final text = stripComma(_answerController.text.trim());
    final parsed = int.tryParse(text);
    final elapsed = _answerStartTime != null
        ? DateTime.now().difference(_answerStartTime!).inMilliseconds
        : 0;

    setState(() {
      _userAnswer = parsed;
      _isCorrect = parsed != null && parsed == _correctAnswer;
      _answerTimeMs = elapsed;
      _phase = _TrainingPhase.result;
    });

    final opLabel = _settings.operationMode == OperationMode.additionOnly
        ? '足し算のみ'
        : '足し算・引き算';

    context.read<AppState>().addResult(
      TrainingResult(
        playedAt: DateTime.now(),
        digitModeLabel: _settings.digitMode.shortLabel,
        flashCount: _settings.flashCount,
        flashSpeedMs: _settings.flashSpeedMs,
        operationModeLabel: opLabel,
        correctAnswer: _correctAnswer,
        userAnswer: _userAnswer,
        isCorrect: _isCorrect,
        answerTimeMs: _answerTimeMs,
      ),
    );
  }

  void _retrySameProblem() {
    setState(() {
      _phase = _TrainingPhase.countdown;
      _answerController.clear();
      _userAnswer = null;
      _currentFlashIndex = -1;
    });
    _startCountdown();
  }

  void _newProblem() {
    setState(() {
      final problem = ProblemGenerator.generate(_settings);
      _numbers = problem.numbers;
      _correctAnswer = problem.answer;
      _phase = _TrainingPhase.countdown;
      _answerController.clear();
      _userAnswer = null;
      _currentFlashIndex = -1;
    });
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            icon: const Icon(Icons.arrow_back_ios_new, size: 16),
            label: const Text(
              '設定へ戻る',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const Spacer(),
          Text(
            '${_settings.digitMode.shortLabel} × ${_settings.flashCount}口 (${_settings.durationLabel})',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_phase) {
      case _TrainingPhase.countdown:
        return _buildCountdown();
      case _TrainingPhase.flashing:
        return _buildFlashing();
      case _TrainingPhase.answering:
        return _buildAnswering();
      case _TrainingPhase.result:
        return _buildResult(context);
    }
  }

  Widget _buildCountdown() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryYellow, width: 4),
            ),
            child: Center(
              child: Text(
                _countdownValue > 0 ? '$_countdownValue' : 'GO',
                style: const TextStyle(
                  fontFamily: 'Sorofont',
                  fontSize: 56,
                  color: AppTheme.primaryYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '準備して...',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashing() {
    final showNumber =
        _currentFlashIndex >= 0 && _currentFlashIndex < _numbers.length;
    final number = showNumber ? _numbers[_currentFlashIndex] : null;

    final alignment = _settings.alignment == DisplayAlignment.center
        ? Alignment.center
        : Alignment.centerRight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      alignment: alignment,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 80),
        child: number == null
            ? const SizedBox.shrink(key: ValueKey('blank'))
            : Text(
                formatWithComma(number),
                key: ValueKey(_currentFlashIndex),
                style: TextStyle(
                  fontFamily: _settings.font.fontFamily,
                  fontSize: 96,
                  color: AppTheme.primaryYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildAnswering() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '合計はいくつ?',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _answerController,
            focusNode: _answerFocusNode,
            keyboardType: const TextInputType.numberWithOptions(
              signed: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^-?[\d,]*')),
              CommaNumberInputFormatter(),
            ],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Sorofont',
              fontSize: 48,
              color: AppTheme.primaryYellow,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              hintText: '0',
              hintStyle: const TextStyle(color: AppTheme.textSecondary),
            ),
            onSubmitted: (_) => _submitAnswer(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: _submitAnswer,
              child: const Text('回答する', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isCorrect ? Icons.check_circle : Icons.cancel,
            color: _isCorrect ? AppTheme.accentGreen : AppTheme.accentRed,
            size: 64,
          ),
          const SizedBox(height: 12),
          Text(
            _isCorrect ? '正解!' : '不正解',
            style: TextStyle(
              color: _isCorrect ? AppTheme.accentGreen : AppTheme.accentRed,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            formatWithComma(_correctAnswer),
            style: const TextStyle(
              fontFamily: 'Sorofont',
              fontSize: 72,
              color: AppTheme.primaryYellow,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '正解',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          if (!_isCorrect) ...[
            const SizedBox(height: 16),
            Text(
              'あなたの回答: ${_userAnswer != null ? formatWithComma(_userAnswer!) : "未入力"}',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '回答時間: ${(_answerTimeMs / 1000).toStringAsFixed(1)}秒',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _retrySameProblem,
                  child: const Text('同じ問題'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _newProblem,
                  child: const Text('次の問題'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '設定画面へ戻る',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
