import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { resolve } from "path";

// @ts-expect-error process is a nodejs global
const host = process.env.TAURI_DEV_HOST;
const isTauri = process.env.TAURI_PLATFORM !== undefined;
const isChromeExtension = process.env.BUILD_TARGET === 'chrome-extension';
const isWebApp = process.env.BUILD_TARGET === 'web-app';

// https://vite.dev/config/
export default defineConfig(async () => ({
  plugins: [react()],

  // 基础配置
  base: isChromeExtension ? './' : '/',
  
  // 构建配置
  build: {
    outDir: isChromeExtension ? 'dist-chrome' : isWebApp ? 'dist-web' : 'dist',
    rollupOptions: {
      input: isChromeExtension ? {
        popup: resolve(__dirname, 'src/popup.html'),
        background: resolve(__dirname, 'src/background.ts'),
        content: resolve(__dirname, 'src/content.ts'),
      } : undefined,
    },
  },

  // 开发服务器配置
  server: isTauri ? {
    // Tauri 开发模式
    port: 1420,
    strictPort: true,
    host: host || false,
    hmr: host
      ? {
          protocol: "ws",
          host,
          port: 1421,
        }
      : undefined,
    watch: {
      ignored: ["**/src-tauri/**"],
    },
  } : {
    // Web 开发模式
    port: 3000,
    open: true,
  },

  // 防止 Vite 隐藏 Rust 错误
  clearScreen: false,
}));
