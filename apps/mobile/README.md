# KIRI - 移动端

刻 | KIRI 的移动应用版本

## 简介

使用 Expo + React Native + TypeScript 构建的跨平台移动番茄钟应用。

### 技术栈

- **Expo** - React Native 开发框架
- **React Native** - 移动 UI 框架
- **TypeScript** - 类型安全
- **Expo Router** - 文件系统路由
- **React Navigation** - 导航管理

## 快速开始

### 环境要求

- Node.js 18+
- pnpm 8+
- iOS 开发：Xcode (macOS 专用)
- Android 开发：Android Studio

### 安装依赖

```bash
# 从根目录安装（推荐）
pnpm install

# 或从当前目录安装
npm install
```

### 开发

```bash
# 启动开发服务器
pnpm start

# iOS 模拟器
pnpm ios

# Android 模拟器/设备
pnpm android

# Web 浏览器
pnpm web

# 代码检查
pnpm lint
```

### 构建

```bash
# Android APK
pnpm android -- --no-build

# iOS
pnpm ios -- --no-build

# 生产构建
eas build
```

## 项目结构

```
apps/mobile/
├── app/
│   ├── _layout.tsx        # 根布局
│   ├── (tabs)/            # Tab 导航
│   │   ├── _layout.tsx
│   │   ├── index.tsx      # 首页
│   │   └── explore.tsx   # 探索页
│   └── modal.tsx          # 模态页面
├── components/             # 共享组件
│   ├── themed-text.tsx
│   ├── themed-view.tsx
│   ├── hello-wave.tsx
│   ├── haptic-tab.tsx
│   ├── parallax-scroll-view.tsx
│   ├── external-link.tsx
│   └── ui/                # UI 组件库
│       ├── collapsible.tsx
│       └── icon-symbol.tsx
├── constants/
│   └── theme.ts           # 主题配置
├── hooks/                 # React Hooks
│   ├── use-color-scheme.ts
│   └── use-theme-color.ts
├── assets/                # 静态资源
│   └── images/            # 图片资源
└── scripts/               # 构建脚本
```

## 功能特性

### 核心功能

- ⏰ 可自定义的工作/休息时间
- 📊 圆形进度环可视化
- 🔄 自动工作/休息切换
- 📈 完成数量统计
- 🎨 状态清晰指示

### 移动端特性

- 📱 原生体验
- 🎨 主题适配（明暗模式）
- 🔔 推送通知
- 📱 触觉反馈
- 💾 本地数据持久化
- 📊 Expo Router 文件路由
- 🔄 热重载开发

## 平台支持

- ✅ Android 6.0+
- ✅ iOS 13+
- ✅ Web 浏览器

## 开发指南

### Expo 常用命令

```bash
# 启动开发服务器
npx expo start

# 清除缓存
npx expo start --clear

# 显示二维码（扫描运行）
npx expo start --tunnel
```

### 路由系统

使用 Expo Router 基于文件系统的路由：

- `app/` - 路由页面
- `app/_layout.tsx` - 根布局
- `app/(tabs)/` - Tab 导航组

### 主题系统

支持明暗主题自动切换：

- `constants/theme.ts` - 主题配置
- `hooks/use-color-scheme.ts` - 主题 Hook
- `components/themed-*.tsx` - 主题组件

### 性能优化

- React Native Reanimated - 60fps 动画
- 触觉反馈优化交互
- 图片懒加载
- 代码分割

## 开发工具

### Expo Dev Tools

开发模式下支持：

- 💻 热重载
- 🔍 远程调试
- 📊 性能监控
- 🔧 开发菜单

### 调试

```bash
# 查看日志
npx expo start --dev-client

# React DevTools
npm install -g react-devtools
react-devtools
```

## 构建发布

### 使用 EAS Build

```bash
# 安装 EAS CLI
npm install -g eas-cli

# 配置
eas build:configure

# 构建
eas build --platform android
eas build --platform ios
```

### 本地构建

需要安装相应平台的开发工具。

## 图标和启动屏

- `app.json` - 应用配置
- `assets/images/` - 图标资源
- 支持自定义启动屏

## 权限管理

使用 Expo 权限 API：

- 通知权限
- 存储权限
- 系统提示

## 测试

```bash
# 运行测试
npm test

# 测试覆盖
npm test -- --coverage
```

## 许可证

MIT License

---

*专注当下，每一刻都是新的开始。*
