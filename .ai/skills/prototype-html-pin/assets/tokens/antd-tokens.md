# antd v5 Design Token 速查（原型用）

> 数据源：`npx @ant-design/cli@latest token --version 5` + `design.md`（2026-07-08 核对）。
> **版本号不要凭记忆写**——使用前用 `npm view antd version` 或 `npm view @ant-design/icons version` 实查。本文件的颜色值是稳定的（antd v5 Token 不会变），但配套库的版本号会更新。
> 主色未特殊说明时为 antd 默认 #1677FF；项目有品牌色时由 ConfigProvider 覆盖。

## 色板（Map Tokens，由 Seed Token 派生）

### 主色梯度（colorPrimary 系列）
| Token | 默认值 | 用途 |
|-------|--------|------|
| colorPrimary | `#1677FF` | 主色，按钮/链接/选中态 |
| colorPrimaryHover | `#4096FF` | 主色 hover |
| colorPrimaryActive | `#0958D9` | 主色 active |

### 功能色
| Token | 默认值 | 用途 |
|-------|--------|------|
| colorSuccess | `#52C41A` | 成功（绿色 Tag、Result 成功态） |
| colorWarning | `#FAAD14` | 警告 |
| colorError | `#FF4D4F` | 错误（红色 Tag、必填星号、校验失败） |
| colorInfo | `#1677FF` | 信息提示（同主色） |

### 中性色（文本/背景/边框）
| Token | 默认值 | 用途 |
|-------|--------|------|
| colorText | `rgba(0,0,0,0.88)` | 一级文本（最深） |
| colorTextSecondary | `rgba(0,0,0,0.65)` | 二级文本 |
| colorTextTertiary | `rgba(0,0,0,0.45)` | 三级文本/占位符 |
| colorTextQuaternary | `rgba(0,0,0,0.25)` | 四级文本（禁用） |
| colorBgContainer | `#FFFFFF` | 组件容器背景（按钮默认底、输入框底） |
| colorBgLayout | `#F5F5F5` | 页面整体背景（B1 视觉层级） |
| colorBgElevated | `#FFFFFF` | 浮层背景（Modal、Dropdown） |
| colorBorder | `#D9D9D9` | 一级边框（输入框、卡片分割线） |
| colorBorderSecondary | `#F0F0F0` | 二级边框（更浅，表格行分隔） |
| colorSplit | `#F0F0F0` | 分割线 |

## 字体（Typography）

| Token | 默认值 | 用途 |
|-------|--------|------|
| fontFamily | `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, 'Noto Sans', sans-serif` | 全局字体栈 |
| fontSize | `14` | 基础字号（正文，body-md） |
| fontSizeLG | `16` | 大号 |
| fontSizeSM | `12` | 小号（辅助说明、Tag） |
| fontSizeHeading1 | `38` | H1 |
| fontSizeHeading2 | `30` | H2 |
| fontSizeHeading3 | `24` | H3 |
| fontSizeHeading4 | `20` | H4 |
| fontSizeHeading5 | `16` | H5 |
| lineHeight | `1.5715` | 正文行高（约 22px / 14px） |
| lineHeightHeading | `1.235` | 标题行高 |

## 圆角（borderRadius）

| Token | 默认值 | 用途 |
|-------|--------|------|
| borderRadius | `6` | 默认圆角（按钮、输入框、卡片） |
| borderRadiusLG | `8` | 大圆角（Card、Modal） |
| borderRadiusSM | `4` | 小圆角（小尺寸控件） |
| borderRadiusXS | `2` | 超小圆角（内部元素） |

## 间距与尺寸

| Token | 默认值 | 用途 |
|-------|--------|------|
| sizeUnit / sizeStep | `4` | 尺寸基本单位（4 的倍数） |
| margin | `16` | 外边距默认 |
| marginXS | `8` | |
| marginSM | `12` | |
| marginLG | `24` | |
| marginXL | `32` | |
| padding | `16` | 内边距默认 |
| paddingXS | `8` | |
| paddingSM | `12` | |
| paddingLG | `24` | |

## 控件高度（controlHeight 系列）

| Token | 默认值 | 用途 |
|-------|--------|------|
| controlHeight | `32` | 默认控件高度（按钮、输入框） |
| controlHeightLG | `40` | 大尺寸 |
| controlHeightSM | `24` | 小尺寸 |
| controlHeightXS | `16` | 超小 |

## 线条

| Token | 默认值 | 用途 |
|-------|--------|------|
| lineWidth | `1` | 边框宽度 |
| lineType | `solid` | 线型 |

---

## B 轨速查（Tailwind + 手写 CSS 对齐用）

老页面（2026-07-08 前已存在）不引入 React，但必须对齐以下参数。以下为 CSS 变量形式，可直接复制到 `<style>`：

```css
:root {
  /* 主色——由项目决定，此处为 antd 默认值，实际用 ConfigProvider 或手动改 */
  --color-primary: #1677FF;
  --color-primary-hover: #4096FF;
  --color-primary-active: #0958D9;

  /* 功能色 */
  --color-success: #52C41A;
  --color-warning: #FAAD14;
  --color-error: #FF4D4F;

  /* 文本 */
  --color-text: rgba(0,0,0,0.88);
  --color-text-secondary: rgba(0,0,0,0.65);
  --color-text-tertiary: rgba(0,0,0,0.45);
  --color-text-disabled: rgba(0,0,0,0.25);

  /* 背景 */
  --color-bg-container: #FFFFFF;
  --color-bg-layout: #F5F5F5;
  --color-bg-elevated: #FFFFFF;

  /* 边框 */
  --color-border: #D9D9D9;
  --color-border-secondary: #F0F0F0;

  /* 圆角 */
  --border-radius: 6px;      /* 默认 */
  --border-radius-lg: 8px;   /* Card/Modal */
  --border-radius-sm: 4px;

  /* 控件高度 */
  --control-height: 32px;
  --control-height-lg: 40px;
  --control-height-sm: 24px;

  /* 字号 */
  --font-size: 14px;
  --font-size-lg: 16px;
  --font-size-sm: 12px;
  --line-height: 1.5715;

  /* 间距 */
  --spacing-unit: 4px;
  --margin: 16px;
  --padding: 16px;
}
```

## Tag 配色对照（列表状态标签高频用）

antd v5 的 Tag `color` 属性接受预设色名或自定义色值。状态标签推荐映射：

| 业务语义 | Tag color | 色值 | 背景 |
|---------|-----------|------|------|
| 成功/有效/已通过 | `success` | `#52C41A` | `#F6FFED` |
| 处理中/进行中 | `processing` | `#1677FF` | `#E6F4FF` |
| 警告/待处理 | `warning` | `#FAAD14` | `#FFFBE6` |
| 错误/失败/驳回 | `error` | `#FF4D4F` | `#FFF2F0` |
| 默认/中性/草稿 | `default` | `rgba(0,0,0,0.65)` | `#FAFAFA` |

> Tag 底色是功能色的浅色背景变体，无需手动调，直接用预设色名即可。
