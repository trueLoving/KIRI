class PomodoroSession {
  final int id;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration; // 持续时间（秒）
  final bool isWorkTime;
  final String? taskName;
  final bool completed;

  PomodoroSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.isWorkTime,
    this.taskName,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'duration': duration,
      'isWorkTime': isWorkTime ? 1 : 0,
      'taskName': taskName,
      'completed': completed ? 1 : 0,
    };
  }

  factory PomodoroSession.fromMap(Map<String, dynamic> map) {
    return PomodoroSession(
      id: map['id'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: map['endTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['endTime'])
          : null,
      duration: map['duration'],
      isWorkTime: map['isWorkTime'] == 1,
      taskName: map['taskName'],
      completed: map['completed'] == 1,
    );
  }

  PomodoroSession copyWith({
    int? id,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    bool? isWorkTime,
    String? taskName,
    bool? completed,
  }) {
    return PomodoroSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      isWorkTime: isWorkTime ?? this.isWorkTime,
      taskName: taskName ?? this.taskName,
      completed: completed ?? this.completed,
    );
  }
}

class PomodoroSettings {
  final int workDuration; // 工作时间（分钟）
  final int breakDuration; // 休息时间（分钟）
  final bool enableNotifications; // 启用通知
  final bool enableSound; // 启用音效
  final String selectedSound; // 选择的音效
  final bool enableAutoStart; // 自动开始下一个阶段
  final bool enableHapticFeedback; // 触觉反馈

  PomodoroSettings({
    this.workDuration = 25,
    this.breakDuration = 5,
    this.enableNotifications = true,
    this.enableSound = true,
    this.selectedSound = 'default',
    this.enableAutoStart = false,
    this.enableHapticFeedback = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'workDuration': workDuration,
      'breakDuration': breakDuration,
      'enableNotifications': enableNotifications,
      'enableSound': enableSound,
      'selectedSound': selectedSound,
      'enableAutoStart': enableAutoStart,
      'enableHapticFeedback': enableHapticFeedback,
    };
  }

  factory PomodoroSettings.fromMap(Map<String, dynamic> map) {
    return PomodoroSettings(
      workDuration: map['workDuration'] ?? 25,
      breakDuration: map['breakDuration'] ?? 5,
      enableNotifications: map['enableNotifications'] ?? true,
      enableSound: map['enableSound'] ?? true,
      selectedSound: map['selectedSound'] ?? 'default',
      enableAutoStart: map['enableAutoStart'] ?? false,
      enableHapticFeedback: map['enableHapticFeedback'] ?? true,
    );
  }

  PomodoroSettings copyWith({
    int? workDuration,
    int? breakDuration,
    bool? enableNotifications,
    bool? enableSound,
    String? selectedSound,
    bool? enableAutoStart,
    bool? enableHapticFeedback,
  }) {
    return PomodoroSettings(
      workDuration: workDuration ?? this.workDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableSound: enableSound ?? this.enableSound,
      selectedSound: selectedSound ?? this.selectedSound,
      enableAutoStart: enableAutoStart ?? this.enableAutoStart,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
    );
  }
}

class Task {
  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool completed;

  Task({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.completedAt,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'completed': completed ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      completedAt: map['completedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
          : null,
      completed: map['completed'] == 1,
    );
  }

  Task copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? completed,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      completed: completed ?? this.completed,
    );
  }
}
