# Pin 红点标注技术要点（scaffold 版）

> 触发条件：用 scaffold 体系画原型、实现标注时读取。
> 本文档对应 scaffold 的 `proto-connect.js`。标注方案是 **Pin 独立红点**，不画连线。

---

## 标注机制（proto-connect.js）

scaffold 采用 **Pin 独立红点** 方案：被标注元素右边缘贴红色编号圆点，hover 时与右侧说明项联动高亮。**没有 SVG 连线**。

### 标注元素属性（两步即可，无需声明任何数组）

- 左侧被标注元素：`class="proto-element"` + `data-proto-id="N"`（N 为编号）
- 右侧说明条目：`class="proto-desc"` + `data-proto-desc="N"`（编号与左侧对应）

proto-connect.js 启动时自动扫描页面上所有 `data-proto-id` 和 `data-proto-desc`，按编号配对，自动注入红点圆标。**不需要声明 `window.connections`，不需要写 SVG。**

```html
<!-- 左侧：在要标注的元素上加这两个属性 -->
<div class="proto-element filter-bar" data-proto-id="1">...</div>

<!-- 右侧：对应编号的说明条目 -->
<div class="proto-desc doc-section" data-proto-desc="1">
  <div class="doc-label"><span class="doc-num">1</span> 筛选栏</div>
  <div class="doc-desc">说明文字...</div>
</div>
```

> 写法与旧连线版完全一致（属性名没变），只是渲染从连线改成了红点。已有源文件无需改 HTML，重建即可看到红点效果。

### 自动功能

proto-connect.js 自动处理：
- `markActiveSidebar()`：根据当前页 URL 给侧边栏对应项加 active
- `collectPins()` + `createPins()`：扫描配对、注入红点、绑定 hover 联动
- `updatePinPositions()`：fixed 定位计算红点坐标，滚动/resize/侧边栏折叠时自动重算
- `toggleStdSidebar()`：侧边栏折叠

### 样式（已固化在 proto-base.css）

- 红点：`background: #F53F3F`，22×22 圆，白色编号 12px，hover 放大 1.3 倍
- 红点带 8px 短引线（`::before`）连到元素右边缘
- 被标注元素 hover：`box-shadow: 0 0 0 2px #F53F3F`
- 右侧说明项 hover：左边框变红、背景 #FFF1F0
- 移动端（<768px）红点自动隐藏

### 常见坑

1. **只加属性不重建**：改了源文件（.src.html）必须跑 `build.sh` 重新生成产物，红点脚本才会内联进去。
2. **编号不配对**：`data-proto-id="3"` 必须有对应的 `data-proto-desc="3"`，否则该红点点击无联动。脚本不会报错，只能打开页面看。
3. **滚动容器不重算**：红点 fixed 定位，页面内部滚动时位置会错。proto-connect.js 已监听 `.content-area`/`.main-content`/`#leftPanel` 的 scroll 事件自动重算；若页面用了其他滚动容器，需在该容器上手动加 `addEventListener('scroll', updatePinPositions)`。
