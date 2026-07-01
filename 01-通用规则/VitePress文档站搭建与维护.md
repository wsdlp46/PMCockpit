# VitePress 文档站搭建与维护

> 将项目 MD 文档和 HTML 原型部署为带鉴权的在线文档站，支持按版本组织、密码保护、增量更新。
>
> **创建日期**：2026-06-21 ｜ **技术栈**：VitePress 1.6 + Express + PM2 + rsync
> **首个应用案例**：<项目名>文档站（<服务器IP>:<端口>）

---

## 一、适用场景

- 需要把项目的需求文档、原型设计、知识库**在线共享**给同事/客户
- 需要**密码保护**，不同人看不同内容
- 内容以 **Markdown 文档 + HTML 交互原型**为主
- 服务器资源有限，希望**零成本**（GitHub Pages 免费 或 一台云服务器）

---

## 二、架构

```
本地 Mac                        云服务器
┌──────────────────┐           ┌───────────────────────────┐
│ docs-site/       │  rsync   │ /root/docs-site/           │
│ ├── .vitepress/  │ ──────→  │  ├── .vitepress/dist/  ←── npm run build
│ ├── versions/    │  同步    │  ├── server/            ←── PM2 守护(:端口)
│ ├── prototypes/  │  源码    │  │   ├── auth.js  ←── 密码
│ ├── public/      │          │  │   └── index.js
│ └── server/      │          │  └── ecosystem.config.cjs
└──────────────────┘           └───────────────────────────┘
                                        │
                                 用户浏览器访问
                                   → 输密码 → Cookie 鉴权 → 看内容
```

**三层结构**：
1. **VitePress** —— 把 MD 渲染成静态 HTML 站点
2. **Express 服务** —— 托管静态文件 + Cookie 鉴权（保护内容不裸奔）
3. **PM2** —— 进程守护 + 开机自启

---

## 三、目录约定

| 目录 | 放什么 | 改了要不要 rebuild |
|------|--------|:-----------------:|
| `guide/` | 项目概述、通用规范等顶层文档（.md） | ✅ |
| `versions/vX.Y.Z/` | 按版本组织的需求文档 + 规格文档（.md） | ✅ |
| `prototypes/` | 原型导航页（.md 列表页） | ✅ |
| `public/prototypes/` | **HTML 原型文件本身**（静态资源） | ❌ |
| `.vitepress/config.mts` | 侧边栏、导航、构建配置 | ✅ |
| `server/auth.js` | 登录密码 | ❌（重启即可） |
| `server/index.js` | 鉴权服务代码 | ❌（重启即可） |

---

## 四、日常维护场景

### 场景 A：换原型 HTML（最高频）

原型是静态文件，**不需要 rebuild**，直接替换：

```bash
# 复制到 public 目录
cp "源目录/某页面-原型.html" docs-site/public/prototypes/<项目>/HTML/

# 只同步 public/ 到服务器即可
rsync -az -e "ssh -i <密钥> ..." \
  docs-site/public/ root@<IP>:/root/docs-site/public/
```

### 场景 B：改文档内容

```bash
vi docs-site/versions/v1.0.0/某文档.md
cd docs-site && npm run build    # 本地验证（有 dead link 会报错）
# → 完整部署（见第六节）
```

### 场景 C：从源目录导入新文档

```bash
# 1. 复制文件
cp "源目录/新文档.md" docs-site/versions/v1.0.0/specs/

# 2. ⚠️ 修复文档内的相对链接（关键）
#    源文档的 ../需求文档/xxx.md 必须改成 VitePress 绝对路径：
#    /versions/v1.0.0/requirements/xxx（去掉 .md 后缀）

# 3. 在 config.mts 侧边栏里加一条导航项

# 4. 构建验证 → 完整部署
```

### 场景 D：改密码

```bash
ssh ... root@<IP>
source ~/.nvm/nvm.sh
cd /root/docs-site
vi server/auth.js          # 改 ACCESS_PASSWORD
pm2 restart docs-site
```

### 场景 E：新增版本（含原型上架）

以源目录已有原型和文档为前提的完整流程：

```
1. 建目录：mkdir -p docs-site/versions/vX.Y.Z/{requirements,specs}

2. 建版本首页：versions/vX.Y.Z/index.md（含版本概述、交付物统计、需求清单）

3. 导入文档：
   - 复制需求文档到 requirements/，规格文档到 specs/
   - ⚠️ 修相对链接（坑3）：../需求文档/xxx.md → /versions/vX.Y.Z/requirements/xxx
   - 如目录无 index.md，创建一个

4. 导入原型（⚠️ 版本分目录，避免同名覆盖）：
   - mkdir -p public/prototypes/<项目>/vX.Y.Z/{HTML,小程序}
   - 复制原型 HTML，排除归档端（如 R3/U3）
   - 创建 prototypes/vX.Y.Z.md（按端分组，新增/优化标注跟在链接后）

5. 更新 config.mts 侧边栏（⚠️ 坑11：4 处全改）：
   - sideDoc() 加版本组（文档侧边栏）
   - /prototypes/ sidebar 加一条（原型侧边栏）
   - 新版排最上面（最新在上），旧版 collapsed:true

6. 更新入口页：guide/index.md、prototypes/index.md 的版本表格/列表

7. 构建验证（npm run build，修 dead link）→ 完整部署
```

**原型标注规范**：新版原型页按端分组列全部原型，不单独分组。相对上版的变化用行内标注跟在链接后：

```markdown
- [O2g-代理分组管理](/prototypes/.../O2g-代理分组管理-原型.html) `新增 V1-2`
- [O2-代理管理](/prototypes/.../O2-代理管理-原型.html) `优化 V1-2`
```

判断方法：规格文件名含「变更规格」= 优化（已有页面改版），含「原型设计规格」= 新建页面。

### 场景 F：多项目部署（物理隔离）

每个项目独立一套站点，各自端口、各自密码、各自目录。解决同站多项目的内容泄露问题（坑9）。

```
<服务器IP>:9900  → <项目A>站          密码 <项目A密码>
<服务器IP>:9901  → <项目B>站          密码 <项目B密码>
<服务器IP>:9902  → <项目C>站          密码 <项目C密码>
```

每站复制现有站结构，改 4 样：config.mts 的 title、auth.js 的密码、ecosystem.config.cjs 的 PORT+name、文档和原型内容。

> ⚠️ 内存限制：每站 ~65MB，服务器内存 2G 建议最多 4 个站。超过需升级内存或改 Nginx 统一代理方案。

---

## 五、部署命令模板

```bash
KEY="<密钥路径>"
IP="<服务器IP>"
DOCS="<docs-site 路径>"

# 1. 本地构建验证
cd "$DOCS" && npm run build

# 2. 同步源码到服务器
rsync -az --delete \
  -e "ssh -i $KEY -o BatchMode=yes -o IdentitiesOnly=yes -o PubkeyAcceptedAlgorithms=+ssh-rsa" \
  --exclude='node_modules/' --exclude='.git/' --exclude='.vitepress/dist/' \
  --exclude='.vitepress/cache/' --exclude='.DS_Store' \
  "$DOCS/" root@$IP:/root/docs-site/

# 3. 服务器重建 + 重启
ssh -i "$KEY" -o BatchMode=yes -o IdentitiesOnly=yes \
    -o PubkeyAcceptedAlgorithms=+ssh-rsa root@$IP \
    'source ~/.nvm/nvm.sh; cd /root/docs-site; npm run build; pm2 restart docs-site'
```

> 只换原型 HTML 时，跳过第 1、3 步，只跑第 2 步。

---

## 六、已知坑（踩过记下，换项目也会遇到）

| # | 坑 | 规则 |
|---|-----|------|
| 1 | **原型点不开 404** | 原型链接必须 `target="_blank"`（config.mts 的 markdown 插件自动加），否则 VitePress SPA 路由会拦截，把静态 HTML 当内部页面处理 |
| 2 | **构建报 dead link** | 指向 `public/` 下 `.html` 的链接不是 markdown 页面，需配 `ignoreDeadLinks` 正则跳过，否则构建失败 |
| 3 | **文档间链接断裂** | 源文档的相对链接 `../需求文档/xxx.md` 必须改成 VitePress 绝对路径 `/versions/.../xxx`（去掉 .md） |
| 4 | **`_index.md` 不识别** | VitePress 目录首页必须叫 `index.md`，不是 `_index.md`（那是 Docusaurus 约定） |
| 5 | **SSH Permission denied** | 密钥权限必须 600：`chmod 600 xxx.pem`；macOS 新版 OpenSSH 需加 `-o PubkeyAcceptedAlgorithms=+ssh-rsa` |
| 6 | **pm2 里 node 找不到** | 服务器用 nvm 时，非交互 shell 要先 `source ~/.nvm/nvm.sh` |
| 7 | **pm2 restart 不加载新配置** | 改了 `ecosystem.config.cjs`（端口/环境变量）要 `pm2 delete <name> && pm2 start`，不能只 restart |
| 8 | **密码泄露到 GitHub** | `server/auth.js` 含明文密码，仓库若公开**绝不 push**，全程 rsync 传服务器 |
| 9 | **多项目隔离失效** | VitePress 是静态站，所有内容编译进 bundle，服务端按路径拦截无法阻止 chunk 内正文泄露。**严格隔离必须物理分站点**，不能靠同站密码区分 |
| 10 | **删项目后残留** | 删项目内容后检查 config.mts 的 title/nav/footer/sidebar，以及首页 index.md，确保无残留泄露 |
| 11 | **改版本后侧边栏只改了一处** | config.mts 里侧边栏分两个独立区——`/guide/`+`/versions/` 共用 sideDoc()（文档侧），`/prototypes/` 单独数组（原型侧）。改版本时 **4 处全改**：sideDoc()、/prototypes/ sidebar、guide/index.md、prototypes/index.md。改完 grep 自查：`grep -n "旧文字" config.mts guide/index.md prototypes/index.md` |
| 12 | **原型版本覆盖** | 不同版本原型同名（如 V1.0.0 和 V1.0.1 都有 E0），必须按版本分目录存储 `public/prototypes/<项目>/vX.Y.Z/`，否则后上传的覆盖前者 |

---

## 七、config.mts 关键配置项

```ts
// base 路径：GitHub Pages 用 /repo-name/，自部署用 '/'
const SITE_BASE = process.env.VITEPRESS_BASE ?? '/'

export default defineConfig({
  base: SITE_BASE,

  // 坑2：跳过原型 HTML 的 dead link 检查
  ignoreDeadLinks: [/^\/prototypes\/.*\.html$/],

  // 坑1：给原型链接加 target=_blank，绕过 SPA 路由
  markdown: {
    config(md) {
      const defaultLinkOpen = md.renderer.rules.link_open
      md.renderer.rules.link_open = (tokens, idx, options, env, self) => {
        const hrefIndex = tokens[idx].attrIndex('href')
        if (hrefIndex >= 0) {
          const href = tokens[idx].attrs[hrefIndex][1]
          if (href.startsWith('/prototypes/') && href.endsWith('.html')) {
            if (tokens[idx].attrIndex('target') < 0) {
              tokens[idx].attrPush(['target', '_blank'])
              tokens[idx].attrPush(['rel', 'noreferrer'])
            }
          }
        }
        return defaultLinkOpen
          ? defaultLinkOpen(tokens, idx, options, env, self)
          : self.renderToken(tokens, idx, options)
      }
    }
  },
  // ...
})
```

---

## 八、服务器初始化（从零搭建时用）

```bash
# 1. 装 Node（用 nvm）
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.nvm/nvm.sh
nvm install 22

# 2. 装 PM2
npm install -g pm2

# 3. 拉代码 + 安装 + 构建
git clone <仓库> docs-site && cd docs-site
npm ci && npm run build
cd server && npm ci && cd ..

# 4. 配置 ecosystem.config.cjs（端口、SESSION_SECRET）
#    SESSION_SECRET 用 openssl rand -hex 32 生成

# 5. 启动 + 开机自启
pm2 start ecosystem.config.cjs
pm2 save && pm2 startup    # 按提示执行返回的命令

# 6. 防火墙/安全组放行端口
```

---

## 九、部署实例（脱敏参考）

部署实例含服务器地址、密钥路径、密码等敏感信息，不纳入通用规则。每个团队按自身服务器环境填写以下模板：

| 项 | 值 |
|----|-----|
| 项目 | <项目名> |
| 地址 | http://<服务器IP>:<端口> |
| 服务器 | <服务器型号与系统>，root@<服务器IP> |
| 密钥 | `<密钥文件路径>`（权限 600） |
| 密码 | `<站点访问密码>`（在 server/auth.js 改） |
| Node | v22+（nvm 管理） |
| 文档 | <版本与内容统计> |
| 内容隔离 | 单一密码保护，站点只含单个项目内容。多项目需分站点部署（场景F） |

---

*创建：2026-06-21 ｜ 最后更新：2026-06-21 ｜ 作者：ZCode*
