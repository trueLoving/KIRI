import 'package:flutter/foundation.dart';

/// 非web平台的权限管理服务存根
class WebPermissionService {
  static final WebPermissionService _instance = WebPermissionService._internal();
  factory WebPermissionService() => _instance;
  WebPermissionService._internal();

  /// 检查是否为web平台
  bool get isWeb => false;

  /// 检查通知权限状态
  Future<PermissionStatus> checkNotificationPermission() async {
    return PermissionStatus.denied;
  }

  /// 请求通知权限
  Future<PermissionStatus> requestNotificationPermission() async {
    return PermissionStatus.denied;
  }

  /// 检查存储权限状态
  Future<PermissionStatus> checkStoragePermission() async {
    return PermissionStatus.granted;
  }

  /// 检查音频权限状态
  Future<PermissionStatus> checkAudioPermission() async {
    return PermissionStatus.granted;
  }

  /// 请求所有必要权限
  Future<Map<String, PermissionStatus>> requestAllPermissions() async {
    return {
      'notifications': PermissionStatus.denied,
      'storage': PermissionStatus.granted,
      'audio': PermissionStatus.granted,
    };
  }

  /// 检查所有权限状态
  Future<Map<String, PermissionStatus>> checkAllPermissions() async {
    return {
      'notifications': PermissionStatus.denied,
      'storage': PermissionStatus.granted,
      'audio': PermissionStatus.granted,
    };
  }

  /// 显示权限说明对话框
  Future<void> showPermissionExplanation(String permission) async {
    // 非web平台不显示
  }

  /// 打开浏览器权限设置页面
  Future<void> openPermissionSettings() async {
    // 非web平台不显示
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
