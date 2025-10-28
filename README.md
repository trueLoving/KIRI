# 刻 | KIRI

> 禅意与锋利的平衡 - 极简番茄闹钟

## 项目初衷

个人需要一个简洁高效的番茄闹钟应用，使用跨平台技术栈实现全平台覆盖。

### 技术选型

- **React Native** ✅ - 移动端开发（Android、iOS）
- **Electron** ✅ - 桌面端开发（macOS、Windows、Linux）
- **React** ✅ - Web端开发（浏览器）

通过 React Native + Electron + React 的组合，实现了移动端、桌面端和Web端的完整覆盖。

## 核心理念

"kiri"在日语中意为"切割"，体现禅学中"当下"的概念。追求极简、宁静的设计美学，帮助用户在专注与休息之间找到平衡。

### 设计哲学
- **纯粹专注** - 移除所有不必要的功能，专注于核心的番茄钟体验
- **极简美学** - 简洁的界面设计，减少认知负担
- **禅学理念** - 体现"空"与"静"的哲学思想，让用户专注于当下
- **平衡和谐** - 工作与休息的完美平衡，避免过度复杂化

## 功能特性

### 核心功能
- ⏰ **可调时间** - 工作/休息时间 1-60分钟自定义
- 📊 **进度可视化** - 圆形进度环，直观展示时间流逝
- 🔄 **智能切换** - 自动在工作与休息模式间切换
- 📈 **完成统计** - 追踪完成的番茄数量
- 🎨 **状态指示** - 清晰的"专注"/"休息"状态显示

### 高级功能
- 📊 **数据统计** - 详细的使用统计和趋势分析
- 📤 **数据导出** - 支持JSON和CSV格式导出
- 🔔 **智能通知** - 工作时间结束提醒
- 🎵 **音效反馈** - 可自定义的音效提醒
- 💾 **数据持久化** - 本地数据库存储所有数据
- ⚙️ **简洁设置** - 只保留核心的时间设置选项

## 快速开始

### 环境要求
- **Node.js** 18+ 
- **pnpm** 10+ (推荐使用 pnpm 管理 monorepo)
- **React Native CLI** (移动端开发)
- **Xcode** (iOS开发，仅 macOS)
- **Android Studio** (Android开发)
- **Electron** (自动安装)

### 安装运行

这是一个 monorepo 项目，使用 pnpm workspace 管理多个应用。

```bash
# 安装所有依赖
pnpm install

# 运行桌面端 (Electron + React)
cd apps/desktop
pnpm dev

# 运行移动端 (Expo + React Native)
cd apps/mobile
pnpm start

# 从根目录运行（如果配置了脚本）
pnpm --filter desktop dev
pnpm --filter mobile start
```

### 构建发布

```bash
# 构建桌面端
cd apps/desktop
pnpm build

# 构建移动端
cd apps/mobile
pnpm android    # Android
pnpm ios        # iOS
```

## 使用指南

### 基本操作
1. **开始计时** - 点击中央播放按钮
2. **暂停计时** - 再次点击播放按钮
3. **重置计时** - 点击左侧重置按钮
4. **设置时间** - 点击右侧设置按钮

### 自定义设置
1. 点击底部"设置"标签页
2. 在"时间设置"中调整工作时间和休息时间
3. 在"功能设置"中配置通知、音效等选项
4. 设置会自动保存

## 技术栈

### 核心框架
- **React** - Web/桌面端 UI 框架
- **React Native** - 移动端 UI 框架（Android、iOS）
- **Electron** - 桌面端应用容器（macOS、Windows、Linux）
- **Expo** - React Native 开发框架

### 桌面端 (apps/desktop)
- **框架**: Electron + React + Vite
- **语言**: TypeScript
- **构建工具**: Vite
- **UI**: React + CSS
- **打包**: electron-builder

### 移动端 (apps/mobile)
- **框架**: Expo (React Native)
- **语言**: TypeScript
- **路由**: Expo Router
- **UI**: React Native 原生组件
- **导航**: React Navigation

### 共享工具
- **包管理**: pnpm (workspace monorepo)
- **状态管理**: Context API / Redux (可选)
- **数据库**: SQLite / AsyncStorage
- **通知**: 原生通知 API
- **动画**: CSS Animation / React Native Reanimated

## 项目结构

这是一个 monorepo 项目，使用 pnpm workspace 管理。

```
KIRI/
├── apps/
│   ├── desktop/          # Electron 桌面应用
│   │   ├── src/          # React + TypeScript 源代码
│   │   ├── electron/     # Electron 主进程
│   │   ├── public/       # 静态资源
│   │   └── package.json
│   │
│   └── mobile/           # Expo 移动应用
│       ├── app/          # Expo Router 路由
│       ├── components/   # 共享组件
│       ├── hooks/        # React Hooks
│       └── package.json
│
├── packages/              # 共享包（未来可扩展）
├── pnpm-workspace.yaml   # pnpm workspace 配置
└── pnpm-lock.yaml        # 依赖锁定文件
```

### 项目说明

- **apps/desktop** - 使用 Electron + React + Vite 构建的桌面应用，支持 macOS、Windows、Linux
- **apps/mobile** - 使用 Expo + React Native 构建的移动应用，支持 Android 和 iOS

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
- **计时器逻辑** - setTimeout/setInterval 精确计时，工作-休息循环
- **动画效果** - CSS/React Native 动画，流畅的界面过渡
- **自定义绘制** - SVG/CSS 绘制圆形进度环
- **状态切换** - 工作/休息模式智能切换
- **数据持久化** - SQLite/AsyncStorage 本地存储
- **数据导出** - JSON/CSV 格式导出
- **极简设计** - 专注于核心功能，移除复杂设置

### 开发命令

#### 桌面端开发 (apps/desktop)
```bash
cd apps/desktop
pnpm dev          # 启动开发服务器
pnpm build        # 构建生产版本
pnpm lint         # 代码检查
```

#### 移动端开发 (apps/mobile)
```bash
cd apps/mobile
pnpm start        # 启动 Expo 开发服务器
pnpm android      # 在 Android 设备上运行
pnpm ios          # 在 iOS 设备上运行
pnpm lint         # 代码检查
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