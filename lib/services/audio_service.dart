import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isEnabled = true;
  String _selectedSound = 'default';

  // 预定义的音效
  static const Map<String, String> _sounds = {
    'default': 'sounds/default.mp3',
    'bell': 'sounds/bell.mp3',
    'chime': 'sounds/chime.mp3',
    'ding': 'sounds/ding.mp3',
    'gong': 'sounds/gong.mp3',
    'notification': 'sounds/notification.mp3',
  };

  bool get isEnabled => _isEnabled;
  String get selectedSound => _selectedSound;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  void setSelectedSound(String sound) {
    _selectedSound = sound;
  }

  Future<void> playWorkCompleteSound() async {
    if (!_isEnabled) return;
    await _playSound('work_complete');
  }

  Future<void> playBreakCompleteSound() async {
    if (!_isEnabled) return;
    await _playSound('break_complete');
  }

  Future<void> playLongBreakSound() async {
    if (!_isEnabled) return;
    await _playSound('long_break');
  }

  Future<void> playStartSound() async {
    if (!_isEnabled) return;
    await _playSound('start');
  }

  Future<void> playPauseSound() async {
    if (!_isEnabled) return;
    await _playSound('pause');
  }

  Future<void> playResetSound() async {
    if (!_isEnabled) return;
    await _playSound('reset');
  }

  Future<void> _playSound(String soundType) async {
    try {
      // 根据音效类型和用户选择播放不同的声音
      String soundPath = _getSoundPath(soundType);
      
      // 停止当前播放
      await _audioPlayer.stop();
      
      // 播放新音效
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      print('播放音效失败: $e');
    }
  }

  String _getSoundPath(String soundType) {
    // 根据音效类型和用户选择返回对应的音效路径
    switch (soundType) {
      case 'work_complete':
        return _sounds[_selectedSound] ?? _sounds['default']!;
      case 'break_complete':
        return _sounds[_selectedSound] ?? _sounds['default']!;
      case 'long_break':
        return _sounds['gong'] ?? _sounds['default']!;
      case 'start':
        return _sounds['bell'] ?? _sounds['default']!;
      case 'pause':
        return _sounds['chime'] ?? _sounds['default']!;
      case 'reset':
        return _sounds['ding'] ?? _sounds['default']!;
      default:
        return _sounds['default']!;
    }
  }

  List<String> getAvailableSounds() {
    return _sounds.keys.toList();
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

