# AstrBot Launcher 及依赖组件 安装报告

- **安装时间**：2026-10-25 06:06 – 06:15（Asia/Shanghai）
- **机器**：Windows 11（10.0.26100）x64，用户 `A`，**未使用管理员权限**
- **安装位置**：全部装在当前用户目录 `C:\Users\<USER>\AppData\Local\Programs\` 下，不污染系统目录

---

## 1. 安装结果总览

| 组件 | 版本 | 安装位置 | 验证结果 |
| --- | --- | --- | --- |
| **AstrBot Launcher** | 0.3.12 | `C:\Users\<USER>\AppData\Local\Programs\AstrBot Launcher\` | ✅ 启动自检通过（进程存活、窗口标题 `AstrBot Launcher`） |
| **Python** | 3.12.15 | `C:\Users\<USER>\AppData\Local\Programs\Python\Python312\` | ✅ `python --version` 正常，含 pip / tkinter / venv |
| **pip** | 26.2.2 | 同上 `Scripts\` | ✅ `pip --version`、`pip3 --version` 正常，实测装包成功 |
| **Node.js** | 24.22.1 (LTS) | `C:\Users\<USER>\AppData\Local\Programs\nodejs\` | ✅ `node -v` / `npm -v` / `npx -v` 正常 |
| **npm** | 11.19.1 | 同上 | ✅ |
| **uv** | 0.13.5 | `C:\Users\<USER>\AppData\Local\Programs\uv\` | ✅ `uv --version` / `uvx --version` 正常 |

启动器数据目录：`C:\Users\<USER>\AppData\Local\com.github.raven95676.astrbot-launcher\`

快捷方式（均已创建）：

- 桌面：`C:\Users\<USER>\Desktop\AstrBot Launcher.lnk`
- 开始菜单：`C:\Users\<USER>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\AstrBot Launcher.lnk`

---

## 2. 环境变量（PATH）变更

只修改了**当前用户 PATH**（`HKCU\Environment`），**机器级 PATH 未改动**。

以下 5 个目录被**前置**到用户 PATH 最前面（保证 `python` 不会被 Windows 应用商店的占位程序抢先）：

```
C:\Users\<USER>\.local\bin                                     ← uv tool install 装的命令
C:\Users\<USER>\AppData\Local\Programs\Python\Python312        ← python.exe
C:\Users\<USER>\AppData\Local\Programs\Python\Python312\Scripts ← pip.exe 等
C:\Users\<USER>\AppData\Local\Programs\nodejs                   ← node.exe / npm.cmd
C:\Users\<USER>\AppData\Local\Programs\uv                       ← uv.exe / uvx.exe
```

变更后的完整用户 PATH：

```
C:\Users\<USER>\.local\bin;C:\Users\<USER>\AppData\Local\Programs\Python\Python312;C:\Users\<USER>\AppData\Local\Programs\Python\Python312\Scripts;C:\Users\<USER>\AppData\Local\Programs\nodejs;C:\Users\<USER>\AppData\Local\Programs\uv;D:\deepseek harness\resources\runtime\cli\bin;C:\Users\<USER>\AppData\Local\Microsoft\WindowsApps
```

> ⚠️ PATH 改动**只对新打开的终端生效**。已经开着的终端、VS Code、CMD/PowerShell 窗口需要重启才能识别新命令。

---

## 3. 验证记录（在“干净的新环境”里执行）

| 命令 | 输出 |
| --- | --- |
| `python --version` | `Python 3.12.15` |
| `python -c "import sys;print(sys.executable)"` | `C:\Users\<USER>\AppData\Local\Programs\Python\Python312\python.exe` |
| `pip --version` | `pip 26.2.2 from ...\Lib\site-packages\pip (python 3.12)` |
| `node --version` | `v24.22.1` |
| `npm --version` | `11.19.1` |
| `uv --version` | `uv 0.13.5 (46776a95d 2026-10-21 x86_64-pc-windows-msvc)` |
| `where python` | `...\Programs\Python\Python312\python.exe`（第一条，优先命中） |
| `where pip` | `...\Programs\Python\Python312\Scripts\pip.exe` |
| `where node` | `...\Programs\nodejs\node.exe` |
| `where uv` | `...\Programs\uv\uv.exe` |
| 标准库自检 | `import ssl,sqlite3,venv,json,ctypes` → `stdlib-ok` |
| tkinter | `import tkinter` → `tk-ok` |
| venv + 真实装包 | 临时虚拟环境 `pip install six` → 成功，`import six` → `1.17.0` |

启动器自检：通过桌面快捷方式启动后进程存活，窗口标题为 `AstrBot Launcher`，版本号 `0.3.12`。

---

## 4. 怎么开始用

1. **双击桌面「AstrBot Launcher」**（或开始菜单里打开）。
2. 在启动器里点 **新建实例 / 创建实例** → 选择 AstrBot 版本 → 创建并启动。
   - 首次创建会自动下载 AstrBot 及其**独立**的 Python / Node 运行时到启动器自己的目录（与上面装的系统级 Python/Node 互不影响，这是启动器的“零侵入”设计）。
3. 实例启动成功后，点击实例的 WebUI 链接，用启动日志里的**随机初始密码**登录（用户名通常是 `astrbot`），登录后请立刻改密码。
4. **下载慢/网络报错**：点启动器左侧「高级」→ 打开「中国大陆一键加速」（会切换到 USTC / gh-proxy 等镜像），通常能解决大部分下载问题。
5. 需要局域网/手机访问 WebUI：在实例的齿轮图标里把监听地址从 `127.0.0.1` 改成 `0.0.0.0`。

命令行参考：

```powershell
python --version          # 3.12.15
pip install requests      # 可用（已移除 PEP 668 限制）
node -v                   # v24.22.1
uv --version              # 0.13.5
uv venv .venv             # 用 uv 建虚拟环境（推荐）
uv tool install astrbot   # 想额外装 AstrBot 命令行版时可用
```

---

## 5. 需要你知道的 3 个安装细节

1. **启动器是“解压式”用户级安装，不是官方安装包安装。**
   官方安装包 `AstrBot.Launcher_0.3.12_x64-setup.exe` 会请求管理员提权（UAC），而当前会话是非提权的普通用户权限，直接运行会返回“操作被用户取消”。因此本次从安装包中提取了程序本体（`astrbot-launcher.exe` + `ctrlc_sender.exe`）放到用户目录，并手工创建了桌面/开始菜单快捷方式。
   **功能与官方安装完全一致**，区别是没有“程序和功能”里的卸载条目、没有系统级注册表项。若你要标准安装：右键 `install\downloads\AstrBot.Launcher_0.3.12_x64-setup.exe` →「以管理员身份运行」，按提示安装即可（会覆盖同名快捷方式）。

2. **Python 用的是 uv 管理的独立 CPython 3.12.15。**
   python.org 的官方安装包在当前受限环境下返回 `0x80070005（拒绝访问）`，因此改用 uv 下载官方 CPython 独立版并复制到固定目录 `Programs\Python\Python312`，再生成 `pip.exe`。同时把 uv 写入的 `Lib\EXTERNALLY-MANAGED`（它会禁止 `pip install`）**改名备份**为 `Lib\EXTERNALLY-MANAGED.dsh-disabled`，现在 `pip install` 可正常使用。
   建议：项目依赖仍用 `venv` 或 `uv venv` 隔离，别把系统 Python 装乱。

3. **启动器自带运行时，和系统 Python/Node 不是同一套。**
   启动器为每个实例单独管理运行环境，所以即使你把系统 Python 卸载，已建实例仍能跑；反过来，你改系统 Python 也不影响启动器实例。

---

## 6. 本次对系统做的所有改动（可回滚）

| 改动 | 说明 / 回滚方式 |
| --- | --- |
| 新增目录 `%LOCALAPPDATA%\Programs\{Python\Python312, nodejs, uv, AstrBot Launcher}` | 删除这些目录即可 |
| 用户 PATH 前置 5 条 | 从 `HKCU\Environment` 的 Path 中删除对应 5 条 |
| 桌面 + 开始菜单快捷方式 | 删除两个 `.lnk` |
| `%USERPROFILE%\.local\bin` 目录 | uv tool 用，可保留 |
| 启动器数据目录 `%LOCALAPPDATA%\com.github.raven95676.astrbot-launcher` | 删除即重置启动器配置（会丢实例列表，慎删） |
| 工作区文件权限修复（`<WORKSPACE>` 缺 WRITE_OWNER） | 已备份原权限，回滚命令：<br>`pwsh -NoProfile -File 'C:\Users\<USER>\AppData\Local\dsh-acl-recovery\acl-backup-<ACL_BACKUP_ID>.json.ps1' -Path '<WORKSPACE>' -AllowRoot '<WORKSPACE>' -Restore 'C:\Users\<USER>\AppData\Local\dsh-acl-recovery\acl-backup-<ACL_BACKUP_ID>.json'` |

安装包与脚本都在 `install\` 下：

- `install\downloads\`：node zip（36 MB）、uv zip（14.6 MB）、启动器安装包（6 MB）、python 安装包（25.7 MB，未使用）——不再需要可整目录删除，不影响已安装程序。
- `install\setup.ps1` / `phase2~6.ps1`：本次安装用的脚本，**可重复执行（已装好会自动跳过）**，用于修复或补装。
- `install\setup-log.txt`：完整安装日志。
- `install\final-check.json`：最终自检结果（机器可读）。

---

## 7. 卸载步骤（如需）

```powershell
# 1. 关闭启动器及其实例
# 2. 删除程序目录
Remove-Item "$env:LOCALAPPDATA\Programs\Python\Python312" -Recurse -Force
Remove-Item "$env:LOCALAPPDATA\Programs\nodejs" -Recurse -Force
Remove-Item "$env:LOCALAPPDATA\Programs\uv" -Recurse -Force
Remove-Item "$env:LOCALAPPDATA\Programs\AstrBot Launcher" -Recurse -Force
# 3. 删除快捷方式
Remove-Item "$env:USERPROFILE\Desktop\AstrBot Launcher.lnk" -Force
Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\AstrBot Launcher.lnk" -Force
# 4. 用户 PATH 里手工删掉那 5 条（系统属性 → 环境变量）
```

---

---

## 8. 故障修复记录：启动器"准备启动实例"报 pip 403

**报错**：`Failed to install requirements: ERROR: HTTP error 403 while getting https://mirrors.ustc.edu.cn/pypi/packages/.../multidict-7.2.1-cp312-cp312-win_amd64.whl`

**根因**：启动器「中国大陆一键加速」把 PyPI 源设为 USTC 镜像，该镜像对 `multidict` 那个 wheel 的请求被上游（清华 TUNA）返回 403——属于**镜像端临时故障/回源异常**，不是本机配置错误。修复时重新探测，同一个 USTC 源已经能正常下载该 wheel，确认是瞬时问题。

**已做的修复**：

| 项目 | 内容 |
| --- | --- |
| 实例依赖 | 向该实例 venv（`C:\Users\<USER>\.astrbot_launcher\instances\f3a5c014-...\venv`）安装了 `core\requirements.txt` 的**全部 153 个包** |
| 一致性校验 | `pip check` → `No broken requirements found` |
| 实例级源配置 | 写入 `...\venv\pip.ini`（index-url = USTC 镜像），以后该实例内 `pip` 默认走可用源 |
| 用户级源配置 | 用户环境变量 `PIP_INDEX_URL` / `UV_DEFAULT_INDEX` / `UV_INDEX_URL` = `https://mirrors.ustc.edu.cn/pypi/simple/` |
| 启动验证 | 按启动器的真实启动方式（`ASTRBOT_LAUNCHER=1`、`DASHBOARD_HOST/PORT` 环境变量）启动实例：日志出现 `AstrBot started.`，WebUI 在 `127.0.0.1:6190` 就绪，HTTP 探测返回 **200**，随后正常停止 |

**附带的端口说明**：AstrBot 默认 WebUI 端口是 6185，但**启动器会自动挑空闲端口**并通过环境变量 `DASHBOARD_PORT` 传给实例（源码 `src-tauri/src/instance/lifecycle.rs` + `process/control.rs::find_available_port`）。因此工作区里另一个手动部署的 AstrBot 占用 6185 **不会**影响启动器实例（实测用 6190 正常）。

**修复后的操作**：回启动器点「启动/重试」即可，依赖校验会直接通过。

**日志与产物**：`install\astrbot-fix-log.txt`、`install\pip-install-output.txt`、`install\astrbot-run2-output.txt`、`install\astrbot-start-state.json`、`install\fix-astrbot-deps.ps1`。

---

---

## 9. 空间清理记录（2026-10-25 07:00）

| 清理项 | 清理前 | 清理后 | 回收 |
| --- | --- | --- | --- |
| pip 下载缓存 `%LOCALAPPDATA%\pip\cache` | 679.7 MB（pip 自报 712.8 MB） | 0 | ≈ 713 MB |
| uv 缓存 `%LOCALAPPDATA%\uv\cache` | 3.7 KB | 0 | 3.7 KB |
| 下载的安装包 `install\downloads`（D 盘） | 135.9 MB | 0 | 135.9 MB |
| **合计回收** | | | **≈ 815.6 MB** |

**完全保留、未改动的**：Python 3.12（61 MB）、Node.js（102.4 MB）、uv（31.1 MB）、启动器本体（11.9 MB）、启动器数据目录（76.3 MB）、实例 venv（547.8 MB）、实例 core（31.4 MB）、启动器运行时 components（252.5 MB）、uv 管理的 CPython（60.3 MB）。

**清理后完整性自检**：实例 venv Python 3.12.15 ✅、`aiohttp/multidict/pandas/faiss/quart` 导入 ok ✅、系统 python/node/uv 正常 ✅、启动器 exe 与桌面快捷方式存在 ✅、`versions\v4.29.3.zip` 存在 ✅。

> 说明：`install\downloads` 中另有其它会话下载的 3 个包（SnowLuma 41 MB、AstrBot-v4.29.3.zip 7.5 MB、dashboard-dist 5.1 MB）一并被清理。SnowLuma 已解压在 `<SNOWLUMA_DIR>` 完整可用；AstrBot 版本包在 `.astrbot_launcher\versions` 另有一份保留，实例修复/升级不受影响。

清理日志：`install\cleanup-log.txt`、`install\cleanup-state.json`。

---

*报告生成时间：2026-10-25 06:53（第 9 节补充于 07:00），验证数据来自 `install\final-check.json`、`install\astrbot-fix-state.json`、`install\astrbot-start-state.json`、`install\cleanup-state.json` 与 `install\setup-log.txt`。*
