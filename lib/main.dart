import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/pomodoro_provider.dart';
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
        return StatefulBuilder(
          builder: (context, setState) {
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
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 工作时间设置
                  _buildTimeSettingItem(
                    icon: Icons.work_outline_rounded,
                    title: '工作时间',
                    value: provider.settings.workDuration,
                    onChanged: (value) {
                      setState(() {
                        // 这里只是UI更新，实际保存会在点击应用时进行
                      });
                    },
                  ),
                  const Divider(height: 1),
                  // 休息时间设置
                  _buildTimeSettingItem(
                    icon: Icons.coffee_outlined,
                    title: '休息时间',
                    value: provider.settings.breakDuration,
                    onChanged: (value) {
                      setState(() {
                        // 这里只是UI更新，实际保存会在点击应用时进行
                      });
                    },
                  ),
                  const Divider(height: 1),
                  _buildSettingItem(
                    icon: Icons.notifications_outlined,
                    title: '通知',
                    subtitle: provider.settings.enableNotifications ? '开启' : '关闭',
                    onTap: () {
                      setState(() {
                        // 切换通知设置
                      });
                    },
                  ),
                ],
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
                  onPressed: () {
                    // 应用设置并重置计时器
                    provider.resetTimer();
                    Navigator.of(context).pop();
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
          },
        );
      },
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: Theme.of(context).hintColor,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).primaryColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).hintColor,
        ),
      ),
      onTap: onTap,
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
