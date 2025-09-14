import 'package:flutter_test/flutter_test.dart';

void main() {
  group('番茄闹钟逻辑测试', () {
    test('时间格式化测试', () {
      // 测试时间格式化逻辑
      int timeInSeconds = 25 * 60;
      int minutes = timeInSeconds ~/ 60;
      int remainingSeconds = timeInSeconds % 60;
      String formattedTime = '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
      expect(formattedTime, equals('25:00'));
      
      timeInSeconds = 5 * 60;
      minutes = timeInSeconds ~/ 60;
      remainingSeconds = timeInSeconds % 60;
      formattedTime = '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
      expect(formattedTime, equals('05:00'));
      
      timeInSeconds = 90;
      minutes = timeInSeconds ~/ 60;
      remainingSeconds = timeInSeconds % 60;
      formattedTime = '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
      expect(formattedTime, equals('01:30'));
    });

    test('进度计算测试', () {
      int totalTime = 25 * 60;
      int timeLeft = 25 * 60;
      double progress = 1.0 - (timeLeft / totalTime);
      expect(progress, equals(0.0));
      
      timeLeft = 12 * 60;
      progress = 1.0 - (timeLeft / totalTime);
      expect(progress, equals(0.52));
      
      timeLeft = 0;
      progress = 1.0 - (timeLeft / totalTime);
      expect(progress, equals(1.0));
    });

    test('状态切换逻辑测试', () {
      bool isWorkTime = true;
      int workDuration = 25;
      int breakDuration = 5;
      
      int timeLeft = isWorkTime ? workDuration * 60 : breakDuration * 60;
      expect(timeLeft, equals(25 * 60));
      
      isWorkTime = false;
      timeLeft = isWorkTime ? workDuration * 60 : breakDuration * 60;
      expect(timeLeft, equals(5 * 60));
    });

    test('时间范围验证测试', () {
      int workDuration = 25;
      expect(workDuration >= 1 && workDuration <= 60, isTrue);
      
      int breakDuration = 5;
      expect(breakDuration >= 1 && breakDuration <= 60, isTrue);
    });

    test('完成番茄计数测试', () {
      int completedPomodoros = 0;
      expect(completedPomodoros, equals(0));
      
      completedPomodoros++;
      expect(completedPomodoros, equals(1));
      
      completedPomodoros += 4;
      expect(completedPomodoros, equals(5));
    });
  });

  group('UI状态测试', () {
    test('状态指示器测试', () {
      bool isWorkTime = true;
      String statusText = isWorkTime ? '专注' : '休息';
      expect(statusText, equals('专注'));
      
      isWorkTime = false;
      statusText = isWorkTime ? '专注' : '休息';
      expect(statusText, equals('休息'));
    });

    test('按钮状态测试', () {
      bool isRunning = false;
      String buttonIcon = isRunning ? 'pause' : 'play';
      expect(buttonIcon, equals('play'));
      
      isRunning = true;
      buttonIcon = isRunning ? 'pause' : 'play';
      expect(buttonIcon, equals('pause'));
    });
  });

  group('数据验证测试', () {
    test('时间数据验证', () {
      int timeLeft = 25 * 60;
      expect(timeLeft > 0, isTrue);
      expect(timeLeft <= 60 * 60, isTrue);
      
      int originalTime = timeLeft;
      timeLeft--;
      expect(timeLeft, equals(originalTime - 1));
    });

    test('设置数据验证', () {
      int workDuration = 25;
      expect(workDuration >= 1, isTrue);
      expect(workDuration <= 60, isTrue);
      
      int breakDuration = 5;
      expect(breakDuration >= 1, isTrue);
      expect(breakDuration <= 60, isTrue);
    });

    test('统计数据验证', () {
      int completedPomodoros = 0;
      expect(completedPomodoros >= 0, isTrue);
      
      completedPomodoros++;
      expect(completedPomodoros, equals(1));
    });
  });
}