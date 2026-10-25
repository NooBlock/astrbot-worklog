# 大肥鱼 QQ 机器人环境搭建工作日记（2026-10-25 ~ 2026-10-26）

> **一句话说明**：用 AI Agent（DeepSeek Harness / DSH）在一台 Windows 11 本机上，以**普通用户、非管理员**权限从零搭起一套「AstrBot v4.29.3 + SnowLuma v2.2.0 + QQ OneBot v11」的机器人运行环境，装上约 10 个插件，并补建了 5 个中文互联网梗 RAG 知识库（合计 4544 条 chunk）。

这套环境给一个叫「大肥鱼」的 AI 聊天机器人做底座：QQ 消息 → SnowLuma 注入 hook → OneBot v11 反向 WebSocket → AstrBot → LLM（DeepSeek / 小米 MiMo）→ 回复；知识库和表情包/记忆类插件作为增强层。

- **时间范围**：2026-10-25 06:06 – 2026-10-26 03:52（Asia/Shanghai）
- **机器**：Windows 11（10.0.26100）x64；普通用户权限，**未使用管理员**；D 盘可用空间约 542 GB
- **主要目录**：`D:\deepseek bot project`（框架、插件、数据、语料、脚本）、`D:\SnowLuma`（SnowLuma 发行版，必须在工作区外）
- **记录原则**：时间以文件 `LastWriteTime` / 日志为准；查不到的细节写「未能确认」，不猜。
- **时效说明**：文中涉及「进程在运行 / 已停止」「端口在监听」这类判断，如无特别说明均以 **2026-10-26 04:00** 为截止；之后环境可能变化，请自行核实。

---

## 一页速览

按主题分组的成果清单（细节见对应的日记文件）：

| 主题 | 成果 | 关键证据 |
| --- | --- | --- |
| **基础环境** | AstrBot Launcher 0.3.12、Python 3.12.15、pip 26.2.2、Node.js 24.22.1、npm 11.19.1、uv 0.13.5，全部用户级安装，未污染系统目录 | `AstrBot-安装报告.md`、`install/final-check.json`、`install/setup-log.txt` |
| **依赖与源** | 修掉 Launcher 实例 `pip install` 的 403（镜像端回源异常）；为该实例 venv 装齐 `core/requirements.txt` 的 153 个包并写 `pip.ini` | `AstrBot-安装报告.md` §8、`install/astrbot-fix-log.txt`、`install/astrbot-fix-state.json` |
| **磁盘回收** | 清理 pip 缓存、uv 缓存、下载包，合计回收 **≈815.6 MB**，并做过完整性自检 | `install/cleanup-log.txt`、`install/cleanup-state.json` |
| **AstrBot** | v4.29.3 手动部署：`uv sync` 解析 172 包；WebUI `http://127.0.0.1:6185`（监听 `0.0.0.0`）；aiocqhttp 反向 WS `0.0.0.0:6199/ws` | `astrbot/DEPLOY-NOTES.md`、`install/uv-sync.log`、`install/uv-sync-2.log` |
| **SnowLuma + QQ** | v2.2.0 部署到 `D:\SnowLuma`，绕过 DSH 工作区给可执行文件打的 Low 完整性标签；hook 注入成功，加载好友/群/群成员并连上 AstrBot | `SNOWLUMA-DEPLOY.md`、`install/screen-*.png` |
| **OneBot 对接** | HTTP 3000 / WS 3001（账号一），第二账号用 3002/3003 规避端口冲突；反向 WS 客户端连 6199，`/ws` 鉴权只认 HTTP 头 | `D:\SnowLuma\config\onebot*.json`、`install/ws-test.mjs`、`SNOWLUMA-DEPLOY.md` |
| **插件** | 10 个插件落地：搜索、Apex 段位、B 站开播监控、B 站链接解析、每日资讯、陪伴、长期记忆、梗百科、Pixiv、表情包管理 | `astrbot/logs/astrbot.log`、`astrbot/data/plugins/`、`astrbot/data/config/` |
| **RAG 知识库** | 按「核心释义 / 风格 / 社区 / 动态」分层，建成 5 个知识库共 **4544** 条 chunk，并写了构建/校验/导入工具链 | `rag_corpora/README.md`、`rag_corpora/SPEC.md`、`rag_corpora/_state/imported.json` |
| **运维脚本** | `start-all.bat`、`start-astrbot.bat`、`start-astrbot-supervised.cmd`、后台 VBS、`snowluma-launch.bat`；一键拉起两个进程 | 工作区根目录同名脚本 |
| **收尾** | 关闭 SnowLuma 内置 `statusCommand`（`#sl`）、修好表情包多包选择规则、确认知识库参与检索的配置 | `_diag/`、`install/apply-statuscmd.cjs`、`astrbot/data/cmd_config.json` |

---

## 关键数字

| 指标 | 数值 | 说明 |
| --- | --- | --- |
| 安装的基础组件 | 6 个 | Launcher / Python / pip / Node.js / npm / uv |
| 框架 | 2 套 | AstrBot v4.29.3、SnowLuma v2.2.0 |
| AstrBot 源码依赖 | 解析 172 包 / 安装 169 包 | 另外 3 个已在环境里；Launcher 实例那条线是 153 包 |
| 插件 | 10 个 | `astrbot/data/plugins/` 下的 10 个目录 |
| RAG 知识库 | 5 个 | 网络流行语释义、网梗对话风格、弱智吧、V 吧黑话、地狱笑话 |
| RAG chunk 总量 | 4544 条 | 1219 + 1804 + 1320 + 120 + 81 |
| Embedding | 1024 维 | SiliconFlow `Qwen/Qwen3-Embedding-8B`（AstrBot 内置 `openai_embedding` provider） |
| 回收磁盘 | ≈815.6 MB | pip 缓存 ≈713 MB + 下载包 135.9 MB + uv 缓存 3.7 KB |
| 语料体积 | 35.5 MB | `rag_corpora/`，其中原始数据约 16 MB 可删 |
| AstrBot 目录 | 约 1.44 GB | 大头是 `.venv` 665 MB 与 `data` 745 MB |
| SnowLuma 目录 | 约 140 MB | `D:\SnowLuma`（含内置 Node 运行时与账号数据） |
| 安装/工具目录 | 约 634 MB | `install/`，含 uv 缓存 545 MB、uv 解释器 63 MB，可整体重建 |

---

## 端口与进程速查

| 端口 | 服务 | 绑定 | 备注 |
| --- | --- | --- | --- |
| 6185 | AstrBot WebUI / HTTP API | `0.0.0.0` | 登录后建议改掉初始密码、改成仅回环监听 |
| 6199 | AstrBot aiocqhttp 反向 WS | `0.0.0.0` | 路径 `/ws`，带 token，只认 HTTP `Authorization` 头 |
| 5099 | SnowLuma WebUI | `127.0.0.1` | 登录接口 `POST /api/login` |
| 3000 | OneBot HTTP（账号一） | `127.0.0.1` | access token 已脱敏 |
| 3001 | OneBot WS Server（账号一） | `127.0.0.1` | 同上 |
| 3002 / 3003 | OneBot HTTP / WS（账号二） | `127.0.0.1` | 为避开 3000/3001 冲突改的端口 |
| 7890 | 本机代理 | `127.0.0.1` | 下载/抓取外部资源时使用 |
| 6190 | Launcher 实例测试端口 | `127.0.0.1` | 仅修复依赖时做过一次启动验证，非日常端口 |

---

## 文档索引

| 文件 | 内容 | 适合谁读 |
| --- | --- | --- |
| [`2026-10-25.md`](2026-10-25.md) | 第一天：环境安装、pip 403、磁盘清理、AstrBot / SnowLuma 部署、QQ hook、OneBot 对接、插件、日志与 watchdog 排障、沙箱限制 | 想复现部署或查当天踩坑的人 |
| [`2026-10-26.md`](2026-10-26.md) | 第二天凌晨：RAG 知识库从来源对话到 5 个库落库、抓取清洗抽样、导入踩坑、校验，以及 03:20 后的 statuscmd / 多包选择 / 模型工具探测 | 想复现知识库或做类似语料工程的人 |
| [`复盘与经验教训.md`](复盘与经验教训.md) | 做对了什么、坑与根因、环境限制清单、若重做一次会怎么做、遗留 TODO | 未来的自己 / 接手的人 |
| [`清单.md`](清单.md) | 资产清单：路径、作用、是否可删/可重建、体积 | 清理磁盘、迁移或备份时 |
| [appendix/](appendix/) | 原始交付文档（已脱敏）：安装报告、SnowLuma 部署说明、AstrBot 部署笔记 | 想核对原始细节的人 |
| [scripts/](scripts/) | 脱敏后的启动/运维脚本（PowerShell/BAT/VBS/Node） | 想直接复用启动方式的人 |

> **证据路径说明**：文中出现的 `rag_corpora/…`、`install/…`、`astrbot/…` 等路径都指**原始工作区**
> （未随本仓库发布，只作为可核对的来源）。其中 RAG 语料、构建/导入工具与使用 wiki 已单独整理成
> 公开仓库 **`astrbot-rag-kb`**；原始交付文档收在本仓库 [`appendix/`](appendix/)，脱敏后的启动脚本收在
> [`scripts/`](scripts/)。

---

## 免责声明

- 本仓库只记录**一次本机环境搭建过程**，不保证在其它机器、其它版本上可复现；按此操作风险自负。
- 文中所有凭据已脱敏；如果你在本仓库里发现疑似真实凭据，请提 Issue 提醒删除。
- 第三方数据集/网页内容版权归原作者与站点所有。本仓库**不包含语料本体**，只描述来源、许可边界与处理方法；商用或再分发前请自行核对上游许可。
- 记录基于当时的日志与文件时间戳，仍可能存在遗漏或误差；文中标注「未能确认」的部分请勿当作事实。
- 本项目与 AstrBot、SnowLuma、QQ、各插件作者均无隶属关系，插件与框架的版权/许可归各自作者。

---

## 给读者的三个提醒

1. **这不是一份教程，而是一份工作日志。** 里面很多步骤是「在这种受限环境里绕路」，通用性有限；正常桌面环境下通常有更直接的装法。
2. **所有凭据都已脱敏。** 仓库里不会出现真实密码、token、API Key、JWT secret、QQ 号/群号，也不会出现内网地址；QQ 账号在文中用「账号一 / 账号二」指代，文中出现的 `<REDACTED>`、`<已脱敏>` 就是原值。
3. **第三方数据只做描述，不复刻。** RAG 语料的来源、许可边界、已知局限都写在各语料目录的 `manifest.json` / `README.md` 里；公开数据集和网页内容版权归原作者/站点，若要再分发或商用请先核对上游许可。

---

*本仓库为 2026-10-25 06:06 – 2026-10-26 03:52 期间实际工作的整理版；证据文件均在工作区内，路径以工作区根目录为参照。文中的进程/端口状态以 2026-10-26 04:00 为截止，之后可能变化。*
