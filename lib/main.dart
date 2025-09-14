import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() {
  runApp(const PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '番茄闹钟',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C3E50),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      ),
      home: const PomodoroTimer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _timeLeft = 25 * 60; // 25分钟，以秒为单位
  bool _isRunning = false;
  bool _isWorkTime = true; // true为工作时间，false为休息时间
  int _completedPomodoros = 0;
  
  // 可设置的时间（以分钟为单位）
  int _workDuration = 25; // 工作时间（分钟）
  int _breakDuration = 5;  // 休息时间（分钟）
  
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
    _timer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      setState(() {
        _isRunning = true;
      });
      _pulseController.repeat(reverse: true);
      _progressController.repeat();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            _completeSession();
          }
        });
      });
    }
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
    _pulseController.stop();
    _progressController.stop();
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _timeLeft = _isWorkTime ? _workDuration * 60 : _breakDuration * 60;
    });
    _timer?.cancel();
    _pulseController.reset();
    _progressController.reset();
  }

  void _completeSession() {
    _timer?.cancel();
    _pulseController.stop();
    _progressController.stop();
    
    // 播放完成音效
    HapticFeedback.heavyImpact();
    
    setState(() {
      _isRunning = false;
      if (_isWorkTime) {
        _completedPomodoros++;
        _isWorkTime = false;
        _timeLeft = _breakDuration * 60; // 休息时间
        _showCompletionDialog('工作完成', '开始休息');
      } else {
        _isWorkTime = true;
        _timeLeft = _workDuration * 60; // 工作时间
        _showCompletionDialog('休息结束', '开始工作');
      }
    });
  }

  void _showCompletionDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF7F8C8D),
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF95A5A6),
                    ),
                    child: const Text('稍后'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _startTimer();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3E50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('开始'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double _getProgress() {
    int totalTime = _isWorkTime ? _workDuration * 60 : _breakDuration * 60;
    return 1.0 - (_timeLeft / totalTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
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
                  color: _isWorkTime ? const Color(0xFFE8F5E8) : const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isWorkTime ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _isWorkTime ? '专注' : '休息',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _isWorkTime ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
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
                            scale: _isRunning ? _pulseAnimation.value : 1.0,
                            child: Container(
                              width: 280,
                              height: 280,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
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
                                          progress: _getProgress(),
                                          isWorkTime: _isWorkTime,
                                          isRunning: _isRunning,
                                        ),
                                      );
                                    },
                                  ),
                                  // 时间显示
                                  Center(
                                    child: Text(
                                      _formatTime(_timeLeft),
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.w300,
                                        color: Color(0xFF2C3E50),
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
                            onPressed: _resetTimer,
                            color: const Color(0xFF95A5A6),
                          ),
                          
                          // 开始/暂停按钮
                          _buildControlButton(
                            icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            onPressed: _startTimer,
                            color: const Color(0xFF2C3E50),
                            isLarge: true,
                          ),
                          
                          // 设置按钮
                          _buildControlButton(
                            icon: Icons.settings_rounded,
                            onPressed: () {
                              _showSettingsDialog();
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
                      '$_completedPomodoros',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '个番茄',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF7F8C8D),
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

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                '设置',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E50),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 工作时间设置
                  _buildTimeSettingItem(
                icon: Icons.work_outline_rounded,
                title: '工作时间',
                value: _workDuration,
                onChanged: (value) {
                  setState(() {
                    _workDuration = value;
                  });
                },
              ),
              const Divider(height: 1),
              // 休息时间设置
              _buildTimeSettingItem(
                icon: Icons.coffee_outlined,
                title: '休息时间',
                value: _breakDuration,
                onChanged: (value) {
                  setState(() {
                    _breakDuration = value;
                  });
                },
              ),
              const Divider(height: 1),
              _buildSettingItem(
                icon: Icons.notifications_outlined,
                title: '通知',
                subtitle: '开启',
                onTap: () {},
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF95A5A6),
              ),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                // 应用设置并重置计时器
                this.setState(() {
                  _timeLeft = _isWorkTime ? _workDuration * 60 : _breakDuration * 60;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C3E50),
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
        color: const Color(0xFF7F8C8D),
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF2C3E50),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF7F8C8D),
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
            color: const Color(0xFF7F8C8D),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2C3E50),
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
                    color: value > 1 ? const Color(0xFF2C3E50) : const Color(0xFFE8E8E8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.remove,
                    color: value > 1 ? Colors.white : const Color(0xFFBDBDBD),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 时间显示
              Container(
                width: 60,
                child: Text(
                  '$value分钟',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C3E50),
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
                    color: value < 60 ? const Color(0xFF2C3E50) : const Color(0xFFE8E8E8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    color: value < 60 ? Colors.white : const Color(0xFFBDBDBD),
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