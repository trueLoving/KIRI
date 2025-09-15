# 刻 | KIRI

> 禅意与锋利的平衡 - 极简番茄闹钟

## 项目初衷

个人需要一个简洁高效的番茄闹钟应用，在技术选型时考虑了以下方案：

- **Flutter** ✅ - 一套代码多平台，性能优秀，开发效率高
- **React Native + Electron** ❌ - 桌面端需要额外打包，包体积大
- **React Native + Tauri** ❌ - 学习成本高，生态相对不成熟

最终选择 Flutter，实现了 Android、iOS、Web、macOS、Windows、Linux 全平台覆盖。

## 核心理念

"kiri"在日语中意为"切割"，体现禅学中"当下"的概念。追求极简、宁静的设计美学，帮助用户在专注与休息之间找到平衡。

## 功能特性

### 核心功能
- ⏰ **可调时间** - 工作/休息时间 1-60分钟自定义
- 📊 **进度可视化** - 圆形进度环，直观展示时间流逝
- 🔄 **智能切换** - 自动在工作与休息模式间切换
- 📈 **完成统计** - 追踪完成的番茄数量
- 🎨 **状态指示** - 清晰的"专注"/"休息"状态显示

### 高级功能
- 📝 **任务管理** - 创建、编辑、删除任务
- 📊 **数据统计** - 详细的使用统计和趋势分析
- 📤 **数据导出** - 支持JSON和CSV格式导出
- 🔔 **智能通知** - 工作时间结束提醒
- 🎵 **音效反馈** - 可自定义的音效提醒
- 💾 **数据持久化** - 本地数据库存储所有数据

## 快速开始

### 环境要求
- Flutter 3.0+
- Dart 3.0+

### 安装运行
```bash
# 安装依赖
flutter pub get

# 运行应用
flutter run

# 构建发布
flutter build apk --release        # Android
flutter build ios --release        # iOS
flutter build web --release        # Web
flutter build macos --release      # macOS
flutter build windows --release    # Windows
flutter build linux --release      # Linux
```

## 使用指南

### 基本操作
1. **开始计时** - 点击中央播放按钮
2. **暂停计时** - 再次点击播放按钮
3. **重置计时** - 点击左侧重置按钮
4. **设置时间** - 点击右侧设置按钮

### 自定义设置
1. 点击设置按钮（齿轮图标）
2. 使用加减按钮调整工作时间和休息时间
3. 点击"应用"按钮保存设置

## 技术栈

- **框架**: Flutter 3.35.3
- **语言**: Dart 3.0
- **平台**: Android, iOS, Web, macOS, Windows, Linux
- **状态管理**: Provider
- **动画**: AnimationController + CustomPainter
- **UI组件**: Material Design 3
- **数据库**: SQLite (sqflite)
- **通知**: flutter_local_notifications
- **音频**: audioplayers

## 项目结构

```
lib/
├── main.dart                    # 主应用文件
├── models/
│   └── pomodoro_session.dart    # 数据模型
├── providers/
│   └── pomodoro_provider.dart   # 状态管理
├── screens/
│   ├── export_screen.dart       # 数据导出
│   ├── statistics_screen.dart   # 统计页面
│   └── tasks_screen.dart        # 任务管理
└── services/
    ├── audio_service.dart       # 音频服务
    ├── database_service.dart    # 数据库服务
    ├── export_service.dart      # 导出服务
    └── notification_service.dart # 通知服务
```

## 设计理念

### 色彩系统
- **主色调**: 深蓝灰 (#2C3E50) - 专注与深度
- **工作状态**: 绿色系 - 活力与成长
- **休息状态**: 蓝色系 - 平静与放松
- **背景色**: 浅灰白 (#FAFAFA) - 柔和氛围

### 设计原则
- **极简美学** - 纯净界面，去除不必要元素
- **禅学理念** - 体现"空"与"静"的哲学思想
- **专注体验** - 减少干扰，专注当下
- **平衡和谐** - 工作与休息的完美平衡

## 开发指南

### 主要功能实现
- **计时器逻辑** - Timer.periodic 精确计时
- **动画效果** - 脉冲动画和进度动画
- **自定义绘制** - CustomPainter 绘制圆形进度环
- **状态切换** - 工作/休息模式智能切换
- **数据持久化** - SQLite 数据库存储
- **数据导出** - JSON/CSV 格式导出

### 开发命令
```bash
flutter run          # 开发模式
flutter analyze      # 代码分析
flutter test         # 运行测试
flutter clean        # 清理构建
```

## 浏览器支持

- Chrome 60+
- Firefox 55+
- Safari 12+
- Edge 79+

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目。

---

*"时间不是敌人，而是朋友。每一刻都是新的开始。"*