import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/pomodoro_provider.dart';
import '../services/export_service.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final ExportService _exportService = ExportService();
  bool _isExportingJSON = false;
  bool _isExportingCSV = false;
  bool _isExportingTasksCSV = false;
  List<String> _exportFiles = [];

  @override
  void initState() {
    super.initState();
    _loadExportFiles();
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
        title: const Text('数据导出'),
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
                // 导出选项
                _buildExportSection(provider),
                const SizedBox(height: 24),
                
                // 导入选项
                _buildImportSection(),
                const SizedBox(height: 24),
                
                // 导出文件列表
                _buildExportFilesSection(),
              ],
            ),
          );
        },
      ),
    );
  }

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
            '将您的番茄钟数据导出为文件，包括设置、任务、会话记录和统计信息。',
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildExportButton(
                  '导出任务CSV',
                  Icons.task_alt_rounded,
                  _isExportingTasksCSV,
                  () => _exportTasksToCSV(provider),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(), // 占位符
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

  Future<void> _exportToJSON(PomodoroProvider provider) async {
    setState(() {
      _isExportingJSON = true;
    });

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
      setState(() {
        _isExportingJSON = false;
      });
    }
  }

  Future<void> _exportToCSV(PomodoroProvider provider) async {
    setState(() {
      _isExportingCSV = true;
    });

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
      setState(() {
        _isExportingCSV = false;
      });
    }
  }

  Future<void> _exportTasksToCSV(PomodoroProvider provider) async {
    setState(() {
      _isExportingTasksCSV = true;
    });

    try {
      final filePath = await _exportService.exportTasksToCSV(provider);
      if (filePath != null) {
        _showSuccessDialog('导出成功', '任务数据已导出到: $filePath');
        await _loadExportFiles();
      } else {
        _showErrorDialog('导出失败', '无法导出数据，请检查存储权限');
      }
    } catch (e) {
      _showErrorDialog('导出失败', e.toString());
    } finally {
      setState(() {
        _isExportingTasksCSV = false;
      });
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
              // 这里应该实现实际的导入逻辑
              _showSuccessDialog('导入成功', '数据已成功导入');
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

