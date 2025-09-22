import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/pomodoro_provider.dart';
import '../models/pomodoro_session.dart';
import '../services/export_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final ExportService _exportService = ExportService();
  
  // 统计相关状态
  String _selectedPeriod = 'week';
  
  // 导出相关状态
  bool _isExportingJSON = false;
  bool _isExportingCSV = false;
  List<String> _exportFiles = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadExportFiles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadExportFiles() async {
    final files = await _exportService.getExportFiles();
    setState(() {
      _exportFiles = files;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.settings_rounded), text: '基本设置'),
            Tab(icon: Icon(Icons.analytics_rounded), text: '统计'),
            Tab(icon: Icon(Icons.file_download_rounded), text: '导出'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicSettings(),
          _buildStatisticsTab(),
          _buildExportTab(),
        ],
      ),
    );
  }

  // 基本设置标签页
  Widget _buildBasicSettings() {
    return Consumer<PomodoroProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSettingsCard(
                title: '时间设置',
                children: [
                  _buildTimeSettingItem(
                    icon: Icons.work_outline_rounded,
                    title: '工作时间',
                    value: provider.settings.workDuration,
                    onChanged: (value) => _updateSetting(provider, 'workDuration', value),
                  ),
                  _buildTimeSettingItem(
                    icon: Icons.coffee_outlined,
                    title: '休息时间',
                    value: provider.settings.breakDuration,
                    onChanged: (value) => _updateSetting(provider, 'breakDuration', value),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSettingsCard(
                title: '功能设置',
                children: [
                  _buildToggleSettingItem(
                    icon: Icons.notifications_outlined,
                    title: '通知',
                    value: provider.settings.enableNotifications,
                    onChanged: (value) => _updateSetting(provider, 'enableNotifications', value),
                  ),
                  _buildToggleSettingItem(
                    icon: Icons.volume_up_outlined,
                    title: '音效',
                    value: provider.settings.enableSound,
                    onChanged: (value) => _updateSetting(provider, 'enableSound', value),
                  ),
                  _buildToggleSettingItem(
                    icon: Icons.vibration_outlined,
                    title: '触觉反馈',
                    value: provider.settings.enableHapticFeedback,
                    onChanged: (value) => _updateSetting(provider, 'enableHapticFeedback', value),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 统计标签页
  Widget _buildStatisticsTab() {
    return Consumer<PomodoroProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 时间选择器
              _buildPeriodSelector(),
              const SizedBox(height: 16),
              
              // 总览卡片
              _buildOverviewCard(provider),
              const SizedBox(height: 16),
              
              // 图表
              _buildChartCard(provider),
              const SizedBox(height: 16),
              
              // 详细统计
              _buildDetailedStats(provider),
              const SizedBox(height: 16),
              
              // 成就系统
              _buildAchievements(provider),
            ],
          ),
        );
      },
    );
  }

  // 导出标签页
  Widget _buildExportTab() {
    return Consumer<PomodoroProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 导出选项
              _buildExportSection(provider),
              const SizedBox(height: 16),
              
              // 导入选项
              _buildImportSection(),
              const SizedBox(height: 16),
              
              // 导出文件列表
              _buildExportFilesSection(),
            ],
          ),
        );
      },
    );
  }

  // 设置卡片
  Widget _buildSettingsCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // 时间设置项
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
          Icon(icon, color: Theme.of(context).hintColor, size: 24),
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

  // 开关设置项
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
          Icon(icon, color: Theme.of(context).hintColor, size: 24),
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


  // 更新设置
  void _updateSetting(PomodoroProvider provider, String key, dynamic value) {
    final settings = provider.settings;
    final newSettings = PomodoroSettings(
      workDuration: key == 'workDuration' ? value : settings.workDuration,
      breakDuration: key == 'breakDuration' ? value : settings.breakDuration,
      enableNotifications: key == 'enableNotifications' ? value : settings.enableNotifications,
      enableSound: key == 'enableSound' ? value : settings.enableSound,
      selectedSound: settings.selectedSound,
      enableAutoStart: settings.enableAutoStart,
      enableHapticFeedback: key == 'enableHapticFeedback' ? value : settings.enableHapticFeedback,
    );
    provider.saveSettings(newSettings);
  }

  // 统计相关方法（从StatisticsScreen复制）
  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildPeriodButton('week', '本周')),
          const SizedBox(width: 8),
          Expanded(child: _buildPeriodButton('month', '本月')),
          const SizedBox(width: 8),
          Expanded(child: _buildPeriodButton('year', '今年')),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period, String label) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).primaryColor,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildOverviewCard(PomodoroProvider provider) {
    final stats = _getStatsForPeriod(provider);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '总览',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '完成番茄',
                  '${stats['workSessions'] ?? 0}',
                  Icons.local_fire_department_rounded,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '总时长',
                  '${(stats['totalTime'] ?? 0) ~/ 60}分钟',
                  Icons.timer_rounded,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '平均每日',
                  '${_getAveragePerDay(stats)}个',
                  Icons.trending_up_rounded,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '最长连续',
                  '${_getLongestStreak(provider)}天',
                  Icons.emoji_events_rounded,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).hintColor,
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard(PomodoroProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '每日趋势',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _buildLineChart(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(PomodoroProvider provider) {
    final data = _getChartData();
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data,
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats(PomodoroProvider provider) {
    final stats = _getStatsForPeriod(provider);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '详细统计',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailItem('工作时间', '${stats['workSessions'] ?? 0} 个番茄'),
          _buildDetailItem('休息时间', '${stats['breakSessions'] ?? 0} 次'),
          _buildDetailItem('总专注时间', '${(stats['totalTime'] ?? 0) ~/ 60} 分钟'),
          _buildDetailItem('平均番茄时长', '25 分钟'),
          _buildDetailItem('完成率', '${_getCompletionRate(provider)}%'),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).hintColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(PomodoroProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '成就',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildAchievementItem('初学者', '完成第一个番茄', provider.completedPomodoros >= 1, Icons.star_rounded),
          _buildAchievementItem('专注者', '完成10个番茄', provider.completedPomodoros >= 10, Icons.star_rounded),
          _buildAchievementItem('专家', '完成50个番茄', provider.completedPomodoros >= 50, Icons.star_rounded),
          _buildAchievementItem('大师', '完成100个番茄', provider.completedPomodoros >= 100, Icons.star_rounded),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(String title, String description, bool unlocked, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: unlocked ? Colors.amber : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: unlocked ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: unlocked ? Theme.of(context).hintColor : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (unlocked)
            Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 20,
            ),
        ],
      ),
    );
  }

  // 导出相关方法（从ExportScreen复制）
  Widget _buildExportSection(PomodoroProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '导出数据',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '将您的番茄钟数据导出为文件，包括设置、会话记录和统计信息。',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildExportButton(
                  '导出为JSON',
                  Icons.code_rounded,
                  _isExportingJSON,
                  () => _exportToJSON(provider),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildExportButton(
                  '导出会话CSV',
                  Icons.table_chart_rounded,
                  _isExportingCSV,
                  () => _exportToCSV(provider),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(String title, IconData icon, bool isExporting, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: isExporting ? null : onPressed,
      icon: isExporting 
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, size: 18),
      label: Text(
        isExporting ? '导出中...' : title,
        style: const TextStyle(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildImportSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '导入数据',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '从之前导出的JSON文件中恢复您的数据。',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _importFromFile,
              icon: const Icon(Icons.upload_rounded, size: 18),
              label: const Text('选择文件导入'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportFilesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '导出文件',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadExportFiles,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: '刷新',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_exportFiles.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.folder_open_rounded,
                    size: 48,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '暂无导出文件',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _exportFiles.length,
              itemBuilder: (context, index) {
                final filePath = _exportFiles[index];
                final fileName = filePath.split('/').last;
                final isJSON = fileName.endsWith('.json');
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).hintColor.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isJSON ? Icons.code_rounded : Icons.table_chart_rounded,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              filePath,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).hintColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _deleteFile(filePath),
                        icon: const Icon(Icons.delete_rounded),
                        color: Colors.red,
                        tooltip: '删除',
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // 统计辅助方法
  Map<String, int> _getStatsForPeriod(PomodoroProvider provider) {
    switch (_selectedPeriod) {
      case 'week':
        return provider.weeklyStats;
      case 'month':
        return provider.monthlyStats;
      default:
        return provider.dailyStats;
    }
  }

  List<FlSpot> _getChartData() {
    return List.generate(7, (index) {
      return FlSpot(index.toDouble(), (index * 2 + 1).toDouble());
    });
  }

  int _getAveragePerDay(Map<String, int> stats) {
    final days = _selectedPeriod == 'week' ? 7 : 30;
    return (stats['workSessions'] ?? 0) ~/ days;
  }

  int _getLongestStreak(PomodoroProvider provider) {
    return 5; // 模拟数据
  }

  int _getCompletionRate(PomodoroProvider provider) {
    return 85; // 模拟数据
  }

  // 导出辅助方法
  Future<void> _exportToJSON(PomodoroProvider provider) async {
    setState(() => _isExportingJSON = true);
    try {
      final filePath = await _exportService.exportToJSON(provider);
      if (filePath != null) {
        _showSuccessDialog('导出成功', '数据已导出到: $filePath');
        await _loadExportFiles();
      } else {
        _showErrorDialog('导出失败', '无法导出数据，请检查存储权限');
      }
    } catch (e) {
      _showErrorDialog('导出失败', e.toString());
    } finally {
      setState(() => _isExportingJSON = false);
    }
  }

  Future<void> _exportToCSV(PomodoroProvider provider) async {
    setState(() => _isExportingCSV = true);
    try {
      final filePath = await _exportService.exportToCSV(provider);
      if (filePath != null) {
        _showSuccessDialog('导出成功', '会话数据已导出到: $filePath');
        await _loadExportFiles();
      } else {
        _showErrorDialog('导出失败', '无法导出数据，请检查存储权限');
      }
    } catch (e) {
      _showErrorDialog('导出失败', e.toString());
    } finally {
      setState(() => _isExportingCSV = false);
    }
  }


  Future<void> _importFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.first.path;
        if (filePath != null) {
          final data = await _exportService.importFromJSON(filePath);
          if (data != null) {
            _showImportConfirmDialog(data);
          } else {
            _showErrorDialog('导入失败', '文件格式不正确或已损坏');
          }
        }
      }
    } catch (e) {
      _showErrorDialog('导入失败', e.toString());
    }
  }

  Future<void> _deleteFile(String filePath) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除文件'),
        content: const Text('确定要删除这个文件吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _exportService.deleteExportFile(filePath);
      if (success) {
        _showSuccessDialog('删除成功', '文件已删除');
        await _loadExportFiles();
      } else {
        _showErrorDialog('删除失败', '无法删除文件');
      }
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showImportConfirmDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认导入'),
        content: const Text('导入数据将覆盖当前的所有数据，确定要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSuccessDialog('导入成功', '数据已成功导入');
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
