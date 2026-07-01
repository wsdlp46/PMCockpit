---
name: vitepress-deploy
description: >-
  Deploy and maintain a VitePress documentation site with Node-based auth and rsync server deployment.
  Use this skill whenever the user mentions deploying docs, syncing to server, fixing VitePress build
  errors (dead links, 404 on prototypes), managing auth passwords, adding versions, or troubleshooting
  a VitePress + Express + PM2 site — even if they don't explicitly say "vitepress-deploy". Also triggers
  on phrases like "文档站部署", "原型打不开", "build 报错", "改密码", "同步到服务器", "pm2".
---

# VitePress 文档站部署与维护

本 skill 用于维护采用「VitePress 静态站点 + Express 鉴权服务 + PM2 守护 + rsync 部署」架构的文档站。支持文档增改、原型更新、密码管理、版本迭代、故障排查。

## 架构判断

开始前先确认站点的技术栈组合。典型形态：

- **VitePress** 渲染 MD → 静态 HTML
- **Express 服务**（`server/index.js`）托管静态文件 + Cookie 鉴权
- **PM2**（`ecosystem.config.cjs`）进程守护 + 开机自启
- **rsync** 同步本地源码到服务器，服务器上 `npm run build`

如果用户的项目只是纯 VitePress（GitHub Pages，无鉴权），跳过鉴权相关部分。

## 常用速查

| 做什么 | 改哪里 | 要 rebuild？ | 要重启 PM2？ |
|--------|--------|:----------:|:-----------:|
| 改密码 | `server/auth.js` | ❌ | ✅ |
| 换原型 HTML | `public/` 下替换文件 | ✅ | ✅ |
| 改文档内容（.md） | `versions/` 或 `guide/` 下的 .md | ✅ | ✅ |
| 改侧边栏结构 | `.vitepress/config.mts` | ✅ | ✅ |
| 改鉴权逻辑 | `server/index.js` | ❌ | ✅ |
| 改端口/环境变量 | `ecosystem.config.cjs` | ❌ | delete + start |

> **rebuild** = `npm run build`（本地或服务器上均可，最终生效在服务器上）
> 原型 HTML 是 public/ 下的静态资源，直接替换文件即生效，**不需要 build**。

## 部署命令模板

以下是完整的「改了源码 → 上线」流程。需要用户提供：服务器 IP、SSH 密钥路径、docs-site 目录路径。首次使用时询问，后续记忆。

```bash
KEY="<密钥路径>"
IP="<服务器IP>"
DOCS="<docs-site 路径>"

# 0. 【关键】如果原型文件在源项目目录，先同步到 docs-site
# cp "源项目/04-原型/HTML/O2-代理管理.html" "$DOCS/public/prototypes/<项目>/vX.Y.Z/HTML/"

# 1. 本地构建验证（有 dead link 会在这里报错）
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

> ⚠️ **原型 HTML 也需要 rebuild**：Express 服务的是 `.vitepress/dist/`，不是 `public/`。VitePress build 时会把 `public/` 文件拷贝进 `dist/`。只 rsync `public/` 不 rebuild，dist 里的旧文件不会被覆盖，用户看到的仍是旧版。

## 已知坑（遇到问题时逐条排查）

### 坑 1：原型 HTML 点击 404（最常见）

**症状**：原型导航页里点击链接，浏览器显示 404，但直接输入 URL 能访问。

**根因**：VitePress 是 SPA（单页应用），它的路由器会拦截同站 `<a>` 点击，尝试用客户端路由打开。但原型是 `public/` 下的静态 HTML、不在路由表里，所以 SPA 找不到 → 404。

**修复**：给指向原型的链接加 `target="_blank"`（新标签页打开绕过 SPA 路由）。在 `config.mts` 的 `markdown.config` 里配置插件自动添加：

```ts
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
}
```

> 判断逻辑按实际原型路径前缀调整（不一定都是 `/prototypes/`）。

### 坑 2：npm run build 报 dead link 失败

**症状**：`Found N dead link(s) found`，构建中断。

**根因**：VitePress 把指向 `public/` 下 `.html` 静态资源的链接当成 markdown 页面去校验，但静态文件不在页面索引里。

**修复**：在 `config.mts` 配 `ignoreDeadLinks`：

```ts
ignoreDeadLinks: [/^\/prototypes\/.*\.html$/],
```

> 只跳过指向 public 静态 HTML 的链接，真正的死链（笔误的 markdown 页面链接）仍会被检查。

### 坑 3：文档间相对链接断裂

**症状**：从源项目目录复制 MD 文档后，构建报 dead link，或页面上链接点不动。

**根因**：源文档里用相对路径引用其他文档（如 `../需求文档/xxx.md`），但导入到 VitePress 后目录结构变了，相对路径失效。

**修复**：把所有相对 `.md` 链接改成 VitePress 绝对路径：
- `../需求文档/<项目名>——MVP需求文档V1.md`
- → `/versions/v1.0.0/requirements/<项目名>——MVP需求文档V1.0.0`（去掉 `.md` 后缀，注意文件名要对上）

批量修复用 sed：
```bash
grep -rn '\.md)' versions/  # 先扫描看有哪些
find versions/v1.0.0/specs -name "*.md" -exec sed -i '' \
  's#旧路径#新路径#g' {} \;
```

### 坑 4：SSH Permission denied

**根因 A**：密钥文件权限不是 600。`chmod 600 <密钥路径>`。

**根因 B**：macOS 新版 OpenSSH（10.x）默认禁用 ssh-rsa 签名算法。需加参数：
```bash
ssh -i <密钥> -o IdentitiesOnly=yes -o PubkeyAcceptedAlgorithms=+ssh-rsa root@<IP>
```

**根因 C**：密钥和服务器不匹配。用 `ssh-keygen -y -f <密钥>` 导出公钥指纹，和服务器控制台的密钥指纹对比。

### 坑 5：pm2 里 node 命令找不到

**根因**：服务器用 nvm 安装 Node，非交互 SSH shell 不自动加载 nvm，PATH 里没有 node/pm2。

**修复**：SSH 命令前先 source nvm：
```bash
ssh ... root@$IP 'source ~/.nvm/nvm.sh; cd /root/docs-site; npm run build; pm2 restart docs-site'
```

### 坑 6：pm2 restart 不加载新配置

**根因**：改了 `ecosystem.config.cjs`（端口、环境变量），`pm2 restart` 不重新读取配置文件。

**修复**：`pm2 delete docs-site && pm2 start ecosystem.config.cjs`。

### 坑 7：多项目内容泄露

**症状**：登录后能看到不属于当前项目的文档内容。

**根因**：VitePress 是静态站，所有内容编译进 JS chunk。服务端按 URL 路径拦 HTML 页面可以（403），但 `.js` chunk 里的文档正文会被当成静态资源放行。

**修复**：**不要在同一个站点内做多项目隔离**。每个项目部署独立站点（独立 dist、独立进程、独立密码）。或者只放一个项目的内容，物理隔离。

### 坑 8：密码泄露到公开仓库

**根因**：`server/auth.js` 含明文密码，如果 git push 到 public 仓库，任何人都能看到。

**修复**：
- 把 `server/auth.js` 加入 `.gitignore`（或整个 server/ 目录）
- 部署用 rsync 直传服务器，不走 git push
- 或者仓库改私有

### 坑 9：改版本后侧边栏只改了一处

**症状**：新增/调整版本后，文档页侧边栏对了，但原型页侧边栏还是旧的（或反过来）。

**根因**：`config.mts` 里侧边栏分两个独立配置区——`/guide/` + `/versions/` 共用 `sideDoc()`（文档侧），`/prototypes/` 是单独的数组（原型侧）。改版本时容易只改 `sideDoc()` 漏掉 `/prototypes/`。

**修复**：改版本时检查 **4 个地方**全部同步：
1. `sideDoc()` 里的版本分组（文档侧边栏）
2. `/prototypes/` 的 sidebar 数组（原型侧边栏）
3. `guide/index.md` 的版本表格
4. `prototypes/index.md` 的版本列表

**自查命令**：改完后 grep 确认没有旧文字残留：
```bash
grep -n "待制作\|旧版本名" .vitepress/config.mts guide/index.md prototypes/index.md
```

### 坑 10：原型版本覆盖

**症状**：上传 V1.0.1 原型后，V1.0.0 的同名原型变成了 V1.0.1 的内容。

**根因**：不同版本的原型 HTML 文件名相同（如 V1.0.0 和 V1.0.1 都有 `E0-企业概览-原型.html`），放在同一目录会互相覆盖。

**修复**：按版本分目录存储：
```
public/prototypes/<项目>/v1.0.0/HTML/E0-企业概览-原型.html
public/prototypes/<项目>/v1.0.1/HTML/E0-企业概览-原型.html
```

### 坑 11：原型改了但部署后没变化

**症状**：源项目目录改了原型 HTML，rsync + rebuild 后线上还是旧版。

**根因**：源项目目录（如 `02当前项目/<项目名>/.../04-原型/`）和 docs-site 目录是两个独立位置。rsync 只推 docs-site，源项目文件不在推送范围。

**修复**：改完源项目后，先把文件拷到 docs-site：
```bash
cp "源项目/04-原型/HTML/O2-代理管理.html" \
   "docs-site/public/prototypes/<项目>/vX.Y.Z/HTML/"
```

## 日常场景操作

### 导入新文档（从源目录）

```
1. 复制文件：cp "源目录/文档.md" docs-site/versions/vX.Y.Z/specs/
2. 修相对链接（坑3）
3. config.mts 侧边栏加一条导航项
4. 如目录下无 index.md，创建一个（VitePress 目录首页约定）
5. 构建验证 → 完整部署
```

### 新增版本（含原型上架）

以源目录已有原型和文档为前提的完整流程：

```
1. 建目录：mkdir -p docs-site/versions/vX.Y.Z/{requirements,specs}

2. 建版本首页：versions/vX.Y.Z/index.md（含版本概述、交付物统计、需求清单）

3. 导入文档：
   - 复制需求文档到 requirements/
   - 复制规格文档到 specs/
   - ⚠️ 修相对链接（坑3）：源文档的 ../需求文档/xxx.md → /versions/vX.Y.Z/requirements/xxx
   - 如目录无 index.md，创建一个

4. 导入原型（版本分目录，避免同名覆盖）：
   - mkdir -p public/prototypes/<项目>/vX.Y.Z/{HTML,小程序}
   - 复制原型 HTML，排除归档端（如 R3/U3）
   - 创建 prototypes/vX.Y.Z.md（按端分组，新增/优化标注跟在链接后）

5. 更新 config.mts 侧边栏（⚠️ 坑9：4 处全改）：
   - sideDoc() 加一组（文档侧）
   - /prototypes/ sidebar 加一条（原型侧）
   - 新版排最上面，旧版 collapsed:true

6. 更新入口页：guide/index.md、prototypes/index.md 的版本表格/列表

7. 构建验证（npm run build，修 dead link）→ 完整部署
```

### 原型页标注规范（多版本增量场景）

当站点保留多个版本（如 V1.0.0 + V1.0.1），新版原型页（`prototypes/vX.Y.Z.md`）应**按端分组**列全部原型，不单独分组列新增页面。相对上一版的变化用行内标注跟在链接后面：

```markdown
- [O2g-代理分组管理](/prototypes/.../O2g-代理分组管理-原型.html) `新增 V1-2`
- [O2-代理管理](/prototypes/.../O2-代理管理-原型.html) `优化 V1-2`
- [E0-企业概览](/prototypes/.../E0-企业概览-原型.html)
```

**判断新增 vs 优化**：看规格文档文件名——`xxx-变更规格.md` 是优化（已有页面改版），`xxx-原型设计规格.md` 是新建页面。

**版本分目录存储**：不同版本的原型 HTML 同名但内容不同（如 V1.0.0 和 V1.0.1 都有 E0），必须按版本分目录，避免覆盖：
```
public/prototypes/<项目>/v1.0.0/HTML/E0-企业概览-原型.html
public/prototypes/<项目>/v1.0.1/HTML/E0-企业概览-原型.html
```

**排除归档页面**：R3/U3 等已归档的端，每个版本都排除，原型导航页和 public 目录都不放。

**版本排序（最新在上）**：所有展示版本的地方，最新版本排在最上面。用户进来先看到最新版，往下才是历史版本。侧边栏里用 `collapsed: false`（最新版展开）和 `collapsed: true`（旧版折叠）。

> ⚠️ **版本排序涉及多处**，容易漏改（见坑 9）：文档侧边栏（`sideDoc()`）、原型侧边栏（`/prototypes/` 的 sidebar）、`guide/index.md`、`prototypes/index.md` **全部都要改**。

### 改密码

```
1. SSH 到服务器
2. source ~/.nvm/nvm.sh
3. vi /root/docs-site/server/auth.js 改 ACCESS_PASSWORD
4. pm2 restart docs-site
```
> 不需要 rebuild，不需要 rsync。

## 验证检查清单

每次部署后，用 curl 验证：

```bash
# 1. 未登录是否跳登录页
curl -s -o /dev/null -w "%{http_code} %{redirect_url}\n" http://<IP>:<端口>/
# 应为 302 → /login

# 2. 登录是否成功
curl -s -o /dev/null -w "%{http_code}\n" -c cookie.txt -X POST http://<IP>:<端口>/login -d "password=<密码>"
# 应为 302

# 3. 登录后能否访问内容
curl -s -o /dev/null -w "%{http_code}\n" -b cookie.txt http://<IP>:<端口>/
# 应为 200

# 4. 无内容泄露（grep 其他项目关键词）
grep -rl "其他项目名" .vitepress/dist/ || echo "干净"
```

### 多项目部署（物理隔离）

每个项目独立一套站点，各自端口、各自密码、各自目录。解决同站多项目的内容泄露问题（坑 7）。

```
服务器:9900  → 项目A站   密码A
服务器:9901  → 项目B站   密码B
服务器:9902  → 项目C站   密码C
```

每站复制现有站结构，改 4 样：`config.mts` 的 title、`auth.js` 的密码、`ecosystem.config.cjs` 的 PORT+name（PM2 进程名也要不同）、文档和原型内容。

> ⚠️ 内存限制：每站 ~65MB，2G 内存服务器建议最多 4 个站。超过需升级内存或改 Nginx 统一代理方案。

## 参考文档

如果用户的项目根目录有详细的搭建维护文档（如 `01通用/VitePress文档站搭建与维护.md`），读取它获取该项目的具体配置（IP、端口、密码、密钥路径）。
