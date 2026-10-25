# AstrBot 部署笔记（Windows 本机）

> 部署时间：2026-10-25 06:1x（本机时间）
> 部署人：astrbot-deployer（DSH teammate）
> 目的：为 SnowLuma 的 OneBot v11 对接提供 AstrBot 反向 WebSocket 服务端

---

## 1. 版本与路径

| 项目 | 值 |
| --- | --- |
| AstrBot 版本 | **v4.29.3**（GitHub release 最新稳定 tag，2026-10-24 发布） |
| 源码来源 | `https://codeload.github.com/AstrBotDevs/AstrBot/zip/refs/tags/v4.29.3`（node fetch 下载，7.5 MB） |
| 源码压缩包 | `<WORKSPACE>\install\downloads\AstrBot-v4.29.3.zip` |
| 安装目录 | `<WORKSPACE>\astrbot\`（`main.py` 在根目录） |
| Python | CPython **3.12.15**，由 uv 安装：`<WORKSPACE>\install\uv-python\cpython-3.12.15-windows-x86_64-none\python.exe` |
| 虚拟环境 | `<WORKSPACE>\astrbot\.venv`（由 `uv sync` 创建） |
| 依赖 | `uv sync` 成功，172 个包（含 aiocqhttp 1.4.4 / quart / fastapi / faiss-cpu / pandas / jieba 等） |
| WebUI 静态资源 | 源码包不含 `dist`，已从 `https://astrbot-registry.soulter.top/download/astrbot-dashboard/v4.29.3/dist.zip` 下载并解压到 `<WORKSPACE>\astrbot\data\dist`（`assets/version` = `v4.29.3`，与核心版本匹配） |
| 运行数据 | `<WORKSPACE>\astrbot\data\`（cmd_config.json、data_v4.db、plugins、logs…） |
| 日志目录 | `<WORKSPACE>\astrbot\logs\` |

## 2. 启动命令

**当前运行的实例**（后台 job，pid 见 `logs\stdout.log` 中的 `Running on http://0.0.0.0:6185`）：

```
cd /d "<WORKSPACE>\astrbot"
set PYTHONIOENCODING=utf-8
set PYTHONUTF8=1
set UV_CACHE_DIR=<WORKSPACE>\install\uv-cache
set UV_PYTHON_INSTALL_DIR=<WORKSPACE>\install\uv-python
".venv\Scripts\python.exe" main.py
```

本机双击启动：**`<WORKSPACE>\start-astrbot.bat`**（内容同上，带 pause）。

- `uv run main.py` 也可用（pyproject/uv 项目完整），但**必须先设置 `UV_CACHE_DIR`**（默认 `%LOCALAPPDATA%\uv\cache` 在本机被 ACL 拒绝），且每次启动都会重新 sync。
- 后台/无窗口启动（本次部署使用）：`cmd.exe /c "<WORKSPACE>\install\launch-astrbot.cmd"`，该脚本把控制台输出重定向到 `logs\stdout.log`。
- 重置 WebUI 密码：`.venv\Scripts\python.exe main.py --reset-password`（日志打印新初始密码）。

### 日志
- 主要日志：`<WORKSPACE>\astrbot\logs\stdout.log`（控制台重定向，实测有内容）
- `logs\astrbot.log`：AstrBot 的 loguru 文件 sink（`log_file_enable=true`，绝对路径指向此文件）。在本机 DSH 沙箱下 loguru 的 `enqueue=True` 队列被阻塞，该文件保持 0 字节；**看日志请用 stdout.log**。正常桌面环境（非沙箱）下该文件应正常写入。

## 3. WebUI

| 项目 | 值 |
| --- | --- |
| 地址 | **http://127.0.0.1:6185** （监听 0.0.0.0:6185，局域网亦可访问） |
| 初始用户名 | `astrbot` |
| 初始密码 | **`<REDACTED_PASSWORD>`** （首次启动通过 `ASTRBOT_DASHBOARD_INITIAL_PASSWORD` 指定的确定性密码；`change_pwd_hint=true`，建议登录后修改） |
| 验证 | `node fetch` GET `/` → **200 text/html**；`POST /api/auth/login`（astrbot / <REDACTED_PASSWORD>）→ **200 + JWT token** |

> 注意：`dashboard.host` 为 `0.0.0.0`，WebUI 对局域网开放，仅本机使用时可在 `data/cmd_config.json` 把 `dashboard.host` 改为 `127.0.0.1`。

## 4. OneBot v11（aiocqhttp）配置

- **配置文件**：`<WORKSPACE>\astrbot\data\cmd_config.json`
- **backup**：首次生成的原始配置备份在 `data\cmd_config.json.bak-before-onebot`
- **配置片段**（`platform` 数组中的一条，schema 来源：`astrbot/core/config/default.py` 的 `CONFIG_METADATA_2.platform_group.platform.config_template["OneBot v11"]`）：

```json
{
    "id": "snowluma-onebot",
    "type": "aiocqhttp",
    "enable": true,
    "ws_reverse_host": "0.0.0.0",
    "ws_reverse_port": 6199,
    "ws_reverse_token": "<REDACTED_WS_TOKEN>"
}
```

| 项目 | 值 |
| --- | --- |
| 反向 WS 监听 | **0.0.0.0:6199** |
| 路径 | **`/ws`**（aiocqhttp 同时注册 `/ws`、`/ws/event`、`/ws/api`，`/ws` 为通用端点） |
| Access Token | **`<REDACTED_WS_TOKEN>`** |
| 客户端连接串 | `ws://127.0.0.1:6199/ws` |
| 鉴权方式 | HTTP header `Authorization: Bearer <REDACTED_WS_TOKEN>`，`Token <token>` 亦可（两种均实测通过） |
| 必需 header | `X-Client-Role: universal`（或 `api`/`event`）、`X-Self-ID: <QQ号>`；**缺失 `X-Self-ID` 会被服务端 KeyError 断开** |
| Token 传参 | 只认 `Authorization` 头；query `?access_token=` **不生效**（源码 `aiocqhttp/__init__.py: _handle_wsr`） |

> 注意：OneBot v11 的 `secrets`/`access_token` 在 AstrBot 侧就是 `ws_reverse_token` 字段，WebUI「平台 → OneBot v11」里同样可改。

## 5. 验证结果（2026-10-25 06:16 起）

1. `netstat -ano | findstr ":6185 :6199"`（`Get-NetTCPConnection` 在本机沙箱下返回空，netstat 正常）：
   ```
   TCP    0.0.0.0:6185   0.0.0.0:0   LISTENING   42332
   TCP    0.0.0.0:6199   0.0.0.0:0   LISTENING   42332
   ```
2. WebUI：`node fetch http://127.0.0.1:6185/` → `200 text/html; charset=utf-8`。
3. 登录接口：`POST http://127.0.0.1:6185/api/auth/login` `{"username":"astrbot","password":"<REDACTED_PASSWORD>"}` → `200`，返回 JWT。
4. 平台加载日志（`logs\stdout.log`）：
   ```
   [platform.manager:144] Loading IM platform adapter aiocqhttp(snowluma-onebot) ...
   ```
5. 反向 WS 鉴权测试（node 内置 WebSocket，脚本 `install\ws-test.mjs`）：

   | 用例 | 结果 |
   | --- | --- |
   | 无 token | 握手被拒（close 1006，服务端 401） |
   | 错误 token | 握手被拒（close 1006，服务端 403） |
   | 正确 token（`Authorization: Bearer …`） | **连接建立成功**，服务端日志 `aiocqhttp(OneBot v11) 适配器已连接。` |
   | 正确 token（`Authorization: Token …`） | **连接建立成功** |

   → 6199/`/ws` 已能接受带 SnowLuma token 的反向 WS 连接，SnowLuma 侧按上面的连接串接入即可。

## 6. 本机环境的坑与处理（重要，重装/排障时看）

1. **schannel TLS 损坏**：`curl.exe` / `Invoke-WebRequest` 访问 https 全部失败（`SEC_E_NO_CREDENTIALS`）。下载一律用 **node fetch**（`node install\download-snowluma.mjs <url> <out>`）或 uv。`codeload.github.com`、`api.github.com`、`astrbot-registry.soulter.top` 直连可用；`github.com/releases/...` 直连会连接超时（必要时 `NODE_USE_ENV_PROXY=1` + `HTTPS_PROXY=http://127.0.0.1:7890`）。
2. **uv 缓存/解释器目录不可写**：`%LOCALAPPDATA%\uv\cache` 被沙箱拒绝，必须
   `UV_CACHE_DIR=<WORKSPACE>\install\uv-cache`、`UV_PYTHON_INSTALL_DIR=<WORKSPACE>\install\uv-python`。
3. **tempfile 0o700 目录不可访问（本机沙箱特性）**：`tempfile.mkdtemp()` / `TemporaryDirectory()` 创建的目录连自身进程都写不进（EACCES），导致 uv 构建 sdist（jieba）失败、任何用到临时目录的 Python 代码出错。已在
   `install\uv-python\cpython-3.12.15-windows-x86_64-none\Lib\tempfile.py` 把 `_os.mkdir(file, 0o700)` 改为 `0o777` 规避（含注释）。
   **若重新 `uv python install`，需重新打这个补丁**，否则 `uv sync` 与运行时临时文件都会失败。
4. **进程存活**：DSH 沙箱会连带杀掉 `Start-Process` 拉起的子进程，且 `Win32_Process.Create`（WMI）被拒绝。当前 AstrBot 由 **DSH 后台 job**（`install\launch-astrbot.cmd`）托管；**DSH 会话结束后进程会随之结束**，重启用 `start-astrbot.bat` 双击。
5. **管道/IPC 限制**：沙箱禁止 Node/Python 以管道方式 spawn 子进程（EPERM）。因此 AstrBot 的插件在线安装（内部用 pip 子进程+管道）可能失败，未测试；需要装插件时建议在非沙箱终端手动 `uv pip install`/或直接放进 `data\plugins`。
6. `Get-NetTCPConnection` 在本机沙箱下查不到监听（返回空），用 `netstat -ano` 或 node `net.connect` 验证端口。

## 7. 遗留问题 / 待办

- [ ] SnowLuma 侧尚未登录 QQ / 未起 OneBot 实例，因此**没有真实 QQ 账号连上 6199**；当前仅验证到「AstrBot 端点可被带 token 的 WS 客户端连上」。
- [ ] AstrBot 尚未配置任何 LLM Provider（WebUI「服务提供商」中为空），SnowLuma 的消息暂时不会有 AI 回复；如需完整链路需在 WebUI 配置 Provider。
- [ ] WebUI 初始密码 `<REDACTED_PASSWORD>` 为部署时设定，请在 WebUI 里改成自己的强密码。
- [ ] `logs\astrbot.log` 因沙箱的 loguru enqueue 限制为 0 字节，日志看 `logs\stdout.log`。
- [ ] 未修改系统 PATH / 防火墙 / 服务 / 注册表；`0.0.0.0:6185` 与 `0.0.0.0:6199` 若需被局域网访问，可能需要放行防火墙（本次未动防火墙）。
- [ ] AstrBot 由 DSH 后台 job 托管，DSH 会话结束后需用 `start-astrbot.bat` 重启（数据/配置均已持久化，重启即恢复）。

## 8. 附：本次部署产生的辅助文件

- `install\downloads\AstrBot-v4.29.3.zip`：源码包
- `install\downloads\astrbot-dashboard-dist-4.29.3.zip`：WebUI dist 包
- `install\uv-cache\`、`install\uv-python\`：uv 缓存与 Python 解释器
- `install\launch-astrbot.cmd`：无窗口/后台启动脚本（输出重定向到 `astrbot\logs\stdout.log`）
- `install\patch-astrbot-config.mjs`、`install\patch-astrbot-log.mjs`：写入 platform / 日志配置的小脚本（可重跑，幂等）
- `install\ws-test.mjs`：6199 `/ws` 反向 WS + token 鉴权测试
- `install\webui-login-test.mjs`：WebUI 登录验证
- `install\uv-sync.log`、`install\uv-sync-2.log`：依赖安装日志
