/**
 * 状态切换演示脚本（两轨通用）
 *
 * 用于右侧说明区演示某组件的不同视觉状态（如认证状态、审核状态）。
 * 右侧放一组按钮，点击同步切换左侧组件的 className 和右侧描述文字。
 *
 * 用法：
 * 1. 右侧说明条目内放：
 *    <div class="state-switcher" data-state-target="cert-status">
 *      <button data-state="pending" class="active">待认证</button>
 *      <button data-state="verified">已认证</button>
 *      <button data-state="rejected">已驳回</button>
 *    </div>
 * 2. 左侧被演示元素加 data-state-scope="cert-status"，其 className 包含状态名：
 *    <div data-state-scope="cert-status" class="cert-card cert-pending">...</div>
 *    CSS 中定义 .cert-pending / .cert-verified / .cert-rejected 三套样式
 * 3. 引入本脚本后调用 window.initStateSwitcher()
 */
window.initStateSwitcher = function() {
  document.querySelectorAll('.state-switcher').forEach((switcher) => {
    const scope = switcher.dataset.stateTarget;
    if (!scope) return;
    const target = document.querySelector(`[data-state-scope="${scope}"]`);
    if (!target) return;

    // 记录初始状态类名前缀（假设格式为 {scope}-{state}，需约定）
    const buttons = switcher.querySelectorAll('button[data-state]');
    buttons.forEach((btn) => {
      btn.addEventListener('click', () => {
        const newState = btn.dataset.state;
        // 切换按钮 active
        buttons.forEach((b) => b.classList.remove('active'));
        btn.classList.add('active');
        // 切换目标 className：移除旧状态类，加新状态类
        const classes = target.className.split(' ').filter((c) => !c.startsWith(scope + '-'));
        classes.push(`${scope}-${newState}`);
        target.className = classes.join(' ');
        // 延迟重算 Pin 圆点位置（样式变化可能引起尺寸微调）
        if (window.initPinAnnotation) {
          setTimeout(() => window.dispatchEvent(new Event('resize')), 50);
        }
      });
    });
  });
};
