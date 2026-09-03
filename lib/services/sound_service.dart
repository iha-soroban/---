import 'package:audioplayers/audioplayers.dart';

/// フラッシュ暗算の「ピッ」音を管理するシングルトンサービス。
///
/// 【重要】Webブラウザの自動再生ポリシー対策:
/// ブラウザは「ユーザーの明確な操作(タップ/クリック)」から
/// 直接呼び出された音声再生しか許可しないことが多い。
/// カウントダウンなどの Timer 経由で遅延実行される再生は
/// ブロックされ、エラーも出ずに無音のままになってしまう。
///
/// そのため「出題へ」ボタンが押された瞬間(=確実なユーザー操作)に
/// 一度だけ音を再生して AudioContext をアンロックしておき、
/// 以降のタイマー経由の再生でも音が出るようにする。
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  final AudioPlayer _player = AudioPlayer();
  bool _unlocked = false;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setSource(AssetSource('sounds/beep.mp3'));
    } catch (_) {
      // 初期化に失敗した場合は無音のまま継続する。
    }
  }

  /// ユーザーの明確な操作(ボタン押下など)の中から直接呼び出すこと。
  /// これにより AudioContext がアンロックされ、以降の
  /// タイマー経由の再生でも音が出るようになる。
  Future<void> unlockWithUserGesture() async {
    await _ensureInitialized();
    if (_unlocked) return;
    try {
      // 一瞬だけ再生してすぐ止める(アンロック目的)。
      await _player.resume();
      _unlocked = true;
    } catch (_) {
      // アンロックに失敗しても致命的ではないため継続する。
    }
  }

  /// フラッシュ表示のタイミングで「ピッ」を再生する。
  Future<void> playBeep({double volume = 0.8}) async {
    await _ensureInitialized();
    try {
      await _player.stop();
      await _player.setVolume(volume);
      await _player.seek(Duration.zero);
      await _player.resume();
    } catch (_) {
      // 再生に失敗しても致命的ではないため継続する。
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
