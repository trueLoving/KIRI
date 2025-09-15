import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pomodoro_provider.dart';
import '../models/pomodoro_session.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = '工作';
  int _selectedPriority = 3;
  int _estimatedPomodoros = 1;

  final List<String> _categories = ['工作', '学习', '个人', '健康', '其他'];
  final List<String> _priorities = ['低', '中低', '中', '中高', '高'];

  @override
  void dispose() {
    _taskController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('任务管理'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showAddTaskDialog,
          ),
        ],
      ),
      body: Consumer<PomodoroProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // 当前任务
              if (provider.currentTask != null)
                _buildCurrentTaskCard(provider.currentTask!),
              
              // 任务列表
              Expanded(
                child: provider.tasks.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.tasks.length,
                        itemBuilder: (context, index) {
                          final task = provider.tasks[index];
                          return _buildTaskCard(task, provider);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.play_circle_filled_rounded,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '当前任务',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            task.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).primaryColor,
            ),
          ),
          if (task.description != null) ...[
            const SizedBox(height: 8),
            Text(
              task.description!,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTaskInfoChip(
                Icons.timer_rounded,
                '${task.completedPomodoros}/${task.estimatedPomodoros}',
              ),
              const SizedBox(width: 8),
              _buildTaskInfoChip(
                Icons.category_rounded,
                task.category ?? '未分类',
              ),
              const SizedBox(width: 8),
              _buildTaskInfoChip(
                Icons.priority_high_rounded,
                _priorities[task.priority - 1],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).primaryColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task, PomodoroProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                    decoration: task.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleTaskAction(value, task, provider),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'select',
                    child: Text('选择为当前任务'),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('编辑'),
                  ),
                  const PopupMenuItem(
                    value: 'complete',
                    child: Text('标记完成'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('删除'),
                  ),
                ],
                child: Icon(
                  Icons.more_vert_rounded,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
          if (task.description != null) ...[
            const SizedBox(height: 8),
            Text(
              task.description!,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTaskInfoChip(
                Icons.timer_rounded,
                '${task.completedPomodoros}/${task.estimatedPomodoros}',
              ),
              const SizedBox(width: 8),
              _buildTaskInfoChip(
                Icons.category_rounded,
                task.category ?? '未分类',
              ),
              const SizedBox(width: 8),
              _buildTaskInfoChip(
                Icons.priority_high_rounded,
                _priorities[task.priority - 1],
              ),
              const Spacer(),
              if (task.completed)
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 12),
          // 进度条
          LinearProgressIndicator(
            value: task.estimatedPomodoros > 0 
                ? task.completedPomodoros / task.estimatedPomodoros 
                : 0,
            backgroundColor: Theme.of(context).hintColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt_rounded,
            size: 64,
            color: Theme.of(context).hintColor,
          ),
          const SizedBox(height: 16),
          Text(
            '还没有任务',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右上角的 + 号添加任务',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddTaskDialog,
            icon: const Icon(Icons.add_rounded),
            label: const Text('添加任务'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('添加任务'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      labelText: '任务名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '描述（可选）',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: '分类',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _selectedPriority,
                          decoration: const InputDecoration(
                            labelText: '优先级',
                            border: OutlineInputBorder(),
                          ),
                          items: List.generate(5, (index) {
                            return DropdownMenuItem(
                              value: index + 1,
                              child: Text(_priorities[index]),
                            );
                          }),
                          onChanged: (value) {
                            setState(() {
                              _selectedPriority = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: _estimatedPomodoros.toString(),
                          decoration: const InputDecoration(
                            labelText: '预计番茄数',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _estimatedPomodoros = int.tryParse(value) ?? 1;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: _addTask,
                child: const Text('添加'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addTask() {
    if (_taskController.text.trim().isEmpty) return;

    final task = Task(
      id: 0,
      name: _taskController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      createdAt: DateTime.now(),
      category: _selectedCategory,
      priority: _selectedPriority,
      estimatedPomodoros: _estimatedPomodoros,
    );

    Provider.of<PomodoroProvider>(context, listen: false).addTask(task);

    _taskController.clear();
    _descriptionController.clear();
    _selectedCategory = '工作';
    _selectedPriority = 3;
    _estimatedPomodoros = 1;

    Navigator.of(context).pop();
  }

  void _handleTaskAction(String action, Task task, PomodoroProvider provider) {
    switch (action) {
      case 'select':
        provider.setCurrentTask(task);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已选择任务: ${task.name}')),
        );
        break;
      case 'edit':
        _editTask(task, provider);
        break;
      case 'complete':
        provider.updateTask(task.copyWith(
          completed: true,
          completedAt: DateTime.now(),
        ));
        break;
      case 'delete':
        _showDeleteConfirmDialog(task, provider);
        break;
    }
  }

  void _editTask(Task task, PomodoroProvider provider) {
    _taskController.text = task.name;
    _descriptionController.text = task.description ?? '';
    _selectedCategory = task.category ?? '工作';
    _selectedPriority = task.priority;
    _estimatedPomodoros = task.estimatedPomodoros;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('编辑任务'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      labelText: '任务名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '描述（可选）',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: '分类',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _selectedPriority,
                          decoration: const InputDecoration(
                            labelText: '优先级',
                            border: OutlineInputBorder(),
                          ),
                          items: List.generate(5, (index) {
                            return DropdownMenuItem(
                              value: index + 1,
                              child: Text(_priorities[index]),
                            );
                          }),
                          onChanged: (value) {
                            setState(() {
                              _selectedPriority = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: _estimatedPomodoros.toString(),
                          decoration: const InputDecoration(
                            labelText: '预计番茄数',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _estimatedPomodoros = int.tryParse(value) ?? 1;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  provider.updateTask(task.copyWith(
                    name: _taskController.text.trim(),
                    description: _descriptionController.text.trim().isEmpty 
                        ? null 
                        : _descriptionController.text.trim(),
                    category: _selectedCategory,
                    priority: _selectedPriority,
                    estimatedPomodoros: _estimatedPomodoros,
                  ));
                  Navigator.of(context).pop();
                },
                child: const Text('保存'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(Task task, PomodoroProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除任务'),
        content: Text('确定要删除任务"${task.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteTask(task.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

