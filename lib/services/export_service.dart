import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/pomodoro_provider.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Android 13+ 使用新的权限模型
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }
      
      // 请求存储权限
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        return true;
      }
      
      // 如果存储权限被拒绝，尝试请求管理外部存储权限
      final manageStatus = await Permission.manageExternalStorage.request();
      return manageStatus.isGranted;
    }
    return true; // iOS 不需要存储权限
  }

  Future<String?> exportToJSON(PomodoroProvider provider) async {
    try {
      // 请求权限
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('没有存储权限');
      }

      // 获取导出目录
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('无法获取存储目录');
      }

      // 创建导出数据
      final exportData = {
        'app_name': '番茄闹钟',
        'export_date': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'settings': provider.settings.toMap(),
        'tasks': provider.tasks.map((task) => task.toMap()).toList(),
        'statistics': {
          'daily_stats': provider.dailyStats,
          'weekly_stats': provider.weeklyStats,
          'monthly_stats': provider.monthlyStats,
          'completed_pomodoros': provider.completedPomodoros,
        },
      };

      // 获取所有会话数据
      final sessions = await provider.getSessions();
      exportData['sessions'] = sessions.map((session) => session.toMap()).toList();

      // 生成文件名
      final fileName = 'pomodoro_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');

      // 写入文件
      await file.writeAsString(jsonEncode(exportData));

      return file.path;
    } catch (e) {
      print('导出失败: $e');
      return null;
    }
  }

  Future<String?> exportToCSV(PomodoroProvider provider) async {
    try {
      // 请求权限
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('没有存储权限');
      }

      // 获取导出目录
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('无法获取存储目录');
      }

      // 获取所有会话数据
      final sessions = await provider.getSessions();

      // 生成CSV内容
      final csvContent = StringBuffer();
      csvContent.writeln('开始时间,结束时间,持续时间(秒),类型,任务名称,是否完成');
      
      for (final session in sessions) {
        csvContent.writeln(
          '${session.startTime.toIso8601String()},'
          '${session.endTime?.toIso8601String() ?? ""},'
          '${session.duration},'
          '${session.isWorkTime ? "工作" : "休息"},'
          '${session.taskName ?? ""},'
          '${session.completed ? "是" : "否"}'
        );
      }

      // 生成文件名
      final fileName = 'pomodoro_sessions_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');

      // 写入文件
      await file.writeAsString(csvContent.toString());

      return file.path;
    } catch (e) {
      print('导出失败: $e');
      return null;
    }
  }

  Future<String?> exportTasksToCSV(PomodoroProvider provider) async {
    try {
      // 请求权限
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('没有存储权限');
      }

      // 获取导出目录
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('无法获取存储目录');
      }

      // 生成CSV内容
      final csvContent = StringBuffer();
      csvContent.writeln('任务名称,描述,创建时间,完成时间,是否完成,预计番茄数,完成番茄数,分类,优先级');
      
      for (final task in provider.tasks) {
        csvContent.writeln(
          '${task.name},'
          '${task.description ?? ""},'
          '${task.createdAt.toIso8601String()},'
          '${task.completedAt?.toIso8601String() ?? ""},'
          '${task.completed ? "是" : "否"},'
          '${task.estimatedPomodoros},'
          '${task.completedPomodoros},'
          '${task.category ?? ""},'
          '${task.priority}'
        );
      }

      // 生成文件名
      final fileName = 'pomodoro_tasks_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');

      // 写入文件
      await file.writeAsString(csvContent.toString());

      return file.path;
    } catch (e) {
      print('导出失败: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> importFromJSON(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('文件不存在');
      }

      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      // 验证数据格式
      if (!data.containsKey('app_name') || data['app_name'] != '番茄闹钟') {
        throw Exception('无效的导出文件');
      }

      return data;
    } catch (e) {
      print('导入失败: $e');
      return null;
    }
  }

  Future<List<String>> getExportFiles() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) return [];

      final files = directory.listSync()
          .where((file) => file.path.endsWith('.json') || file.path.endsWith('.csv'))
          .map((file) => file.path)
          .toList();

      return files;
    } catch (e) {
      print('获取文件列表失败: $e');
      return [];
    }
  }

  Future<bool> deleteExportFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('删除文件失败: $e');
      return false;
    }
  }
}
