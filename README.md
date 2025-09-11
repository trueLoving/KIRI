# 刻 | KIRI

> 禅意与锋利的平衡 - 极简番茄闹钟

## 项目理念

"刻"代表时间的精确切割，"KIRI"在日语中意为"切割"，体现了禅学中"当下"的概念。这个番茄闹钟应用追求极简、宁静的设计美学，帮助用户在专注与休息之间找到平衡。

## 多平台支持

- 🌐 **Web App (PWA)** - 可安装的渐进式Web应用
- 🔌 **Chrome插件** - 浏览器扩展，随时可用
- 🖥️ **桌面应用** - 基于Tauri的原生桌面应用
- 📱 **响应式设计** - 适配各种屏幕尺寸
- 🔄 **跨平台同步** - 数据在平台间保持一致

## 设计特色

- **极简美学**：纯净的界面设计，去除一切不必要的元素
- **禅学理念**：体现"空"与"静"的哲学思想
- **专注体验**：减少干扰，让用户专注于当下
- **响应式设计**：适配各种设备尺寸

## 功能特性

### 核心功能
- ⏰ **25分钟工作计时** - 经典番茄工作法
- ☕ **5分钟短休息** - 快速恢复精力
- 🌸 **15分钟长休息** - 深度放松时间
- 📊 **圆形进度条** - 直观的时间可视化
- 🔄 **自动模式切换** - 智能循环管理
- 📈 **专注周期统计** - 追踪完成情况

### 平台特性

#### Web App (PWA)
- 📱 **可安装** - 添加到主屏幕
- 🔄 **离线工作** - 无网络也能使用
- 🔔 **推送通知** - 时间到提醒
- 💾 **本地存储** - 数据持久化

#### Chrome插件
- 🚀 **快速访问** - 浏览器内一键启动
- 🔔 **后台通知** - 即使关闭标签页也能提醒
- 🌐 **跨页面同步** - 状态在所有标签页保持一致
- ⚡ **轻量级** - 不占用系统资源

#### 桌面应用
- 🖥️ **原生性能** - 流畅的用户体验
- 🔔 **系统通知** - 深度系统集成
- ⌨️ **全局快捷键** - 系统级快捷操作
- 🎯 **专注模式** - 减少干扰

### 交互体验
- ⌨️ **键盘快捷键支持** - 高效操作
- 🔔 **智能通知** - 多平台提醒
- 🎨 **深色模式** - 护眼设计
- 📱 **响应式设计** - 完美适配各种设备

### 键盘快捷键
- `空格键` - 开始/暂停
- `R键` - 重置计时器
- `1键` - 切换到工作模式
- `2键` - 切换到短休息模式
- `3键` - 切换到长休息模式

## 设计哲学

### 禅学元素
- **空**：留白设计，给思维留出空间
- **静**：温和的色彩和音效，营造宁静氛围
- **当下**：专注于当前时刻，不被过去未来干扰
- **平衡**：工作与休息的和谐统一

### 色彩理念
- 主色调：深蓝灰 (#2c3e50) - 代表专注与深度
- 辅助色：浅灰 (#7f8c8d) - 代表平静与安宁
- 背景：渐变灰白 - 营造柔和氛围

## 快速开始

### 环境要求
- Node.js 18+
- pnpm 8+
- Rust (仅桌面应用需要)

### 安装依赖
```bash
pnpm install
```

### 开发模式

#### Web App 开发
```bash
pnpm dev:web
```
访问 http://localhost:3000

#### Chrome插件开发
```bash
pnpm dev:chrome
```
在Chrome中加载 `dist-chrome` 目录

#### 桌面应用开发
```bash
pnpm dev:tauri
```

### 构建发布

#### 构建所有平台
```bash
pnpm build:all
```

#### 单独构建
```bash
# Web App
pnpm build:web

# Chrome插件
pnpm build:chrome

# 桌面应用
pnpm build:tauri
```

### 部署指南

#### Web App 部署
1. 构建: `pnpm build:web`
2. 将 `dist-web` 目录部署到任何静态托管服务
3. 确保HTTPS支持（PWA要求）

#### Chrome插件发布
1. 构建: `pnpm build:chrome`
2. 在Chrome扩展管理页面加载 `dist-chrome` 目录
3. 或打包为 `.crx` 文件发布到Chrome Web Store

#### 桌面应用分发
1. 构建: `pnpm build:tauri`
2. 在 `src-tauri/target/release/bundle/` 找到安装包
3. 支持 Windows、macOS、Linux

## 技术栈

- **前端**: React 19 + TypeScript + Vite
- **桌面**: Tauri 2.0 + Rust
- **PWA**: Service Worker + Web App Manifest
- **插件**: Chrome Extension Manifest V3
- **样式**: CSS3 + 响应式设计

## 浏览器支持

- Chrome 60+
- Firefox 55+
- Safari 12+
- Edge 79+

## 开发指南

### 项目结构
```
KIRI/
├── src/                    # 源代码
│   ├── App.tsx            # 主应用组件
│   ├── App.css            # 样式文件
│   ├── manifest.json      # Chrome插件清单
│   ├── popup.html         # Chrome插件弹窗
│   ├── popup.tsx          # Chrome插件React组件
│   ├── background.ts      # Chrome插件后台脚本
│   └── content.ts         # Chrome插件内容脚本
├── public/                # 静态资源
│   ├── manifest.json      # PWA清单
│   ├── sw.js             # Service Worker
│   └── icons/            # 图标文件
├── src-tauri/            # Tauri桌面应用
└── dist-*/               # 构建输出目录
```

### 开发命令
```bash
# 开发
pnpm dev:web          # Web App开发
pnpm dev:chrome       # Chrome插件开发
pnpm dev:tauri        # 桌面应用开发

# 构建
pnpm build:web        # 构建Web App
pnpm build:chrome     # 构建Chrome插件
pnpm build:tauri      # 构建桌面应用
pnpm build:all        # 构建所有平台

# 预览
pnpm preview:web      # 预览Web App
pnpm preview:chrome   # 预览Chrome插件

# 工具
pnpm clean            # 清理构建文件
pnpm type-check       # 类型检查
```

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

---

*"时间不是敌人，而是朋友。每一刻都是新的开始。"*
