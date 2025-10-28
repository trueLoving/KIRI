# KIRI - 桌面端

刻 | KIRI 的 Electron 桌面应用版本

## 简介

使用 Electron + React + Vite + TypeScript 构建的跨平台桌面番茄钟应用。

### 技术栈

- **Electron** - 桌面应用框架
- **React** - UI 框架
- **TypeScript** - 类型安全
- **Vite** - 构建工具
- **electron-builder** - 应用打包

## 快速开始

### 环境要求

- Node.js 18+
- pnpm 8+

### 安装依赖

```bash
# 从根目录安装（推荐）
pnpm install

# 或从当前目录安装
npm install
```

### 开发

```bash
# 启动开发模式
pnpm dev

# 代码检查
pnpm lint

# 预览构建结果
pnpm preview
```

### 构建

```bash
# 构建生产版本
pnpm build

# 构建完成后，安装包位于 dist/ 目录
```

## 项目结构

```
apps/desktop/
├── electron/
│   ├── main.ts           # Electron 主进程
│   ├── preload.ts        # 预加载脚本
│   └── electron-env.d.ts # 类型定义
├── src/
│   ├── App.tsx           # 主应用组件
│   ├── main.tsx          # 入口文件
│   ├── assets/           # 静态资源
│   └── index.css         # 全局样式
├── public/               # 公共资源
├── dist-electron/       # 构建输出
├── vite.config.ts        # Vite 配置
├── electron-builder.json5 # Electron 打包配置
└── tsconfig.json         # TypeScript 配置
```

## 功能特性

### 核心功能

- ⏰ 可自定义的工作/休息时间
- 📊 圆形进度环可视化
- 🔄 自动工作/休息切换
- 📈 完成数量统计
- 🎨 状态清晰指示

### 桌面端特性

- 🪟 原生窗口控制
- 🔔 系统通知
- 💾 本地数据持久化
- ⚙️ 快捷键支持

## 开发规范

### 代码风格

- 使用 TypeScript 严格模式
- 遵循 ESLint 规则
- 组件使用函数式写法

### Electron 架构

- **主进程** (main.ts) - 窗口管理、原生 API
- **渲染进程** (src/) - React 应用
- **预加载脚本** (preload.ts) - 安全通信桥梁

## 打包配置

应用支持打包为以下平台：

- 🍎 macOS (dmg, zip)
- 🪟 Windows (exe, nsis)
- 🐧 Linux (AppImage, deb, rpm)

配置位于 `electron-builder.json5`。

## 调试

```bash
# 开发模式（带 DevTools）
pnpm dev

# 查看日志
# 主进程日志在终端
# 渲染进程日志在 DevTools Console
```

## 构建优化

- Vite 快速构建
- 代码分割减少包体积
- Tree shaking 去除未使用代码

## 平台支持

- ✅ macOS 10.13+
- ✅ Windows 10+
- ✅ Linux (Ubuntu 18.04+)

## 许可证

MIT License

---

*专注当下，每一刻都是新的开始。*
