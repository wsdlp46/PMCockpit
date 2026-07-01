# web后台 设计基线

> 适用于：B端管理后台、运营平台、内部配置系统
> 默认主色 #1E63B2，可被项目自定义色覆盖
> 样式参照：<项目名>管理后台、<项目名>管理运营端

---

## 一、布局

| 参数 | 值 |
|------|-----|
| 侧边栏宽度 | 200px |
| 侧边栏背景 | #FFFFFF |
| 侧边栏右边框 | 1px solid #f0f0f0 |
| 内容区内边距 | 20px |
| 页面背景 | #F5F5F5 |
| 最小宽度 | 1280px（内容区 ≥1080px） |

---

## 二、色值

### 主色与文字

| 用途 | 色值 |
|------|------|
| 主色（primary） | #1E63B2 |
| 主色hover | #174D8A |
| 主色浅底 | rgba(30,99,178,0.04 ~ 0.1) |
| 标题文字 | #1F1F1F |
| 正文文字 | #333333 |
| 辅助文字 | #666666 |
| 占位/禁用 | #909399 / #C0C4CC |
| 边框 | #E5E5E5 |

### 功能色

| 状态 | 色值 | 淡底 |
|------|------|------|
| 成功/已发布 | #52C41A / #009965 | #E6F7EE |
| 警告/待审核 | #FAAD14 / #E07000 | #FFFBE6 / #FFF3E0 |
| 错误/已驳回 | #F5222D / #FF4D4F | #FFF1F0 |
| 禁用/草稿 | #D9D9D9 / #9CA3AF | #F5F5F5 |

---

## 三、字体

| 用途 | 字号 | 字重 |
|------|:---:|:---:|
| 页面标题 | 16px | 600 |
| 模块标题 | 14px | 500 |
| 表格表头 | 13px | 600 |
| 表格内容 | 13px | 400 |
| 表单label | 13px | 500 |
| 输入框内文字 | 13px | 400 |
| 注释/提示 | 12px | 400 |
| 按钮 | 12px | 400 |

---

## 四、侧边栏菜单

| 参数 | 值 |
|------|------|
| 菜单项内边距 | 10px 20px |
| 菜单项字号 | 13px |
| 默认文字色 | #666666 |
| hover背景 | rgba(30,99,178,0.06) |
| hover文字色 | #1E63B2 |
| active背景 | rgba(30,99,178,0.1) |
| active左边框 | 3px solid #1E63B2 |
| active文字色+字重 | #1E63B2, 500 |
| 图标间距 | 8px |

---

## 五、表格

| 参数 | 值 |
|------|------|
| 表头背景 | #F6F6F6 |
| 表头文字 | 13px, 600, #333 |
| 单元格内边距 | 10px 16px |
| 奇数行背景 | #FFFFFF |
| 偶数行背景 | #FBFBFC |
| 行hover背景 | rgba(30,99,178,0.04) |
| 行底边框 | 1px solid #f5f5f5 |
| 表格容器 | bg #fff, border-radius 8px, border 1px #f0f0f0 |

---

## 六、表单

| 参数 | 值 |
|------|------|
| label布局 | 顶置（display:block） |
| label字号+间距 | 13px, 500, margin-bottom 5px |
| input高度 | 36px（8px上下padding + 1px边框） |
| input内边距 | 8px 12px |
| input边框 | 1px solid #E5E5E5 |
| input圆角 | 4px |
| input聚焦 | border #1E63B2, box-shadow 0 0 0 3px rgba(30,99,178,0.1) |
| textarea最小高 | 80px（可调 resize:vertical） |
| 必填标记 | `<span style="color:#F5222D;">*</span>` |
| 表单组间距 | margin-bottom 14px |
| 日期选择 | 原生 `<input type="date">` |

---

## 七、按钮

| 类型 | 样式 |
|------|------|
| primary | bg #1E63B2, color #fff, border none |
| outline | bg #fff, color #1E63B2, border 1px #1E63B2 |
| outline hover | bg #EBF4FF |
| danger | bg #fff, color #F5222D, border 1px #F5222D |
| danger hover | bg #FFF1F0 |
| sm尺寸 | padding 6px 14px, font-size 12px, border-radius 4px |
| active效果 | opacity 0.85 或 hover变深 |

---

## 八、弹窗

| 层级 | z-index | 用途 | 规格 |
|:---:|:---:|------|------|
| L2 弹窗 | 1050 | 新增/编辑 | 480-560px宽, bg #fff, 圆角8px, 内边距24px, 头部16px粗体 |
| L3 确认 | 1100 | 删除确认 | 400px宽, 居中, 警告图标40px #FAAD14 |
| 遮罩 | — | 半透明黑底 | background rgba(0,0,0,0.6), 覆盖全屏 |
| 关闭方式 | — | — | 点击遮罩或取消按钮 |

---

## 九、右侧注释面板

B端原型特有的右侧设计说明区：

| 参数 | 值 |
|------|------|
| 面板宽度 | 25% 或 380px |
| 面板背景 | #FFFBEB |
| 面板左边框 | 4px solid #F59E0B |
| 面板内边距 | 24px |
| 面板标题 | 16px, bold, #92400E |
| 说明条目 | 13px, #78350F, line-height 1.7 |
| 标注卡片 | 12px, bg #FEF3C7, padding 10px 12px, 左边框3px #F59E0B |
| proto-element hover | box-shadow 0 0 0 2px #1E63B2, bg rgba(30,99,178,0.03) |
| SVG连线 | stroke #1E63B2, width 2px, opacity 0.6 |

---

## 关联案例

> 详见 `03知识库/工作案例库/`

| 案例 | 项目 | 关键复用点 |
|------|------|-----------|
| <项目名>管理后台 | <项目名> | 列表页+侧滑窗+弹窗三级结构、导入/导出按钮聚合 |
| <项目名>管理后台 | <项目名> | 多模块侧边栏导航、数据表格+筛选器布局 |
| <项目名>后台 | <项目名> | 三页面侧边栏统一含跳转链接、资讯管理列表 |
