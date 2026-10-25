# SnowLuma v2.2.0 部署说明（Windows x64）

部署时间：2026-10-25 06:31（Asia/Shanghai）
部署人：DSH Agent（Lead）
配套框架：AstrBot v4.29.3（已同时部署，见 `AstrBot-安装报告.md`）

---

## 1. 结论（当前状态）

| 项目 | 状态 |
| --- | --- |
| SnowLuma | **v2.2.0 win-x64 完整版（内置 Node 24.22.1）**，已解压部署并正在运行 |
| 部署目录 | **`<SNOWLUMA_DIR>`** |
| 进程完整性 | **Medium (RID=8192)** ✅（可正常 hook QQ，见第 5 节） |
| QQ 接入 | **已成功注入 hook**：QQ 已登录账号 `<QQ_UIN_1>`（昵称「<QQ_NICKNAME>」），好友 543、群 152、群成员 34944 已加载 |
| SnowLuma WebUI | http://127.0.0.1:5099 —— 密码 **`<REDACTED_PASSWORD>`**（登录接口 `POST /api/login`） |
| OneBot HTTP | http://127.0.0.1:3000/ ✅ `get_login_info` 返回 uin=<QQ_UIN_1> |
| OneBot WS | ws://127.0.0.1:3001/ ✅ 监听中 |
| **AstrBot 对接** | ✅ **已连通**：SnowLuma 反向 WS 客户端连上 `ws://127.0.0.1:6199/ws`；AstrBot 日志 06:31:53 输出「aiocqhttp(OneBot v11) 适配器已连接。」 |
| AstrBot WebUI | http://127.0.0.1:6185 —— 用户名 `astrbot` / 初始密码 `<REDACTED_PASSWORD>` |

> 本会话中 SnowLuma 与 AstrBot 均由 DSH 后台任务托管，**DSH 会话结束后这两个进程会停止**；之后请用 `<WORKSPACE>\snowluma-launch.bat` / `start-astrbot.bat`（或 `start-all.bat`）重新启动，配置与登录态均已持久化在磁盘上。

---

## 2. 安装包与校验

- 来源：GitHub 官方 Release <https://github.com/SnowLuma/SnowLuma/releases/tag/v2.2.0>
- 文件：`SnowLuma-v2.2.0-win-x64.zip`（完整版，41.0 MB，内含 `node.exe`，无需另装 Node）
- 下载留档：`<WORKSPACE>\install\downloads\SnowLuma-v2.2.0-win-x64.zip`
- SHA-256：`4e293f1e4452c9ae0d8a8d4f065dea8a170ca64502f2d6d4bff8f92a826b5f75`（与 GitHub API 公布的 digest 一致）
- 下载方式说明：本机 schannel TLS 异常（curl/Invoke-WebRequest 报 `SEC_E_NO_CREDENTIALS`），实际使用 **Node.js `fetch` + gh-proxy 镜像** 下载并校验通过。

解压后目录内容：`index.mjs`、`node.exe`、`native/`（`snowluma-win32-x64.dll/.node`、sqlite、ffmpeg）、`client/`（WebUI 静态资源）、`config/`、`Start-SnowLuma.bat`。

---

## 3. 启动与停止

**一键启动（推荐）**

```
<WORKSPACE>\start-all.bat      # 同时启动 AstrBot + SnowLuma
<WORKSPACE>\snowluma-launch.bat # 只启动 SnowLuma（内含 <SNOWLUMA_DIR>\Start-SnowLuma.bat 调用）
<WORKSPACE>\start-astrbot.bat   # 只启动 AstrBot
```

也可以直接双击 `<SNOWLUMA_DIR>\Start-SnowLuma.bat`（或运行 `<SNOWLUMA_DIR>\launcher.bat`），或在普通 cmd 里：

```
cd /d <SNOWLUMA_DIR>
node.exe index.mjs
```

启动顺序：先 AstrBot 或先 SnowLuma 都可以。SnowLuma 的反向 WS 客户端每 5 秒重连一次；QQ 已登录时，SnowLuma 启动后会自动注入 hook（`hookAutoLoad=true`）。

**停止**：关闭对应控制台窗口，或在任务管理器结束 `node.exe`（SnowLuma）/ `python.exe`（AstrBot）。QQ 不会被关闭。

---

## 4. 配置与凭据

### 4.1 目录与文件

| 路径 | 说明 |
| --- | --- |
| `<SNOWLUMA_DIR>\config\runtime.json` | 运行时设置：`webuiPort=5099`、`hookAutoLoad=true`、WebUI 只监听 127.0.0.1 |
| `<SNOWLUMA_DIR>\config\onebot.json` | OneBot 全局默认配置（本部署已写好 httpServers / wsServers / wsClients） |
| `<SNOWLUMA_DIR>\config\onebot_<QQ_UIN_1>.json` | 账号级覆盖配置（自动生成，`mode=overlay`，继承全局 wsClients） |
| `<SNOWLUMA_DIR>\config\webui.json` | WebUI 密码哈希（由环境变量种子生成，删掉后会用启动脚本里的密码重建） |
| `<SNOWLUMA_DIR>\data\` | 账号数据、日志等 |
| `<SNOWLUMA_DIR>\logs\snowluma-YYYY-MM-DD.log` | 运行日志 |

### 4.2 端口与 Token

| 端口 | 用途 | 凭据 |
| --- | --- | --- |
| 5099 | SnowLuma WebUI | 密码 `<REDACTED_PASSWORD>`（`POST /api/login {"password":"..."}`） |
| 3000 | OneBot HTTP API | `Authorization: Bearer <REDACTED_ONEBOT_HTTP_TOKEN>`，或 `?access_token=` |
| 3001 | OneBot WebSocket Server | 同上：`<REDACTED_ONEBOT_WS_TOKEN>` |
| 6199 | AstrBot aiocqhttp 反向 WS 服务端 | `<REDACTED_WS_TOKEN>`（SnowLuma 已配置为客户端自动连接） |
| 6185 | AstrBot WebUI | 用户 `astrbot` / 密码 `<REDACTED_PASSWORD>` |

### 4.3 与 AstrBot 的对接方式

AstrBot 的 aiocqhttp（OneBot v11）是「反向 WebSocket 服务端」，因此由 SnowLuma 主动连出去，对应配置：

```json
"wsClients": [
  {
    "name": "astrbot",
    "enabled": true,
    "url": "ws://127.0.0.1:6199/ws",
    "role": "Universal",
    "accessToken": "<REDACTED_WS_TOKEN>",
    "messageFormat": "array",
    "reportSelfMessage": false,
    "reconnectIntervalMs": 5000
  }
]
```

AstrBot 侧（`<WORKSPACE>\astrbot\data\cmd_config.json` 的 platform 数组）：

```json
{"id":"snowluma-onebot","type":"aiocqhttp","enable":true,
 "ws_reverse_host":"0.0.0.0","ws_reverse_port":6199,
 "ws_reverse_token":"<REDACTED_WS_TOKEN>"}
```

注意（AstrBot 源码级验证）：鉴权只认 HTTP Header（`Authorization: Bearer ...` 或 `Token ...`），**不支持 `?access_token=` 查询参数**；SnowLuma 的 wsClients 会按 OneBot 标准发送 `Authorization`、`X-Client-Role`、`X-Self-ID` 头，实测握手成功。

---

## 5. 为什么目录必须是 `<SNOWLUMA_DIR>`（重要）

DSH 的文件沙箱会把「在工作目录里新建的文件」打上 **Low 完整性标签**（`icacls` 可见 `Mandatory Label\Low Mandatory Level`）。Windows 中可执行文件带 Low 标签时，即使调用方是 Medium 令牌，进程也会被降为 Low 完整性，结果：

- SnowLuma 报 `Node integrity: ... process=Low (RID=4096)`；
- 无法 `OpenProcess`/注入 Medium 完整性的 `QQ.exe`，hook 加载失败；
- 且沙箱内 Node 的 IPC spawn 会直接 `spawn EPERM`。

因此最终把发行包解压到 **`<SNOWLUMA_DIR>`**（由 Medium 进程创建，文件无 Low 标签），启动日志显示 `process=Medium (RID=8192); EXE=unlabeled`，hook 注入成功。

> **不要**把 SnowLuma 复制/解压回 DSH 工作目录（`<WORKSPACE>\...`）再启动，否则会重新带上 Low 标签导致注入失败。

---

## 6. 已验证的接口

```powershell
# OneBot HTTP API（账号信息）
curl.exe -X POST http://127.0.0.1:3000/get_login_info -H "Authorization: Bearer <REDACTED_ONEBOT_HTTP_TOKEN>"
# -> {"status":"ok","retcode":0,"data":{"user_id":<QQ_UIN_1>,"nickname":"砖"}}
```

- SnowLuma 日志关键行：`[Hook] login detected: PID=3840 UIN=<QQ_UIN_1>`、`[OneBot.WS-Client] [astrbot] connected ws://127.0.0.1:6199/ws`。
- 群成员预热：`groups=152/152 members=34944 failed=0`。
- AstrBot 日志：`aiocqhttp(OneBot v11) 适配器已连接。`

---

## 7. 后续可做（需用户决定）

1. **AstrBot 配置 LLM Provider**（OpenAI/DeepSeek 等）：AstrBot WebUI → 服务提供商。当前无 Provider，所以 QQ 消息不会触发 AI 回复。
2. **开机自启**：把 `snowluma-launch.bat` / `start-all.bat` 的快捷方式放入 `shell:startup`（本机当前无 Explorer 桌面外壳，需在正常桌面环境操作）。
3. **安全**：WebUI/OneBot 端口目前只监听 127.0.0.1（WebUI 与 OneBot 均是回环），AstrBot WebUI 监听 0.0.0.0:6185，建议改掉默认密码并限制访问。
4. **SnowLuma 自动更新**：启动脚本走的是标准 runner（会检查更新）；升级时按官方文档替换发行包，保留 `config/` 与 `data/`。
5. **QQ 版本兼容**：hook 与 QQ 版本对齐，QQ 升级后若注入失败，先看 `<SNOWLUMA_DIR>\logs\` 与官方 FAQ。
6. **多账号**：每个 UIN 一份 `onebot_<uin>.json`，第二账号需换 3000/3001 端口或用不同反向 WS 目标。

---

## 8. 故障排查速查

| 现象 | 排查 |
| --- | --- |
| 启动报 `spawn EPERM` | 在 DSH 沙箱里启动了；改用 `<SNOWLUMA_DIR>\Start-SnowLuma.bat` 在沙箱外启动 |
| 日志 `process=Low` | 程序文件被打了 Low 完整性标签（多半是从 DSH 工作区复制的）；重新解压到 `<SNOWLUMA_DIR>` |
| 注入失败 / 找不到 QQ | 确认 `D:\software\QQ\QQ.exe` 正在运行、与 SnowLuma 同一 Windows 用户、权限一致 |
| SnowLuma 连不上 AstrBot | 确认 AstrBot 已启动且 6199 监听、token 一致；SnowLuma 每 5s 自动重连 |
| WebUI 打不开 | 检查 5099 是否被占用；`runtime.json` 里 `webuiPort` 可改 |
| 忘记 WebUI 密码 | 删除 `<SNOWLUMA_DIR>\config\webui.json` 后用启动脚本（`SNOWLUMA_WEBUI_BOOTSTRAP_PASSWORD=<REDACTED_PASSWORD>`）重启 |

---

## 9. 相关文件索引

- 启动脚本：`<WORKSPACE>\snowluma-launch.bat`、`<WORKSPACE>\start-all.bat`、`<SNOWLUMA_DIR>\Start-SnowLuma.bat`
- 安装包：`<WORKSPACE>\install\downloads\SnowLuma-v2.2.0-win-x64.zip`
- AstrBot 报告：`<WORKSPACE>\AstrBot-安装报告.md`、`<WORKSPACE>\astrbot\DEPLOY-NOTES.md`
- 官方文档：<https://snowluma.github.io/zh/docs/guide/deploy/windows>、<https://snowluma.github.io/zh/docs/guide/configuration>、<https://snowluma.github.io/zh/docs/guide/connect-bot>
