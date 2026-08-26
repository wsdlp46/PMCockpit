---
name: prototype-html-pin
description: >
  仅根据已确认页面规格生成或修改带 Pin 标注的交互式单文件 HTML 产品原型，使用 scaffold 源文件和 build 构建。
  不用于真实业务前端、静态视觉稿、普通展示页面或公共组件抽取；规格未确认时先补规格，不直接出原型。
agent_created: true
---

# 交互式HTML产品原型生成

生成单文件 HTML 产品原型。本文档是调度器：核心规则和路由表在此，长流程按场景读取 `assets/workflows/` 下对应文档。

> **技术路线铁律**：纯 HTML + Tailwind + 原生 JS，**禁止引入 React/Vue/Babel 等框架**。"按 antd 设计"指视觉对齐（用 scaffold 的 proto-base.css），不是引入 antd 真组件。真组件需工程化构建，与单文件原型流程冲突。

## 核心工作流程

0. **查项目现有资产** - 动手前先查目标版本 `04-原型/`；存量线性项目再查 `03-原型设计/`。有 `_scaffold/` 或既有原型时直接复用，不从 skill 复制新的；没有才把 skill 的 `assets/scaffold/` 复制进项目。同时查项目主色（见"主色查询规则"）。

1. **理解需求** - 明确要展示的功能和界面元素。有规格文档（.md）则通读全文；项目有设计规范文档则读取获取配色、字号、组件尺寸等参数。
2. **风格判定** - 按页面类型定视觉方案：管理后台/B端 → 用 `scaffold/` 体系（见"技术栈要求"）；门户/C端 → 读本 skill `assets/design/web门户-design.md`（同目录有脱敏快照案例可参照布局）；移动端H5 → 政务/强调色风读 `assets/design/手机端-design.md`，电商/钱包/订单/个人中心类读 `assets/design/手机端-极简黑白-design.md`（项目有品牌色规范时按其叠加规则只覆盖操作色）；数据大屏 → 深色底+卡片矩阵。同时读 `01通用规则/设计库/设计约定.md`。未明确端态默认按管理后台处理。
3. **规格匹配** - 从规格文档提取 UI 元素清单（表格列、卡片字段、按钮、弹窗层级、筛选条件）。只做规格明确要求的，不擅自添加。不确定的枚举值只放第一个并标注待确认。
4. **设计标注** - 选定 3-8 个关键元素（视页面复杂度），用 `data-proto-id` 标记，规划右侧说明条目。
5. **编写源文件** - 后台页面复制 `scaffold/examples/` 最接近的 `.src.html` 改，不从零写。改完跑 build.sh 生成产物。
6. **交付前自查** - 读取 `assets/workflows/delivery-checklist.md` 逐项核对，全过才算交付完成。

### 原型迭代（修改已有原型时执行）

改已有原型会触发原型↔规格↔需求三方联动。读取 `assets/workflows/iteration.md` 按六步执行（归档旧版 → 边改边记变更笔记 → 定稿过防遗漏清单 → 列回写清单经用户确认 → 执行回写 → 清理笔记）。新建原型跳过本步。

## B 端原型设计准则（交互层硬约束）

画 B 端管理后台原型时，以下 6 条优先于具体布局规范执行：

1. **分类前置导入**：批量导入弹窗必须包含上级分类选择项，不允许先导入再归类
2. **操作按钮聚合**：同类操作（增删改查、导入导出、批量处理）物理聚合到同一区域
3. **交互流程极简**：能在一屏内完成的操作不分步弹窗，避免"点开三层才能完成任务"
4. **显性化查看入口 + 操作列顺序**：操作列首位固定放"查看"按钮（只读、最高频）。完整顺序按"频率降序、危险升序"排列：查看 → 修改 → 其他操作 → 关闭 → 删除
   - 查看（只读，最高频）
   - 修改/编辑（写操作，次高频）
   - 其他操作（状态相关的业务操作：通过/驳回/冻结/启用/审核等）
   - 关闭（状态终态操作：下架/停用/禁用/注销）
   - 删除（最危险、不可逆，固定末位）
   - 各状态可用的操作不同，但出现的操作必须按此顺序排列；操作项之间用 `|` 分隔，颜色规范：删除/关闭类用 error 色
5. **业务状态去冗余**：无跨角色审批流时砍掉中间态（如"待提交""已暂存"），只保留有业务意义的终态
6. **弹窗层级规范**：严格区分 L0 页面、L1 侧滑窗、L2 居中弹窗、L3 确认弹窗，蒙版不穿透

## 技术栈要求（后台/B 端原型）

采用 **scaffold 源文件 + build 构建** 工作流，公共资产集中维护、源文件干净、产物单文件可分发。

### scaffold 体系（位于 `assets/scaffold/`）

| 文件 | 职责 |
|------|------|
| `proto-base.css` | 公共基线：`:root` 变量、布局骨架（78/22 分栏）、顶栏、侧边栏、卡片、表格、Tag、详情页组件、时间线、响应式 |
| `proto-sidebar-admin.html` | 标准侧边栏 HTML 片段（含 logo、菜单组、data-href 跳转、折叠按钮） |
| `proto-connect.js` | 标注交互：自动标记当前页 active、Pin 红点标注、hover 高亮、侧边栏折叠 |
| `build.sh` | 把 `.src.html` 的占位符替换为公共资产，生成单文件 `.html` |
| `examples/` | 4 个代表性页面源文件（列表/表单/详情/看板），复制改造用 |

### 源文件写法（`.src.html`）

源文件用三个占位符标记公共资产插入点，AI 只写页面特有内容：

```html
<head>
  ...
  <!-- SCAFFOLD:CSS -->      ← build 时内联 proto-base.css
  <style>/* 本页特有样式 */</style>
</head>
<body>
  <div class="app-container">
    <div class="main-content">
      <!-- SCAFFOLD:SIDEBAR -->  ← build 时内联标准侧边栏
      ...页面主体...
    </div>
    <div class="doc-panel">...功能说明...</div>
  </div>
  <!-- SCAFFOLD:JS -->        ← build 时内联 proto-connect.js
</body>
```

### 构建与交付

```bash
# 在目标版本的 04-原型/ 目录下（需先把 _scaffold/ 复制进去）
./_scaffold/build.sh          # 构建全部 *.src.html
./_scaffold/build.sh AD1      # 只构建匹配 AD1*.src.html 的页面
```

产物是单文件 `.html`（去掉 `.src`），所有 CSS/HTML/JS 内联，可直接双击打开或分发。**交付产物，不交付源文件**。

### 其他端态（非后台）

- 门户/C端：读本 skill `assets/design/web门户-design.md`，单文件 HTML + Tailwind，不走 scaffold
- 移动端H5：读本 skill `assets/design/手机端-design.md`，单文件 HTML
- 数据大屏：深色底 + ECharts，单文件 HTML

### 主色查询规则（画原型前第一步，必执行）

主色由项目决定，按优先级查询：

1. 读项目 `00-项目总览.md` 或 `01-项目基线/设计规范.md`，取项目品牌色
2. 项目无明确主色时，读该端既有原型 CSS 变量（如 `--brand`）
3. 两者都查不到，用 scaffold 默认 `--brand: #1E63B2`（可按项目改为 `#1677FF` 等）
4. 找到后修改 `proto-base.css` 的 `:root` 中 `--brand` 三档变量（brand / brand-hover / brand-bg）

> scaffold 的 proto-base.css 默认主色 #1E63B2（政务蓝，取自首个应用项目）。新项目应在项目本地复制 scaffold 后改主色，不改 skill 源文件。

## 布局规范

- **左右分栏**：左侧产品界面 78%，右侧功能说明 22%（scaffold 已内置，`.main-content` + `.doc-panel`）
- **独立滚动**：左右两栏各自独立滚动
- **右侧说明区**：琥珀色系（`--amber-bg: #FFFBEB` + `--amber-border: #fde68a`）
- **标注方案**：Pin 红色圆点标注（`data-proto-id` + `data-proto-desc`）。被标注元素右边缘贴红点圆标，hover 与右侧说明项联动高亮。**不画连线**。技术细节见 `assets/workflows/pin-technical.md`，`assets/annotation-demo.html` 是效果演示

## 样式与视觉规范

scaffold 的 proto-base.css 已固化完整规范（slate 色阶、卡片、表格、Tag、详情组件等）。关键参数：

- 功能色：success #52C41A、warning #FAAD14、error #F5222D、info #1890FF
- 字体：`-apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif`
- 表格：表头 #F6F6F6、斑马纹 #FBFBFC、hover 主色浅底
- Tag 六色：orange/blue/purple/green/red/gray，语义映射见 proto-base.css 注释

完整 antd v5 Token 对照见 `assets/tokens/antd-tokens.md`（proto-base.css 的功能色已对齐 antd，主色按项目调整）。

## 多页面系列规则

scaffold 的 proto-sidebar-admin.html 含标准侧边栏，proto-connect.js 的 `markActiveSidebar()` 根据当前页 URL 自动高亮。多页面共用同一侧边栏，菜单项用 `data-href` 指向各页文件名，新增页面时同步更新侧边栏文件。

## 参考实现

**scaffold 体系（后台/B 端必用）：**
- `assets/scaffold/proto-base.css` — 公共基线（变量、布局、组件）
- `assets/scaffold/proto-sidebar-admin.html` — 标准侧边栏
- `assets/scaffold/proto-connect.js` — 标注交互 + 侧边栏逻辑
- `assets/scaffold/build.sh` — 源文件构建脚本
- `assets/scaffold/examples/list-page.src.html` — 列表页参考
- `assets/scaffold/examples/form-page.html` — 表单页参考
- `assets/scaffold/examples/detail-page.html` — 详情页参考
- `assets/scaffold/examples/dashboard-page.src.html` — 看板页参考

**按场景触发读取的流程文档（`assets/workflows/`）：**
- `iteration.md` — 改已有原型时读（六步迭代工作流）
- `delivery-checklist.md` — 交付前读（自查清单）
- `pin-technical.md` — 实现标注时读（Pin 红点标注技术要点）

**辅助资产：**
- `assets/tokens/antd-tokens.md` — antd v5 Token 速查
- `assets/snippets/pin-annotation.js` — 旧版 Pin 标注脚本（scaffold 版已含，仅留作参考）
- `assets/annotation-demo.html` — 标注方案演示（单文件版，非 scaffold）
