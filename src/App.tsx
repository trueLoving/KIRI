import { useState, useEffect } from "react";
import "./App.css";

type TimerMode = 'work' | 'shortBreak' | 'longBreak';

function App() {
  const [timeLeft, setTimeLeft] = useState(25 * 60); // 25分钟工作
  const [isRunning, setIsRunning] = useState(false);
  const [mode, setMode] = useState<TimerMode>('work');
  const [cycles, setCycles] = useState(0);

  const modes = {
    work: { duration: 25 * 60, label: '专注工作', color: '#2c3e50' },
    shortBreak: { duration: 5 * 60, label: '短休息', color: '#7f8c8d' },
    longBreak: { duration: 15 * 60, label: '长休息', color: '#95a5a6' }
  };

  useEffect(() => {
    let interval: number;
    if (isRunning && timeLeft > 0) {
      interval = setInterval(() => {
        setTimeLeft(time => time - 1);
      }, 1000);
    } else if (timeLeft === 0) {
      handleTimerComplete();
    }
    return () => clearInterval(interval);
  }, [isRunning, timeLeft]);

  const handleTimerComplete = async () => {
    setIsRunning(false);
    
    // 发送通知
    if ('Notification' in window && Notification.permission === 'granted') {
      new Notification(mode === 'work' ? '专注时间结束！' : '休息时间结束！', {
        body: mode === 'work' ? '该休息一下了' : '准备开始工作',
        icon: '/icon-192.png'
      });
    } else if ('Notification' in window && Notification.permission !== 'denied') {
      const permission = await Notification.requestPermission();
      if (permission === 'granted') {
        new Notification(mode === 'work' ? '专注时间结束！' : '休息时间结束！', {
          body: mode === 'work' ? '该休息一下了' : '准备开始工作',
          icon: '/icon-192.png'
        });
      }
    }

    // 自动切换到下一个模式
    if (mode === 'work') {
      setCycles(prev => prev + 1);
      const nextMode = cycles % 3 === 2 ? 'longBreak' : 'shortBreak';
      setMode(nextMode);
      setTimeLeft(modes[nextMode].duration);
    } else {
      setMode('work');
      setTimeLeft(modes.work.duration);
    }
  };

  const toggleTimer = () => {
    setIsRunning(!isRunning);
  };

  const resetTimer = () => {
    setIsRunning(false);
    setTimeLeft(modes[mode].duration);
  };

  const switchMode = (newMode: TimerMode) => {
    setMode(newMode);
    setTimeLeft(modes[newMode].duration);
    setIsRunning(false);
  };

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const progress = ((modes[mode].duration - timeLeft) / modes[mode].duration) * 100;

  return (
    <div className="app">
      <header className="app-header">
        <h1 className="app-title">刻 | KIRI</h1>
        <p className="app-subtitle">禅意与锋利的平衡</p>
      </header>

      <main className="timer-container">
        <div className="mode-selector">
          {Object.entries(modes).map(([key, config]) => (
            <button
              key={key}
              className={`mode-btn ${mode === key ? 'active' : ''}`}
              onClick={() => switchMode(key as TimerMode)}
              style={{ '--mode-color': config.color } as React.CSSProperties}
            >
              {config.label}
            </button>
          ))}
        </div>

        <div className="timer-display">
          <div className="progress-ring">
            <svg className="progress-ring-svg" width="280" height="280">
              <circle
                className="progress-ring-circle-bg"
                stroke="#e0e0e0"
                strokeWidth="8"
                fill="transparent"
                r="132"
                cx="140"
                cy="140"
              />
              <circle
                className="progress-ring-circle"
                stroke={modes[mode].color}
                strokeWidth="8"
                fill="transparent"
                r="132"
                cx="140"
                cy="140"
                style={{
                  strokeDasharray: 2 * Math.PI * 132,
                  strokeDashoffset: 2 * Math.PI * 132 * (1 - progress / 100),
                  transition: 'stroke-dashoffset 0.3s ease'
                }}
              />
            </svg>
            <div className="timer-text">
              <div className="time">{formatTime(timeLeft)}</div>
              <div className="mode-label">{modes[mode].label}</div>
            </div>
          </div>
        </div>

        <div className="timer-controls">
          <button className="control-btn primary" onClick={toggleTimer}>
            {isRunning ? '暂停' : '开始'}
          </button>
          <button className="control-btn secondary" onClick={resetTimer}>
            重置
          </button>
        </div>

        <div className="cycles-info">
          <p>已完成 {cycles} 个专注周期</p>
        </div>
      </main>

      <footer className="app-footer">
        <p>专注当下，把握每一刻</p>
      </footer>
    </div>
  );
}

export default App;
