// Chrome插件内容脚本
console.log('刻 | KIRI 内容脚本已加载');

// 监听来自页面的消息
window.addEventListener('message', (event) => {
  if (event.source !== window) return;
  
  if (event.data.type === 'KIRI_TIMER_COMPLETE') {
    // 发送消息到后台脚本
    chrome.runtime.sendMessage({
      action: 'showNotification',
      title: event.data.title,
      message: event.data.message
    });
  }
});

// 可以在这里添加页面注入的功能
// 比如在页面上显示计时器状态等
