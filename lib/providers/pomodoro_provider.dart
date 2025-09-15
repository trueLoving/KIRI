import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pomodoro_session.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/audio_service.dart';

class PomodoroProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  final AudioService _audioService = AudioService();

  // 计时器状态
  Timer? _timer;
  int _timeLeft = 25 * 60; // 25分钟，以秒为单位
  bool _isRunning = false;
  bool _isWorkTime = true; // true为工作时间，false为休息时间
  int _completedPomodoros = 0;
  int _sessionsInCurrentCycle = 0;

  // 设置
  PomodoroSettings _settings = PomodoroSettings();
  bool _isSettingsLoaded = false;

  // 任务管理
  List<Task> _tasks = [];
  Task? _currentTask;

  // 统计
  Map<String, int> _dailyStats = {};
  Map<String, int> _weeklyStats = {};
  Map<String, int> _monthlyStats = {};

  // Getters
  int get timeLeft => _timeLeft;
  bool get isRunning => _isRunning;
  bool get isWorkTime => _isWorkTime;
  int get completedPomodoros => _completedPomodoros;
  int get sessionsInCurrentCycle => _sessionsInCurrentCycle;
  PomodoroSettings get settings => _settings;
  List<Task> get tasks => _tasks;
  Task? get currentTask => _currentTask;
  Map<String, int> get dailyStats => _dailyStats;
  Map<String, int> get weeklyStats => _weeklyStats;
  Map<String, int> get monthlyStats => _monthlyStats;

  // 初始化
  Future<void> initialize() async {
    await _loadSettings();
    await _loadTasks();
    await _loadStats();
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
  }

  // 加载设置
  Future<void> _loadSettings() async {
    if (_isSettingsLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    _settings = PomodoroSettings(
      workDuration: prefs.getInt('workDuration') ?? 25,
      breakDuration: prefs.getInt('breakDuration') ?? 5,
      longBreakDuration: prefs.getInt('longBreakDuration') ?? 15,
      sessionsBeforeLongBreak: prefs.getInt('sessionsBeforeLongBreak') ?? 4,
      enableNotifications: prefs.getBool('enableNotifications') ?? true,
      enableSound: prefs.getBool('enableSound') ?? true,
      selectedSound: prefs.getString('selectedSound') ?? 'default',
      enableAutoStart: prefs.getBool('enableAutoStart') ?? false,
      theme: prefs.getString('theme') ?? 'light',
      enableHapticFeedback: prefs.getBool('enableHapticFeedback') ?? true,
    );

    _timeLeft = _isWorkTime ? _settings.workDuration * 60 : _settings.breakDuration * 60;
    _isSettingsLoaded = true;
    notifyListeners();
  }

  // 保存设置
  Future<void> saveSettings(PomodoroSettings newSettings) async {
    _settings = newSettings;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('workDuration', _settings.workDuration);
    await prefs.setInt('breakDuration', _settings.breakDuration);
    await prefs.setInt('longBreakDuration', _settings.longBreakDuration);
    await prefs.setInt('sessionsBeforeLongBreak', _settings.sessionsBeforeLongBreak);
    await prefs.setBool('enableNotifications', _settings.enableNotifications);
    await prefs.setBool('enableSound', _settings.enableSound);
    await prefs.setString('selectedSound', _settings.selectedSound);
    await prefs.setBool('enableAutoStart', _settings.enableAutoStart);
    await prefs.setString('theme', _settings.theme);
    await prefs.setBool('enableHapticFeedback', _settings.enableHapticFeedback);

    // 更新音效设置
    _audioService.setEnabled(_settings.enableSound);
    _audioService.setSelectedSound(_settings.selectedSound);

    // 重置计时器
    _timeLeft = _isWorkTime ? _settings.workDuration * 60 : _settings.breakDuration * 60;
    notifyListeners();
  }

  // 计时器控制
  void startTimer() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timeLeft > 0) {
          _timeLeft--;
          notifyListeners();
        } else {
          _completeSession();
        }
      });
      
      if (_settings.enableSound) {
        _audioService.playStartSound();
      }
      notifyListeners();
    }
  }

  void _pauseTimer() {
    _isRunning = false;
    _timer?.cancel();
    
    if (_settings.enableSound) {
      _audioService.playPauseSound();
    }
    notifyListeners();
  }

  void resetTimer() {
    _isRunning = false;
    _timer?.cancel();
    _timeLeft = _isWorkTime ? _settings.workDuration * 60 : _settings.breakDuration * 60;
    
    if (_settings.enableSound) {
      _audioService.playResetSound();
    }
    notifyListeners();
  }

  void _completeSession() {
    _timer?.cancel();
    _isRunning = false;

    // 保存会话记录
    _saveSession();

    if (_isWorkTime) {
      _completedPomodoros++;
      _sessionsInCurrentCycle++;
      _isWorkTime = false;
      
      // 判断是否需要长休息
      if (_sessionsInCurrentCycle >= _settings.sessionsBeforeLongBreak) {
        _timeLeft = _settings.longBreakDuration * 60;
        _sessionsInCurrentCycle = 0;
        
        if (_settings.enableNotifications) {
          _notificationService.showLongBreakNotification();
        }
        if (_settings.enableSound) {
          _audioService.playLongBreakSound();
        }
      } else {
        _timeLeft = _settings.breakDuration * 60;
        
        if (_settings.enableNotifications) {
          _notificationService.showWorkCompleteNotification();
        }
        if (_settings.enableSound) {
          _audioService.playWorkCompleteSound();
        }
      }
    } else {
      _isWorkTime = true;
      _timeLeft = _settings.workDuration * 60;
      
      if (_settings.enableNotifications) {
        _notificationService.showBreakCompleteNotification();
      }
      if (_settings.enableSound) {
        _audioService.playBreakCompleteSound();
      }
    }

    // 触觉反馈
    if (_settings.enableHapticFeedback) {
      HapticFeedback.heavyImpact();
    }

    notifyListeners();
  }

  // 保存会话记录
  Future<void> _saveSession() async {
    final session = PomodoroSession(
      id: 0, // 数据库会自动生成
      startTime: DateTime.now().subtract(Duration(seconds: _isWorkTime ? _settings.workDuration * 60 : _settings.breakDuration * 60)),
      endTime: DateTime.now(),
      duration: _isWorkTime ? _settings.workDuration * 60 : _settings.breakDuration * 60,
      isWorkTime: _isWorkTime,
      taskName: _currentTask?.name,
      completed: true,
    );

    await _databaseService.insertSession(session);
  }

  // 任务管理
  Future<void> _loadTasks() async {
    _tasks = await _databaseService.getTasks(completed: false);
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    final id = await _databaseService.insertTask(task);
    task = task.copyWith(id: id);
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _databaseService.updateTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
    notifyListeners();
  }

  Future<void> deleteTask(int taskId) async {
    await _databaseService.deleteTask(taskId);
    _tasks.removeWhere((task) => task.id == taskId);
    if (_currentTask?.id == taskId) {
      _currentTask = null;
    }
    notifyListeners();
  }

  void setCurrentTask(Task? task) {
    _currentTask = task;
    notifyListeners();
  }

  // 统计
  Future<void> _loadStats() async {
    final now = DateTime.now();
    _dailyStats = await _databaseService.getDailyStats(now);
    _weeklyStats = await _databaseService.getWeeklyStats(now.subtract(Duration(days: now.weekday - 1)));
    _monthlyStats = await _databaseService.getMonthlyStats(DateTime(now.year, now.month, 1));
    notifyListeners();
  }

  Future<void> refreshStats() async {
    await _loadStats();
  }

  // 获取所有会话数据
  Future<List<PomodoroSession>> getSessions() async {
    return await _databaseService.getSessions();
  }

  // 格式化时间
  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // 获取进度
  double getProgress() {
    int totalTime = _isWorkTime ? _settings.workDuration * 60 : _settings.breakDuration * 60;
    return 1.0 - (_timeLeft / totalTime);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
