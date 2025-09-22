import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/pomodoro_provider.dart';
import 'screens/tasks_screen.dart';
import 'screens/settings_screen.dart';

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
    const SettingsScreen(),
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
            icon: Icon(Icons.settings_rounded),
            label: '设置',
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

