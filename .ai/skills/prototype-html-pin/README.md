# prototype-html-pin

让产品经理用自然语言生成可交互 HTML 原型的 AI Skill，采用**数字编号圆点标注**替代传统 SVG 连线，解决连线交叉、偏移、远距离不可读的痛点。

> 基于 [vagerent/prototype-html](https://github.com/vagerent/prototype-html)（Apache 2.0）深度改造。

## 改进点

| 维度 | 原版（SVG 贝塞尔线） | Pin 版（编号圆点） |
|------|----------------------|-------------------|
| 标注方式 | 跨左右分栏画 SVG 贝塞尔曲线 | 统一红色数字圆点贴在标注目标上 |
| 交叉问题 | 超过 4 条线即纠缠不清 | 永不交叉 |
| 滚动偏移 | resize/滚动后线常对不齐 | `position: fixed` + 实时重算，始终准确 |
| 截图友好 | 线条遮挡界面元素 | 圆点极小，且支持一键隐藏 |
| 打印/存档 | 线条可能丢失 | 纯 DOM 元素，稳定可靠 |

## 输入

可直接用自然语言描述需求，也可配合 [proto-spec-generator](https://github.com/wsdlp46/proto-spec-generator) 产出的标准化规格文档生成更严谨的原型。

> 完整产品工作流建议搭配 [pm-assistant-lrw](https://github.com/wsdlp46/pm-assistant-lrw) Expert，一站式覆盖 PRD → 方案 → 规格 → 原型。

## 新增能力

- **标签显隐开关**：右侧面板一键隐藏所有标注圆点，适合截图展示纯界面
- **多状态组件演示**：右侧说明区嵌入状态切换按钮，点击即可切换左侧组件的不同视觉状态（如认证卡片：已认证/未认证/认证中/已过期）
- **说明文档同步检查**：迭代页面时自动提醒检查右侧说明是否过时
- **原型迭代闭环**：修改已有原型时自动归档旧版、边改边记变更笔记、经防遗漏清单检查后，生成回写清单更新关联的规格文档和需求文档，确保原型与文档始终同步

## 效果演示

打开 `assets/annotation-demo.html` 即可在浏览器中看到完整效果——

- 左侧：数据资源管理后台列表页，5 个红色数字圆点贴在各自的标注目标上
- 右侧：琥珀色功能说明面板，同号圆点一一对应
- 交互：悬停双向高亮、状态切换按钮、标签显隐开关

## 安装

复制到 AI 工具的 skills 目录：

```bash
# 推荐：使用仓库根目录安装脚本（自动创建软链接）
cd ~/Skills && bash install.sh

# 或手动复制到工具的 skills 目录
cp -r prototype-html-pin ~/.workbuddy/skills/
```

适用于任何支持 Skill 机制的 AI 工具（如 CodeBuddy、WorkBuddy、Cursor 等）。

## 目录结构

```
prototype-html-pin/
├── SKILL.md                  # Skill 指令（给 AI 读的工作手册）
├── README.md                 # 本文件（给人读）
└── assets/
    ├── annotation-demo.html  # Pin 标注方案完整演示
    └── example.html          # 参考布局示例
```

## 许可

Apache 2.0 — 与原项目保持一致。

## 作者

微信公众号：青燃AI说
