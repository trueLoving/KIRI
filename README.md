# 刻 | KIRI

> 禅意与锋利的平衡 - 极简番茄闹钟

## 项目理念

"刻"代表时间的精确切割，"KIRI"在日语中意为"切割"，体现了禅学中"当下"的概念。这个番茄闹钟应用追求极简、宁静的设计美学，帮助用户在专注与休息之间找到平衡。

## 应用特色

- 🌸 **禅意设计** - 极简界面，体现"空"与"静"的哲学思想
- ⏰ **经典番茄钟** - 25分钟专注 + 5分钟休息的经典循环
- 🎯 **可自定义时间** - 灵活设置工作时间和休息时间
- 📊 **直观进度** - 圆形进度环，清晰展示时间流逝
- 🔄 **智能切换** - 自动在工作与休息模式间切换
- 📱 **跨平台** - 支持Android、iOS、Web、桌面等多平台

## 功能特性

### 核心功能
- ⏰ **可调工作时间** - 1-60分钟自定义设置
- ☕ **可调休息时间** - 1-60分钟自定义设置
- 📊 **圆形进度指示器** - 直观的时间可视化
- 🔄 **自动模式切换** - 工作与休息智能循环
- 📈 **完成统计** - 追踪完成的番茄数量
- 🎨 **状态指示** - 清晰的"专注"/"休息"状态显示

### 交互体验
- 🎯 **简洁控制** - 开始/暂停、重置、设置三个核心按钮
- 🔔 **触觉反馈** - 时间到时的震动提醒
- 💫 **微妙动画** - 脉冲效果和进度动画
- 🎨 **优雅配色** - 工作状态绿色，休息状态蓝色

### 设计哲学
- **极简美学**：纯净的界面设计，去除一切不必要的元素
- **禅学理念**：体现"空"与"静"的哲学思想
- **专注体验**：减少干扰，让用户专注于当下
- **平衡和谐**：工作与休息的完美平衡

## 界面设计

### 色彩理念
- **主色调**：深蓝灰 (#2C3E50) - 代表专注与深度
- **工作状态**：绿色系 - 代表活力与成长
- **休息状态**：蓝色系 - 代表平静与放松
- **背景色**：浅灰白 (#FAFAFA) - 营造柔和氛围
- **辅助色**：中性灰 - 减少视觉干扰

### 设计元素
- **圆形设计** - 所有按钮和进度环都采用圆形
- **留白空间** - 大量留白营造宁静感
- **微妙阴影** - 轻柔的阴影增加层次感
- **圆润边角** - 所有元素都采用圆角设计

## 快速开始

### 环境要求
- Flutter 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Android SDK (Android开发)
- Xcode (iOS开发)

### 安装依赖
```bash
flutter pub get
```

### 运行应用

#### Android
```bash
flutter run -d android
```

#### iOS
```bash
flutter run -d ios
```

#### Web
```bash
flutter run -d chrome
```

#### 桌面
```bash
flutter run -d macos
# 或
flutter run -d windows
# 或
flutter run -d linux
```

### 构建发布

#### Android APK
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

#### 桌面应用
```bash
flutter build macos --release
flutter build windows --release
flutter build linux --release
```

## 使用指南

### 基本操作
1. **开始计时** - 点击中央的播放按钮
2. **暂停计时** - 再次点击播放按钮
3. **重置计时** - 点击左侧的重置按钮
4. **设置时间** - 点击右侧的设置按钮

### 自定义设置
1. 点击设置按钮（齿轮图标）
2. 使用加减按钮调整工作时间和休息时间
3. 点击"应用"按钮保存设置
4. 计时器会立即更新到新的时间设置

### 时间管理
- **工作时间**：默认25分钟，可设置1-60分钟
- **休息时间**：默认5分钟，可设置1-60分钟
- **自动切换**：时间到后自动切换到下一个模式
- **完成统计**：自动记录完成的番茄数量

## 技术栈

- **框架**: Flutter 3.35.3
- **语言**: Dart 3.0
- **平台**: Android, iOS, Web, macOS, Windows, Linux
- **状态管理**: StatefulWidget
- **动画**: AnimationController + CustomPainter
- **UI组件**: Material Design 3

## 项目结构

```
lib/
├── main.dart              # 主应用文件
└── (其他文件将根据需要添加)

android/                   # Android平台配置
ios/                       # iOS平台配置
web/                       # Web平台配置
macos/                     # macOS平台配置
windows/                   # Windows平台配置
linux/                     # Linux平台配置
```

## 开发指南

### 代码结构
- **PomodoroApp** - 主应用组件
- **PomodoroTimer** - 计时器主界面
- **ProgressPainter** - 自定义进度环绘制器
- **时间管理** - 可配置的工作/休息时间
- **状态管理** - 计时器状态和动画控制

### 主要功能实现
- **计时器逻辑** - 使用Timer.periodic实现精确计时
- **动画效果** - 脉冲动画和进度动画
- **自定义绘制** - CustomPainter绘制圆形进度环
- **状态切换** - 工作/休息模式的智能切换
- **设置管理** - 可配置的时间参数

### 开发命令
```bash
# 开发模式
flutter run

# 热重载
r - 热重载
R - 热重启
q - 退出

# 调试
flutter analyze          # 代码分析
flutter test             # 运行测试
flutter clean            # 清理构建文件
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

### 贡献指南
1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 更新日志

### v1.0.0
- ✨ 初始版本发布
- 🎨 禅意极简设计
- ⏰ 经典番茄钟功能
- 🎯 可自定义工作时间
- ☕ 可自定义休息时间
- 📊 圆形进度指示器
- 📱 跨平台支持

---

*"时间不是敌人，而是朋友。每一刻都是新的开始。"*