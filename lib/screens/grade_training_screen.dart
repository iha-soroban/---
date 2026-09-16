import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/grade_level.dart';
import '../models/training_settings.dart';
import '../models/training_result.dart';
import '../services/app_state.dart';
import '../services/problem_generator.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../utils/number_format.dart';

enum _Phase { countdown, flashing, answering, questionResult, finalResult }

/// 級位・段位トレーニング画面。
/// 1つのメニューにつき15問を連続で出題し、加算のみで出題する。
/// 15問終了後、10問以上正解なら合格・それ未満なら不合格を表示する。
class GradeTrainingScreen extends StatefulWidget {
  final GradeLevel level;

  const GradeTrainingScreen({super.key, required this.level});

  @override
  State<GradeTrainingScreen> createState() => _GradeTrainingScreenState();
}

class _GradeTrainingScreenState extends State<GradeTrainingScreen> {
  static const int totalQuestions = GradeLevel.questionsPerLevel;
  static const int passScore = GradeLevel.passScore;

  _Phase _phase = _Phase.countdown;

  int _questionIndex = 0; // 0-based
  int _correctCount = 0;

  int _countdownValue = 3;
  Timer? _timer;

  List<int> _numbers = [];
  int _correctAnswer = 0;
  int _currentFlashIndex = -1;

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
    final baseSettings = context.read<AppState>().settings;
    _settings = widget.level.buildSettings(baseSettings);
    _generateProblem();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  void _generateProblem() {
    final problem = ProblemGenerator.generate(_settings);
    _numbers = problem.numbers;
    _correctAnswer = problem.answer;
  }

  void _playBeep() {
    if (!_settings.soundEnabled) return;
    SoundService.instance.playBeep();
  }

  void _startCountdown() {
    _countdownValue = 3;
    _phase = _Phase.countdown;
    _timer = Timer.periodic(const Duration(milliseconds: 700), (t) {
      if (!mounted) return;
      setState(() {
        _countdownValue--;
      });
      if (_countdownValue <= 0) {
        t.cancel();
        _startFlashing();
      }
    });
  }

  int _flashStep = 0;

  void _startFlashing() {
    _flashStep = 0;
    setState(() {
      _phase = _Phase.flashing;
      _currentFlashIndex = 0;
    });
    _playBeep();

    final int flashOnMs = (_settings.flashSpeedMs * 0.7).round();
    final int flashOffMs = (_settings.flashSpeedMs * 0.3).round();
    _scheduleNextFlash(flashOnMs, flashOffMs);
  }

  void _scheduleNextFlash(int onMs, int offMs) {
    _timer = Timer(Duration(milliseconds: onMs), () {
      if (!mounted) return;
      setState(() {
        _currentFlashIndex = -1;
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
          _playBeep();
          _scheduleNextFlash(onMs, offMs);
        }
      });
    });
  }

  void _startAnswering() {
    setState(() {
      _phase = _Phase.answering;
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

    final isCorrect = parsed != null && parsed == _correctAnswer;

    setState(() {
      _userAnswer = parsed;
      _isCorrect = isCorrect;
      _answerTimeMs = elapsed;
      if (isCorrect) _correctCount++;
      _phase = _Phase.questionResult;
    });

    context.read<AppState>().addResult(
      TrainingResult(
        playedAt: DateTime.now(),
        digitModeLabel:
            '${widget.level.label}(${_settings.digitMode.shortLabel})',
        flashCount: _settings.flashCount,
        flashSpeedMs: _settings.flashSpeedMs,
        operationModeLabel: '足し算のみ',
        correctAnswer: _correctAnswer,
        userAnswer: _userAnswer,
        isCorrect: isCorrect,
        answerTimeMs: _answerTimeMs,
      ),
    );
  }

  void _nextQuestion() {
    if (_questionIndex + 1 >= totalQuestions) {
      setState(() {
        _phase = _Phase.finalResult;
      });
      return;
    }
    setState(() {
      _questionIndex++;
      _answerController.clear();
      _userAnswer = null;
      _currentFlashIndex = -1;
      _generateProblem();
    });
    _startCountdown();
  }

  void _retryAll() {
    setState(() {
      _questionIndex = 0;
      _correctCount = 0;
      _answerController.clear();
      _userAnswer = null;
      _currentFlashIndex = -1;
      _generateProblem();
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
              'メニューへ戻る',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const Spacer(),
          if (_phase != _Phase.finalResult)
            Text(
              '${widget.level.label}  ${_questionIndex + 1}/$totalQuestions問',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_phase) {
      case _Phase.countdown:
        return _buildCountdown();
      case _Phase.flashing:
        return _buildFlashing();
      case _Phase.answering:
        return _buildAnswering();
      case _Phase.questionResult:
        return _buildQuestionResult();
      case _Phase.finalResult:
        return _buildFinalResult(context);
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
                  fontSize: 56,
                  color: AppTheme.primaryYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '第${_questionIndex + 1}問  準備して...',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
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
            keyboardType: const TextInputType.numberWithOptions(signed: true),
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

  Widget _buildQuestionResult() {
    final isLast = _questionIndex + 1 >= totalQuestions;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isCorrect ? Icons.check_circle : Icons.cancel,
            color: _isCorrect ? AppTheme.accentGreen : AppTheme.accentRed,
            size: 56,
          ),
          const SizedBox(height: 10),
          Text(
            _isCorrect ? '正解!' : '不正解',
            style: TextStyle(
              color: _isCorrect ? AppTheme.accentGreen : AppTheme.accentRed,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            formatWithComma(_correctAnswer),
            style: const TextStyle(
              fontFamily: 'Sorofont',
              fontSize: 56,
              color: AppTheme.primaryYellow,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '正解',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Text(
            '現在の正解数: $_correctCount / ${_questionIndex + 1}問',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: _nextQuestion,
              child: Text(
                isLast ? '結果を見る' : '次の問題へ',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalResult(BuildContext context) {
    final passed = _correctCount >= passScore;
    final color = passed ? AppTheme.accentGreen : AppTheme.accentRed;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 5),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    passed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                    color: color,
                    size: 40,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    passed ? '合格' : '不合格',
                    style: TextStyle(
                      color: color,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            widget.level.label,
            style: const TextStyle(
              color: AppTheme.primaryYellow,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_correctCount / $totalQuestions 問正解',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '合格ライン: $passScore問以上正解',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _retryAll,
                  child: const Text('もう一度'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('メニューへ戻る'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
