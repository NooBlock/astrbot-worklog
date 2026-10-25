# scripts/ — 启动与运维脚本（已脱敏）

工作区里实际在用的启动/运维脚本，已把密码、token、QQ 号、绝对路径替换为占位符，
**不能直接双击运行**，需按你的环境改回路径与凭据后使用。

| 文件 | 作用 |
| --- | --- |
| `start-all.bat` | 一键启动 AstrBot（supervised）+ SnowLuma，等 12 秒让 6199 就绪 |
| `start-astrbot.bat` | 前台启动 AstrBot（WebUI 6185、OneBot 6199） |
| `start-astrbot-supervised.cmd` | 带自动重启的 AstrBot 启动器（关闭窗口才停止） |
| `start-astrbot-bg.vbs` | 无窗口后台启动 `start-astrbot.bat` |
| `snowluma-launch.bat` | 调用 `<SNOWLUMA_DIR>\Start-SnowLuma.bat` 启动 SnowLuma |
| `launch-astrbot.cmd` | 部署时用的分离式启动（控制台输出重定向到 `logs/stdout.log`） |
| `statuscmd/apply-statuscmd.cjs` | 调 SnowLuma WebUI API，把 `statusCommand`（`#sl`）置为 disabled |
| `statuscmd/disable-statuscmd.cjs` | 直接改 `onebot*.json`，关闭 statusCommand 并备份原文件 |

占位符：`<WORKSPACE>` = 工作区根目录，`<SNOWLUMA_DIR>` = SnowLuma 解压目录，
`<REDACTED_PASSWORD>` = 部署时设定的 WebUI 密码（请自行更换为强密码）。

> 注意：`launch-astrbot.cmd` 里 `UV_CACHE_DIR` / `UV_PYTHON_INSTALL_DIR` 指向工作区内的
> `install/` 目录，是这台机器的沙箱绕路做法；普通环境用默认值即可。
