import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/pomodoro_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'week'; // week, month, year

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('统计'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: Consumer<PomodoroProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 时间选择器
                _buildPeriodSelector(),
                const SizedBox(height: 24),
                
                // 总览卡片
                _buildOverviewCard(provider),
                const SizedBox(height: 24),
                
                // 图表
                _buildChartCard(provider),
                const SizedBox(height: 24),
                
                // 详细统计
                _buildDetailedStats(provider),
                const SizedBox(height: 24),
                
                // 成就系统
                _buildAchievements(provider),
              ],
            ),
          );
        },
      ),
    );
  }

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
          Expanded(
            child: _buildPeriodButton('week', '本周'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPeriodButton('month', '本月'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPeriodButton('year', '今年'),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period, String label) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
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
    // 这里应该从数据库获取实际数据
    // 现在使用模拟数据
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
          _buildAchievementItem(
            '初学者',
            '完成第一个番茄',
            provider.completedPomodoros >= 1,
            Icons.star_rounded,
          ),
          _buildAchievementItem(
            '专注者',
            '完成10个番茄',
            provider.completedPomodoros >= 10,
            Icons.star_rounded,
          ),
          _buildAchievementItem(
            '专家',
            '完成50个番茄',
            provider.completedPomodoros >= 50,
            Icons.star_rounded,
          ),
          _buildAchievementItem(
            '大师',
            '完成100个番茄',
            provider.completedPomodoros >= 100,
            Icons.star_rounded,
          ),
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
    // 模拟数据，实际应该从数据库获取
    return List.generate(7, (index) {
      return FlSpot(index.toDouble(), (index * 2 + 1).toDouble());
    });
  }

  int _getAveragePerDay(Map<String, int> stats) {
    final days = _selectedPeriod == 'week' ? 7 : 30;
    return (stats['workSessions'] ?? 0) ~/ days;
  }

  int _getLongestStreak(PomodoroProvider provider) {
    // 这里应该从数据库计算最长连续天数
    return 5; // 模拟数据
  }

  int _getCompletionRate(PomodoroProvider provider) {
    // 这里应该计算完成率
    return 85; // 模拟数据
  }
}

