// Chrome插件后台脚本
chrome.runtime.onInstalled.addListener(() => {
  console.log('刻 | KIRI 插件已安装');
});

// 处理通知点击
chrome.notifications.onClicked.addListener((notificationId) => {
  console.log('通知被点击:', notificationId);
  // 可以在这里添加打开弹窗的逻辑
});

// 处理插件图标点击
chrome.action.onClicked.addListener((_tab) => {
  // 这个事件在manifest v3中通常不需要，因为使用了default_popup
  console.log('插件图标被点击');
});

// 监听来自content script的消息
chrome.runtime.onMessage.addListener((request, _sender, _sendResponse) => {
  if (request.action === 'showNotification') {
    chrome.notifications.create({
      type: 'basic',
      iconUrl: 'icons/48x48.png',
      title: request.title,
      message: request.message
    });
  }
  return true;
});
