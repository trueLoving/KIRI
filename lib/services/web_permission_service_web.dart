import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Web平台权限管理服务实现
class WebPermissionService {
  static final WebPermissionService _instance = WebPermissionService._internal();
  factory WebPermissionService() => _instance;
  WebPermissionService._internal();

  /// 检查是否为web平台
  bool get isWeb => kIsWeb;

  /// 检查通知权限状态
  Future<PermissionStatus> checkNotificationPermission() async {
    if (!isWeb) return PermissionStatus.denied;
    
    try {
      final permission = await html.Notification.requestPermission();
      return _convertNotificationPermission(permission);
    } catch (e) {
      debugPrint('检查通知权限失败: $e');
      return PermissionStatus.denied;
    }
  }

  /// 请求通知权限
  Future<PermissionStatus> requestNotificationPermission() async {
    if (!isWeb) return PermissionStatus.denied;
    
    try {
      final permission = await html.Notification.requestPermission();
      return _convertNotificationPermission(permission);
    } catch (e) {
      debugPrint('请求通知权限失败: $e');
      return PermissionStatus.denied;
    }
  }

  /// 检查存储权限状态
  Future<PermissionStatus> checkStoragePermission() async {
    if (!isWeb) return PermissionStatus.granted; // Web存储通常不需要特殊权限
    
    try {
      // 检查IndexedDB是否可用
      final hasIndexedDB = html.window.indexedDB != null;
      return hasIndexedDB ? PermissionStatus.granted : PermissionStatus.denied;
    } catch (e) {
      debugPrint('检查存储权限失败: $e');
      return PermissionStatus.denied;
    }
  }

  /// 检查音频权限状态
  Future<PermissionStatus> checkAudioPermission() async {
    if (!isWeb) return PermissionStatus.granted; // Web音频通常不需要特殊权限
    
    try {
      // Web音频通常不需要特殊权限，直接返回已授权
      // 实际的音频播放权限会在用户首次交互时自动获得
      return PermissionStatus.granted;
    } catch (e) {
      debugPrint('检查音频权限失败: $e');
      return PermissionStatus.denied;
    }
  }

  /// 请求所有必要权限
  Future<Map<String, PermissionStatus>> requestAllPermissions() async {
    final results = <String, PermissionStatus>{};
    
    // 请求通知权限
    results['notifications'] = await requestNotificationPermission();
    
    // 检查存储权限
    results['storage'] = await checkStoragePermission();
    
    // 检查音频权限
    results['audio'] = await checkAudioPermission();
    
    return results;
  }

  /// 检查所有权限状态
  Future<Map<String, PermissionStatus>> checkAllPermissions() async {
    final results = <String, PermissionStatus>{};
    
    // 检查通知权限
    results['notifications'] = await checkNotificationPermission();
    
    // 检查存储权限
    results['storage'] = await checkStoragePermission();
    
    // 检查音频权限
    results['audio'] = await checkAudioPermission();
    
    return results;
  }

  /// 显示权限说明对话框
  Future<void> showPermissionExplanation(String permission) async {
    if (!isWeb) return;
    
    String message;
    switch (permission) {
      case 'notifications':
        message = '刻需要通知权限来提醒您工作时间和休息时间的切换，帮助您更好地管理专注时间。';
        break;
      case 'storage':
        message = '刻需要存储权限来保存您的设置和统计数据，以及导出您的番茄钟记录。';
        break;
      case 'audio':
        message = '刻需要音频权限来播放音效提醒，您可以在设置中关闭音效。';
        break;
      default:
        message = '此功能需要相应权限才能正常工作。';
    }
    
    // 在web平台上，我们可以使用浏览器的alert或者自定义对话框
    html.window.alert(message);
  }

  /// 打开浏览器权限设置页面
  Future<void> openPermissionSettings() async {
    if (!isWeb) return;
    
    // 在web平台上，我们无法直接打开系统设置
    // 但可以提供说明
    html.window.alert(
      '请在浏览器地址栏左侧点击锁图标或信息图标，然后选择"权限"来管理通知权限。\n\n'
      '或者点击浏览器菜单 > 设置 > 隐私和安全 > 网站设置来管理权限。'
    );
  }

  /// 转换通知权限状态
  PermissionStatus _convertNotificationPermission(String permission) {
    switch (permission.toLowerCase()) {
      case 'granted':
        return PermissionStatus.granted;
      case 'denied':
        return PermissionStatus.denied;
      case 'default':
        return PermissionStatus.denied;
      default:
        return PermissionStatus.denied;
    }
  }

  /// 获取权限状态描述
  String getPermissionStatusDescription(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return '已授权';
      case PermissionStatus.denied:
        return '已拒绝';
      case PermissionStatus.permanentlyDenied:
        return '永久拒绝';
      case PermissionStatus.restricted:
        return '受限制';
      case PermissionStatus.limited:
        return '部分授权';
      case PermissionStatus.provisional:
        return '临时授权';
    }
  }

  /// 检查权限是否已授权
  bool isPermissionGranted(PermissionStatus status) {
    return status == PermissionStatus.granted;
  }

  /// 检查权限是否被拒绝
  bool isPermissionDenied(PermissionStatus status) {
    return status == PermissionStatus.denied || 
           status == PermissionStatus.permanentlyDenied;
  }
}

/// 权限状态枚举
enum PermissionStatus {
  granted,           // 已授权
  denied,            // 已拒绝
  permanentlyDenied, // 永久拒绝
  restricted,        // 受限制
  limited,           // 部分授权
  provisional,       // 临时授权
}
