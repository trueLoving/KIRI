import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pomodoro_session.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pomodoro.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 创建番茄钟会话表
    await db.execute('''
      CREATE TABLE pomodoro_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        startTime INTEGER NOT NULL,
        endTime INTEGER,
        duration INTEGER NOT NULL,
        isWorkTime INTEGER NOT NULL,
        taskName TEXT,
        completed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 创建任务表
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        createdAt INTEGER NOT NULL,
        completedAt INTEGER,
        completed INTEGER NOT NULL DEFAULT 0,
        estimatedPomodoros INTEGER NOT NULL DEFAULT 1,
        completedPomodoros INTEGER NOT NULL DEFAULT 0,
        category TEXT,
        priority INTEGER NOT NULL DEFAULT 3
      )
    ''');

    // 创建设置表
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  // 番茄钟会话相关方法
  Future<int> insertSession(PomodoroSession session) async {
    final db = await database;
    return await db.insert('pomodoro_sessions', session.toMap());
  }

  Future<List<PomodoroSession>> getSessions({
    DateTime? startDate,
    DateTime? endDate,
    bool? isWorkTime,
  }) async {
    final db = await database;
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereClause += ' AND startTime >= ?';
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }

    if (endDate != null) {
      whereClause += ' AND startTime <= ?';
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }

    if (isWorkTime != null) {
      whereClause += ' AND isWorkTime = ?';
      whereArgs.add(isWorkTime ? 1 : 0);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'pomodoro_sessions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'startTime DESC',
    );

    return List.generate(maps.length, (i) {
      return PomodoroSession.fromMap(maps[i]);
    });
  }

  Future<int> updateSession(PomodoroSession session) async {
    final db = await database;
    return await db.update(
      'pomodoro_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> deleteSession(int id) async {
    final db = await database;
    return await db.delete(
      'pomodoro_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 任务相关方法
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasks({
    bool? completed,
    String? category,
    int? priority,
  }) async {
    final db = await database;
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (completed != null) {
      whereClause += ' AND completed = ?';
      whereArgs.add(completed ? 1 : 0);
    }

    if (category != null) {
      whereClause += ' AND category = ?';
      whereArgs.add(category);
    }

    if (priority != null) {
      whereClause += ' AND priority = ?';
      whereArgs.add(priority);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'priority DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 设置相关方法
  Future<void> saveSetting(String key, dynamic value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value.toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    }
    return null;
  }

  // 统计方法
  Future<Map<String, int>> getDailyStats(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final workSessions = await db.rawQuery('''
      SELECT COUNT(*) as count FROM pomodoro_sessions 
      WHERE startTime >= ? AND startTime < ? AND isWorkTime = 1 AND completed = 1
    ''', [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch]);

    final breakSessions = await db.rawQuery('''
      SELECT COUNT(*) as count FROM pomodoro_sessions 
      WHERE startTime >= ? AND startTime < ? AND isWorkTime = 0 AND completed = 1
    ''', [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch]);

    final totalTime = await db.rawQuery('''
      SELECT SUM(duration) as total FROM pomodoro_sessions 
      WHERE startTime >= ? AND startTime < ? AND isWorkTime = 1 AND completed = 1
    ''', [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch]);

    return {
      'workSessions': workSessions.first['count'] as int,
      'breakSessions': breakSessions.first['count'] as int,
      'totalTime': (totalTime.first['total'] as int?) ?? 0,
    };
  }

  Future<Map<String, int>> getWeeklyStats(DateTime weekStart) async {
    final db = await database;
    final weekEnd = weekStart.add(const Duration(days: 7));

    final workSessions = await db.rawQuery('''
      SELECT COUNT(*) as count FROM pomodoro_sessions 
      WHERE startTime >= ? AND startTime < ? AND isWorkTime = 1 AND completed = 1
    ''', [weekStart.millisecondsSinceEpoch, weekEnd.millisecondsSinceEpoch]);

    final totalTime = await db.rawQuery('''
      SELECT SUM(duration) as total FROM pomodoro_sessions 
      WHERE startTime >= ? AND startTime < ? AND isWorkTime = 1 AND completed = 1
    ''', [weekStart.millisecondsSinceEpoch, weekEnd.millisecondsSinceEpoch]);

    return {
      'workSessions': workSessions.first['count'] as int,
      'totalTime': (totalTime.first['total'] as int?) ?? 0,
    };
  }

  Future<Map<String, int>> getMonthlyStats(DateTime monthStart) async {
    final db = await database;
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 1);

    final workSessions = await db.rawQuery('''
      SELECT COUNT(*) as count FROM pomodoro_sessions 
      WHERE startTime >= ? AND startTime < ? AND isWorkTime = 1 AND completed = 1
    ''', [monthStart.millisecondsSinceEpoch, monthEnd.millisecondsSinceEpoch]);

    final totalTime = await db.rawQuery('''
      SELECT SUM(duration) as total FROM pomodoro_sessions 
      WHERE startTime >= ? AND startTime < ? AND isWorkTime = 1 AND completed = 1
    ''', [monthStart.millisecondsSinceEpoch, monthEnd.millisecondsSinceEpoch]);

    return {
      'workSessions': workSessions.first['count'] as int,
      'totalTime': (totalTime.first['total'] as int?) ?? 0,
    };
  }
}

