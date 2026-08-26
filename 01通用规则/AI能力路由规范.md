# AI 能力路由规范

> 本文件是 PMCockpit 发行版的 Skill 清单、冲突裁决和回归语句权威源。权限、MCP 与安装规则见《AI能力治理规范》和 `.ai/TOOL-MAPPING.md`。

## 一、核心 Skill 清单

<!-- skill-inventory:start -->
`prd-writer` `project-intake-pm` `project-iteration` `project-retrospective-pm` `proto-spec-generator` `prototype-html-pin` `research-pm` `tapd-requirement-upload`
<!-- skill-inventory:end -->

`solution-designer` 是仅由 ZCode 链接的专用 Agent。它只能使用本仓库已存在的通用方法、模板和使用者自建案例；没有命中案例时必须明确说明，不得虚构历史经验。

`test-flow-pm` 与 `vitepress-deploy` 是可选能力，不在默认清单内。测试仅在执行 `bash .ai/install.sh --with-test` 后参与任务路由；VitePress 还要求已有独立站点，并执行 `bash .ai/install.sh --with-vitepress`。

## 二、冲突裁决与固定回归语句

同一请求出现多个关键词时，以用户直接要交付的产物、已满足的前置条件和以下裁决为准；不能因词面命中跳过确认门。

| 编号 | 路由语句 | 目标能力 | 裁决 |
|---|---|---|---|
| R01 | 在既有“数据治理平台”项目中启动 V1.0.0。 | `project-iteration` | 仅既有项目的新版本、收尾或索引请求；新建项目不命中。 |
| R02 | 将本周会议纪要入库到数据治理平台 V1.0.0。 | `project-intake-pm` | 归属明确的新材料或会议记录；项目创建和版本创建不命中。 |
| R03 | 对数据治理平台的目标客户、市场、行业政策或竞品开展调研，形成决策依据。 | `research-pm` | 需要外部或多源证据、比较和判断的调研任务；普通材料整理不命中。 |
| R04 | 为已确定主题撰写 V1.0.0 PRD。 | `prd-writer` | 交付物为需求文档；规格、原型、方案分别走 R06、R07、专用 Agent。 |
| R05 | 依据已确认 PRD 写数据治理平台的业务建设方案。 | `solution-designer` | 方案设计；无本地案例命中时按用户输入和通用方法设计，并说明限制。 |
| R06 | 按已确认 PRD，为管理后台逐页编写原型设计规格。 | `proto-spec-generator` | 页面规格；规格未确认不得转入 R07。 |
| R07 | 依据已确认页面规格，生成带 Pin 标注的单文件 HTML 原型。 | `prototype-html-pin` | 仅交互式 HTML 原型，不处理真实业务前端或组件抽取。 |
| R09 | 基于已确认 PRD 生成 TAPD 需求规划，先不要上传。 | `tapd-requirement-upload` | TAPD 规划或上传事务；外部写入仍逐条确认。 |
| R10 | 版本完成后复盘本次交付并沉淀改进项。 | `project-retrospective-pm` | 复盘、经验沉淀或工作流改进；不替代普通项目收尾。 |

### 可选路由

| 编号 | 路由语句 | 目标能力 | 前置条件 |
|---|---|---|---|
| O01 | V1.0.0 已提测，请输出用例并执行冒烟测试。 | `test-flow-pm` | 已执行 `--with-test`，且版本已提测或用户明确要求测试。 |
| O02 | 已确认原型，请 dry-run 同步到现有 VitePress 文档站。 | `vitepress-deploy` | 已执行 `--with-vitepress`，且用户已提供独立站点路径与授权范围。 |
