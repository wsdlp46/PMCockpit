/**
 * Pin 标注脚本（两轨通用：A 轨 antd 真组件 / B 轨 Tailwind 手写）
 *
 * 用法：
 * 1. 左侧元素加 className="anchor-target" data-anchor="N"（N 为 1-6 数字）
 * 2. 右侧说明条目加 class="doc-item" data-pin="N"，内部含 <span class="doc-pin">N</span>
 * 3. 右侧顶部放按钮 id="pin-toggle-btn"（可选，控制标注显隐）
 * 4. 左侧滚动容器 id="proto-stage"
 *
 * 初始化时机：
 * - B 轨（纯 HTML）：DOMContentLoaded 后直接调用
 * - A 轨（React）：createRoot().render() 后，用 requestAnimationFrame 双帧延迟调用
 *   原因：antd 组件异步渲染，单帧后 DOM 可能还没 commit
 */
window.initPinAnnotation = function() {
  const targets = document.querySelectorAll('[data-anchor]');
  if (!targets.length) { console.warn('[pin] 未找到 data-anchor 标注目标'); return; }

  const pins = [];
  let visible = true;

  // 创建圆点
  targets.forEach((t) => {
    const n = t.getAttribute('data-anchor');
    const dot = document.createElement('div');
    dot.className = 'pin-dot';
    dot.textContent = n;
    dot.dataset.pin = n;
    document.body.appendChild(dot);
    pins.push({ target: t, dot, n });

    dot.addEventListener('mouseenter', () => highlight(n, true));
    dot.addEventListener('mouseleave', () => highlight(n, false));
  });

  // 右侧条目联动
  document.querySelectorAll('.doc-item').forEach((item) => {
    const n = item.dataset.pin;
    if (!n) return;
    item.addEventListener('mouseenter', () => highlight(n, true));
    item.addEventListener('mouseleave', () => highlight(n, false));
  });

  function highlight(n, on) {
    const pin = pins.find((p) => p.n === n);
    if (pin) pin.target.classList.toggle('highlight', on);
    document.querySelectorAll('.doc-item').forEach((it) => {
      if (it.dataset.pin === n) it.classList.toggle('active', on);
    });
  }

  // 位置重算（圆点贴目标元素右边缘外侧、垂直居中）
  function reposition() {
    pins.forEach(({ target, dot }) => {
      if (!visible) return;
      const rect = target.getBoundingClientRect();
      // 目标不在视口内时隐藏圆点
      if (rect.bottom < 0 || rect.top > window.innerHeight) {
        dot.style.display = 'none';
        return;
      }
      dot.style.display = visible ? 'flex' : 'none';
      dot.style.left = (rect.right + 4) + 'px';
      dot.style.top = (rect.top + rect.height / 2 - 11) + 'px';
    });
  }
  reposition();

  // 监听滚动和 resize
  const stage = document.getElementById('proto-stage');
  if (stage) stage.addEventListener('scroll', reposition);
  window.addEventListener('scroll', reposition, true);
  window.addEventListener('resize', reposition);

  // 显隐开关（可选）
  const btn = document.getElementById('pin-toggle-btn');
  if (btn) {
    btn.addEventListener('click', () => {
      visible = !visible;
      document.querySelectorAll('.pin-dot').forEach((d) => d.classList.toggle('hidden', !visible));
      btn.textContent = visible ? '隐藏标注' : '显示标注';
    });
  }
};
