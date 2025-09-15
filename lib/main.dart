import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/pomodoro_provider.dart';
import 'models/pomodoro_session.dart';
import 'screens/statistics_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/export_screen.dart';

void main() {
  runApp(const PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PomodoroProvider()..initialize(),
      child: Consumer<PomodoroProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: '番茄闹钟',
            theme: _buildTheme(provider.settings.theme),
            home: const PomodoroTimer(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(String themeName) {
    switch (themeName) {
      case 'dark':
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2C3E50),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xFF121212),
        );
      case 'blue':
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        );
      case 'green':
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4CAF50),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xFFF1F8E9),
        );
      default: // light
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2C3E50),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        );
    }
  }
}

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const TimerScreen(),
    const TasksScreen(),
    const StatisticsScreen(),
    const ExportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_rounded),
            label: '计时器',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_rounded),
            label: '任务',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: '统计',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_download_rounded),
            label: '导出',
          ),
        ],
      ),
    );
  }
}

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    // 脉冲动画控制器
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // 进度动画控制器
    _progressController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startTimer(BuildContext context) {
    final provider = Provider.of<PomodoroProvider>(context, listen: false);
    provider.startTimer();
    
    if (provider.isRunning) {
      _pulseController.repeat(reverse: true);
      _progressController.repeat();
    } else {
      _pulseController.stop();
      _progressController.stop();
    }
  }

  void _resetTimer(BuildContext context) {
    final provider = Provider.of<PomodoroProvider>(context, listen: false);
    provider.resetTimer();
    _pulseController.reset();
    _progressController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  
                  // 状态指示器
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: provider.isWorkTime ? const Color(0xFFE8F5E8) : const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: provider.isWorkTime ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      provider.isWorkTime ? '专注' : '休息',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: provider.isWorkTime ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 80),
                  
                  // 主计时器
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 圆形进度指示器
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: provider.isRunning ? _pulseAnimation.value : 1.0,
                                child: Container(
                                  width: 280,
                                  height: 280,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).cardColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      // 进度环
                                      AnimatedBuilder(
                                        animation: _progressAnimation,
                                        builder: (context, child) {
                                          return CustomPaint(
                                            size: const Size(280, 280),
                                            painter: ProgressPainter(
                                              progress: provider.getProgress(),
                                              isWorkTime: provider.isWorkTime,
                                              isRunning: provider.isRunning,
                                            ),
                                          );
                                        },
                                      ),
                                      // 时间显示
                                      Center(
                                        child: Text(
                                          provider.formatTime(provider.timeLeft),
                                          style: TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.w300,
                                            color: Theme.of(context).primaryColor,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 80),
                          
                          // 控制按钮
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // 重置按钮
                              _buildControlButton(
                                icon: Icons.refresh_rounded,
                                onPressed: () => _resetTimer(context),
                                color: const Color(0xFF95A5A6),
                              ),
                              
                              // 开始/暂停按钮
                              _buildControlButton(
                                icon: provider.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                onPressed: () => _startTimer(context),
                                color: Theme.of(context).primaryColor,
                                isLarge: true,
                              ),
                              
                              // 设置按钮
                              _buildControlButton(
                                icon: Icons.settings_rounded,
                                onPressed: () {
                                  _showSettingsDialog(context);
                                },
                                color: const Color(0xFF95A5A6),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // 底部统计
                  Container(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.orange.shade400,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${provider.completedPomodoros}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '个番茄',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final provider = Provider.of<PomodoroProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _SettingsDialog(provider: provider);
      },
    );
  }


  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isLarge ? 80 : 56,
        height: isLarge ? 80 : 56,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: isLarge ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isLarge ? 32 : 24,
        ),
      ),
    );
  }
}

// 自定义进度绘制器
class ProgressPainter extends CustomPainter {
  final double progress;
  final bool isWorkTime;
  final bool isRunning;

  ProgressPainter({
    required this.progress,
    required this.isWorkTime,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    
    // 背景圆环
    final backgroundPaint = Paint()
      ..color = const Color(0xFFE8E8E8)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // 进度圆环
    final progressPaint = Paint()
      ..color = isWorkTime ? const Color(0xFF4CAF50) : const Color(0xFF2196F3)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final startAngle = -90 * (3.14159 / 180); // 从顶部开始
    final sweepAngle = 2 * 3.14159 * progress;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// 设置对话框组件
class _SettingsDialog extends StatefulWidget {
  final PomodoroProvider provider;

  const _SettingsDialog({required this.provider});

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  late int tempWorkDuration;
  late int tempBreakDuration;
  late int tempLongBreakDuration;
  late int tempSessionsBeforeLongBreak;
  late bool tempEnableNotifications;
  late bool tempEnableSound;
  late String tempTheme;
  late bool tempEnableHapticFeedback;

  @override
  void initState() {
    super.initState();
    // 初始化临时设置状态
    tempWorkDuration = widget.provider.settings.workDuration;
    tempBreakDuration = widget.provider.settings.breakDuration;
    tempLongBreakDuration = widget.provider.settings.longBreakDuration;
    tempSessionsBeforeLongBreak = widget.provider.settings.sessionsBeforeLongBreak;
    tempEnableNotifications = widget.provider.settings.enableNotifications;
    tempEnableSound = widget.provider.settings.enableSound;
    tempTheme = widget.provider.settings.theme;
    tempEnableHapticFeedback = widget.provider.settings.enableHapticFeedback;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        '设置',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).primaryColor,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 工作时间设置
            _buildTimeSettingItem(
              icon: Icons.work_outline_rounded,
              title: '工作时间',
              value: tempWorkDuration,
              onChanged: (value) {
                setState(() {
                  tempWorkDuration = value;
                });
              },
            ),
            const Divider(height: 1),
            // 休息时间设置
            _buildTimeSettingItem(
              icon: Icons.coffee_outlined,
              title: '休息时间',
              value: tempBreakDuration,
              onChanged: (value) {
                setState(() {
                  tempBreakDuration = value;
                });
              },
            ),
            const Divider(height: 1),
            // 长休息时间设置
            _buildTimeSettingItem(
              icon: Icons.hotel_outlined,
              title: '长休息时间',
              value: tempLongBreakDuration,
              onChanged: (value) {
                setState(() {
                  tempLongBreakDuration = value;
                });
              },
            ),
            const Divider(height: 1),
            // 长休息前会话数设置
            _buildTimeSettingItem(
              icon: Icons.repeat_outlined,
              title: '长休息前会话数',
              value: tempSessionsBeforeLongBreak,
              onChanged: (value) {
                setState(() {
                  tempSessionsBeforeLongBreak = value;
                });
              },
            ),
            const Divider(height: 1),
            // 通知设置
            _buildToggleSettingItem(
              icon: Icons.notifications_outlined,
              title: '通知',
              value: tempEnableNotifications,
              onChanged: (value) {
                setState(() {
                  tempEnableNotifications = value;
                });
              },
            ),
            const Divider(height: 1),
            // 音效设置
            _buildToggleSettingItem(
              icon: Icons.volume_up_outlined,
              title: '音效',
              value: tempEnableSound,
              onChanged: (value) {
                setState(() {
                  tempEnableSound = value;
                });
              },
            ),
            const Divider(height: 1),
            // 触觉反馈设置
            _buildToggleSettingItem(
              icon: Icons.vibration_outlined,
              title: '触觉反馈',
              value: tempEnableHapticFeedback,
              onChanged: (value) {
                setState(() {
                  tempEnableHapticFeedback = value;
                });
              },
            ),
            const Divider(height: 1),
            // 主题设置
            _buildThemeSettingItem(
              icon: Icons.palette_outlined,
              title: '主题',
              currentTheme: tempTheme,
              onChanged: (value) {
                setState(() {
                  tempTheme = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).hintColor,
          ),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () async {
            // 创建新的设置对象
            final newSettings = PomodoroSettings(
              workDuration: tempWorkDuration,
              breakDuration: tempBreakDuration,
              longBreakDuration: tempLongBreakDuration,
              sessionsBeforeLongBreak: tempSessionsBeforeLongBreak,
              enableNotifications: tempEnableNotifications,
              enableSound: tempEnableSound,
              selectedSound: widget.provider.settings.selectedSound,
              enableAutoStart: widget.provider.settings.enableAutoStart,
              theme: tempTheme,
              enableHapticFeedback: tempEnableHapticFeedback,
            );
            
            // 保存设置
            await widget.provider.saveSettings(newSettings);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('应用'),
        ),
      ],
    );
  }

  Widget _buildTimeSettingItem({
    required IconData icon,
    required String title,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).hintColor,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Row(
            children: [
              // 减少按钮
              GestureDetector(
                onTap: value > 1 ? () => onChanged(value - 1) : null,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: value > 1 ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.remove,
                    color: value > 1 ? Colors.white : Theme.of(context).hintColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 时间显示
              SizedBox(
                width: 60,
                child: Text(
                  '$value分钟',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 16),
              // 增加按钮
              GestureDetector(
                onTap: value < 60 ? () => onChanged(value + 1) : null,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: value < 60 ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    color: value < 60 ? Colors.white : Theme.of(context).hintColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSettingItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).hintColor,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSettingItem({
    required IconData icon,
    required String title,
    required String currentTheme,
    required ValueChanged<String> onChanged,
  }) {
    final themes = [
      {'key': 'light', 'name': '浅色'},
      {'key': 'dark', 'name': '深色'},
      {'key': 'blue', 'name': '蓝色'},
      {'key': 'green', 'name': '绿色'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).hintColor,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          DropdownButton<String>(
            value: currentTheme,
            onChanged: (String? newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
            items: themes.map<DropdownMenuItem<String>>((theme) {
              return DropdownMenuItem<String>(
                value: theme['key'],
                child: Text(
                  theme['name']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              );
            }).toList(),
            underline: Container(),
            icon: Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}
