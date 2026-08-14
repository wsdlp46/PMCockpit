/* ==========================================================================
   proto-connect.js — 原型公共脚本（Pin 红点标注版）
   含：当前页自动高亮(active)、Pin 标注系统、侧边栏折叠。
   所有页面共用。页面特有交互留在各页内联 <script>。
   ========================================================================== */

// ==================== 当前页自动标记 active ====================
function markActiveSidebar() {
  var current = location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('#stdSidebar .nav-item[data-href]').forEach(function(item) {
    var href = item.getAttribute('data-href');
    item.style.cursor = 'pointer';
    item.addEventListener('click', function() { location.href = href; });
    if (href === current) item.classList.add('active');
  });
}

// ==================== Pin 红点标注系统 ====================
// 页面元素用 data-proto-id="N" 标注，右侧说明用 data-proto-desc="N"。
// 脚本自动扫描配对，注入红点，无需声明 window.connections。
var pinEls = {};      // { '1': <div.pin-overlay>, ... }
var pinTargets = {};  // { '1': <被标注元素>, ... }
var pinDocs = {};     // { '1': <右侧说明项>, ... }
var pinsVisible = true;

function collectPins() {
  document.querySelectorAll('[data-proto-id]').forEach(function(el) {
    var id = el.getAttribute('data-proto-id');
    pinTargets[id] = el;
  });
  document.querySelectorAll('[data-proto-desc]').forEach(function(el) {
    var id = el.getAttribute('data-proto-desc');
    pinDocs[id] = el;
  });
}

function createPins() {
  Object.keys(pinTargets).forEach(function(id) {
    if (pinEls[id]) return;
    var pin = document.createElement('div');
    pin.className = 'pin-overlay';
    pin.textContent = id;
    pin.setAttribute('data-pin', id);
    document.body.appendChild(pin);
    pinEls[id] = pin;
    // hover 联动
    pin.addEventListener('mouseenter', function() { highlightPin(id); });
    pin.addEventListener('mouseleave', clearPinHighlight);
    var target = pinTargets[id];
    target.addEventListener('mouseenter', function() { highlightPin(id); });
    target.addEventListener('mouseleave', clearPinHighlight);
  });
  // 右侧说明项 hover
  Object.keys(pinDocs).forEach(function(id) {
    var doc = pinDocs[id];
    doc.addEventListener('mouseenter', function() { highlightPin(id); });
    doc.addEventListener('mouseleave', clearPinHighlight);
  });
  updatePinPositions();
}

function highlightPin(id) {
  clearPinHighlight();
  if (pinEls[id]) pinEls[id].classList.add('active');
  if (pinTargets[id]) pinTargets[id].classList.add('pin-highlighted');
  if (pinDocs[id]) pinDocs[id].classList.add('pin-doc-highlight');
}

function clearPinHighlight() {
  Object.values(pinEls).forEach(function(p) { p.classList.remove('active'); });
  Object.values(pinTargets).forEach(function(t) { t.classList.remove('pin-highlighted'); });
  Object.values(pinDocs).forEach(function(d) { d.classList.remove('pin-doc-highlight'); });
}

function updatePinPositions() {
  Object.keys(pinEls).forEach(function(id) {
    var target = pinTargets[id];
    if (!target) return;
    var rect = target.getBoundingClientRect();
    var pin = pinEls[id];
    pin.style.left = (rect.right + 2) + 'px';
    pin.style.top = (rect.top + rect.height / 2) + 'px';
  });
}

function setPinsVisible(visible) {
  pinsVisible = visible;
  Object.values(pinEls).forEach(function(p) {
    p.classList.toggle('hidden', !visible);
  });
}

// ==================== 侧边栏折叠 ====================
function toggleStdSidebar(toggleEl) {
  var sidebar = document.getElementById('stdSidebar');
  if (!sidebar) return;
  sidebar.classList.toggle('collapsed');
  var icon = toggleEl.querySelector('i');
  if (icon) {
    icon.className = sidebar.classList.contains('collapsed') ? 'fas fa-chevron-right' : 'fas fa-chevron-left';
  }
  setTimeout(updatePinPositions, 350);
}

// ==================== 初始化 ====================
window.addEventListener('DOMContentLoaded', function() {
  markActiveSidebar();
  collectPins();
  createPins();
  // 滚动重算位置：监听最近的滚动容器
  document.querySelectorAll('[id*="leftPanel"], .content-area, .main-content').forEach(function(c) {
    c.addEventListener('scroll', updatePinPositions);
  });
});
window.addEventListener('resize', updatePinPositions);
