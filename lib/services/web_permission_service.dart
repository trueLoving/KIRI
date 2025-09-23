// 条件导入，根据平台选择不同的实现
export 'web_permission_service_stub.dart'
    if (dart.library.html) 'web_permission_service_web.dart';
